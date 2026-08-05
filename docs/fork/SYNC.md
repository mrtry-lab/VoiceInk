# 本家追従プレイブック

本家 [Beingpax/VoiceInk](https://github.com/Beingpax/VoiceInk)（remote `upstream`）の更新を取り込む手順。作業対象は **衝突面（本家も編集するファイルへの fork パッチ）** だけで、fork 固有の新規ファイルは衝突しない。

## 現状

- 分岐の基点（merge-base）と fork コミットは `git log upstream/main..main --oneline` で確認する。
- 未取り込みの本家コミットは `git log main..upstream/main --oneline` で確認する。

## 手順

1. `git fetch upstream` で最新を取得する。
2. [README.md](README.md) の「衝突面」一覧で、今回ぶつかりうるファイルを把握する。特に `Localizable.xcstrings`（4 変更が重なる）と `DashboardContent.swift`（2 変更）に注意。
3. 作業ブランチを切る（`git switch -c sync/upstream-YYYYMMDD`）。default ブランチで直接マージしない。
4. `git merge upstream/main`（または rebase）を実行する。
5. 衝突ファイルごとに、[README.md](README.md) の衝突面一覧から対応する [changes/](changes/) ページを開き、「追従時の注意」を読んで **意味で解決** する。行単位の機械的マージに任せない。
6. `grep -rn "fork:" VoiceInk`（コードアンカーを導入している場合）で fork パッチが生きているか確認する。本家のリファクタでパッチが消えていないかを見る。
7. fork 固有の新規ファイル（[README.md](README.md) の該当節）が残っているか確認する。
8. `make signed` でビルドし、主要機能（署名の安定性・日本語 UI・無音トリミング・ダッシュボード表示）を確認する。
9. 各 [changes/](changes/) ページの `last_reconciled` を更新し、`status` が変わったもの（本家が同等機能を入れた=`upstreamed`、不要になった=`reverted` など）を直す。[log.md](log.md) に追従を 1 行追記する。

## 状態の意味

- `active` — fork で有効。追従時に維持する。
- `upstreamed` — 本家が同等機能を取り込んだ。fork パッチを捨てて本家版に寄せてよい。
- `superseded` — 別の fork 変更に置き換わった。
- `reverted` — 取り下げた。追従時に再適用しない。
