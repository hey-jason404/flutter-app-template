import 'package:app/src/config/app_config.dart';
import 'package:flutter/material.dart';

/// 啟動序列;Task 4 完成完整五步,目前為可編譯佔位。
Future<void> bootstrap(AppConfig config) async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const Placeholder());
}
