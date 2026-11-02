
import 'package:dartz/dartz.dart';
import 'package:golds_nuts/core/exeptions/failures.dart';
import 'package:golds_nuts/features/production/domain/entities/production_entity.dart';
import 'package:golds_nuts/features/production/domain/repo/production_repository.dart';

class GetMonthlyProductionsUseCase {
  final ProductionRepository repository;

  GetMonthlyProductionsUseCase({
    required this.repository,
  });

  Future<Either<Failure, List<ProductionEntity>>> call({
    required DateTime month,
    String? workerId,
  }) async {
    return await repository.getMonthlyProductions(
      month: month,
      workerId: workerId,
    );
  }
}
