---
title: ビルドツールと安定署名
status: active
upstream_files:
  - Makefile
  - .gitignore
fork_files:
  - .env.example
  - CLAUDE.md
commits: [f30eb28, 841f132]
last_reconciled: 2026-08-05
---

## 何を・なぜ

`make signed` ターゲットを追加した。ad-hoc ビルド（`make local`）はリビルドのたびに cdhash が変わり、macOS の TCC がアプリを別物とみなしてアクセシビリティ等の権限が無効化される。実 Developer 証明書で署名すれば designated requirement が安定し、権限がリビルドをまたいで維持される。署名 ID は `.env`（gitignore）で上書きし、公開リポジトリに個人値を残さない。運用手順は `CLAUDE.md` にまとめた。

## コードのどこ

- `Makefile` の `signed` ターゲット: ad-hoc でビルド → `security find-identity` で解決した証明書ハッシュで framework/XPC/dylib/本体を内側から再署名 → `/Applications` へ導入。
- `.gitignore` に `.env` を追加、`.env.example` はテンプレート。
- `CLAUDE.md` にビルド/署名/TCC の説明。

## 追従時の注意

- `Makefile` / `.gitignore` は本家も触りうる。`signed` ターゲットと `-include .env` / `SIGN_IDENTITY` 定義、`.gitignore` の `.env` 行を維持する。本家が Makefile を再構成したら `signed` ターゲットを移植し直す。
- `.env.example` と `CLAUDE.md` は fork 新規なので衝突しない（存在確認のみ）。
- 詳細な背景は [../../../CLAUDE.md](../../../CLAUDE.md) にある。

## 関連

- [../README.md](../README.md)
