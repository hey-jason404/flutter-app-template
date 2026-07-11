import 'package:app/src/bootstrap.dart';
import 'package:app/src/config/app_config.dart';

// firebaseEnabled 出廠預設維持 false;待專案完成 Firebase 設定後再改為 true。
void main() => bootstrap(
  const AppConfig(
    environment: AppEnvironment.prod,
    apiBaseUrl: 'https://api.example.com',
  ),
);
