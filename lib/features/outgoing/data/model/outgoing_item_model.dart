
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
    final quantity = (json['quantity'] as num).toInt();

    // Cloud Function saves the total item amount as orderAmount.
    final totalAmount = (json['orderAmount'] as num).toDouble();

    return OutgoingItemModel(
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      quantity: quantity,
      totalAmount: totalAmount,
      pricePerCarton: quantity > 0 ? totalAmount / quantity : 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'orderAmount': totalAmount,
    };
  }
}
