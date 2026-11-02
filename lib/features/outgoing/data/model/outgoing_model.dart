import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:golds_nuts/features/outgoing/domain/entities/outgoing_entity.dart';

import 'outgoing_item_model.dart';

class OutgoingModel extends OutgoingEntity {
  const OutgoingModel({
    required super.id,
    required super.recordNumber,
    required super.date,
    required super.deliveredBy,
    required super.receivedBy,
    required super.direction,
    required super.items,
    required super.totalCartons,
    required super.totalAmount,
    required super.createdAt,
    required super.createdBy,
  });

  factory OutgoingModel.fromJson(
      Map<String, dynamic> json,
      String documentId,
      ) {
    return OutgoingModel(
      id: documentId,
      recordNumber: json['recordNumber'] as String,
      date: (json['date'] as Timestamp).toDate(),
      deliveredBy: json['deliveredBy'] as String,
      receivedBy: json['receivedBy'] as String,
      direction: json['direction'] as String,
      items: (json['items'] as List<dynamic>)
          .map(
            (item) => OutgoingItemModel.fromJson(
          Map<String, dynamic>.from(item as Map),
        ),
      )
          .toList(),
      totalCartons: (json['totalCartons'] as num).toInt(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      createdBy: json['createdBy'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recordNumber': recordNumber,
      'date': Timestamp.fromDate(date),
      'deliveredBy': deliveredBy,
      'receivedBy': receivedBy,
      'direction': direction,
      'items': items
          .map((item) => OutgoingItemModel(
        productId: item.productId,
        productName: item.productName,
        quantity: item.quantity,
        pricePerCarton: item.pricePerCarton,
        totalAmount: item.totalAmount,
      ).toJson())
          .toList(),
      'totalCartons': totalCartons,
      'totalAmount': totalAmount,
      'createdAt': Timestamp.fromDate(createdAt),
      'createdBy': createdBy,
    };
  }
}