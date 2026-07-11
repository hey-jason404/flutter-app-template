/// 全專案唯一的例外體系(spec §2.4)。
///
/// 規則:repository 一律回傳 Result 且 failure 端只能是 AppException 子類;
/// 各 feature 不得自創例外型別。轉換責任:networking 攔截器產生前四類,
/// data 層產生 ParsingException,persistence 產生 StorageException,
/// packages/native 產生 NativeException。
sealed class AppException implements Exception {
  const AppException({this.cause, this.stackTrace});

  /// 原始錯誤(如 DioException),僅供 observability 記錄,UI 不得使用。
  final Object? cause;
  final StackTrace? stackTrace;
}

/// 無網路、DNS 失敗、連線逾時。
final class ConnectivityException extends AppException {
  const ConnectivityException({super.cause, super.stackTrace});
}

/// HTTP 5xx。
final class ServerException extends AppException {
  const ServerException({required this.statusCode, super.cause, super.stackTrace});

  final int statusCode;
}

/// 401,且 token refresh 失敗(觸發 session 過期流程)。
final class UnauthorizedException extends AppException {
  const UnauthorizedException({super.cause, super.stackTrace});
}

/// HTTP 4xx 業務錯誤,攜帶後端錯誤碼與訊息。
final class ApiException extends AppException {
  const ApiException({
    required this.code,
    required this.message,
    super.cause,
    super.stackTrace,
  });

  final String code;
  final String message;
}

/// JSON 解析或 DTO 轉換失敗。
final class ParsingException extends AppException {
  const ParsingException({super.cause, super.stackTrace});
}

/// 本地儲存讀寫失敗。
final class StorageException extends AppException {
  const StorageException({super.cause, super.stackTrace});
}

/// 原生能力呼叫失敗,code 為 pigeon 介面定義的錯誤碼。
final class NativeException extends AppException {
  const NativeException({required this.code, super.cause, super.stackTrace});

  final String code;
}

/// 以上皆非的兜底。出現即代表有未收攏的錯誤來源,應追查 cause。
final class UnknownException extends AppException {
  const UnknownException({super.cause, super.stackTrace});
}
