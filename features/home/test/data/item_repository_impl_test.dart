import 'package:flutter_test/flutter_test.dart';
import 'package:foundation/foundation.dart';
import 'package:home/src/data/repositories/item_repository_impl.dart';
import 'package:home/src/domain/entities/item.dart';
import 'package:networking/networking.dart';
import 'package:networking/testing.dart';

const _config = NetworkingConfig(baseUrl: 'https://api.test');

void main() {
  group('ItemRepositoryImpl.fetchItems', () {
    test('成功時回傳 Success(List<Item>)（5 筆）', () async {
      final adapter = ScriptedAdapter([
        (_) => jsonResponse(200, '''
{"items":[
  {"id":"1","title":"t1","description":"d1"},
  {"id":"2","title":"t2","description":"d2"},
  {"id":"3","title":"t3","description":"d3"},
  {"id":"4","title":"t4","description":"d4"},
  {"id":"5","title":"t5","description":"d5"}
]}
'''),
      ]);
      final client = ApiClient(
        createPlainDio(config: _config, adapter: adapter),
      );
      final repository = ItemRepositoryImpl(client);

      final result = await repository.fetchItems();

      expect(result, isA<Success<List<Item>>>());
      final items = (result as Success<List<Item>>).value;
      expect(items, hasLength(5));
      expect(items.first.id, '1');
      expect(items.first.title, 't1');
      expect(items.first.description, 'd1');
    });

    test('404 時回傳 Failure(ApiException)', () async {
      final adapter = ScriptedAdapter([(_) => jsonResponse(404, '{}')]);
      final client = ApiClient(
        createPlainDio(config: _config, adapter: adapter),
      );
      final repository = ItemRepositoryImpl(client);

      final result = await repository.fetchItems();

      expect(result, isA<Failure<List<Item>>>());
      expect((result as Failure<List<Item>>).exception, isA<ApiException>());
    });

    test('items 缺欄位時回傳 Failure(ParsingException)', () async {
      final adapter = ScriptedAdapter([
        (_) => jsonResponse(200, '{"items":[{"id":"1","title":"t1"}]}'),
      ]);
      final client = ApiClient(
        createPlainDio(config: _config, adapter: adapter),
      );
      final repository = ItemRepositoryImpl(client);

      final result = await repository.fetchItems();

      expect(result, isA<Failure<List<Item>>>());
      expect(
        (result as Failure<List<Item>>).exception,
        isA<ParsingException>(),
      );
    });
  });

  group('ItemRepositoryImpl.fetchItem', () {
    test('成功時回傳 Success(Item) 並打對路徑', () async {
      final adapter = ScriptedAdapter([
        (_) => jsonResponse(200, '{"id":"1","title":"t1","description":"d1"}'),
      ]);
      final client = ApiClient(
        createPlainDio(config: _config, adapter: adapter),
      );
      final repository = ItemRepositoryImpl(client);

      final result = await repository.fetchItem('1');

      expect(result, isA<Success<Item>>());
      final item = (result as Success<Item>).value;
      expect(item.id, '1');
      expect(item.title, 't1');
      expect(item.description, 'd1');
      expect(adapter.seen, hasLength(1));
      expect(adapter.seen.single.path, '/items/1');
    });
  });
}
