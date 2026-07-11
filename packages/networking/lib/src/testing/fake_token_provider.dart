import 'package:networking/src/token_provider.dart';

/// [TokenProvider] 的官方 fake(spec §3 規則 1)。
class FakeTokenProvider implements TokenProvider {
  /// 建立 fake;[refreshResult] 控制 refresh 成敗,
  /// 成功時 token 換為 [tokenAfterRefresh]。
  FakeTokenProvider({
    String? accessToken,
    this.refreshResult = false,
    this.tokenAfterRefresh,
  }) : _accessToken = accessToken;

  /// refreshTokens 的固定回傳值。
  final bool refreshResult;

  /// refresh 成功後生效的新 token。
  final String? tokenAfterRefresh;

  /// refreshTokens 被呼叫的次數。
  int refreshCallCount = 0;

  String? _accessToken;

  @override
  Future<String?> currentAccessToken() async => _accessToken;

  @override
  Future<bool> refreshTokens() async {
    refreshCallCount++;
    if (refreshResult && tokenAfterRefresh != null) {
      _accessToken = tokenAfterRefresh;
    }
    return refreshResult;
  }
}
