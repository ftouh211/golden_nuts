import 'package:dartz/dartz.dart';
import 'package:golds_nuts/core/exeptions/failures.dart';
import 'package:golds_nuts/features/inventory/data/datasources/inventory_remote_data_source.dart';
import 'package:golds_nuts/features/inventory/domain/entities/inventory_entity.dart';
import 'package:golds_nuts/features/inventory/domain/repo/inventory_repository.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  final InventoryRemoteDataSource remoteDataSource;

  InventoryRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, List<InventoryEntity>>>
  getInventoryBalances() async {
    try {
      final inventoryList =
      await remoteDataSource.getInventoryBalances();

      return Right(inventoryList);
    } catch (e) {
      return Left(
        ServerFailure('Something went wrong. Please try again.'),
      );
    }
  }
}