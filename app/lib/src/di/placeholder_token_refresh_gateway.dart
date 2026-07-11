import 'package:foundation/foundation.dart';
import 'package:session/session.dart';

/// [TokenRefreshGateway] 的占位實作;Plan 5 auth feature 取代。
///
/// 安全預設:在真正的 refresh API 接上之前，一律回傳失敗
/// (`UnauthorizedException`),讓 token 過期時視同登出，
/// 不會把使用者卡在「看似有效但實際永遠拿不到新 token」的狀態。
class PlaceholderTokenRefreshGateway implements TokenRefreshGateway {
  @override
  Future<Result<AuthTokens>> refresh(String refreshToken) async {
    return const Result.failure(UnauthorizedException());
  }
}
