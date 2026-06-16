import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../cubit/locale_cubit.dart';
import '../../features/admin/data/repositories/admin_repository_impl.dart';
import '../../features/admin/domain/repositories/admin_repository.dart';
import '../../features/admin/presentation/cubit/admin_cubit.dart';
import '../../features/cart/presentation/cubit/cart_cubit.dart';
import '../../features/checkout/data/repositories/checkout_repository_impl.dart';
import '../../features/checkout/domain/repositories/checkout_repository.dart';
import '../../features/checkout/presentation/cubit/checkout_cubit.dart';
import '../../features/home/data/datasources/home_local_datasource.dart';
import '../../features/home/data/datasources/home_remote_datasource.dart';
import '../../features/home/data/repositories/home_repository_impl.dart';
import '../../features/home/domain/repositories/home_repository.dart';
import '../../features/home/presentation/cubit/home_cubit.dart';

final getIt = GetIt.instance;

/// Registers all dependencies for the application.
/// Call this once in main.dart before runApp().
Future<void> configureDependencies() async {
  // ─── External ──────────────────────────────────────────────────────────────
  final sharedPrefs = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => sharedPrefs);
  getIt.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  // ─── Data Sources ──────────────────────────────────────────────────────────
  getIt.registerLazySingleton<HomeLocalDataSource>(
    () => HomeLocalDataSourceImpl(),
  );
  getIt.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSourceImpl(getIt<SupabaseClient>()),
  );

  // ─── Repositories ─────────────────────────────────────────────────────────
  getIt.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(
      getIt<HomeLocalDataSource>(),
      getIt<HomeRemoteDataSource>(),
      useRemote: true,
    ),
  );
  getIt.registerLazySingleton<AdminRepository>(
    () => AdminRepositoryImpl(getIt<SupabaseClient>()),
  );
  getIt.registerLazySingleton<CheckoutRepository>(
    () => CheckoutRepositoryImpl(getIt<SupabaseClient>()),
  );

  // ─── Cubits ───────────────────────────────────────────────────────────────
  // CartCubit is a singleton because it manages global cart state
  getIt.registerLazySingleton<CartCubit>(() => CartCubit());

  getIt.registerLazySingleton<LocaleCubit>(() => LocaleCubit(getIt<SharedPreferences>()));

  // HomeCubit is a factory because each home page gets a fresh instance
  getIt.registerFactory<HomeCubit>(
    () => HomeCubit(getIt<HomeRepository>()),
  );

  getIt.registerFactory<AdminCubit>(
    () => AdminCubit(getIt<AdminRepository>()),
  );

  getIt.registerFactory<CheckoutCubit>(
    () => CheckoutCubit(getIt<CheckoutRepository>()),
  );
}
