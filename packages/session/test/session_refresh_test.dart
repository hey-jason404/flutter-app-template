import 'package:flutter_test/flutter_test.dart';
import 'package:foundation/foundation.dart';
import 'package:foundation/testing.dart';
import 'package:persistence/testing.dart';
import 'package:session/session.dart';
import 'package:session/testing.dart';

void main() {
  late InMemorySecureStore store;
  late FakeLogger logger;

  SessionManager build(FakeTokenRefreshGateway gateway) => SessionManager(
        store: store,
        gateway: gateway,
        logger: logger,
      );

  setUp(() {
    store = InMemorySecureStore();
    logger = FakeLogger();
  });

  Future<SessionManager> signedIn(FakeTokenRefreshGateway gateway) async {
    final manager = build(gateway);
    await manager.signIn(
      const AuthTokens(accessToken: 'a0', refreshToken: 'r0'),
    );
    return manager;
  }

  test('未登入時 refresh 直接 false 且不打 gateway', () async {
    final gateway = FakeTokenRefreshGateway();
    final manager = build(gateway);
    expect(await manager.refreshTokens(), isFalse);
    expect(gateway.callCount, 0);
  });

  test('成功:換新 tokens、持久化、回 true', () async {
    final gateway = FakeTokenRefreshGateway(
      result: const Result.success(
        AuthTokens(accessToken: 'a1', refreshToken: 'r1'),
      ),
    );
    final manager = await signedIn(gateway);
    expect(await manager.refreshTokens(), isTrue);
    expect(await manager.currentAccessToken(), 'a1');
    expect(store.values[SessionManager.refreshTokenKey], 'r1');
    expect(gateway.receivedRefreshTokens, ['r0']);
    expect(manager.state, isA<SessionAuthenticated>());
  });

  test('失敗:登出並發布 Unauthenticated、回 false', () async {
    final gateway = FakeTokenRefreshGateway();
    final manager = await signedIn(gateway);
    final emitted = <SessionState>[];
    final sub = manager.states.listen(emitted.add);
    expect(await manager.refreshTokens(), isFalse);
    await sub.cancel();
    expect(manager.state, isA<SessionUnauthenticated>());
    expect(emitted.single, isA<SessionUnauthenticated>());
    expect(store.values, isEmpty);
  });

  test('單一飛行:並發呼叫只打一次 gateway,結果共享', () async {
    final gateway = FakeTokenRefreshGateway(
      result: const Result.success(
        AuthTokens(accessToken: 'a1', refreshToken: 'r1'),
      ),
      delay: const Duration(milliseconds: 50),
    );
    final manager = await signedIn(gateway);
    final results = await Future.wait([
      manager.refreshTokens(),
      manager.refreshTokens(),
      manager.refreshTokens(),
    ]);
    expect(results, [true, true, true]);
    expect(gateway.callCount, 1);
  });

  test('refresh 完成後可再次 refresh(飛行旗標有重置)', () async {
    final gateway = FakeTokenRefreshGateway(
      result: const Result.success(
        AuthTokens(accessToken: 'a1', refreshToken: 'r1'),
      ),
    );
    final manager = await signedIn(gateway);
    expect(await manager.refreshTokens(), isTrue);
    expect(await manager.refreshTokens(), isTrue);
    expect(gateway.callCount, 2);
  });
}
