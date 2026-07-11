import 'package:get_it/get_it.dart';
import 'package:home/src/data/repositories/item_repository_impl.dart';
import 'package:home/src/domain/repositories/item_repository.dart';
import 'package:home/src/presentation/blocs/item_detail/item_detail_bloc.dart';
import 'package:home/src/presentation/blocs/item_list/item_list_bloc.dart';
import 'package:networking/networking.dart';

/// 註冊 home feature 的依賴(供 app 以 `{{feature-registry}}` 插入)。
void registerHomeFeature(GetIt gi) {
  gi
    ..registerLazySingleton<ItemRepository>(
      () => ItemRepositoryImpl(gi<ApiClient>()),
    )
    ..registerFactory<ItemListBloc>(
      () => ItemListBloc(repository: gi<ItemRepository>()),
    )
    ..registerFactory<ItemDetailBloc>(
      () => ItemDetailBloc(repository: gi<ItemRepository>()),
    );
}
