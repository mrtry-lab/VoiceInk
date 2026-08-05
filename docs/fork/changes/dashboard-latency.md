---
title: 平均レイテンシ表示（文字起こし+AI整形）
status: active
upstream_files:
  - VoiceInk/Views/Dashboard/DashboardStatsModels.swift
  - VoiceInk/Views/Dashboard/DashboardContent.swift
  - VoiceInk/Views/Dashboard/DashboardProductivityCard.swift
  - VoiceInk/Views/Dashboard/DashboardTimeSavedCard.swift
  - VoiceInk/Localizable.xcstrings
fork_files: []
commits: [279f58d]
last_reconciled: 2026-08-05
---

## 何を・なぜ

音声をモデルに送信してから結果が返るまで（文字起こし）＋ AI整形の平均所要時間を、ヒーローカード（全体平均）とインサイトのサマリーストリップ（選択期間の平均）に表示する。1 回あたりどれくらいで文字起こしできるかを見たいため。

## コードのどこ

- `DashboardStatsModels.swift`: `DashboardStatsSummary.averageProcessingLatency(for:)` を追加。既存の期間別モデル性能（`ModelPerformanceSummary.averageProcessingDuration` × `sessionCount`）から、文字起こし平均と AI整形平均を加重平均して合算。集計ローダーは無変更。
- `DashboardTimeSavedCard.swift`: `DashboardTimeSavedSummary` に `averageProcessingLatency` フィールドを追加。
- `DashboardContent.swift`: ヒーロー subtext（全体平均）と `selectedTimeSavedSummary`（選択期間）へ注入。
- `DashboardProductivityCard.swift`: サマリーストリップに `Avg. latency`（平均レイテンシ）セルを追加。
- `Localizable.xcstrings`: ヒーロー文言 `Averaging %@ per session.` の ja を追加（`Avg. latency` の ja は既存を流用）。

## 追従時の注意

- Dashboard 系 4 ファイルに分散。本家がダッシュボードを再設計すると影響が大きい。集計は既存データ（modelPerformance）からの導出なので、`averageProcessingLatency(for:)` を移植すれば表示側は繋ぎ直せる。
- `DashboardContent.swift` は [解錠しきい値](dashboard-insights-threshold.md) と、`Localizable.xcstrings` は [日本語化](japanese-localization.md) 等と共有する。

## 関連

- [../README.md](../README.md)
