import AVFoundation
import Foundation
import os

#if canImport(whisper)
    import whisper
#endif

/// Removes silent regions from a recording before it is uploaded to a cloud
/// transcription provider, reusing the bundled Silero VAD model. This shrinks the
/// audio payload — and therefore upload time and provider cost — without touching the
/// stored recording that the dashboard uses for its stats.
///
/// The trimmer is best-effort: on any failure it returns `nil` so the caller keeps
/// using the original, untrimmed audio.
enum CloudAudioSilenceTrimmer {
    private static let logger = Logger(subsystem: "com.prakashjoshipax.voiceink", category: "SilenceTrimmer")
    private static let sampleRate: Double = 16_000
    /// Short silence kept between speech segments so sentence boundaries survive.
    private static let interSegmentSilenceSeconds: Double = 0.15
    /// Skip re-encoding unless trimming removes at least this fraction of the audio.
    private static let minimumReductionRatio: Double = 0.05

    /// Produces a trimmed copy of `audioURL` at a temporary location, or `nil` when
    /// trimming is unavailable or not worthwhile. The caller is responsible for
    /// deleting the returned file once the upload finishes.
    static func trimmedAudioURL(from audioURL: URL, vadModelPath: String) async -> URL? {
        do {
            let processor = AudioProcessor()
            let samples = try await processor.processAudioToSamples(audioURL)
            guard samples.count > Int(sampleRate) else { return nil }  // ignore very short clips

            guard let segments = detectSpeechSegments(in: samples, vadModelPath: vadModelPath),
                !segments.isEmpty
            else {
                return nil
            }

            let trimmed = assembleSpeechSamples(from: samples, segments: segments)
            guard !trimmed.isEmpty else { return nil }

            let reduction = 1.0 - Double(trimmed.count) / Double(samples.count)
            guard reduction >= minimumReductionRatio else { return nil }

            let outputURL = FileManager.default.temporaryDirectory
                .appendingPathComponent("voiceink-trimmed-\(UUID().uuidString).wav")
            try processor.saveSamplesAsWav(samples: trimmed, to: outputURL)

            logger.notice(
                "Trimmed silence for upload: \(samples.count, privacy: .public) → \(trimmed.count, privacy: .public) samples (\(Int(reduction * 100), privacy: .public)% removed)"
            )
            return outputURL
        } catch {
            logger.error(
                "Silence trimming failed, using original audio: \(error.localizedDescription, privacy: .public)"
            )
            return nil
        }
    }

    /// Speech region expressed as sample indices into the 16 kHz sample buffer.
    private struct SpeechSegment {
        let start: Int
        let end: Int
    }

    private static func detectSpeechSegments(in samples: [Float], vadModelPath: String) -> [SpeechSegment]? {
        #if canImport(whisper)
            let contextParams = whisper_vad_default_context_params()
            guard let vadContext = whisper_vad_init_from_file_with_params(vadModelPath, contextParams) else {
                logger.error("Failed to initialise VAD context from \(vadModelPath, privacy: .public)")
                return nil
            }
            defer { whisper_vad_free(vadContext) }

            var params = whisper_vad_default_params()
            params.threshold = 0.50
            params.min_speech_duration_ms = 250
            params.min_silence_duration_ms = 300
            params.speech_pad_ms = 200

            let segmentsPointer: OpaquePointer? = samples.withUnsafeBufferPointer { buffer in
                whisper_vad_segments_from_samples(vadContext, params, buffer.baseAddress, Int32(buffer.count))
            }
            guard let segments = segmentsPointer else { return nil }
            defer { whisper_vad_free_segments(segments) }

            let count = Int(whisper_vad_segments_n_segments(segments))
            guard count > 0 else { return [] }

            var result: [SpeechSegment] = []
            result.reserveCapacity(count)
            for index in 0..<count {
                // Segment boundaries are reported in centiseconds.
                let start = Double(whisper_vad_segments_get_segment_t0(segments, Int32(index))) / 100.0
                let end = Double(whisper_vad_segments_get_segment_t1(segments, Int32(index))) / 100.0
                let startSample = max(0, Int(start * sampleRate))
                let endSample = min(samples.count, Int(end * sampleRate))
                if endSample > startSample {
                    result.append(SpeechSegment(start: startSample, end: endSample))
                }
            }
            return result
        #else
            return nil
        #endif
    }

    private static func assembleSpeechSamples(from samples: [Float], segments: [SpeechSegment]) -> [Float] {
        let gap = [Float](repeating: 0, count: Int(interSegmentSilenceSeconds * sampleRate))
        var output: [Float] = []
        output.reserveCapacity(segments.reduce(0) { $0 + ($1.end - $1.start) })
        for (index, segment) in segments.enumerated() {
            if index > 0 {
                output.append(contentsOf: gap)
            }
            output.append(contentsOf: samples[segment.start..<segment.end])
        }
        return output
    }
}
