/// 登入頁的事件(sealed;命名採「主詞+過去式」)。
sealed class LoginEvent {
  /// 基底建構子,僅供子類 super 呼叫。
  const LoginEvent();
}

/// 使用者送出登入表單。
final class LoginSubmitted extends LoginEvent {
  /// 以帳號密碼建立事件。
  const LoginSubmitted({required this.email, required this.password});

  /// 使用者輸入的電子郵件。
  final String email;

  /// 使用者輸入的密碼。
  final String password;
}
