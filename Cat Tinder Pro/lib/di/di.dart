import 'package:get_it/get_it.dart';
import '../services/cat_api_service.dart';
import '../presentation/bloc/liked_cats_cubit.dart';

final getIt = GetIt.instance;

void setupDI() {
  getIt.registerSingleton<CatApiService>(CatApiService());
  getIt.registerSingleton<LikedCatsCubit>(LikedCatsCubit());
}
