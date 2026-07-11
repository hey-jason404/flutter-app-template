import 'dart:typed_data';

import 'package:dio/dio.dart';

/// 依序回放腳本回應的測試用 adapter;超出腳本長度時重複最後一項。
class ScriptedAdapter implements HttpClientAdapter {
  /// 以回應腳本建立 adapter。
  ScriptedAdapter(this._script);

  final List<ResponseBody Function(RequestOptions options)> _script;

  /// 實際收到的請求,依序記錄。
  final List<RequestOptions> seen = [];

  int _index = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    seen.add(options);
    final step = _script[_index < _script.length ? _index : _script.length - 1];
    _index++;
    return step(options);
  }

  @override
  void close({bool force = false}) {}
}

/// 產生 JSON 回應。
ResponseBody jsonResponse(int statusCode, String json) =>
    ResponseBody.fromString(
      json,
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
