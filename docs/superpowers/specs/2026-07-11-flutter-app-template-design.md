# Flutter Mobile App 泛用模板 — 設計文件

日期:2026-07-11
狀態:已與需求方確認全部設計段落,待實作規劃

## 1. 目的與需求

建立一個泛用於不同領域的 Flutter Mobile App **Starter Repo 模板**,讓不同資質的 RD 都能快速建立並共同維護一個架構清晰的中大型 App。

已確認的需求邊界:

- **適用範圍**:典型後端驅動 App——登入/會員、API 存取、列表/表單/詳情頁、推播、分析。
- **交付形式**:可直接 clone/copy 的範本專案(含基礎設施代碼、示範 feature、工具鏈、文件)。
- **使用者輪廓**:需求方本人(medium level mobile developer)為主要維護者,與不同資質的 RD 共同維護。設計原則:規則由工具(編譯器、lint、CI、產生器)執行,不靠人力紀律。
- **硬性條件**:對 AI coding agent 協作友善;內建常見服務(Firebase 推播/分析/crash 上報)的整合位置。
- **選型定案**:Bloc + get_it(完整分層、事件可追溯,取其中大型專案的可控性;樣板量由 AI 輔助與程式碼產生器吸收)。已明確排除 Riverpod 路線與輕量 MVVM 路線。

## 2. 核心架構決策:多 package workspace

模組邊界用 **Dart 3.6+ 原生 pub workspace(多 package)** 強制,不用 melos。依賴方向由各 package 的 pubspec 強制——沒宣告依賴的東西 import 不到,邊界是編譯器級的,lint 與 code review 只是輔助。

### 2.1 Workspace 拓撲

```
<project_name>/
├── pubspec.yaml               # workspace 根(Dart 3.6+ 原生 workspace)
├── .fvmrc                     # 鎖定 Flutter 版本(FVM),全團隊/CI 一致
├── app/                       # 唯一可執行的 Flutter app —— 純組裝層
├── packages/
│   ├── foundation/            # 純 Dart 零依賴:Result<T>、例外體系、logger 介面、
│   │                          #   原生錯誤共用型別
│   ├── networking/            # dio 封裝:client 工廠、攔截器、統一錯誤轉換;
│   │                          #   定義 TokenProvider 介面(由 session 實作)
│   ├── persistence/           # 本地儲存:secure storage、key-value、(選配)db
│   ├── session/               # 登入狀態單一真相:token 存取(用 persistence)、
│   │                          #   SessionState stream、實作 networking 的 TokenProvider
│   ├── navigation/            # 跨 feature 導航契約:路由路徑常數 + 型別化參數
│   ├── design_system/         # design tokens、theme、共用 UI 元件、頁面外框元件
│   │                          #   (page scaffold)、共用 assets
│   ├── localization/          # 多語系(官方 gen-l10n + ARB),含各 feature 文案
│   │                          #   (以 feature 前綴命名 key)
│   ├── observability/         # log 輸出端、crash 上報、事件埋點(介面 + Firebase 實作)
│   ├── push_notifications/    # 推播抽象介面 + FCM 實作、token 生命週期、
│   │                          #   點擊轉路由事件
│   └── native/                # 原生能力群:每項能力一個 plugin package
│       └── <capability>/      #   (Dart 介面 + android/ Kotlin + ios/ Swift),
│                              #   channel 程式碼一律用 pigeon 產生,不手寫
├── features/                  # 每個 feature 一個獨立 package,互不依賴
│   ├── auth/                  # 示範 1:有狀態流程(登入),驅動 session
│   └── home/                  # 示範 2:API 列表+詳情(CRUD 範本)
├── tool/                      # 開發指令:new_feature.dart、rename_project.dart、
│                              #   check.sh(與 CI 同構)
├── docs/                      # 架構文件、how-to 教學、ADR
└── .github/workflows/ci.yaml
```

### 2.2 依賴方向規則(四條)

1. `foundation` 不依賴任何東西(純 Dart,不依賴 Flutter)。
2. `packages/*` 之間允許依賴,但必須單向、且在 `docs/architecture.md` 的依賴圖中明列;永遠不能依賴 `features/*` 或 `app`。
3. `features/*` 可依賴 `packages/*` 與 `foundation`;**永遠不能依賴其他 feature**,不能依賴 `app`。
4. `app` 是唯一什麼都能依賴的地方,負責組裝(DI、路由表、flavor 進入點),自身幾乎不含邏輯。

### 2.3 關鍵糾結點的定案解法

- **token 循環依賴**:`networking` 定義 `TokenProvider` 介面但不實作;`session` 依賴 `networking` 並實作該介面(含 401 refresh 流程);`app` 組裝時注入。依賴單向:`session → networking → foundation`。`auth` feature 只負責 UI 流程,登入成功後把 token 交給 `session`。
- **跨 feature 溝通**:feature 之間永遠不直接對話。共享狀態的抽象契約下沉到 `packages/`(如 `session`),由 `app` 組裝接線。
- **跨 feature 導航**:`navigation` package 只放路由路徑常數與型別化參數類別(如 `OrderDetailRoute(orderId)`),不含頁面。features 依賴它發起導航;`app` 把路徑對應到實際頁面。
- **feature 對外的臉**:每個 feature 只透過 barrel file(`lib/<name>.dart`)輸出:路由建構函式、DI 註冊函式、極少數公開 widget。`lib/src/` 內一切私有(Dart 語言級保護)。
- **原生平台通訊**:features 永遠不直接碰 MethodChannel。每項原生能力一個 plugin package,channel 程式碼一律用 pigeon 產生;第三方 SDK 的原生初始化設定留在 `app/android/`、`app/ios/`,Dart 端存取一律透過 `packages/` 抽象介面。

## 3. 測試架構

原則:**測試跟著 package 走,每個 package 可獨立測試**,不需模擬器、Firebase、真後端。

```
packages/<name>/test/          # 結構鏡射 lib/src/
packages/<name>/lib/testing.dart   # 提供介面的 package 必須附官方假實作(fake)
features/<name>/test/
├── data/                      # repository:假 API client,驗證 DTO 轉換與錯誤映射
├── domain/                    # 純邏輯(如有)
└── presentation/              # bloc_test 驗證事件→狀態序列;page 三態渲染測試
app/test/di_smoke_test.dart    # 解析 get_it 全部註冊項:「忘記註冊」在 CI 失敗,
                               #   不在執行期閃退
app/integration_test/          # 假後端啟動 app,跑登入→首頁關鍵路徑(nightly)
```

測試規範(四條):

1. 提供介面的 package 必須同時從 `lib/testing.dart` 匯出官方 fake;下游測試一律用官方 fake,禁止各自手寫 mock。
2. 測試替身統一用 **mocktail**(無 code-gen)+ **bloc_test**。工具唯一化,不給選擇。
3. 完成的定義(進 conventions.md 與 PR checklist):bloc 事件→狀態轉換、repository 資料轉換與錯誤映射必須有測試;page 至少有 loading/success/error 三態渲染測試。golden、integration 為建議項。
4. `tool/new_feature.dart` 連同測試骨架一起產出。

## 4. Feature package 內部結構與 Bloc 規範

### 4.1 內部結構(所有 feature 形狀一致)

```
features/<name>/
├── pubspec.yaml               # 依賴依需要,不多不少
├── lib/
│   ├── <name>.dart            # barrel:路由建構函式、DI 註冊函式、極少數公開 widget
│   └── src/
│       ├── di.dart            # void register<Name>Feature(GetIt gi)
│       ├── routes.dart        # List<GoRoute> <name>Routes(),路徑常數取自 navigation
│       ├── data/
│       │   ├── dtos/          # json_serializable + DTO→entity 轉換函式
│       │   ├── sources/       # remote(用 networking client)、local
│       │   └── repositories/  # domain 介面的實作
│       ├── domain/
│       │   ├── entities/      # 純 Dart 業務物件
│       │   ├── repositories/  # 抽象介面
│       │   └── usecases/      # 選配(準則見 4.3)
│       └── presentation/
│           ├── blocs/         # 一個使用情境一個資料夾:bloc、event、state 三檔
│           ├── pages/
│           └── widgets/       # feature 私有元件
└── test/
```

層內依賴方向:`presentation → domain ← data`。presentation 不碰 DTO 與 data source;DTO 欄位變動的爆炸範圍止於 data 層。

### 4.2 Bloc 規範(定死,不給選擇)

1. 一律用 Bloc,不用 Cubit。
2. State 用 Dart 3 `sealed class` 表達互斥狀態;UI 用 exhaustive `switch` 渲染——漏處理狀態是編譯錯誤。
3. 命名:事件用「主詞+過去式動詞」(`LoginSubmitted`),不用命令式;狀態類別 `<情境><階段>`。
4. Bloc 之間禁止互相引用;共享狀態下沉到 domain(repository 暴露 stream),各自訂閱。
5. 錯誤處理單一路徑:repository 一律回傳 `Result<T, AppException>`(foundation 定義);禁止 bloc/UI 以 `try/catch` 接 raw exception。
6. Bloc 檔案不 import Flutter,保持純 Dart。

### 4.3 usecase 選配準則(唯一允許的彈性)

預設 bloc 直接呼叫 repository。僅兩種情況抽 usecase:(a) 一個動作協調兩個以上 repository;(b) 同一段業務規則被兩個以上 bloc 使用。準則外新增 usecase,code review 退回。

### 4.4 DI 規範

- repository、data source 註冊 `lazySingleton`;bloc 一律 `factory`,跟隨頁面生命週期,不做全域 bloc。全域狀態(如 session 監聽)不住在 feature。
- feature 的 `di.dart` 是唯一註冊點;`app` 只呼叫一行註冊函式;`di_smoke_test` 驗證全部可解析。

## 5. app/ 組裝層

定位:把所有 package 接起來、決定啟動順序,自己不含業務邏輯,刻意保持薄。

```
app/
├── lib/
│   ├── main_dev.dart / main_stg.dart / main_prod.dart   # 各兩行:建 AppConfig → bootstrap()
│   └── src/
│       ├── config/            # AppConfig:API base URL、feature flags、環境名
│       ├── bootstrap.dart     # 啟動序列,全專案唯一一份
│       ├── di.dart            # composeDependencies(gi, config)
│       ├── router.dart        # 合併 feature routes、登入守衛 redirect、深連結落地
│       ├── app.dart           # MaterialApp.router、theme、locale 綁定
│       └── shell/             # 登入後外殼 UI(底部導覽列)——app 層唯一合法 UI
├── android/ ios/              # flavor/scheme、Firebase 設定檔(三環境各一)
├── test/di_smoke_test.dart
└── integration_test/
```

### 5.1 環境策略(定死)

- 三環境 `dev / stg / prod`,各一個 `main_*.dart`,對應 Android product flavors 與 iOS schemes;bundle id 加後綴,三環境可同機並存。
- 非機密環境常數寫在各環境 `AppConfig`,進版控。
- 機密用 `--dart-define-from-file` 注入,定義檔 gitignore,附 `env/secrets.example.json`。

### 5.2 bootstrap 啟動序列(定死)

1. `WidgetsFlutterBinding.ensureInitialized()`
2. `composeDependencies(gi, config)`(純註冊,不做 I/O)
3. 掛載全域錯誤捕捉:`PlatformDispatcher.onError` + `FlutterError.onError` → `observability`
4. `await` 必要初始化:persistence 開啟、Firebase init、session 還原
5. `runApp()`

整段在錯誤邊界內,啟動期未捕捉例外進 crash 上報。

### 5.3 全域行為歸屬

- **登入守衛**:只在 `router.dart` 的 `redirect`,讀 session 狀態。
- **token 失效登出**:app 層訂閱 `SessionState`,過期時清資料導回登入。
- **推播點擊/深連結**:`push_notifications` 只發「指向某路徑的點擊事件」,app 訂閱後轉 `router.go(path)`。

app 層紀律:出現業務行為的環境分支、或 shell 之外的頁面,即為腐化訊號,review 退回。

## 6. 護欄工具鏈與 AI 協作配套

### 6.1 Lint 基線

- workspace 根唯一一份 `analysis_options.yaml`:`very_good_analysis` + `strict-casts / strict-inference / strict-raw-types`,全 package 繼承,禁止放寬。
- 例外僅允許逐行 `// ignore: 規則 -- 原因`;CI 以 grep 擋無原因的 ignore。

### 6.2 CI(與 tool/check.sh 完全同構)

1. `dart format --set-exit-if-changed`
2. `flutter analyze`(全 workspace)
3. 逐 package `flutter test`(平行;「只測變動 package」為後續優化項)
4. integration test 為 nightly 獨立 job,不擋 PR

PR template 內建「完成的定義」checklist。

### 6.3 tool/new_feature.dart 產生器規格

`dart run tool/new_feature.dart <name>` 之後:

1. 產生完整 feature 骨架:pubspec、barrel、di.dart、routes.dart、三層目錄、一組會動的範例(bloc + 頁面 + 測試),範例即規範。
2. 自動把新 package 加進 workspace 根 pubspec。
3. 自動插入 `app` 的 DI 與路由標記區塊(`// {{feature-registry}}`),接線不靠人記得。
4. 在 `navigation` package 的標記區塊插入路徑常數。

### 6.4 CLAUDE.md(一頁以內,三種內容)

1. **鐵律清單**:四條依賴規則、一律 Bloc + sealed state、repository 回傳 Result、測試用官方 fake。
2. **任務路由表**:加 feature → 產生器 + `docs/how-to/add-a-feature.md`;加 API → `add-an-api.md`;加原生能力 → `add-a-native-capability.md`。
3. **指令清單**:check.sh、codegen、單 package 測試。

### 6.5 docs/ 結構

```
docs/
├── architecture.md            # 拓撲圖 + 依賴方向圖 + 每 package 一句話職責
├── conventions.md             # 命名、檔案位置、Bloc 規範、完成的定義
├── how-to/
│   ├── add-a-feature.md
│   ├── add-an-api.md          # DTO → source → repository → bloc → UI 完整走法
│   ├── add-a-native-capability.md   # pigeon 流程
│   └── add-a-shared-package.md
└── adr/                       # 0001-multi-package-workspace、0002-bloc-over-riverpod…
```

how-to 以示範 feature 的實際檔案為範例,文件與代碼互相印證。

## 7. 主要技術選型一覽

| 領域 | 選型 | 備註 |
|---|---|---|
| 狀態管理 | flutter_bloc(一律 Bloc) | sealed class state |
| DI | get_it | feature 各自註冊,di_smoke_test 把關 |
| 路由 | go_router | app 層組裝,navigation package 放契約 |
| HTTP | dio | networking package 統一封裝 |
| 序列化 | json_serializable | DTO 限 data 層 |
| 不可變物件 | freezed(entities/DTO 視需要) | sealed state 可手寫,不強制 freezed |
| 多語系 | 官方 gen-l10n + ARB | 集中於 localization package |
| 原生通訊 | pigeon | 禁手寫 MethodChannel |
| 測試 | mocktail + bloc_test | 官方 fake 從 lib/testing.dart 匯出 |
| 推播/分析/crash | Firebase(FCM/Analytics/Crashlytics) | 一律隔在抽象介面後 |
| 版本管理 | FVM + pub workspace | 不用 melos |
| Lint | very_good_analysis + strict 模式 | 根目錄唯一一份 |

## 8. 護欄總覽(對應「不同資質共同維護」)

1. **編譯器級**:workspace/pubspec 邊界、`lib/src/` 私有性、sealed state 的 exhaustive switch、pigeon 型別安全。
2. **工具級**:strict lint、di_smoke_test、CI 同構 check.sh。
3. **程序級**:new_feature 產生器(骨架與接線自動化)、how-to 文件、PR checklist。
4. **AI 級**:CLAUDE.md 鐵律 + 任務路由,AI 產出自然落在正確位置,違規會被前三層擋下。

## 9. 範圍外(本次不做)

- Web / Desktop 支援、離線優先與本地資料庫深度整合(persistence 留有選配位置)。
- mason brick 形式的產生器(先用 Dart script,驗證後再考慮)。
- 「只測變動 package」的 CI 優化。
