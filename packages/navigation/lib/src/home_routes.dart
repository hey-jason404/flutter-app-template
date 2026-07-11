import 'package:navigation/src/app_route.dart';
import 'package:navigation/src/route_paths.dart';

/// 導向項目詳情頁。
class ItemDetailRoute implements AppRoute {
  /// 以 [id] 建立項目詳情頁路由。
  const ItemDetailRoute(this.id);

  /// 項目識別碼。
  final String id;

  @override
  String get location => RoutePaths.homeItemDetail.replaceFirst(':id', id);
}
