import 'outgoing_item_entity.dart';

class OutgoingEntity {
  final String id;
  final String recordNumber;

  final DateTime date;
  final String deliveredBy;
  final String receivedBy;
  final String direction;

  final List<OutgoingItemEntity> items;

  final int totalCartons;
  final double totalAmount;

  final DateTime createdAt;
  final String createdBy;

  const OutgoingEntity({
    required this.id,
    required this.recordNumber,
    required this.date,
    required this.deliveredBy,
    required this.receivedBy,
    required this.direction,
    required this.items,
    required this.totalCartons,
    required this.totalAmount,
    required this.createdAt,
    required this.createdBy,
  });
}
