import 'package:dartz/dartz.dart';
import 'package:golds_nuts/core/exeptions/failures.dart';

import '../entities/inventory_entity.dart';

abstract class InventoryRepository {
  Future<Either<Failure, List<InventoryEntity>>> getInventoryBalances();
}