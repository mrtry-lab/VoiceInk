---
title: ダッシュボードの書籍ベンチマーク削除
status: active
upstream_files:
  - VoiceInk/Localizable.xcstrings
fork_files: []
commits: [aee3f92]
last_reconciled: 2026-08-05
---

## 何を・なぜ

ダッシュボードの momentum 比較文（音声入力した語数を有名書籍『変身』等の長さと比べる文）を、日本語では語数のみの表示に変えた。比較文自体が分かりにくかったため。機能（コード側の `DashboardProgressBenchmark`）は残し、**ja の string template だけ**書き換えて書籍参照を消している。

## コードのどこ

- `Localizable.xcstrings` の以下 3 キーの ja 値を `%1$@ を音声入力しました。` に統一（書籍参照 `%2$@`/`%3$@` を未使用に）。
  - `Dictated %@, %@ words from %@.`
  - `Dictated %@, equivalent to %@ %@.`
  - `Dictated %@, equivalent to %@.`
- コード（`DashboardStatsModels.swift` の `DashboardProgressBenchmark`、`DashboardContent.swift` の生成側）は無変更。

## 追従時の注意

- ja 値のみ。本家がこのベンチマーク文の英語原文やフォーマット引数を変えるとキーが変わるので、マージ後に該当 ja が語数のみ表示のままかを確認する。
- コード側で比較を消しているわけではないので、本家が momentum 機能を作り替えても ja template を同じ方針（語数のみ）で当て直せばよい。
- `Localizable.xcstrings` を [日本語化](japanese-localization.md) / [機能名英語化](english-feature-labels.md) と共有する。

## 関連

- [../README.md](../README.md)
