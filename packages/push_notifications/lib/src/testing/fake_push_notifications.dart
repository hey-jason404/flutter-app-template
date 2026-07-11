import 'dart:async';

import 'package:push_notifications/src/push_notifications.dart';

/// [PushNotifications] 的官方 fake。
class FakePushNotifications implements PushNotifications {
  /// 建立 fake。
  FakePushNotifications({this.permissionResult = true, this.token = 'fake'});

  /// requestPermission 的固定回傳。
  final bool permissionResult;

  /// currentToken 的固定回傳。
  final String? token;

  final _tokenController = StreamController<String>.broadcast();
  final _tapController = StreamController<PushTapEvent>.broadcast();

  /// 模擬 token 更新。
  void emitTokenRefresh(String token) => _tokenController.add(token);

  /// 模擬使用者點擊推播。
  void emitTap(PushTapEvent event) => _tapController.add(event);

  @override
  Future<bool> requestPermission() async => permissionResult;

  @override
  Future<String?> currentToken() async => token;

  @override
  Stream<String> get tokenRefreshes => _tokenController.stream;

  @override
  Stream<PushTapEvent> get taps => _tapController.stream;
}
