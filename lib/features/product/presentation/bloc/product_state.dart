import 'package:equatable/equatable.dart';
import 'package:golds_nuts/features/product/domain/entities/product_entity.dart';

abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

// Initial
class ProductInitial extends ProductState {
  const ProductInitial();
}

// Initial Products Loading
class ProductLoading extends ProductState {
  const ProductLoading();
}

// Products Loaded + Operations Status
class ProductsLoaded extends ProductState {
  final List<ProductEntity> products;

  // Is an operation currently running?
  final bool isProcessing;

  // Success or error message for the last operation
  final String? operationMessage;
  final String? operationError;

  const ProductsLoaded({
    required this.products,
    this.isProcessing = false,
    this.operationMessage,
    this.operationError,
  });

  @override
  List<Object?> get props => [
    products,
    isProcessing,
    operationMessage,
    operationError,
  ];
}

// Failure while loading products
class ProductFailure extends ProductState {
  final String message;

  const ProductFailure(this.message);

  @override
  List<Object?> get props => [message];
}
