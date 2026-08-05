import Foundation
import LLMkit
import SwiftData

enum CloudTranscriptionError: Error, LocalizedError {
    case unsupportedProvider
    case missingAPIKey
    case invalidAPIKey
    case audioFileNotFound
    case apiRequestFailed(statusCode: Int, message: String)
    case networkError(Error)
    case noTranscriptionReturned
    case dataEncodingError

    var errorDescription: String? {
        switch self {
        case .unsupportedProvider:
            return String(localized: "The model provider is not supported by this service.")
        case .missingAPIKey:
            return String(localized: "API key for this service is missing. Please configure it in the settings.")
        case .invalidAPIKey:
            return String(localized: "The provided API key is invalid.")
        case .audioFileNotFound:
            return String(localized: "The audio file to transcribe could not be found.")
        case .apiRequestFailed(let statusCode, let message):
            return String(
                format: String(localized: "The API request failed with status code %lld: %@"), Int64(statusCode),
                message)
        case .networkError(let error):
            return String(format: String(localized: "A network error occurred: %@"), error.localizedDescription)
        case .noTranscriptionReturned:
            return String(localized: "The API returned an empty or invalid response.")
        case .dataEncodingError:
            return String(localized: "Failed to encode the request body.")
        }
    }
}

class CloudTranscriptionService: TranscriptionService {
    private let modelContext: ModelContext
    private lazy var openAICompatibleService = OpenAICompatibleTranscriptionService()

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func transcribe(audioURL: URL, model: any TranscriptionModel, context: TranscriptionRequestContext) async throws
        -> String
    {
        // Reduce the uploaded audio by removing silence, when a trimmed copy is produced.
        let uploadURL = await silenceTrimmedUploadURL(for: audioURL)
        let usesTrimmedCopy = uploadURL != audioURL
        defer {
            if usesTrimmedCopy {
                try? FileManager.default.removeItem(at: uploadURL)
            }
        }

        // Keep the original file name (and extension) even when uploading a trimmed copy.
        let fileName = audioURL.lastPathComponent
        let language = selectedLanguage(from: context)

        do {
            if model.provider == .custom {
                guard let customModel = model as? CustomCloudModel else {
                    throw CloudTranscriptionError.unsupportedProvider
                }
                return try await openAICompatibleService.transcribe(
                    audioURL: uploadURL, model: customModel, context: context)
            }

            guard let cloudProvider = CloudProviderRegistry.provider(for: model.provider) else {
                throw CloudTranscriptionError.unsupportedProvider
            }
            let apiKey = try requireAPIKey(forProvider: cloudProvider.providerKey)
            let audioData = try loadAudioData(from: uploadURL)
            return try await cloudProvider.transcribe(
                audioData: audioData,
                fileName: fileName,
                apiKey: apiKey,
                model: model.name,
                language: language,
                customVocabulary: getCustomDictionaryTerms()
            )
        } catch let error as CloudTranscriptionError {
            throw error
        } catch let error as LLMKitError {
            throw mapLLMKitError(error)
        } catch {
            throw CloudTranscriptionError.networkError(error)
        }
    }

    /// Returns a temporary silence-trimmed copy of the recording when Voice Activity
    /// Detection is enabled and the bundled VAD model produces a smaller file; otherwise
    /// returns the original URL unchanged.
    private func silenceTrimmedUploadURL(for audioURL: URL) async -> URL {
        // Match the @AppStorage default (true): treat an unset key as enabled, since it is
        // only written to UserDefaults once the user toggles the switch.
        let isVADEnabled = UserDefaults.standard.object(forKey: "IsVADEnabled") as? Bool ?? true
        guard isVADEnabled else { return audioURL }
        guard let vadModelPath = await VADModelManager.shared.getModelPath() else { return audioURL }
        return await CloudAudioSilenceTrimmer.trimmedAudioURL(from: audioURL, vadModelPath: vadModelPath)
            ?? audioURL
    }

    // MARK: - Helpers

    private func loadAudioData(from url: URL) throws -> Data {
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw CloudTranscriptionError.audioFileNotFound
        }
        return try Data(contentsOf: url)
    }

    private func requireAPIKey(forProvider provider: String) throws -> String {
        guard let apiKey = APIKeyManager.shared.getAPIKey(forProvider: provider), !apiKey.isEmpty else {
            throw CloudTranscriptionError.missingAPIKey
        }
        return apiKey
    }

    private func selectedLanguage(from context: TranscriptionRequestContext) -> String? {
        let lang = context.language ?? "auto"
        return (lang == "auto" || lang.isEmpty) ? nil : lang
    }

    private func getCustomDictionaryTerms() -> [String] {
        let descriptor = FetchDescriptor<VocabularyWord>(sortBy: [SortDescriptor(\.word)])
        guard let vocabularyWords = try? modelContext.fetch(descriptor) else {
            return []
        }
        var seen = Set<String>()
        var unique: [String] = []
        for word in vocabularyWords {
            let trimmed = word.word.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { continue }
            let key = trimmed.lowercased()
            if !seen.contains(key) {
                seen.insert(key)
                unique.append(trimmed)
            }
        }
        return unique
    }

    private func mapLLMKitError(_ error: LLMKitError) -> CloudTranscriptionError {
        switch error {
        case .missingAPIKey:
            return .missingAPIKey
        case .httpError(let statusCode, let message):
            return .apiRequestFailed(statusCode: statusCode, message: message)
        case .noResultReturned:
            return .noTranscriptionReturned
        case .encodingError:
            return .dataEncodingError
        case .networkError(let detail):
            return .networkError(NSError(domain: "LLMkit", code: -1, userInfo: [NSLocalizedDescriptionKey: detail]))
        case .invalidURL, .decodingError, .timeout:
            return .networkError(error)
        }
    }
}
