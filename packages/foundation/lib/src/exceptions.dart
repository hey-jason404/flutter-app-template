/// 全專案唯一的例外體系(spec §2.4)。
///
/// 規則:repository 一律回傳 Result 且 failure 端只能是 AppException 子類;
/// 各 feature 不得自創例外型別。轉換責任:networking 攔截器產生前四類,
/// data 層產生 ParsingException,persistence 產生 StorageException,
/// packages/native 產生 NativeException。
sealed class AppException implements Exception {
  /// 建立例外,可選擇性攜帶原始錯誤 [cause] 與其堆疊 [stackTrace]。
  const AppException({this.cause, this.stackTrace});

  /// 原始錯誤(如 DioException),僅供 observability 記錄,UI 不得使用。
  final Object? cause;

  /// 原始錯誤發生當下的堆疊追蹤,僅供 observability 記錄。
  final StackTrace? stackTrace;
}

/// 無網路、DNS 失敗、連線逾時。
final class ConnectivityException extends AppException {
  /// 建立連線失敗例外。
  const ConnectivityException({super.cause, super.stackTrace});
}

/// HTTP 5xx。
final class ServerException extends AppException {
  /// 建立伺服器錯誤例外,需帶入 HTTP 狀態碼 [statusCode]。
  const ServerException({
    required this.statusCode,
    super.cause,
    super.stackTrace,
  });

  /// 伺服器回應的 HTTP 狀態碼(5xx)。
  final int statusCode;
}

/// 401,且 token refresh 失敗(觸發 session 過期流程)。
final class UnauthorizedException extends AppException {
  /// 建立未授權例外。
  const UnauthorizedException({super.cause, super.stackTrace});
}

/// HTTP 4xx 業務錯誤,攜帶後端錯誤碼與訊息。
final class ApiException extends AppException {
  /// 建立業務錯誤例外,需帶入後端錯誤碼 [code] 與訊息 [message]。
  const ApiException({
    required this.code,
    required this.message,
    super.cause,
    super.stackTrace,
  });

  /// 後端定義的業務錯誤碼。
  final String code;

  /// 後端回傳的錯誤訊息。
  final String message;
}

/// JSON 解析或 DTO 轉換失敗。
final class ParsingException extends AppException {
  /// 建立解析失敗例外。
  const ParsingException({super.cause, super.stackTrace});
}

/// 本地儲存讀寫失敗。
final class StorageException extends AppException {
  /// 建立本地儲存失敗例外。
  const StorageException({super.cause, super.stackTrace});
}

/// 原生能力呼叫失敗,code 為 pigeon 介面定義的錯誤碼。
final class NativeException extends AppException {
  /// 建立原生呼叫失敗例外,需帶入錯誤碼 [code]。
  const NativeException({required this.code, super.cause, super.stackTrace});

  /// pigeon 介面定義的錯誤碼。
  final String code;
}

/// 以上皆非的兜底。出現即代表有未收攏的錯誤來源,應追查 cause。
final class UnknownException extends AppException {
  /// 建立未知錯誤例外。
  const UnknownException({super.cause, super.stackTrace});
}
