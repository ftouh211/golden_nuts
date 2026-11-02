
import 'package:dartz/dartz.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:golds_nuts/core/exeptions/failures.dart';
import 'package:golds_nuts/features/product/data/datasources/product_remote_data_source.dart';
import 'package:golds_nuts/features/product/domain/entities/product_entity.dart';
import 'package:golds_nuts/features/product/domain/repo/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;

  ProductRepositoryImpl({
    required this.remoteDataSource,
  });

  // Get Products
  @override
  Future<Either<Failure, List<ProductEntity>>> getProducts({
    bool activeOnly = false,
  }) async {
    try {
      final products = await remoteDataSource.getProducts(
        activeOnly: activeOnly,
      );

      return Right(products);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(
        e.message ?? 'Failed to get products',
      ));
    } catch (e) {
      return Left(ServerFailure('Something went wrong'));
    }
  }

  // Add Product
  @override
  Future<Either<Failure, Unit>> addProduct({
    required String name,
    required double pricePerCarton,
  }) async {
    try {
      await remoteDataSource.addProduct(
        name: name,
        pricePerCarton: pricePerCarton,
      );

      return const Right(unit);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(
        e.message ?? 'Failed to add product',
      ));
    } catch (e) {
      return Left(ServerFailure('Something went wrong'));
    }
  }

  // Update Product
  @override
  Future<Either<Failure, Unit>> updateProduct({
    required String productId,
    required String name,
    required double pricePerCarton,
  }) async {
    try {
      await remoteDataSource.updateProduct(
        productId: productId,
        name: name,
        pricePerCarton: pricePerCarton,
      );

      return const Right(unit);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(
        e.message ?? 'Failed to update product',
      ));
    } catch (e) {
      return Left(ServerFailure('Something went wrong'));
    }
  }

  // Activate Product
  @override
  Future<Either<Failure, Unit>> activateProduct(
      String productId,
      ) async {
    try {
      await remoteDataSource.activateProduct(productId);

      return const Right(unit);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(
        e.message ?? 'Failed to activate product',
      ));
    } catch (e) {
      return Left(ServerFailure('Something went wrong'));
    }
  }

  // Deactivate Product
  @override
  Future<Either<Failure, Unit>> deactivateProduct(
      String productId,
      ) async {
    try {
      await remoteDataSource.deactivateProduct(productId);

      return const Right(unit);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(
        e.message ?? 'Failed to deactivate product',
      ));
    } catch (e) {
      return Left(ServerFailure('Something went wrong'));
    }
  }

  // Delete Product
  @override
  Future<Either<Failure, Unit>> deleteProduct(
      String productId,
      ) async {
    try {
      await remoteDataSource.deleteProduct(productId);

      return const Right(unit);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(
        e.message ?? 'Failed to delete product',
      ));
    } catch (e) {
      return Left(ServerFailure('Something went wrong'));
    }
  }
}
