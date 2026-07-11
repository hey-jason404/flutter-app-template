import 'package:dio/dio.dart';
import 'package:foundation/foundation.dart';
import 'package:networking/src/error_mapper.dart';

/// repository 的唯一 HTTP 入口:所有結果收攏為 Result(spec §4.2)。
class ApiClient {
  /// 以組裝好的 [Dio] 建立 client。
  ApiClient(this._dio);

  final Dio _dio;

  /// GET 請求。
  Future<Result<T>> get<T>(
    String path, {
    required T Function(dynamic data) parse,
    Map<String, dynamic>? queryParameters,
  }) =>
      _send(
        (dio) => dio.get<dynamic>(path, queryParameters: queryParameters),
        parse,
      );

  /// POST 請求。
  Future<Result<T>> post<T>(
    String path, {
    required T Function(dynamic data) parse,
    Object? body,
  }) =>
      _send((dio) => dio.post<dynamic>(path, data: body), parse);

  /// PUT 請求。
  Future<Result<T>> put<T>(
    String path, {
    required T Function(dynamic data) parse,
    Object? body,
  }) =>
      _send((dio) => dio.put<dynamic>(path, data: body), parse);

  /// DELETE 請求。
  Future<Result<T>> delete<T>(
    String path, {
    required T Function(dynamic data) parse,
  }) =>
      _send((dio) => dio.delete<dynamic>(path), parse);

  Future<Result<T>> _send<T>(
    Future<Response<dynamic>> Function(Dio dio) request,
    T Function(dynamic data) parse,
  ) async {
    try {
      final response = await request(_dio);
      try {
        return Result.success(parse(response.data));
      } on Object catch (e, st) {
        return Result.failure(ParsingException(cause: e, stackTrace: st));
      }
    } on DioException catch (e) {
      return Result.failure(mapDioException(e));
    } on Object catch (e, st) {
      return Result.failure(UnknownException(cause: e, stackTrace: st));
    }
  }
}
