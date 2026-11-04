import 'package:equatable/equatable.dart';
import 'package:golds_nuts/features/notifications/domain/entities/notification_entity.dart';

abstract class NotificationsEvent extends Equatable {
  const NotificationsEvent();

  @override
  List<Object?> get props => [];
}

class WatchNotificationsEvent extends NotificationsEvent {
  final String receiverId;

  const WatchNotificationsEvent({
    required this.receiverId,
  });

  @override
  List<Object?> get props => [receiverId];
}

class NotificationsUpdatedEvent extends NotificationsEvent {
  final List<NotificationEntity> notifications;

  const NotificationsUpdatedEvent({
    required this.notifications,
  });

  @override
  List<Object?> get props => [notifications];
}

class NotificationsFailedEvent extends NotificationsEvent {
  final String message;

  const NotificationsFailedEvent({
    required this.message,
  });

  @override
  List<Object?> get props => [message];
}