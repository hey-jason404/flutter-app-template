/// App 執行環境。
enum AppEnvironment {
  /// 開發環境。
  dev,

  /// 測試/預備環境。
  stg,

  /// 正式環境。
  prod,
}

/// App 啟動設定,依 flavor 於各 `main_*.dart` 建構。
class AppConfig {
  /// 建立設定。
  const AppConfig({
    required this.environment,
    required this.apiBaseUrl,
    this.firebaseEnabled = false,
    this.useFakeBackend = true,
    this.demoBackendLatency = const Duration(milliseconds: 300),
  });

  /// 目前執行環境。
  final AppEnvironment environment;

  /// API 基底網址。
  final String apiBaseUrl;

  /// 是否啟用 Firebase;出廠預設 false,待專案設定 Firebase 專案後再改為 true。
  final bool firebaseEnabled;

  /// 是否使用內建假後端(`DemoBackendAdapter`)取代真實網路請求。
  ///
  /// 出廠預設 true,讓範本開箱即可跑;接上真後端後改為 false。
  final bool useFakeBackend;

  /// 假後端模擬的每個請求延遲;僅在 [useFakeBackend] 為 true 時生效。
  final Duration demoBackendLatency;
}
