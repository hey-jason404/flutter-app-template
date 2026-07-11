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
  });

  /// 目前執行環境。
  final AppEnvironment environment;

  /// API 基底網址。
  final String apiBaseUrl;

  /// 是否啟用 Firebase;出廠預設 false,待專案設定 Firebase 專案後再改為 true。
  final bool firebaseEnabled;
}
