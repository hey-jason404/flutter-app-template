import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:push_notifications/push_notifications.dart';

void main() {
  late StreamController<RemoteMessage> opened;

  setUp(() {
    opened = StreamController<RemoteMessage>();
  });

  tearDown(() async {
    await opened.close();
  });

  test('taps 把 RemoteMessage 映射為 PushTapEvent(route key)', () async {
    final push = FcmPushNotifications(
      messaging: const _DummyMessaging(),
      openedMessages: opened.stream,
    );
    final events = <PushTapEvent>[];
    final sub = push.taps.listen(events.add);

    opened
      ..add(const RemoteMessage(data: {'route': '/home', 'x': '1'}))
      ..add(const RemoteMessage(data: {'x': '2'}));
    await Future<void>.delayed(Duration.zero);
    await sub.cancel();

    expect(events, hasLength(2));
    expect(events[0].routePath, '/home');
    expect(events[0].data['x'], '1');
    expect(events[1].routePath, isNull);
  });
}

/// 最小的 FirebaseMessaging 實現用於測試。
class _DummyMessaging implements FirebaseMessaging {
  const _DummyMessaging();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
