import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import 'package:golds_nuts/core/exeptions/failures.dart';
import 'package:golds_nuts/features/notifications/data/datasources/notification_remote_data_source.dart';
import 'package:golds_nuts/features/notifications/domain/entities/notification_entity.dart';
import 'package:golds_nuts/features/notifications/domain/repo/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;

  NotificationRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Stream<Either<Failure, List<NotificationEntity>>> watchNotifications({
    required String receiverId,
  }) async* {
    try {
      await for (final notifications
      in remoteDataSource.watchNotifications(
        receiverId: receiverId,
      )) {
        yield Right<Failure, List<NotificationEntity>>(notifications);
      }
    } on FirebaseException catch (e) {
      yield Left<Failure, List<NotificationEntity>>(
        ServerFailure(e.message ?? 'A Firebase error occurred'),
      );
    } catch (e) {
      yield Left<Failure, List<NotificationEntity>>(
        ServerFailure('Something went wrong. Please try again.'),
      );
    }
  }
}