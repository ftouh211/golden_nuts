import 'package:cloud_functions/cloud_functions.dart';

class WorkerRemoteDataSource {
  final FirebaseFunctions firebaseFunctions;

  WorkerRemoteDataSource({
    required this.firebaseFunctions,
  });

  // Create Worker
  Future<Map<String, dynamic>> createWorker({
    required String name,
    required String email,
    required String password,
  }) async {
    final callable = firebaseFunctions.httpsCallable(
      'createWorker',
    );

    final result = await callable.call<Map<String, dynamic>>({
      'name': name,
      'email': email,
      'password': password,
    });

    return result.data;
  }

  // Update Worker Status
  Future<void> updateWorkerStatus({
    required String workerId,
    required bool isActive,
  }) async {
    final callable = firebaseFunctions.httpsCallable(
      'updateWorkerStatus',
    );

    await callable.call({
      'workerId': workerId,
      'isActive': isActive,
    });
  }
}