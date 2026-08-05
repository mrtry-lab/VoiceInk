---
title: クラウド送信前の無音トリミング
status: active
upstream_files:
  - VoiceInk/Transcription/Cloud/CloudTranscriptionService.swift
  - VoiceInk/Views/AI Models/ModelSettingsPanel.swift
  - VoiceInk/Localizable.xcstrings
fork_files:
  - VoiceInk/Transcription/Engine/CloudAudioSilenceTrimmer.swift
commits: [8e7a1d3]
last_reconciled: 2026-08-05
---

## 何を・なぜ

クラウド（Gemini 等）に送る前に、同梱の Silero VAD モデルで発話区間を検出し、無音を除去した音声をアップロードする。送信量・アップロード時間・プロバイダコストを削減するため。本家は録音した .wav を無加工で送っていた。実測で 10 秒の無音混じり録音が 81% 削減された。

## コードのどこ

- `CloudAudioSilenceTrimmer.swift`（fork 新規）: `AudioProcessor.processAudioToSamples` で 16kHz Float に変換 → whisper 単体 VAD API（`whisper_vad_segments_from_samples`）で発話区間取得（境界はセンチ秒）→ 発話部分のみ連結（間に 0.15 秒の無音）→ `saveSamplesAsWav` で一時 WAV に書き出し。失敗・短尺・削減5%未満は nil を返し元音声にフォールバック。
- `CloudTranscriptionService.swift`: `transcribe` の送信直前に `silenceTrimmedUploadURL(for:)` を挟み、標準/custom 両プロバイダにトリミング版 URL を渡す。一時ファイルは `defer` で削除。統計用の録音長（`transcription.duration`）は元のまま。
- 有効判定は既存の `IsVADEnabled` を流用。キー未設定時は `@AppStorage` の既定に合わせ **true 扱い**（`UserDefaults.object(forKey:) as? Bool ?? true`）。本家の LibWhisper 側も `bool(forKey:)` を直読みしており、未設定だと VAD が UI 表示（ON）と裏腹に効かない潜在バグがある点に注意。
- `ModelSettingsPanel.swift`: VAD トグルの説明をクラウド送信量削減にも触れる内容に更新。`Localizable.xcstrings`: その InfoTip の ja を追加。

## 追従時の注意

- `CloudAudioSilenceTrimmer.swift` は fork 新規なので衝突しない（存在確認のみ）。ただし `AudioProcessor` の API（`processAudioToSamples` / `saveSamplesAsWav`）と whisper の VAD C API に依存する。本家がこれらを変えたら追従が要る。
- `CloudTranscriptionService.transcribe` への挿入点が衝突面。本家がこの関数を再設計したら、送信直前に `silenceTrimmedUploadURL` を同じ位置へ入れ直す。
- VAD 既定値の未設定→true 扱いは意図的（本家の潜在バグ回避）。本家が register(defaults:) 等で直したら整合を取る。

## 関連

- [機能名英語化](english-feature-labels.md)（VAD トグル文言も英語圏 UI に出る）/ [../README.md](../README.md)
