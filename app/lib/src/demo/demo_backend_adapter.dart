import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// 假後端:demo API 契約的記憶體實作,接上真後端前供開發與 e2e 測試使用。
///
/// 契約(app pubspec 的 Global Constraints):
/// - `POST /auth/login` `{email,password}` → 200 `{accessToken,refreshToken}`;
///   `password == 'wrong'` → 401
///   `{code:'AUTH_INVALID', message:'Invalid credentials'}`。
/// - `POST /auth/refresh` `{refreshToken}` → 200 新 tokens;
///   `refreshToken == 'expired'` → 401。
/// - `GET /items` → 200 `{items:[...5 筆...]}`。
/// - `GET /items/<id>` → 200 單品;不存在 → 404 `{code:'NOT_FOUND', message:''}`。
/// - 未知路徑一律 404;不驗證 `Authorization` header(假後端不做授權檢查)。
class DemoBackendAdapter implements HttpClientAdapter {
  /// 建立假後端 adapter;[latency] 模擬每個請求的網路延遲。
  DemoBackendAdapter({this.latency = const Duration(milliseconds: 300)});

  /// 每個請求前的模擬延遲。
  final Duration latency;

  static final List<Map<String, String>> _items = List.generate(
    5,
    (i) => {
      'id': '${i + 1}',
      'title': 'Demo item ${i + 1}',
      'description': 'Description for demo item ${i + 1}.',
    },
  );

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    await Future<void>.delayed(latency);

    final path = options.uri.path;
    final method = options.method.toUpperCase();

    if (method == 'POST' && path == '/auth/login') {
      final body = options.data as Map<String, dynamic>? ?? const {};
      if (body['password'] == 'wrong') {
        return _json(401, {
          'code': 'AUTH_INVALID',
          'message': 'Invalid credentials',
        });
      }
      return _json(200, {
        'accessToken': 'demo-access-1',
        'refreshToken': 'demo-refresh-1',
      });
    }

    if (method == 'POST' && path == '/auth/refresh') {
      final body = options.data as Map<String, dynamic>? ?? const {};
      if (body['refreshToken'] == 'expired') {
        return _json(401, {
          'code': 'AUTH_INVALID',
          'message': 'Invalid refresh token',
        });
      }
      return _json(200, {
        'accessToken': 'demo-access-1',
        'refreshToken': 'demo-refresh-1',
      });
    }

    if (method == 'GET' && path == '/items') {
      return _json(200, {'items': _items});
    }

    if (method == 'GET' && path.startsWith('/items/')) {
      final id = path.substring('/items/'.length);
      final matches = _items.where((e) => e['id'] == id);
      if (matches.isEmpty) {
        return _json(404, {'code': 'NOT_FOUND', 'message': ''});
      }
      return _json(200, matches.first);
    }

    return _json(404, {'code': 'NOT_FOUND', 'message': ''});
  }

  ResponseBody _json(int statusCode, Object body) {
    return ResponseBody.fromString(
      jsonEncode(body),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
