import 'package:foundation/foundation.dart';
import 'package:test/test.dart';

/// sealed class 的核心價值:exhaustive switch。
/// 這個函式若少列任何子類,是編譯錯誤——測試本身就是護欄的驗證。
String describe(AppException e) => switch (e) {
  ConnectivityException() => 'connectivity',
  ServerException(:final statusCode) => 'server:$statusCode',
  UnauthorizedException() => 'unauthorized',
  ApiException(:final code, :final message) => 'api:$code:$message',
  ParsingException() => 'parsing',
  StorageException() => 'storage',
  NativeException(:final code) => 'native:$code',
  UnknownException() => 'unknown',
};

void main() {
  test('exhaustive switch 覆蓋所有子類', () {
    expect(describe(const ConnectivityException()), 'connectivity');
    expect(describe(const ServerException(statusCode: 503)), 'server:503');
    expect(describe(const UnauthorizedException()), 'unauthorized');
    expect(
      describe(const ApiException(code: 'E001', message: 'bad request')),
      'api:E001:bad request',
    );
    expect(describe(const ParsingException()), 'parsing');
    expect(describe(const StorageException()), 'storage');
    expect(
      describe(const NativeException(code: 'CAMERA_DENIED')),
      'native:CAMERA_DENIED',
    );
    expect(describe(const UnknownException()), 'unknown');
  });

  test('cause 與 stackTrace 可攜帶原始錯誤', () {
    const cause = FormatException('bad json');
    final st = StackTrace.current;
    final e = ParsingException(cause: cause, stackTrace: st);
    expect(e.cause, same(cause));
    expect(e.stackTrace, same(st));
  });
}
