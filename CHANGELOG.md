# Changelog

本檔案記錄每次 release 的重點變更;格式依循 [Keep a Changelog](https://keepachangelog.com/zh-TW/1.1.0/),版本依循 [SemVer](https://semver.org/lang/zh-TW/)。維護方式見 `docs/conventions.md` 的「分支與 PR 規範」。

## [0.2.0] - 2026-07-11

### Changed

- SDK:`.fvmrc` 與全部 13 份 pubspec 的 `environment.sdk` 升級為 Flutter
  3.44.6 / Dart ^3.12.0(原 3.29.3 / ^3.7.0)。
- Lint 基線:`very_good_analysis` ^7.0.0 → ^8.0.0;修正新規則
  `unnecessary_underscores` 兩處(`(_, __)` → `(_, _)`)。停用單一規則
  `prefer_initializing_formals`(新版 analyzer 對「私有欄位 + 具名建構子
  可讀參數名」此模板既有慣例的建議實際上無法套用——具名參數不得以底線
  開頭,套用即編譯失敗;17 處全屬此類,詳見
  `.superpowers/sdd/deps-upgrade-report.md`)。
- 依賴 major 升級:`get_it` ^8 → ^9、`go_router` ^14 → ^17、
  `flutter_secure_storage` ^9 → ^10、`firebase_core` ^3 → ^4、
  `firebase_analytics` ^11 → ^12、`firebase_crashlytics` ^4 → ^5、
  `firebase_messaging` ^15 → ^16。呼叫端 API 皆相容,無業務邏輯變動。
- 原生設定:Firebase iOS pod 自本次升級版本起要求
  `deployment_target 15.0`;`app/ios` 的 `IPHONEOS_DEPLOYMENT_TARGET` 與
  `Flutter/AppFrameworkInfo.plist` 的 `MinimumOSVersion` 由 13.0 提升為
  15.0。Android `minSdk` 沿用 Flutter 預設(24),未變動。
- 收尾修正:`packages/localization` 補上 `flutter: generate: true`
  (Flutter 3.44 的 `gen-l10n` 要求此旗標)、`l10n.yaml` 移除已無作用的
  `synthetic-package`;`tool/new_feature.dart` 產生器範本同步 SDK/依賴
  主版本與 lint 修正,確保新產生的 feature 在新 SDK 下仍可通過
  `tool/check.sh`。

## [0.1.0] - 2026-07-11

### Added

- 初版模板:pub workspace(app + 9 packages + 2 示範 features)、Bloc + get_it + go_router、假後端出廠可跑。
- 工具鏈:`tool/check.sh`(七段稽核,與 CI 同構)、`tool/guard.sh`、`tool/new_feature.dart`、`tool/rename_project.dart`。
- 文件:CLAUDE.md/AGENTS.md、docs/architecture、conventions、7 份 how-to、5 份 ADR。
- 護欄:CI(check/generator-smoke/gitleaks)、CODEOWNERS、PR template、branch rulesets(master/develop)。
