import 'package:app/src/bootstrap.dart';
import 'package:app/src/config/app_config.dart';

// firebaseEnabled 出廠預設維持 false;待專案完成 Firebase 設定後再改為 true。
// useFakeBackend 出廠預設維持 true(AppConfig 預設值)：prod 進入點目前仍靜默
// 走內建假後端 DemoBackendAdapter，這是模板陷阱——接上真實後端後，
// 務必在此顯式傳入 useFakeBackend: false，否則 prod build 會誤以為已對接真 API。
void main() => bootstrap(
  const AppConfig(
    environment: AppEnvironment.prod,
    apiBaseUrl: 'https://api.example.com',
  ),
);
