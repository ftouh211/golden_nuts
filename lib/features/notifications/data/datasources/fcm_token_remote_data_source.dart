import 'package:cloud_firestore/cloud_firestore.dart';

class FcmTokenRemoteDataSource {
  final FirebaseFirestore firestore;

  FcmTokenRemoteDataSource({
    required this.firestore,
  });

  // Save or update device token
  Future<void> saveToken({
    required String uid,
    required String token,
    required String platform,
  }) async {
    await firestore
        .collection('users')
        .doc(uid)
        .collection('fcm_tokens')
        .doc(token)
        .set({
      'token': token,
      'platform': platform,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Delete current device token
  Future<void> deleteToken({
    required String uid,
    required String token,
  }) async {
    await firestore
        .collection('users')
        .doc(uid)
        .collection('fcm_tokens')
        .doc(token)
        .delete();
  }
}