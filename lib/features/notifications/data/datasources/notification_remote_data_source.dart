import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:golds_nuts/features/notifications/data/models/notification_model.dart';

class NotificationRemoteDataSource {
  final FirebaseFirestore firestore;

  NotificationRemoteDataSource({
    required this.firestore,
  });

  Stream<List<NotificationModel>> watchNotifications({
    required String receiverId,
  }) {
    return firestore
        .collection('notifications')
        .where('receiverId', isEqualTo: receiverId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((document) {
        return NotificationModel.fromMap(
          document.id,
          document.data(),
        );
      }).toList();
    });
  }
}