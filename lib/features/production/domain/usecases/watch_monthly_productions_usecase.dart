import 'package:dartz/dartz.dart';
import 'package:golds_nuts/core/exeptions/failures.dart';
import 'package:golds_nuts/features/production/domain/entities/production_entity.dart';
import 'package:golds_nuts/features/production/domain/repo/production_repository.dart';

class WatchMonthlyProductionsUseCase {
  final ProductionRepository repository;

  WatchMonthlyProductionsUseCase({required this.repository});

  Stream<Either<Failure, List<ProductionEntity>>> call({
    required DateTime month,
    String? workerId,
  }) {
    return repository.watchMonthlyProductions(
      month: month,
      workerId: workerId,
    );
  }
}