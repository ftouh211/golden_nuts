
import 'package:dartz/dartz.dart';

import 'package:golds_nuts/core/exeptions/failures.dart';
import 'package:golds_nuts/features/product/domain/entities/product_entity.dart';

abstract class ProductRepository {
  // Get Products
  Future<Either<Failure, List<ProductEntity>>> getProducts({
    bool activeOnly = false,
  });

  // Add Product
  Future<Either<Failure, Unit>> addProduct({
    required String name,
    required double pricePerCarton,
  });

  // Update Product
  Future<Either<Failure, Unit>> updateProduct({
    required String productId,
    required String name,
    required double pricePerCarton,
  });

  // Activate Product
  Future<Either<Failure, Unit>> activateProduct(String productId);

  // Deactivate Product
  Future<Either<Failure, Unit>> deactivateProduct(String productId);

  // Delete Product
  Future<Either<Failure, Unit>> deleteProduct(String productId);
}
