import 'package:equatable/equatable.dart';

class ProductionItemEntity extends Equatable {
  final String productId;
  final String productName;
  final int quantity;
  final double pricePerCarton;
  final double totalAmount;

  const ProductionItemEntity({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.pricePerCarton,
    required this.totalAmount,
  });

  @override
  List<Object?> get props => [
    productId,
    productName,
    quantity,
    pricePerCarton,
    totalAmount,
  ];
}

class ProductionEntity extends Equatable {
  final String id;
  final String workerId;
  final String workerName;
  final DateTime date;
  final List<ProductionItemEntity> items;
  final int totalCartons;
  final double totalAmount;
  final DateTime createdAt;

  const ProductionEntity({
    required this.id,
    required this.workerId,
    required this.workerName,
    required this.date,
    required this.items,
    required this.totalCartons,
    required this.totalAmount,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    workerId,
    workerName,
    date,
    items,
    totalCartons,
    totalAmount,
    createdAt,
  ];
}
