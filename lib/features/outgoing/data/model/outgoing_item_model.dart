import 'package:golds_nuts/features/outgoing/domain/entities/outgoing_item_entity.dart';

class OutgoingItemModel extends OutgoingItemEntity {
  const OutgoingItemModel({
    required super.productId,
    required super.productName,
    required super.quantity,
    required super.pricePerCarton,
    required super.totalAmount,
  });

  factory OutgoingItemModel.fromJson(Map<String, dynamic> json) {
    return OutgoingItemModel(
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      quantity: (json['quantity'] as num).toInt(),
      pricePerCarton: (json['pricePerCarton'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'pricePerCarton': pricePerCarton,
      'totalAmount': totalAmount,
    };
  }
}
