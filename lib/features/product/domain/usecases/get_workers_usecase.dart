
import 'package:dartz/dartz.dart';
import 'package:golds_nuts/core/exeptions/failures.dart';
import 'package:golds_nuts/features/auth/domain/entities/user_entity.dart';
import 'package:golds_nuts/features/product/domain/repo/worker_repository.dart';

class GetWorkersUseCase {
  final WorkerRepository repository;

  GetWorkersUseCase({
    required this.repository,
  });

  Future<Either<Failure, List<UserEntity>>> call() async {
    return await repository.getWorkers();
  }
}
