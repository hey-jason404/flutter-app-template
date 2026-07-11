import 'dart:async';

import 'package:foundation/foundation.dart';
import 'package:networking/networking.dart';
import 'package:persistence/persistence.dart';
import 'package:session/src/auth_tokens.dart';
import 'package:session/src/session_state.dart';
import 'package:session/src/token_refresh_gateway.dart';

/// 登入狀態的單一真相,並實作 networking 的 [TokenProvider]。
///
/// 生命週期:app bootstrap 建立唯一實例並 `restore()`;
/// auth feature 登入成功後呼叫 [signIn];
/// app 層訂閱 [states] 處理 token 失效導回登入。
class SessionManager implements TokenProvider {
  /// 以儲存、換發 gateway 與 logger 建立。
  SessionManager({
    required SecureStore store,
    required TokenRefreshGateway gateway,
    required AppLogger logger,
  })  : _store = store,
        _gateway = gateway,
        _logger = logger;

  /// access token 的儲存 key。
  static const accessTokenKey = 'session.access_token';

  /// refresh token 的儲存 key。
  static const refreshTokenKey = 'session.refresh_token';

  final SecureStore _store;
  // ignore: unused_field -- Task 9 completes refresh logic
  final TokenRefreshGateway _gateway;
  final AppLogger _logger;

  final StreamController<SessionState> _controller =
      StreamController<SessionState>.broadcast(sync: true);

  AuthTokens? _tokens;
  SessionState _state = const SessionRestoring();

  /// 目前狀態。
  SessionState get state => _state;

  /// 狀態變化的 broadcast stream(僅在改變時發布)。
  Stream<SessionState> get states => _controller.stream;

  /// 從儲存還原登入狀態;儲存損壞時視為未登入,不阻斷啟動。
  Future<void> restore() async {
    try {
      final access = await _store.read(accessTokenKey);
      final refresh = await _store.read(refreshTokenKey);
      if (access != null && refresh != null) {
        _tokens = AuthTokens(accessToken: access, refreshToken: refresh);
        _emit(const SessionAuthenticated());
        return;
      }
    } on StorageException catch (e, st) {
      _logger.error('session restore failed', error: e, stackTrace: st);
    }
    _tokens = null;
    _emit(const SessionUnauthenticated());
  }

  /// 登入成功後保存 tokens 並發布已登入。
  Future<void> signIn(AuthTokens tokens) async {
    await _store.write(accessTokenKey, tokens.accessToken);
    await _store.write(refreshTokenKey, tokens.refreshToken);
    _tokens = tokens;
    _emit(const SessionAuthenticated());
  }

  /// 登出:清除儲存與快取;即使刪除失敗也保證回到未登入。
  Future<void> signOut() async {
    try {
      await _store.delete(accessTokenKey);
      await _store.delete(refreshTokenKey);
    } on StorageException catch (e, st) {
      _logger.error('session signOut cleanup failed', error: e, stackTrace: st);
    }
    _tokens = null;
    _emit(const SessionUnauthenticated());
  }

  @override
  Future<String?> currentAccessToken() async => _tokens?.accessToken;

  @override
  Future<bool> refreshTokens() async => false; // Task 9 完成實作。

  void _emit(SessionState next) {
    if (next.runtimeType != _state.runtimeType) {
      _controller.add(next);
    }
    _state = next;
  }
}
