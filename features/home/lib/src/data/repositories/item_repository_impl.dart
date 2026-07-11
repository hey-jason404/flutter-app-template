import 'package:foundation/foundation.dart';
import 'package:home/src/data/dtos/item_dto.dart';
import 'package:home/src/domain/entities/item.dart';
import 'package:home/src/domain/repositories/item_repository.dart';
import 'package:networking/networking.dart';

/// [ItemRepository] 的 HTTP 實作。
class ItemRepositoryImpl implements ItemRepository {
  /// 以 [ApiClient] 建立。
  ItemRepositoryImpl(this._client);

  final ApiClient _client;

  @override
  Future<Result<List<Item>>> fetchItems() => _client.get<List<Item>>(
    '/items',
    parse: (data) {
      final items = (data as Map<String, dynamic>)['items'] as List<dynamic>;
      return items
          .map((e) => ItemDto.fromJson(e as Map<String, dynamic>).toEntity())
          .toList();
    },
  );

  @override
  Future<Result<Item>> fetchItem(String id) => _client.get<Item>(
    '/items/$id',
    parse: (data) => ItemDto.fromJson(data as Map<String, dynamic>).toEntity(),
  );
}
