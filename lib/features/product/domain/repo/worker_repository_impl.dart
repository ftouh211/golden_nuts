
import 'package:dartz/dartz.dart';
import 'package:golds_nuts/core/exeptions/failures.dart';
import 'package:golds_nuts/features/auth/domain/entities/user_entity.dart';
import 'package:golds_nuts/features/auth/data/datasources/user_remote_data_source.dart';
import 'package:golds_nuts/features/product/domain/repo/worker_repository.dart';

import '../../data/datasources/worker_remote_data_source.dart';

class WorkerRepositoryImpl implements WorkerRepository {
  final WorkerRemoteDataSource remoteDataSource;
  final UserRemoteDataSource userRemoteDataSource;

  WorkerRepositoryImpl({
    required this.remoteDataSource,
    required this.userRemoteDataSource,
  });

  @override
  Future<Either<Failure, void>> createWorker({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      await remoteDataSource.createWorker(
        name: name,
        email: email,
        password: password,
      );

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<UserEntity>>> getWorkers() async {
    try {
      final workers = await userRemoteDataSource.getWorkers();

      return Right(workers);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateWorkerStatus({
    required String workerId,
    required bool isActive,
  }) async {
    try {
      await remoteDataSource.updateWorkerStatus(
        workerId: workerId,
        isActive: isActive,
      );

      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
