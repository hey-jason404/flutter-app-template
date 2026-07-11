import 'package:app/src/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foundation/testing.dart';
import 'package:get_it/get_it.dart';
import 'package:navigation/navigation.dart';
import 'package:persistence/testing.dart';
import 'package:push_notifications/push_notifications.dart';
import 'package:push_notifications/testing.dart';
import 'package:session/session.dart';
import 'package:session/testing.dart';

void main() {
  late GetIt gi;
  late SessionManager session;
  late FakePushNotifications push;

  Future<void> setupGetIt({PushTapEvent? initialTapEvent}) async {
    gi = GetIt.asNewInstance();
    session = SessionManager(
      store: InMemorySecureStore(),
      gateway: FakeTokenRefreshGateway(),
      logger: FakeLogger(),
    );
    await session.restore(); // 空儲存 → Unauthenticated
    push = FakePushNotifications(initialTapEvent: initialTapEvent);
    gi
      ..registerSingleton<SessionManager>(session)
      ..registerSingleton<PushNotifications>(push);
  }

  tearDown(() => gi.reset());

  testWidgets('未登入 → 顯示 login placeholder，且 shell 不生效(無 NavigationBar)', (
    tester,
  ) async {
    await setupGetIt();
    await tester.pumpWidget(App(gi: gi));
    await tester.pumpAndSettle();

    expect(find.text('login placeholder'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('signIn 後 → 顯示 home placeholder，shell 生效(有 NavigationBar)', (
    tester,
  ) async {
    await setupGetIt();
    await tester.pumpWidget(App(gi: gi));
    await tester.pumpAndSettle();

    await session.signIn(const AuthTokens(accessToken: 'a', refreshToken: 'r'));
    await tester.pumpAndSettle();

    expect(find.text('home placeholder'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('已登入時點擊推播導向 login → 守衛擋回，仍顯示 home', (tester) async {
    await setupGetIt();
    await tester.pumpWidget(App(gi: gi));
    await tester.pumpAndSettle();

    await session.signIn(const AuthTokens(accessToken: 'a', refreshToken: 'r'));
    await tester.pumpAndSettle();
    expect(find.text('home placeholder'), findsOneWidget);

    push.emitTap(const PushTapEvent(routePath: RoutePaths.login));
    await tester.pumpAndSettle();

    expect(find.text('home placeholder'), findsOneWidget);
  });

  testWidgets('冷啟動點擊(未登入)導向 home → 守衛導回 login，不崩潰', (tester) async {
    await setupGetIt(
      initialTapEvent: const PushTapEvent(routePath: RoutePaths.home),
    );
    await tester.pumpWidget(App(gi: gi));
    await tester.pumpAndSettle();

    expect(find.text('login placeholder'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
