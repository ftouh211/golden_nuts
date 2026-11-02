
import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  final String id;
  final String name;
  final double pricePerCarton;
  final bool isActive;
  final DateTime? createdAt;

  const ProductEntity({
    required this.id,
    required this.name,
    required this.pricePerCarton,
    required this.isActive,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    pricePerCarton,
    isActive,
    createdAt,
  ];
}
