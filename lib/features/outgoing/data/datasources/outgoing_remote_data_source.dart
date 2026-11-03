import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:golds_nuts/features/outgoing/data/model/outgoing_model.dart';

abstract class OutgoingRemoteDataSource {
  Future<String> addOutgoing({
    required Map<String, dynamic> data,
  });

  Future<List<OutgoingModel>> getOutgoingRecords();
}

class OutgoingRemoteDataSourceImpl
    implements OutgoingRemoteDataSource {
  final FirebaseFunctions firebaseFunctions;
  final FirebaseFirestore firestore;

  OutgoingRemoteDataSourceImpl({
    required this.firebaseFunctions,
    required this.firestore,
  });

  @override
  Future<String> addOutgoing({
    required Map<String, dynamic> data,
  }) async {
    final callable =
    firebaseFunctions.httpsCallable('createOutgoingRecord');

    final result = await callable.call(data);

    final response = Map<String, dynamic>.from(result.data);

    return response['recordId'] as String;
  }

  @override
  Future<List<OutgoingModel>> getOutgoingRecords() async {
    final snapshot = await firestore
        .collection('outgoing_records')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      return OutgoingModel.fromJson(
        doc.data(),
        doc.id,
      );
    }).toList();
  }
}