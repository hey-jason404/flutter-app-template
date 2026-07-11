import 'package:flutter/material.dart';

/// 已登入區域的共用外框:底部 [NavigationBar] + 目前路由的頁面內容。
class AppShell extends StatelessWidget {
  /// 建立 shell。
  const AppShell({required this.child, super.key});

  /// 目前路由對應的頁面內容。
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          // [NavigationBar] 至少需 2 個 destinations;佔位 destination 待
          // Plan 5 依 feature 擴充後移除。
          NavigationDestination(
            icon: Icon(Icons.more_horiz),
            label: '',
            enabled: false,
          ),
        ],
      ),
    );
  }
}
