import 'package:dartz/dartz.dart';
import 'package:golds_nuts/core/exeptions/failures.dart';
import 'package:golds_nuts/features/production/data/datasources/production_remote_data_source.dart';
import 'package:golds_nuts/features/production/data/models/production_model.dart';
import 'package:golds_nuts/features/production/domain/entities/production_entity.dart';
import 'package:golds_nuts/features/production/domain/repo/production_repository.dart';

class ProductionRepositoryImpl implements ProductionRepository {
  final ProductionRemoteDataSource remoteDataSource;

  ProductionRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, String>> addProduction({
    required ProductionEntity production,
  }) async {
    try {
      final productionModel = ProductionModel(
        id: production.id,
        workerId: production.workerId,
        workerName: production.workerName,
        date: production.date,
        items: production.items
            .map(
              (item) => ProductionItemModel(
            productId: item.productId,
            productName: item.productName,
            quantity: item.quantity,
            pricePerCarton: item.pricePerCarton,
            totalAmount: item.totalAmount,
          ),
        )
            .toList(),
        totalCartons: production.totalCartons,
        totalAmount: production.totalAmount,
        createdAt: production.createdAt,
      );

      final documentId = await remoteDataSource.addProduction(
        production: productionModel,
      );

      return Right(documentId);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProductionEntity>>> getMonthlyProductions({
    required DateTime month,
    String? workerId,
  }) async {
    try {
      final productions = await remoteDataSource.getMonthlyProductions(
        month: month,
        workerId: workerId,
      );

      return Right(productions);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

}
