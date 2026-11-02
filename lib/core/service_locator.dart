import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:golds_nuts/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:golds_nuts/features/auth/data/datasources/user_remote_data_source.dart';
import 'package:golds_nuts/features/auth/domain/repo/auth_repo.dart';
import 'package:golds_nuts/features/auth/domain/repo/auth_repository_impl.dart';
import 'package:golds_nuts/features/auth/domain/usecases/login_usecase.dart';
import 'package:golds_nuts/features/auth/domain/usecases/logout_usecase.dart';
import 'package:golds_nuts/features/auth/presentation/bloc/login/login_bloc.dart';
import 'package:golds_nuts/features/auth/presentation/bloc/logout/logout_bloc.dart';
import 'package:golds_nuts/features/product/data/datasources/product_remote_data_source.dart';
import 'package:golds_nuts/features/product/data/datasources/worker_remote_data_source.dart';
import 'package:golds_nuts/features/product/domain/repo/product_repository.dart';
import 'package:golds_nuts/features/product/domain/repo/product_repository_impl.dart';
import 'package:golds_nuts/features/product/domain/repo/worker_repository.dart';
import 'package:golds_nuts/features/product/domain/repo/worker_repository_impl.dart';
import 'package:golds_nuts/features/product/domain/usecases/activate_product_usecase.dart';
import 'package:golds_nuts/features/product/domain/usecases/add_product_usecase.dart';
import 'package:golds_nuts/features/product/domain/usecases/create_worker_usecase.dart';
import 'package:golds_nuts/features/product/domain/usecases/deactivate_product_usecase.dart';
import 'package:golds_nuts/features/product/domain/usecases/delete_product_usecase.dart';
import 'package:golds_nuts/features/product/domain/usecases/get_products_usecase.dart';
import 'package:golds_nuts/features/product/domain/usecases/get_workers_usecase.dart';
import 'package:golds_nuts/features/product/domain/usecases/update_product_usecase.dart';
import 'package:golds_nuts/features/product/domain/usecases/update_worker_status_use_case.dart';
import 'package:golds_nuts/features/product/presentation/bloc/product_bloc.dart';
import 'package:golds_nuts/features/product/presentation/bloc/worker/create_worker/create_worker_bloc.dart';
import 'package:golds_nuts/features/product/presentation/bloc/worker/get_worker/get_workers_bloc.dart';
import 'package:golds_nuts/features/product/presentation/bloc/worker/update_worker_status/update_worker_status_bloc.dart';
import 'package:golds_nuts/features/production/data/datasources/production_remote_data_source.dart';
import 'package:golds_nuts/features/production/domain/repo/production_repository.dart';
import 'package:golds_nuts/features/production/domain/repo/production_repository_impl.dart';
import 'package:golds_nuts/features/production/domain/usecases/add_production_usecase.dart';
import 'package:golds_nuts/features/production/domain/usecases/get_monthly_productions_usecase.dart';
import 'package:golds_nuts/features/production/presentation/bloc/production/add_production/add_production_bloc.dart';
import 'package:golds_nuts/features/production/presentation/bloc/production/get_monthly_productions/get_monthly_productions_bloc.dart';

final sl = GetIt.instance;

void setupDependencies() {
  // Firebase Authentication
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);

  // Cloud Firestore
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(firebaseAuth: sl<FirebaseAuth>()),
  );

  sl.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSource(firestore: sl<FirebaseFirestore>()),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      authRemoteDataSource: sl<AuthRemoteDataSource>(),
      userRemoteDataSource: sl<UserRemoteDataSource>(),
    ),
  );

  sl.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(repository: sl<AuthRepository>()),
  );
  // Bloc
  sl.registerFactory<LoginBloc>(() => LoginBloc(sl<LoginUseCase>()));


  // Logout
  sl.registerLazySingleton<LogoutUseCase>(
        () => LogoutUseCase(repository: sl<AuthRepository>()),
  );

  sl.registerFactory<LogoutBloc>(
        () => LogoutBloc(logoutUseCase: sl<LogoutUseCase>()),
  );
  // ================= Product Feature =================

  // Data Source
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSource(firestore: sl<FirebaseFirestore>()),
  );

  // Repository
  sl.registerLazySingleton<ProductRepository>(
    () =>
        ProductRepositoryImpl(remoteDataSource: sl<ProductRemoteDataSource>()),
  );

  // Use Cases
  sl.registerLazySingleton<GetProductsUseCase>(
    () => GetProductsUseCase(repository: sl<ProductRepository>()),
  );

  sl.registerLazySingleton<AddProductUseCase>(
    () => AddProductUseCase(repository: sl<ProductRepository>()),
  );

  sl.registerLazySingleton<UpdateProductUseCase>(
    () => UpdateProductUseCase(repository: sl<ProductRepository>()),
  );

  sl.registerLazySingleton<DeactivateProductUseCase>(
    () => DeactivateProductUseCase(repository: sl<ProductRepository>()),
  );

  sl.registerLazySingleton<ActivateProductUseCase>(
    () => ActivateProductUseCase(repository: sl<ProductRepository>()),
  );

  sl.registerLazySingleton<DeleteProductUseCase>(
    () => DeleteProductUseCase(repository: sl<ProductRepository>()),
  );
  sl.registerFactory<ProductBloc>(
    () => ProductBloc(
      getProductsUseCase: sl<GetProductsUseCase>(),
      addProductUseCase: sl<AddProductUseCase>(),
      updateProductUseCase: sl<UpdateProductUseCase>(),
      activateProductUseCase: sl<ActivateProductUseCase>(),
      deactivateProductUseCase: sl<DeactivateProductUseCase>(),
      deleteProductUseCase: sl<DeleteProductUseCase>(),
    ),
  );

  // ================= Worker Feature =================

  // Data Source
  sl.registerLazySingleton<WorkerRemoteDataSource>(
    () => WorkerRemoteDataSource(
      firebaseFunctions: FirebaseFunctions.instanceFor(region: 'us-central1'),
    ),
  );

  // Repository
  sl.registerLazySingleton<WorkerRepository>(
    () => WorkerRepositoryImpl(
      remoteDataSource: sl<WorkerRemoteDataSource>(),
      userRemoteDataSource: sl<UserRemoteDataSource>(),
    ),
  );

  sl.registerLazySingleton(
        () => UpdateWorkerStatusUseCase(
      repository: sl(),
    ),
  );

  sl.registerFactory(
        () => UpdateWorkerStatusBloc(
      updateWorkerStatusUseCase: sl(),
    ),
  );
  // Use Case
  sl.registerLazySingleton<CreateWorkerUseCase>(
    () => CreateWorkerUseCase(repository: sl<WorkerRepository>()),
  );

  // Bloc
  sl.registerFactory<CreateWorkerBloc>(
    () => CreateWorkerBloc(createWorkerUseCase: sl<CreateWorkerUseCase>()),
  );

  sl.registerLazySingleton<GetWorkersUseCase>(
    () => GetWorkersUseCase(repository: sl<WorkerRepository>()),
  );

  sl.registerFactory<GetWorkersBloc>(
    () => GetWorkersBloc(getWorkersUseCase: sl<GetWorkersUseCase>()),
  );

  // ================= Production Feature =================

  // Data Source
  sl.registerLazySingleton<ProductionRemoteDataSource>(
        () => ProductionRemoteDataSource(
      firestore: sl<FirebaseFirestore>(),
    ),
  );

  // Repository
  sl.registerLazySingleton<ProductionRepository>(
        () => ProductionRepositoryImpl(
      remoteDataSource: sl<ProductionRemoteDataSource>(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton<AddProductionUseCase>(
        () => AddProductionUseCase(
      repository: sl<ProductionRepository>(),
    ),
  );

  sl.registerLazySingleton<GetMonthlyProductionsUseCase>(
        () => GetMonthlyProductionsUseCase(
      repository: sl<ProductionRepository>(),
    ),
  );

  // Blocs
  sl.registerFactory<AddProductionBloc>(
        () => AddProductionBloc(
      addProductionUseCase: sl<AddProductionUseCase>(),
    ),
  );

  sl.registerFactory<GetMonthlyProductionsBloc>(
        () => GetMonthlyProductionsBloc(
      getMonthlyProductionsUseCase:
      sl<GetMonthlyProductionsUseCase>(),
    ),
  );


}
