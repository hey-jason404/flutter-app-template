import 'package:bloc/bloc.dart';
import 'package:home/src/domain/repositories/item_repository.dart';
import 'package:home/src/presentation/blocs/item_list/item_list_event.dart';
import 'package:home/src/presentation/blocs/item_list/item_list_state.dart';

/// 項目清單頁的 bloc(spec §4.2 典範實作:純 Dart,不 import Flutter)。
class ItemListBloc extends Bloc<ItemListEvent, ItemListState> {
  /// 以 [repository] 建立。
  ItemListBloc({required ItemRepository repository})
    : _repository = repository,
      super(const ItemListLoading()) {
    on<ItemListRequested>(_onItemListRequested);
  }

  final ItemRepository _repository;

  Future<void> _onItemListRequested(
    ItemListRequested event,
    Emitter<ItemListState> emit,
  ) async {
    emit(const ItemListLoading());
    final result = await _repository.fetchItems();
    result.fold(
      onSuccess: (items) => emit(ItemListLoaded(items)),
      onFailure: (exception) => emit(ItemListError(exception)),
    );
  }
}
