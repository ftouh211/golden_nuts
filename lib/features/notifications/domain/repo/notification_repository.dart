import 'package:dartz/dartz.dart';
import 'package:golds_nuts/core/exeptions/failures.dart';
import '../entities/notification_entity.dart';

abstract class NotificationRepository {
  Stream<Either<Failure, List<NotificationEntity>>> watchNotifications({
    required String receiverId,
  });
}