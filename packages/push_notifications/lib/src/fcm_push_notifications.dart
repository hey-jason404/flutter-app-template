import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:push_notifications/src/push_notifications.dart';

/// [PushNotifications] 的 FCM 實作。
///
/// openedMessages 由 app 傳入開啟推播時的 stream
/// (static stream 無法注入替身,故由組裝層提供)。
class FcmPushNotifications implements PushNotifications {
  /// 以注入的 messaging 實例與事件來源建立。
  FcmPushNotifications({
    required FirebaseMessaging messaging,
    required Stream<RemoteMessage> openedMessages,
    Stream<String>? tokenRefreshes,
  })  : _messaging = messaging,
        _openedMessages = openedMessages,
        _tokenRefreshes = tokenRefreshes;

  final FirebaseMessaging _messaging;
  final Stream<RemoteMessage> _openedMessages;
  final Stream<String>? _tokenRefreshes;

  @override
  Future<bool> requestPermission() async {
    final settings = await _messaging.requestPermission();
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  @override
  Future<String?> currentToken() => _messaging.getToken();

  @override
  Stream<String> get tokenRefreshes =>
      _tokenRefreshes ?? _messaging.onTokenRefresh;

  @override
  Stream<PushTapEvent> get taps => _openedMessages.map(
        (message) => PushTapEvent(
          routePath: message.data['route'] as String?,
          data: message.data,
        ),
      );
}
