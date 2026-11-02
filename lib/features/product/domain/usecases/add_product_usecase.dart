
import 'package:dartz/dartz.dart';

import 'package:golds_nuts/core/exeptions/failures.dart';
import 'package:golds_nuts/features/product/domain/repo/product_repository.dart';

class AddProductUseCase {
  final ProductRepository repository;

  AddProductUseCase({
    required this.repository,
  });

  Future<Either<Failure, Unit>> call({
    required String name,
    required double pricePerCarton,
  }) {
    return repository.addProduct(
      name: name,
      pricePerCarton: pricePerCarton,
    );
  }
}
