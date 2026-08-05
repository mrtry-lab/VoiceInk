# CLAUDE.md

このリポジトリは [Beingpax/VoiceInk](https://github.com/Beingpax/VoiceInk) の個人 fork（`mrtry-lab/VoiceInk`）で、手元の Mac で自前ビルドして使う運用を前提にしている。Claude Code で作業するときは、まずこのファイルのビルド手順と署名の注意点を読むこと。

## ドキュメントの規約

ドキュメント（このファイル・[docs/fork/](docs/fork/README.md)・その他 markdown）でファイル同士をリンクするときは、wikilink `[[name]]` ではなく **標準 markdown リンク `[テキスト](相対パス)`** を使う。

## ビルドコマンド

ビルドは `Makefile` に集約されている。用途で使い分ける。

- **`make signed`** : このリポジトリの標準ビルド。ad-hoc でビルドしたあと実 Developer 証明書で再署名し、`/Applications/VoiceInk.app` に入れ替えて検証まで行う。手元で常用するアプリを更新するときはこれを使う。
- **`make local`** : Apple Developer 証明書なしで ad-hoc 署名ビルドし、`~/Downloads/VoiceInk.app` に出力する。証明書を持たない環境向け。ただしショートカット等の権限は再ビルドのたびに切れる（後述）。
- **`make build`** : Xcode プロジェクトを Debug 構成でビルドするだけ（配置はしない）。
- **`make dev`** : `build` して `run` する開発用ショートカット。
- **`make help`** : 全ターゲットの一覧。

`make signed` / `make local` は `LocalBuild.xcconfig` と `VoiceInk/VoiceInk.local.entitlements` を使う。この entitlements は iCloud・Push・keychain 共有を外してあり、その結果としてローカルビルドでは iCloud 辞書同期と自動更新が効かない。bundle id `com.prakashjoshipax.VoiceInk` は本家チームの所有で、fork 側のアカウントでは App ID を登録できないため、これらの capability は付けられない。

## 署名とアクセシビリティ権限の注意点

**ローカルビルドで最も嵌まりやすいのがここなので、必ず把握しておく。**

macOS の TCC（アクセシビリティ・入力監視などの権限を管理する仕組み）は、アプリを **コード署名の同一性** で識別する。ad-hoc 署名にはチーム ID や証明書という安定した同一性がなく、同一性はバイナリのハッシュ（cdhash）そのものになる。つまり ad-hoc の `make local` では、**リビルドするたびに cdhash が変わり、TCC が「別のアプリ」とみなす**。設定画面のトグルは前のビルドに紐づいたまま「オン」に見えるが、その許可は新しいバイナリには適用されない。「権限は付与済みなのにショートカットが反応しない」という症状はこれが原因である。

`make signed` はこの問題を回避するために用意してある。実 Developer 証明書で署名すると、TCC の同一性判定が cdhash から「チーム ID + bundle id」に変わり、リビルドしても designated requirement が一致し続ける。一度アクセシビリティ権限を付与すれば、以後は焼き直しても許可が維持される。

署名フローは xcodebuild 任せにしていない。`CODE_SIGN_STYLE=Manual` に `CODE_SIGN_IDENTITY="Apple Development"` のような総称名を渡すと、Manual では具体的な証明書に解決できず ad-hoc へ黙ってフォールバックする。そのため `make signed` は、ad-hoc でビルドしたあとに `security find-identity` で解決した正確な証明書ハッシュで、フレームワーク・XPC・dylib・本体の順に内側から `codesign` で再署名している。

権限が壊れて反応しなくなったときの復旧手順は次のとおり。

1. `make signed` で焼き直して `/Applications` に入れ替える。
2. 署名を変えた直後は古い許可が食い違うので、一度だけリセットする。
   ```bash
   tccutil reset Accessibility com.prakashjoshipax.VoiceInk
   tccutil reset ListenEvent com.prakashjoshipax.VoiceInk
   ```
3. アプリを起動し、システム設定 → プライバシーとセキュリティ → アクセシビリティ で `/Applications/VoiceInk.app` を許可し直す。

署名が正しいかは次で確認できる。`Signature=adhoc` ではなく `Authority=Apple Development: ...` と出れば成功している。

```bash
codesign -dv --verbose=2 /Applications/VoiceInk.app
```

## ローカル設定（.env）

`make signed` が使う署名 ID は `.env` で上書きできる。`.env` は gitignore 済みで、公開リポジトリには入らない。個人・マシン固有の値はここに書く。

```bash
cp .env.example .env   # SIGN_IDENTITY を自分の証明書に合わせて編集
```

`SIGN_IDENTITY` は `security find-identity -v -p codesigning` の出力に対する正規表現として照合される。証明書名（`Apple Development` など）でも、正確な 40 桁の SHA-1 ハッシュでもよい。`.env` が無いか未設定のときは `Apple Development` にフォールバックする。

公開リポジトリに含めるファイル（`Makefile`・`.env.example`・`.gitignore` など）には、チーム ID・証明書ハッシュ・氏名・メールといった個人識別子を書かない。それらは `.env` にだけ置く。

## upstream との関係

`upstream` に本家 [Beingpax/VoiceInk](https://github.com/Beingpax/VoiceInk) を設定している。本家の更新を取り込むときは upstream から fetch してマージする。fork 固有の変更は [docs/fork/](docs/fork/README.md) に記録し、追従手順は [docs/fork/SYNC.md](docs/fork/SYNC.md) に従う。

## Fork 変更レジストリの維持

本家と分岐する変更（本家も編集するファイルへのパッチ、または fork 固有の新規ファイル）をしたら、[docs/fork/](docs/fork/README.md) を必ず更新する。純粋に本家由来コードの追従・バグ修正で分岐を増やさないものは対象外。

- **log**: [docs/fork/log.md](docs/fork/log.md) の先頭に 1 行追記する（`## [日付] slug | commit | 要約`）。tiny な変更もここには残す。
- **page**: 実質的な変更は [docs/fork/changes/](docs/fork/changes/) にページを持つ。**まず既存ページを探し、同じ機能・同じ領域への改修なら新規作成せず既存ページに追記する**（本文に追記し、frontmatter の `commits` に今回のコミットを足し、`last_reconciled` を更新し、新たに触ったファイルを `upstream_files`/`fork_files` に加える）。探し方は、触ったファイルが既存ページの `upstream_files`/`fork_files` に載っているか、[docs/fork/README.md](docs/fork/README.md) の変更カタログ/衝突面一覧に同じ機能のページがあるかで判断する。真に新しい分岐領域のときだけ新規ページを作る。frontmatter の `upstream_files`（本家も触る=衝突面）と `fork_files`（fork 固有=衝突しない）の 2 分類は必ず埋める。これが追従の作業対象を決める。
- **index**: [docs/fork/README.md](docs/fork/README.md) の変更カタログと「衝突面」一覧を最新化する。
- **link**: ファイル間リンクは wikilink ではなく標準 markdown の `[テキスト](相対パス)` を使う。
- **lint**（追従前や気づいたとき）: 各ページの `upstream_files` が実在するか、`status: active` のページのコードが生きているか、`git log upstream/main..main` の全コミットが log に載っているかを点検する。
