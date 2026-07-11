import 'package:foundation/foundation.dart';
import 'package:home/src/domain/entities/item.dart';

/// 項目清單頁的狀態(sealed;UI 端須 exhaustive switch 渲染)。
sealed class ItemListState {
  /// 基底建構子,僅供子類 super 呼叫。
  const ItemListState();
}

/// 載入中(初始狀態)。
final class ItemListLoading extends ItemListState {
  /// 建立載入中狀態。
  const ItemListLoading();
}

/// 載入成功,攜帶項目清單。
final class ItemListLoaded extends ItemListState {
  /// 以項目清單建立成功狀態。
  const ItemListLoaded(this.items);

  /// 項目清單。
  final List<Item> items;
}

/// 載入失敗,攜帶失敗原因。
final class ItemListError extends ItemListState {
  /// 以例外建立失敗狀態。
  const ItemListError(this.exception);

  /// 失敗原因。
  final AppException exception;
}
