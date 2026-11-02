import 'package:dartz/dartz.dart';
import 'package:golds_nuts/core/exeptions/failures.dart';
import 'package:golds_nuts/features/product/domain/repo/worker_repository.dart';

class UpdateWorkerStatusUseCase {
  final WorkerRepository repository;

  UpdateWorkerStatusUseCase({
    required this.repository,
  });

  Future<Either<Failure, Unit>> call({
    required String workerId,
    required bool isActive,
  }) {
    return repository.updateWorkerStatus(
      workerId: workerId,
      isActive: isActive,
    );
  }
}