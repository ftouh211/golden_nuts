import 'package:dartz/dartz.dart';
import 'package:golds_nuts/core/exeptions/failures.dart';
import 'package:golds_nuts/features/inventory/domain/entities/inventory_entity.dart';
import 'package:golds_nuts/features/inventory/domain/repo/inventory_repository.dart';

class GetInventoryUseCase {
  final InventoryRepository repository;

  GetInventoryUseCase({required this.repository});

  Future<Either<Failure, List<InventoryEntity>>> call() async {
    return await repository.getInventoryBalances();
  }
}
