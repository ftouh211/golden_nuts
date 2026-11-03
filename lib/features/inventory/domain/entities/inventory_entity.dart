import 'package:equatable/equatable.dart';

class InventoryEntity extends Equatable {
  final String productId;
  final int totalProduced;
  final int totalOutgoing;
  final int availableQuantity;
  final DateTime? updatedAt;

  const InventoryEntity({
    required this.productId,
    required this.totalProduced,
    required this.totalOutgoing,
    required this.availableQuantity,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    productId,
    totalProduced,
    totalOutgoing,
    availableQuantity,
    updatedAt,
  ];
}