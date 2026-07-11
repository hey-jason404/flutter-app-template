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
          // [NavigationBar] 至少需 2 個 destinations;佔位 destination 視覺
          // 隱形(空 icon/label + enabled false),Plan 6/下一個 feature
          // 加入底部導覽項目時替換。
          NavigationDestination(
            icon: SizedBox.shrink(),
            label: '',
            enabled: false,
          ),
        ],
      ),
    );
  }
}
