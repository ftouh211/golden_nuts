import 'package:dartz/dartz.dart';

import 'package:golds_nuts/core/exeptions/failures.dart';
import 'package:golds_nuts/features/product/domain/repo/product_repository.dart';

class DeleteProductUseCase {
  final ProductRepository repository;

  DeleteProductUseCase({
    required this.repository,
  });

  Future<Either<Failure, Unit>> call(String productId) {
    return repository.deleteProduct(productId);
  }
}