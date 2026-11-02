
import 'package:equatable/equatable.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

// Get Products
class GetProductsEvent extends ProductEvent {
  final bool activeOnly;

  const GetProductsEvent({
    this.activeOnly = false,
  });

  @override
  List<Object?> get props => [activeOnly];
}

// Add Product
class AddProductEvent extends ProductEvent {
  final String name;
  final double pricePerCarton;

  const AddProductEvent({
    required this.name,
    required this.pricePerCarton,
  });

  @override
  List<Object?> get props => [name, pricePerCarton];
}

// Update Product
class UpdateProductEvent extends ProductEvent {
  final String productId;
  final String name;
  final double pricePerCarton;

  const UpdateProductEvent({
    required this.productId,
    required this.name,
    required this.pricePerCarton,
  });

  @override
  List<Object?> get props => [
    productId,
    name,
    pricePerCarton,
  ];
}

// Deactivate Product
class DeactivateProductEvent extends ProductEvent {
  final String productId;

  const DeactivateProductEvent({
    required this.productId,
  });

  @override
  List<Object?> get props => [productId];
}

// Activate Product
class ActivateProductEvent extends ProductEvent {
  final String productId;

  const ActivateProductEvent({
    required this.productId,
  });

  @override
  List<Object?> get props => [productId];
}

// Delete Product
class DeleteProductEvent extends ProductEvent {
  final String productId;

  const DeleteProductEvent({
    required this.productId,
  });

  @override
  List<Object?> get props => [productId];
}
