/// 使用者點擊推播的事件。
class PushTapEvent {
  /// 建立事件。
  const PushTapEvent({this.routePath, this.data = const {}});

  /// 目標路由(取自 FCM data payload 的 `route` key——與後端的契約);
  /// 無此 key 時為 null,由 app 決定預設行為。
  final String? routePath;

  /// 完整 data payload。
  final Map<String, dynamic> data;
}

/// 推播能力契約;FCM 實作見 FcmPushNotifications。
abstract interface class PushNotifications {
  /// 要求推播權限;授權(含 provisional)回 true。
  Future<bool> requestPermission();

  /// 目前裝置 token;不可用時為 null。
  Future<String?> currentToken();

  /// token 更新事件(app 應上報後端)。
  Stream<String> get tokenRefreshes;

  /// 使用者點擊推播的事件(app 訂閱後轉路由)。
  Stream<PushTapEvent> get taps;
}
