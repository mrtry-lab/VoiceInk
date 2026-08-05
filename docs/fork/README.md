# Fork 変更レジストリ

このリポジトリは [Beingpax/VoiceInk](https://github.com/Beingpax/VoiceInk) の fork を自分用にカスタムして運用している。ここは **本家と分岐した変更を記録する場所** で、後から本家バージョンに追従するときに「どのファイルのどの変更を再適用・調整すべきか」を即座に引けるようにするためのもの。

追従の作業対象は **本家も編集するファイルへのパッチ（衝突面）** だけ。fork 固有の新規ファイルはマージで衝突しないので、存在確認で済む。この 2 分類を各ページの `upstream_files` / `fork_files` に必ず記録する。

## 使い方

- 変更したら [log.md](log.md) に 1 行追記する。実質的な変更は [changes/](changes/) にページを持つが、**既にある機能への改修は新規ページを作らず既存ページに追記する**（本文追記・`commits` 追加・`last_reconciled` 更新・触ったファイルを `upstream_files`/`fork_files` に追加）。新規ページは真に新しい分岐領域のときだけ。維持規約は [../../CLAUDE.md](../../CLAUDE.md) の「Fork 変更レジストリの維持」を参照。
- 本家に追従するときは [SYNC.md](SYNC.md) の手順に従う。

## 変更カタログ

| 変更 | 種別 | 主なファイル | 状態 |
|---|---|---|---|
| [日本語ローカライズ](changes/japanese-localization.md) | パッチ | InfoPlist/Localizable.xcstrings, AppLanguagePreference.swift, project.pbxproj | active |
| [ダッシュボード解錠しきい値 30→3分](changes/dashboard-insights-threshold.md) | パッチ | DashboardContent.swift | active |
| [ビルドツールと署名](changes/build-tooling-and-signing.md) | 新規+パッチ | Makefile, .env.example, .gitignore, CLAUDE.md | active |
| [機能名ラベルの英語化](changes/english-feature-labels.md) | パッチ | Localizable.xcstrings | active |
| [ダッシュボードの書籍ベンチマーク削除](changes/dashboard-book-benchmark-removed.md) | パッチ | Localizable.xcstrings | active |
| [平均レイテンシ表示](changes/dashboard-latency.md) | パッチ | DashboardStatsModels/Content/ProductivityCard/TimeSavedCard.swift | active |
| [クラウド送信前の無音トリミング](changes/silence-trim.md) | 新規+パッチ | CloudAudioSilenceTrimmer.swift, CloudTranscriptionService.swift, ModelSettingsPanel.swift, Localizable.xcstrings | active |
| README の fork 注記 | パッチ | README.md | active（[log.md](log.md) のみ） |

## 衝突面（本家も編集するファイル = 追従で必ず見る）

本家マージで衝突しうるのはこれらだけ。括弧内はこのファイルを触っている変更ページ。

- `VoiceInk/Localizable.xcstrings` — [日本語化](changes/japanese-localization.md) / [機能名英語化](changes/english-feature-labels.md) / [書籍ベンチマーク削除](changes/dashboard-book-benchmark-removed.md) / [無音トリミング](changes/silence-trim.md) ← **最頻。4 変更が重なる**
- `VoiceInk/Views/Dashboard/DashboardContent.swift` — [解錠しきい値](changes/dashboard-insights-threshold.md) / [レイテンシ表示](changes/dashboard-latency.md)
- `VoiceInk/InfoPlist.xcstrings` — [日本語化](changes/japanese-localization.md)
- `VoiceInk/Services/AppLanguagePreference.swift` — [日本語化](changes/japanese-localization.md)
- `VoiceInk.xcodeproj/project.pbxproj` — [日本語化](changes/japanese-localization.md)（knownRegions への ja 追加）
- `VoiceInk/Views/Dashboard/DashboardStatsModels.swift` / `DashboardProductivityCard.swift` / `DashboardTimeSavedCard.swift` — [レイテンシ表示](changes/dashboard-latency.md)
- `VoiceInk/Transcription/Cloud/CloudTranscriptionService.swift` / `VoiceInk/Views/AI Models/ModelSettingsPanel.swift` — [無音トリミング](changes/silence-trim.md)
- `Makefile` / `.gitignore` — [ビルドツールと署名](changes/build-tooling-and-signing.md)
- `README.md` — fork 注記

## fork 固有の新規ファイル（衝突しない = 存在確認のみ）

- `VoiceInk/Transcription/Engine/CloudAudioSilenceTrimmer.swift` — [無音トリミング](changes/silence-trim.md)
- `.env.example` — [ビルドツールと署名](changes/build-tooling-and-signing.md)
- `CLAUDE.md` — [ビルドツールと署名](changes/build-tooling-and-signing.md)
- `docs/fork/*` — このレジストリ自体

## 真実の源

このレジストリは意味の層で、機械的な真実は git にある。本家から分岐した全コミットは次で引ける。

```
git log upstream/main..main --oneline
git diff --name-status upstream/main...main   # A=fork新規 / M=衝突面
```
