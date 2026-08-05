---
title: 日本語ローカライズ
status: active
upstream_files:
  - VoiceInk/Localizable.xcstrings
  - VoiceInk/InfoPlist.xcstrings
  - VoiceInk/Services/AppLanguagePreference.swift
  - VoiceInk.xcodeproj/project.pbxproj
fork_files: []
commits: [66a6d3a]
last_reconciled: 2026-08-05
---

## 何を・なぜ

UI 文字列と権限説明を日本語化し、言語ピッカーに ja を追加した。本家は英語中心なので、日本語で使うために fork 側で持つ。

## コードのどこ

- `Localizable.xcstrings` / `InfoPlist.xcstrings` に ja の翻訳を追加。
- `AppLanguagePreference.swift` と `project.pbxproj` の `knownRegions` に ja を追加。

## 追従時の注意

- xcstrings は本家が文字列を追加/変更するたびに衝突する。**本家の新規キーは en のまま入り、ja は空**になるので、マージ後に未翻訳キーを埋める。`swiftlang`/Xcode が xcstrings をソート再シリアライズするため、diff が実際の変更より膨らむ点に注意。
- この xcstrings は [機能名英語化](english-feature-labels.md) / [書籍ベンチマーク削除](dashboard-book-benchmark-removed.md) / [無音トリミング](silence-trim.md) とも共有する。衝突時はそれらの意図も併せて確認する。
- 本家が公式に i18n/ja を入れた場合は `status: upstreamed` にして本家版へ寄せる。

## 関連

- [../README.md](../README.md)
