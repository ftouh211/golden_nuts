
import 'package:dartz/dartz.dart';
import 'package:golds_nuts/core/exeptions/failures.dart';
import 'package:golds_nuts/features/auth/domain/entities/user_entity.dart';

abstract class WorkerRepository {
  // Create Worker
  Future<Either<Failure, void>> createWorker({
    required String name,
    required String email,
    required String password,
  });

  // Get Workers
  Future<Either<Failure, List<UserEntity>>> getWorkers();

  Future<Either<Failure, Unit>> updateWorkerStatus({
    required String workerId,
    required bool isActive,
  });
}
