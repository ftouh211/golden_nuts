import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';

class UserRemoteDataSource {
  final FirebaseFirestore firestore;

  UserRemoteDataSource({required this.firestore});

  Future<UserModel?> getUserData(String uid) async {
    final document = await firestore.collection('users').doc(uid).get();

    if (!document.exists) {
      return null;
    }

    final data = document.data();

    if (data == null) {
      return null;
    }

    return UserModel.fromMap(document.id, data);
  }

  Future<List<UserModel>> getWorkers() async {
    final query = await firestore
        .collection('users')
        .where('role', isEqualTo: 'worker')
        .get();

    return query.docs.map((document) {
      return UserModel.fromMap(
        document.id,
        document.data(),
      );
    }).toList();
  }

}
