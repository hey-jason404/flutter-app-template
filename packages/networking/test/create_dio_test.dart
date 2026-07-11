import 'package:networking/networking.dart';
import 'package:networking/testing.dart';
import 'package:test/test.dart';

void main() {
  test('createDio 套用 config 並掛上 AuthInterceptor', () async {
    final adapter = ScriptedAdapter([
      (_) => jsonResponse(401, '{}'),
      (_) => jsonResponse(200, '{}'),
    ]);
    final dio = createDio(
      config: const NetworkingConfig(baseUrl: 'https://api.test'),
      tokenProvider: FakeTokenProvider(
        accessToken: 'old',
        refreshResult: true,
        tokenAfterRefresh: 'new',
      ),
      adapter: adapter,
    );
    expect(dio.options.baseUrl, 'https://api.test');
    expect(dio.options.connectTimeout, const Duration(seconds: 10));
    expect(dio.options.receiveTimeout, const Duration(seconds: 20));

    final res = await dio.get<dynamic>('/me');
    expect(res.statusCode, 200);
    expect(adapter.seen[1].headers['Authorization'], 'Bearer new');
  });
}
