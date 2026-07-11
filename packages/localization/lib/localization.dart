/// 多語系入口:AppLocalizations 與 BuildContext 便捷取用。
library;

import 'package:flutter/widgets.dart';
import 'package:localization/src/generated/app_localizations.dart';

export 'src/generated/app_localizations.dart';

/// 讓頁面以 `context.l10n.commonRetry` 取用文案。
extension LocalizationContextX on BuildContext {
  /// 目前 locale 的文案。
  AppLocalizations get l10n => AppLocalizations.of(this);
}
