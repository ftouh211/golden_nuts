import 'package:dartz/dartz.dart';
import 'package:golds_nuts/core/exeptions/failures.dart';
import 'package:golds_nuts/features/product/domain/repo/worker_repository.dart';

class CreateWorkerUseCase {
  final WorkerRepository repository;

  CreateWorkerUseCase({
    required this.repository,
  });

  Future<Either<Failure, void>> call({
    required String name,
    required String email,
    required String password,
  }) {
    return repository.createWorker(
      name: name,
      email: email,
      password: password,
    );
  }
}