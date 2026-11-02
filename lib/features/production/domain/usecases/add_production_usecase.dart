import 'package:dartz/dartz.dart';
import 'package:golds_nuts/core/exeptions/failures.dart';
import 'package:golds_nuts/features/production/domain/entities/production_entity.dart';
import 'package:golds_nuts/features/production/domain/repo/production_repository.dart';

class AddProductionUseCase {
  final ProductionRepository repository;

  AddProductionUseCase({required this.repository});

  Future<Either<Failure, String>> call({
    required ProductionEntity production,
  }) async {
    return await repository.addProduction(production: production);
  }
}
