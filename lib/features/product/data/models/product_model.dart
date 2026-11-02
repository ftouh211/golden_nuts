
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:golds_nuts/features/product/domain/entities/product_entity.dart';


class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.name,
    required super.pricePerCarton,
    required super.isActive,
    super.createdAt,
  });

  // From Firestore
  factory ProductModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> document,
      ) {
    final data = document.data() ?? {};

    return ProductModel(
      id: document.id,
      name: data['name'] ?? '',
      pricePerCarton:
      (data['pricePerCarton'] as num? ?? 0).toDouble(),
      isActive: data['isActive'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  // To Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'pricePerCarton': pricePerCarton,
      'isActive': isActive,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
