---
title: ダッシュボード解錠しきい値 30分→3分
status: active
upstream_files:
  - VoiceInk/Views/Dashboard/DashboardContent.swift
fork_files: []
commits: [440d1e0]
last_reconciled: 2026-08-05
---

## 何を・なぜ

インサイト画面の解錠しきい値（累計録音時間）を 30 分から 3 分に下げた。個人利用ですぐにダッシュボードを見たいため。

## コードのどこ

- `DashboardContent.swift` の `insightsUnlockDuration`（解錠に必要な累計録音時間）を 3 分相当に変更。

## 追従時の注意

- 1 行の定数変更。本家が同ファイルの解錠まわりをリファクタしたら、新しい定数/ロジックに同じ意図（3 分）を入れ直す。
- `DashboardContent.swift` は [レイテンシ表示](dashboard-latency.md) とも共有する。

## 関連

- [../README.md](../README.md)
