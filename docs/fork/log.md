# 変更ログ（append-only）

新しいものを上に。1 行 = 1 変更。書式は `## [日付] slug | commit | 要約`。実質的な変更は [changes/](changes/) にページを持つ。

## [2026-08-05] build-tooling-and-signing | (未コミット) | ビルド/署名手順を CLAUDE.md から docs/build.md へ分離（CLAUDE.md はリンクのみ）。レジストリ設計が LLM Wiki ベースである旨を明記 → [changes/build-tooling-and-signing.md](changes/build-tooling-and-signing.md)

## [2026-08-05] silence-trim | 8e7a1d3 | クラウド送信前に同梱 VAD で無音を除去（実測81%削減）。新規 CloudAudioSilenceTrimmer.swift + CloudTranscriptionService/ModelSettingsPanel/xcstrings をパッチ → [changes/silence-trim.md](changes/silence-trim.md)

## [2026-08-05] readme-fork-note | fa633e4 | README 先頭に fork 運用の注記を追加

## [2026-08-05] dashboard-latency | 279f58d | 文字起こし+AI整形の平均レイテンシをヒーロー/インサイトに表示 → [changes/dashboard-latency.md](changes/dashboard-latency.md)

## [2026-08-05] english-feature-labels / book-benchmark-removed | aee3f92 | 機能名ラベルを英語統一、ダッシュボードの書籍比較を削除 → [changes/english-feature-labels.md](changes/english-feature-labels.md) / [changes/dashboard-book-benchmark-removed.md](changes/dashboard-book-benchmark-removed.md)

## [2026-08-05] build-tooling-and-signing | 841f132 | CLAUDE.md にビルド/署名手順を追加 → [changes/build-tooling-and-signing.md](changes/build-tooling-and-signing.md)

## [2026-08-05] build-tooling-and-signing | f30eb28 | make signed（安定署名で /Applications へ導入）と .env 外出しを追加 → [changes/build-tooling-and-signing.md](changes/build-tooling-and-signing.md)

## [2026-08-04] dashboard-insights-threshold | 440d1e0 | インサイト解錠しきい値を 30分→3分 → [changes/dashboard-insights-threshold.md](changes/dashboard-insights-threshold.md)

## [2026-08-04] japanese-localization | 66a6d3a | UI の日本語ローカライズを追加 → [changes/japanese-localization.md](changes/japanese-localization.md)
