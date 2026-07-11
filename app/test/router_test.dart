import 'package:app/src/demo/demo_backend_adapter.dart';
import 'package:app/src/router/app_router.dart';
import 'package:auth/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foundation/testing.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:home/home.dart';
import 'package:localization/localization.dart';
import 'package:navigation/navigation.dart';
import 'package:networking/networking.dart';
import 'package:persistence/testing.dart';
import 'package:session/session.dart';
import 'package:session/testing.dart';

void main() {
  late GetIt gi;
  late SessionManager session;
  late GoRouter router;

  setUp(() async {
    gi = GetIt.instance;
    session = SessionManager(
      store: InMemorySecureStore(),
      gateway: FakeTokenRefreshGateway(),
      logger: FakeLogger(),
    );
    await session.restore(); // 空儲存 → Unauthenticated
    final apiClient = ApiClient(
      createDio(
        config: const NetworkingConfig(baseUrl: 'https://demo.example.com'),
        tokenProvider: session,
        adapter: DemoBackendAdapter(latency: Duration.zero),
      ),
    );
    gi
      ..registerSingleton<SessionManager>(session)
      ..registerSingleton<ApiClient>(apiClient);
    registerAuthFeature(gi);
    registerHomeFeature(gi);
    router = buildRouter(session);
  });

  tearDown(() async {
    await gi.reset();
  });

  Future<void> pumpApp(WidgetTester tester) => tester.pumpWidget(
    MaterialApp.router(
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    ),
  );

  testWidgets('未登入導向 login', (tester) async {
    await pumpApp(tester);
    await tester.pumpAndSettle();
    expect(find.byType(LoginPage), findsOneWidget);
  });

  testWidgets('signIn 後轉 home;signOut 後回 login', (tester) async {
    await pumpApp(tester);
    await tester.pumpAndSettle();
    await session.signIn(const AuthTokens(accessToken: 'a', refreshToken: 'r'));
    await tester.pumpAndSettle();
    expect(find.byType(HomePage), findsOneWidget);

    router.go(RoutePaths.login);
    await tester.pumpAndSettle();
    expect(find.byType(HomePage), findsOneWidget);

    await session.signOut();
    await tester.pumpAndSettle();
    expect(find.byType(LoginPage), findsOneWidget);
  });
}
