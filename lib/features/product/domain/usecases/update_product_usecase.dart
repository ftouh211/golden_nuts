
import 'package:dartz/dartz.dart';

import 'package:golds_nuts/core/exeptions/failures.dart';
import 'package:golds_nuts/features/product/domain/repo/product_repository.dart';

class UpdateProductUseCase {
  final ProductRepository repository;

  UpdateProductUseCase({
    required this.repository,
  });

  Future<Either<Failure, Unit>> call({
    required String productId,
    required String name,
    required double pricePerCarton,
  }) {
    return repository.updateProduct(
      productId: productId,
      name: name,
      pricePerCarton: pricePerCarton,
    );
  }
}
