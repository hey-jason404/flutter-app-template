// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get authEmailLabel => '電子郵件';

  @override
  String get authLoginButton => '登入';

  @override
  String get authLoginFailed => '登入失敗,請確認帳號密碼。';

  @override
  String get authLoginTitle => '登入';

  @override
  String get authPasswordLabel => '密碼';

  @override
  String get commonCancel => '取消';

  @override
  String get commonConfirm => '確認';

  @override
  String get commonErrorGeneric => '發生錯誤,請再試一次。';

  @override
  String get commonLoading => '載入中…';

  @override
  String get commonRetry => '重試';

  @override
  String get homeDetailTitle => '詳情';

  @override
  String get homeEmpty => '目前沒有項目。';

  @override
  String get homeTitle => '首頁';
}
