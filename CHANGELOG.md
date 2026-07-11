# Changelog

本檔案記錄每次 release 的重點變更;格式依循 [Keep a Changelog](https://keepachangelog.com/zh-TW/1.1.0/),版本依循 [SemVer](https://semver.org/lang/zh-TW/)。維護方式見 `docs/conventions.md` 的「分支與 PR 規範」。

## [0.1.0] - 2026-07-11

### Added

- 初版模板:pub workspace(app + 9 packages + 2 示範 features)、Bloc + get_it + go_router、假後端出廠可跑。
- 工具鏈:`tool/check.sh`(七段稽核,與 CI 同構)、`tool/guard.sh`、`tool/new_feature.dart`、`tool/rename_project.dart`。
- 文件:CLAUDE.md/AGENTS.md、docs/architecture、conventions、7 份 how-to、5 份 ADR。
- 護欄:CI(check/generator-smoke/gitleaks)、CODEOWNERS、PR template、branch rulesets(master/develop)。
