import 'package:app/src/app.dart';
import 'package:app/src/demo/demo_backend_adapter.dart';
import 'package:auth/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foundation/testing.dart';
import 'package:get_it/get_it.dart';
import 'package:home/home.dart';
import 'package:navigation/navigation.dart';
import 'package:networking/networking.dart';
import 'package:persistence/testing.dart';
import 'package:push_notifications/push_notifications.dart';
import 'package:push_notifications/testing.dart';
import 'package:session/session.dart';
import 'package:session/testing.dart';

void main() {
  late GetIt gi;
  late SessionManager session;
  late FakePushNotifications push;

  // App 頁面一律透過全域 GetIt.instance 解析 bloc(見 LoginPage/HomePage),
  // 因此測試需註冊到同一個實例(而非 GetIt.asNewInstance()),
  // 並在 tearDown 重置以隔離各測試。
  Future<void> setupGetIt({PushTapEvent? initialTapEvent}) async {
    gi = GetIt.instance;
    session = SessionManager(
      store: InMemorySecureStore(),
      gateway: FakeTokenRefreshGateway(),
      logger: FakeLogger(),
    );
    await session.restore(); // 空儲存 → Unauthenticated
    push = FakePushNotifications(initialTapEvent: initialTapEvent);
    final apiClient = ApiClient(
      createDio(
        config: const NetworkingConfig(baseUrl: 'https://demo.example.com'),
        tokenProvider: session,
        adapter: DemoBackendAdapter(latency: Duration.zero),
      ),
    );
    gi
      ..registerSingleton<SessionManager>(session)
      ..registerSingleton<PushNotifications>(push)
      ..registerSingleton<ApiClient>(apiClient);
    registerAuthFeature(gi);
    registerHomeFeature(gi);
  }

  tearDown(() async {
    await gi.reset();
  });

  testWidgets('未登入 → 顯示 login 頁，且 shell 不生效(無 NavigationBar)', (tester) async {
    await setupGetIt();
    await tester.pumpWidget(App(gi: gi));
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('signIn 後 → 顯示 home 頁，shell 生效(有 NavigationBar)', (tester) async {
    await setupGetIt();
    await tester.pumpWidget(App(gi: gi));
    await tester.pumpAndSettle();

    await session.signIn(const AuthTokens(accessToken: 'a', refreshToken: 'r'));
    await tester.pumpAndSettle();

    expect(find.byType(HomePage), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('已登入時點擊推播導向 login → 守衛擋回，仍顯示 home', (tester) async {
    await setupGetIt();
    await tester.pumpWidget(App(gi: gi));
    await tester.pumpAndSettle();

    await session.signIn(const AuthTokens(accessToken: 'a', refreshToken: 'r'));
    await tester.pumpAndSettle();
    expect(find.byType(HomePage), findsOneWidget);

    push.emitTap(const PushTapEvent(routePath: RoutePaths.login));
    await tester.pumpAndSettle();

    expect(find.byType(HomePage), findsOneWidget);
  });

  testWidgets('冷啟動點擊(未登入)導向 home → 守衛導回 login，不崩潰', (tester) async {
    await setupGetIt(
      initialTapEvent: const PushTapEvent(routePath: RoutePaths.home),
    );
    await tester.pumpWidget(App(gi: gi));
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
