# CLAUDE.md

このリポジトリは [Beingpax/VoiceInk](https://github.com/Beingpax/VoiceInk) の個人 fork（`mrtry-lab/VoiceInk`）で、手元の Mac で自前ビルドして使う運用を前提にしている。

## ビルド

ビルド・署名（`make signed`）・`.env` の詳細は、必要になったときに [docs/build.md](docs/build.md) を読む。

## ドキュメントの規約

ドキュメント（このファイル・[docs/fork/](docs/fork/README.md)・その他 markdown）でファイル同士をリンクするときは、wikilink `[[name]]` ではなく **標準 markdown リンク `[テキスト](相対パス)`** を使う。

## upstream との関係

`upstream` に本家 [Beingpax/VoiceInk](https://github.com/Beingpax/VoiceInk) を設定している。本家の更新を取り込むときは upstream から fetch してマージする。fork 固有の変更は [docs/fork/](docs/fork/README.md) に記録し、追従手順は [docs/fork/SYNC.md](docs/fork/SYNC.md) に従う。

## Fork 変更レジストリの維持

この記録戦略は、Karpathy の [LLM Wiki](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)（LLM が index / append-only log / トピック別ページを継続的に維持し、lint で陳腐化を防ぐ）を fork 追従用に応用したもの。

本家と分岐する変更（本家も編集するファイルへのパッチ、または fork 固有の新規ファイル）をしたら、[docs/fork/](docs/fork/README.md) を必ず更新する。純粋に本家由来コードの追従・バグ修正で分岐を増やさないものは対象外。

- **log**: [docs/fork/log.md](docs/fork/log.md) の先頭に 1 行追記する（`## [日付] slug | commit | 要約`）。tiny な変更もここには残す。
- **page**: 実質的な変更は [docs/fork/changes/](docs/fork/changes/) にページを持つ。**まず既存ページを探し、同じ機能・同じ領域への改修なら新規作成せず既存ページに追記する**（本文に追記し、frontmatter の `commits` に今回のコミットを足し、`last_reconciled` を更新し、新たに触ったファイルを `upstream_files`/`fork_files` に加える）。探し方は、触ったファイルが既存ページの `upstream_files`/`fork_files` に載っているか、[docs/fork/README.md](docs/fork/README.md) の変更カタログ/衝突面一覧に同じ機能のページがあるかで判断する。真に新しい分岐領域のときだけ新規ページを作る。frontmatter の `upstream_files`（本家も触る=衝突面）と `fork_files`（fork 固有=衝突しない）の 2 分類は必ず埋める。これが追従の作業対象を決める。
- **index**: [docs/fork/README.md](docs/fork/README.md) の変更カタログと「衝突面」一覧を最新化する。
- **link**: ファイル間リンクは wikilink ではなく標準 markdown の `[テキスト](相対パス)` を使う。
- **lint**（追従前や気づいたとき）: 各ページの `upstream_files` が実在するか、`status: active` のページのコードが生きているか、`git log upstream/main..main` の全コミットが log に載っているかを点検する。
