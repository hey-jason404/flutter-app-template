import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foundation/foundation.dart';
import 'package:home/src/domain/entities/item.dart';
import 'package:home/src/domain/repositories/item_repository.dart';
import 'package:home/src/presentation/blocs/item_list/item_list_bloc.dart';
import 'package:home/src/presentation/blocs/item_list/item_list_event.dart';
import 'package:home/src/presentation/blocs/item_list/item_list_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockItemRepository extends Mock implements ItemRepository {}

void main() {
  late _MockItemRepository repository;

  const items = [
    Item(id: '1', title: 't1', description: 'd1'),
    Item(id: '2', title: 't2', description: 'd2'),
  ];

  setUp(() {
    repository = _MockItemRepository();
  });

  group('ItemListBloc', () {
    blocTest<ItemListBloc, ItemListState>(
      '初始狀態為 ItemListLoading',
      build: () => ItemListBloc(repository: repository),
      verify: (bloc) {
        expect(bloc.state, isA<ItemListLoading>());
      },
    );

    blocTest<ItemListBloc, ItemListState>(
      '取得成功 → [ItemListLoaded]',
      setUp: () {
        when(
          () => repository.fetchItems(),
        ).thenAnswer((_) async => const Result.success(items));
      },
      build: () => ItemListBloc(repository: repository),
      act: (bloc) => bloc.add(const ItemListRequested()),
      expect:
          () => [
            isA<ItemListLoading>(),
            isA<ItemListLoaded>().having((s) => s.items, 'items', items),
          ],
    );

    blocTest<ItemListBloc, ItemListState>(
      '取得失敗 → [ItemListError]',
      setUp: () {
        when(() => repository.fetchItems()).thenAnswer(
          (_) async =>
              const Result.failure(ApiException(code: 'E500', message: 'boom')),
        );
      },
      build: () => ItemListBloc(repository: repository),
      act: (bloc) => bloc.add(const ItemListRequested()),
      expect:
          () => [
            isA<ItemListLoading>(),
            isA<ItemListError>().having(
              (s) => s.exception,
              'exception',
              isA<ApiException>(),
            ),
          ],
    );
  });
}
