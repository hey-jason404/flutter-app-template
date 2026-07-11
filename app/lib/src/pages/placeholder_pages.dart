import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

// Plan 5 以 feature 頁面取代

/// 登入頁佔位頁。
class PlaceholderLoginPage extends StatelessWidget {
  /// 建立登入佔位頁。
  const PlaceholderLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppPageScaffold(
      title: 'Login',
      body: Text('login placeholder'),
    );
  }
}

/// 首頁佔位頁。
class PlaceholderHomePage extends StatelessWidget {
  /// 建立首頁佔位頁。
  const PlaceholderHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppPageScaffold(title: 'Home', body: Text('home placeholder'));
  }
}
