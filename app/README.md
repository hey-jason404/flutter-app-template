# app

唯一可執行的 Flutter app,是純組裝層:三個 flavor 進入點(`main_dev.dart`/`main_stg.dart`/`main_prod.dart`)、DI(`compose_dependencies.dart`)、路由(`app_router.dart`)、登入後 shell,自身幾乎不含業務邏輯——所有業務邏輯住在 `features/*`,基礎能力住在 `packages/*`。

見根目錄 [`README.md`](../README.md) 的快速開始與目錄導覽,架構細節見 [`../docs/architecture.md`](../docs/architecture.md)。
