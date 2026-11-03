import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/inventory_entity.dart';

class InventoryModel extends InventoryEntity {
  const InventoryModel({
    required super.productId,
    required super.totalProduced,
    required super.totalOutgoing,
    required super.availableQuantity,
    super.updatedAt,
  });

  factory InventoryModel.fromFirestore(
      Map<String, dynamic> json,
      String productId,
      ) {
    final timestamp = json['updatedAt'];

    return InventoryModel(
      productId: productId,
      totalProduced: (json['totalProduced'] as num?)?.toInt() ?? 0,
      totalOutgoing: (json['totalOutgoing'] as num?)?.toInt() ?? 0,
      availableQuantity:
      (json['availableQuantity'] as num?)?.toInt() ?? 0,
      updatedAt: timestamp is Timestamp ? timestamp.toDate() : null,
    );
  }
}