import 'package:app/src/config/app_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AppConfig 保存環境設定,firebaseEnabled 預設 false', () {
    const config = AppConfig(
      environment: AppEnvironment.dev,
      apiBaseUrl: 'https://dev.api.example.com',
    );
    expect(config.environment, AppEnvironment.dev);
    expect(config.apiBaseUrl, 'https://dev.api.example.com');
    expect(config.firebaseEnabled, isFalse);
  });
}
