import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: buildAppTheme(brightness: Brightness.light),
      home: child,
    );

void main() {
  testWidgets('AppPageScaffold 顯示標題與 body', (tester) async {
    await tester.pumpWidget(
      _wrap(const AppPageScaffold(title: 'T', body: Text('B'))),
    );
    expect(find.text('T'), findsOneWidget);
    expect(find.text('B'), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);
  });

  testWidgets('AppErrorView 顯示訊息並觸發 onRetry', (tester) async {
    var retried = false;
    await tester.pumpWidget(
      _wrap(
        Scaffold(
          body: AppErrorView(
            message: 'boom',
            onRetry: () => retried = true,
            retryLabel: 'Retry',
          ),
        ),
      ),
    );
    expect(find.text('boom'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    expect(retried, isTrue);
  });

  testWidgets('AppErrorView 無 onRetry 時不顯示按鈕', (tester) async {
    await tester.pumpWidget(
      _wrap(const Scaffold(body: AppErrorView(message: 'x'))),
    );
    expect(find.byType(FilledButton), findsNothing);
  });

  testWidgets('AppPrimaryButton loading 時停用且顯示 indicator', (tester) async {
    var pressed = false;
    await tester.pumpWidget(
      _wrap(
        Scaffold(
          body: AppPrimaryButton(
            label: 'Go',
            loading: true,
            onPressed: () => pressed = true,
          ),
        ),
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.tap(find.byType(FilledButton), warnIfMissed: false);
    expect(pressed, isFalse);
  });

  testWidgets('AppEmptyView 與 AppLoadingIndicator 可渲染', (tester) async {
    await tester.pumpWidget(
      _wrap(const Scaffold(body: AppEmptyView(message: 'empty'))),
    );
    expect(find.text('empty'), findsOneWidget);
    await tester.pumpWidget(
      _wrap(const Scaffold(body: AppLoadingIndicator())),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
