import 'package:dio/dio.dart';
import 'package:networking/networking.dart';
import 'package:networking/testing.dart';
import 'package:test/test.dart';

import 'support/scripted_adapter.dart';

({Dio dio, ScriptedAdapter adapter}) _harness({
  required List<ResponseBody Function(RequestOptions)> script,
  required TokenProvider tokenProvider,
}) {
  final adapter = ScriptedAdapter(script);
  final options = BaseOptions(baseUrl: 'https://api.test');
  final retryClient = Dio(options)..httpClientAdapter = adapter;
  final dio = Dio(options)
    ..httpClientAdapter = adapter
    ..interceptors.add(
      AuthInterceptor(tokenProvider: tokenProvider, retryClient: retryClient),
    );
  return (dio: dio, adapter: adapter);
}

void main() {
  test('onRequest 注入 Bearer header', () async {
    final h = _harness(
      script: [(_) => jsonResponse(200, '{}')],
      tokenProvider: FakeTokenProvider(accessToken: 't1'),
    );
    await h.dio.get<dynamic>('/me');
    expect(h.adapter.seen.single.headers['Authorization'], 'Bearer t1');
  });

  test('未登入(token null)不注入 header', () async {
    final h = _harness(
      script: [(_) => jsonResponse(200, '{}')],
      tokenProvider: FakeTokenProvider(),
    );
    await h.dio.get<dynamic>('/public');
    expect(h.adapter.seen.single.headers.containsKey('Authorization'), isFalse);
  });

  test('401 → refresh 成功 → 以新 token 重試一次並成功', () async {
    final provider = FakeTokenProvider(
      accessToken: 'old',
      refreshResult: true,
      tokenAfterRefresh: 'new',
    );
    final h = _harness(
      script: [
        (_) => jsonResponse(401, '{}'),
        (_) => jsonResponse(200, '{"ok":true}'),
      ],
      tokenProvider: provider,
    );
    final res = await h.dio.get<dynamic>('/me');
    expect(res.statusCode, 200);
    expect(provider.refreshCallCount, 1);
    expect(h.adapter.seen, hasLength(2));
    expect(h.adapter.seen[1].headers['Authorization'], 'Bearer new');
  });

  test('401 → refresh 失敗 → 原 401 錯誤往下傳且不重試', () async {
    final provider = FakeTokenProvider(accessToken: 'old');
    final h = _harness(
      script: [(_) => jsonResponse(401, '{}')],
      tokenProvider: provider,
    );
    await expectLater(
      h.dio.get<dynamic>('/me'),
      throwsA(
        isA<DioException>().having(
          (e) => e.response?.statusCode,
          'statusCode',
          401,
        ),
      ),
    );
    expect(h.adapter.seen, hasLength(1));
  });

  test('重試後仍 401 → 不再重試(單次重試上限)', () async {
    final provider = FakeTokenProvider(
      accessToken: 'old',
      refreshResult: true,
      tokenAfterRefresh: 'new',
    );
    final h = _harness(
      script: [
        (_) => jsonResponse(401, '{}'),
        (_) => jsonResponse(401, '{}'),
      ],
      tokenProvider: provider,
    );
    await expectLater(
      h.dio.get<dynamic>('/me'),
      throwsA(isA<DioException>()),
    );
    expect(h.adapter.seen, hasLength(2));
    expect(provider.refreshCallCount, 1);
  });
}
