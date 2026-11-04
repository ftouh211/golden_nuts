import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:golds_nuts/features/notifications/domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.receiverId,
    required super.workerId,
    required super.workerName,
    required super.title,
    required super.body,
    required super.totalCartons,
    required super.totalAmount,
    required super.productionId,
    required super.isRead,
    required super.createdAt,
  });

  factory NotificationModel.fromMap(
      String id,
      Map<String, dynamic> map,
      ) {
    return NotificationModel(
      id: id,
      receiverId: map['receiverId'] as String,
      workerId: map['workerId'] as String,
      workerName: map['workerName'] as String,
      title: map['title'] as String,
      body: map['body'] as String,
      totalCartons: (map['totalCartons'] as num).toInt(),
      totalAmount: (map['totalAmount'] as num).toDouble(),
      productionId: map['productionId'] as String,
      isRead: map['isRead'] as bool? ?? false,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'receiverId': receiverId,
      'workerId': workerId,
      'workerName': workerName,
      'title': title,
      'body': body,
      'totalCartons': totalCartons,
      'totalAmount': totalAmount,
      'productionId': productionId,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}