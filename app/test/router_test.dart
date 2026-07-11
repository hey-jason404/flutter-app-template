import 'package:app/src/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foundation/testing.dart';
import 'package:go_router/go_router.dart';
import 'package:navigation/navigation.dart';
import 'package:persistence/testing.dart';
import 'package:session/session.dart';
import 'package:session/testing.dart';

void main() {
  late SessionManager session;
  late GoRouter router;

  setUp(() async {
    session = SessionManager(
      store: InMemorySecureStore(),
      gateway: FakeTokenRefreshGateway(),
      logger: FakeLogger(),
    );
    await session.restore(); // 空儲存 → Unauthenticated
    router = buildRouter(session);
  });

  Future<void> pumpApp(WidgetTester tester) => tester.pumpWidget(
        MaterialApp.router(routerConfig: router),
      );

  testWidgets('未登入導向 login', (tester) async {
    await pumpApp(tester);
    await tester.pumpAndSettle();
    expect(find.text('login placeholder'), findsOneWidget);
  });

  testWidgets('signIn 後轉 home;signOut 後回 login', (tester) async {
    await pumpApp(tester);
    await tester.pumpAndSettle();
    await session.signIn(
      const AuthTokens(accessToken: 'a', refreshToken: 'r'),
    );
    await tester.pumpAndSettle();
    expect(find.text('home placeholder'), findsOneWidget);

    router.go(RoutePaths.login);
    await tester.pumpAndSettle();
    expect(find.text('home placeholder'), findsOneWidget);

    await session.signOut();
    await tester.pumpAndSettle();
    expect(find.text('login placeholder'), findsOneWidget);
  });
}
