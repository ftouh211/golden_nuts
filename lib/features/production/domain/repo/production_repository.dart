
import 'package:dartz/dartz.dart';
import 'package:golds_nuts/core/exeptions/failures.dart';
import 'package:golds_nuts/features/production/domain/entities/production_entity.dart';

abstract class ProductionRepository {
  Future<Either<Failure, String>> addProduction({
    required ProductionEntity production,
  });

  Future<Either<Failure, List<ProductionEntity>>> getMonthlyProductions({
    required DateTime month,
    String? workerId,
  });
}
