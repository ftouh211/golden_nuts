import 'package:cloud_functions/cloud_functions.dart';

abstract class OutgoingRemoteDataSource {
  Future<String> addOutgoing({
    required Map<String, dynamic> data,
  });
}

class OutgoingRemoteDataSourceImpl
    implements OutgoingRemoteDataSource {
  final FirebaseFunctions firebaseFunctions;

  OutgoingRemoteDataSourceImpl({
    required this.firebaseFunctions,
  });

  @override
  Future<String> addOutgoing({
    required Map<String, dynamic> data,
  }) async {
    final callable =
    firebaseFunctions.httpsCallable('createOutgoingRecord');

    final result = await callable.call(data);

    return result.data['recordId'] as String;
  }
}