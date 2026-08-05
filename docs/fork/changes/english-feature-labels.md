---
title: 機能名ラベルの英語化
status: active
upstream_files:
  - VoiceInk/Localizable.xcstrings
fork_files: []
commits: [aee3f92]
last_reconciled: 2026-08-05
---

## 何を・なぜ

日本語 UI の中で、機能名ラベル（複合含む）を Transcription / Enhancement に英語統一した。説明文は日本語のまま残し、和英混じりを避けた。翻訳された機能名（文字起こし / 整形）よりも英語ラベルの方が識別しやすいという判断。

## コードのどこ

- `Localizable.xcstrings` の ja 値のみ変更。`Transcribe`/`Transcription` 系ラベル → `Transcription`、`Enhance`/`Enhancement`/`AI Enhancement` 系 → `Enhancement`。合計 65 ラベル。説明文（`。`で終わる文・メッセージ）は日本語のまま。

## 追従時の注意

- ja 値だけの変更なので en/他言語とは衝突しにくいが、[日本語化](japanese-localization.md) と同じ `Localizable.xcstrings` を触る。本家が該当キーの英語原文を変えるとキーが変わり、ja が未翻訳に戻ることがある。マージ後、ラベル系キーの ja が英語表記のままかを確認する。
- どのキーがラベル（英語化対象）でどれが説明文（日本語維持）かの判定は、原文が文（`.`終わり）か短い名詞句/UIラベルかで分けた。

## 関連

- [日本語化](japanese-localization.md) / [../README.md](../README.md)
