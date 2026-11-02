import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:golds_nuts/features/production/domain/entities/production_entity.dart';

class ProductionItemModel extends ProductionItemEntity {
  const ProductionItemModel({
    required super.productId,
    required super.productName,
    required super.quantity,
    required super.pricePerCarton,
    required super.totalAmount,
  });

  factory ProductionItemModel.fromMap(Map<String, dynamic> map) {
    return ProductionItemModel(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      quantity: (map['quantity'] as num).toInt(),
      pricePerCarton: (map['pricePerCarton'] as num).toDouble(),
      totalAmount: (map['totalAmount'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'pricePerCarton': pricePerCarton,
      'totalAmount': totalAmount,
    };
  }
}

class ProductionModel extends ProductionEntity {
  const ProductionModel({
    required super.id,
    required super.workerId,
    required super.workerName,
    required List<ProductionItemModel> items,
    required super.date,
    required super.totalCartons,
    required super.totalAmount,
    required super.createdAt,
  }) : super(items: items);

  factory ProductionModel.fromMap(
      String id,
      Map<String, dynamic> map,
      ) {
    return ProductionModel(
      id: id,
      workerId: map['workerId'] ?? '',
      workerName: map['workerName'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      items: (map['items'] as List)
          .map(
            (item) => ProductionItemModel.fromMap(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList(),
      totalCartons: (map['totalCartons'] as num).toInt(),
      totalAmount: (map['totalAmount'] as num).toDouble(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'workerId': workerId,
      'workerName': workerName,
      'date': Timestamp.fromDate(date),
      'items': items.map((item) {
        return {
          'productId': item.productId,
          'productName': item.productName,
          'quantity': item.quantity,
          'pricePerCarton': item.pricePerCarton,
          'totalAmount': item.totalAmount,
        };
      }).toList(),
      'totalCartons': totalCartons,
      'totalAmount': totalAmount,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
