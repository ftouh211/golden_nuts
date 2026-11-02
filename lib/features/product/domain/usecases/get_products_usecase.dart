
import 'package:dartz/dartz.dart';

import 'package:golds_nuts/core/exeptions/failures.dart';
import 'package:golds_nuts/features/product/domain/entities/product_entity.dart';
import 'package:golds_nuts/features/product/domain/repo/product_repository.dart';


class GetProductsUseCase {
  final ProductRepository repository;

  GetProductsUseCase({
    required this.repository,
  });

  Future<Either<Failure, List<ProductEntity>>> call({
    bool activeOnly = false,
  }) {
    return repository.getProducts(
      activeOnly: activeOnly,
    );
  }
}
