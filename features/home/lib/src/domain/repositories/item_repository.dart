import 'package:foundation/foundation.dart';
import 'package:home/src/domain/entities/item.dart';

/// 首頁功能的 domain 契約。
abstract interface class ItemRepository {
  /// 取得項目清單。
  Future<Result<List<Item>>> fetchItems();

  /// 以 [id] 取得單一項目。
  Future<Result<Item>> fetchItem(String id);
}
