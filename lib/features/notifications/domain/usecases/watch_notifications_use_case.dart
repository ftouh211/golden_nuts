import 'package:dartz/dartz.dart';

import 'package:golds_nuts/core/exeptions/failures.dart';
import 'package:golds_nuts/features/notifications/domain/entities/notification_entity.dart';
import 'package:golds_nuts/features/notifications/domain/repo/notification_repository.dart';

class WatchNotificationsUseCase {
  final NotificationRepository repository;

  WatchNotificationsUseCase({
    required this.repository,
  });

  Stream<Either<Failure, List<NotificationEntity>>> call({
    required String receiverId,
  }) {
    return repository.watchNotifications(
      receiverId: receiverId,
    );
  }
}