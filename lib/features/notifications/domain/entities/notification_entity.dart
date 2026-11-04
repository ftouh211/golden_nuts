import 'package:equatable/equatable.dart';

class NotificationEntity extends Equatable {
  final String id;
  final String receiverId;
  final String workerId;
  final String workerName;
  final String title;
  final String body;
  final int totalCartons;
  final double totalAmount;
  final String productionId;
  final bool isRead;
  final DateTime createdAt;

  const NotificationEntity({
    required this.id,
    required this.receiverId,
    required this.workerId,
    required this.workerName,
    required this.title,
    required this.body,
    required this.totalCartons,
    required this.totalAmount,
    required this.productionId,
    required this.isRead,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    receiverId,
    workerId,
    workerName,
    title,
    body,
    totalCartons,
    totalAmount,
    productionId,
    isRead,
    createdAt,
  ];
}