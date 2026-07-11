import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localization/localization.dart';

Widget _app(Locale locale, void Function(BuildContext) capture) => MaterialApp(
  locale: locale,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Builder(
    builder: (context) {
      capture(context);
      return const SizedBox.shrink();
    },
  ),
);

void main() {
  testWidgets('en 與 zh 文案正確', (tester) async {
    late BuildContext ctx;
    await tester.pumpWidget(_app(const Locale('en'), (c) => ctx = c));
    expect(ctx.l10n.commonRetry, 'Retry');

    await tester.pumpWidget(_app(const Locale('zh'), (c) => ctx = c));
    await tester.pumpAndSettle();
    expect(ctx.l10n.commonRetry, '重試');
    expect(ctx.l10n.commonErrorGeneric, '發生錯誤,請再試一次。');
  });

  test('supportedLocales 含 en 與 zh', () {
    expect(
      AppLocalizations.supportedLocales.map((l) => l.languageCode),
      containsAll(['en', 'zh']),
    );
  });
}
