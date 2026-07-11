import 'package:bloc/bloc.dart';
import 'package:home/src/domain/repositories/item_repository.dart';
import 'package:home/src/presentation/blocs/item_detail/item_detail_event.dart';
import 'package:home/src/presentation/blocs/item_detail/item_detail_state.dart';

/// 項目詳情頁的 bloc(spec §4.2 典範實作:純 Dart,不 import Flutter)。
class ItemDetailBloc extends Bloc<ItemDetailEvent, ItemDetailState> {
  /// 以 [repository] 建立。
  ItemDetailBloc({required ItemRepository repository})
    : _repository = repository,
      super(const ItemDetailLoading()) {
    on<ItemDetailRequested>(_onItemDetailRequested);
  }

  final ItemRepository _repository;

  Future<void> _onItemDetailRequested(
    ItemDetailRequested event,
    Emitter<ItemDetailState> emit,
  ) async {
    final result = await _repository.fetchItem(event.id);
    result.fold(
      onSuccess: (item) => emit(ItemDetailLoaded(item)),
      onFailure: (exception) => emit(ItemDetailError(exception)),
    );
  }
}
