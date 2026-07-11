import 'package:app/src/bootstrap.dart';
import 'package:app/src/config/app_config.dart';

void main() => bootstrap(
  const AppConfig(
    environment: AppEnvironment.stg,
    apiBaseUrl: 'https://stg.api.example.com',
  ),
);
