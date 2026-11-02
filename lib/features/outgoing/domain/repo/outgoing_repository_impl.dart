import 'package:dartz/dartz.dart';
import 'package:golds_nuts/core/exeptions/failures.dart';
import 'package:golds_nuts/features/outgoing/data/datasources/outgoing_remote_data_source.dart';
import 'package:golds_nuts/features/outgoing/domain/repo/outgoing_repository.dart';

class OutgoingRepositoryImpl implements OutgoingRepository {
  final OutgoingRemoteDataSource remoteDataSource;

  OutgoingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, String>> addOutgoing({
    required Map<String, dynamic> data,
  }) async {
    try {
      final recordId = await remoteDataSource.addOutgoing(data: data);

      return Right(recordId);
    } catch (e) {
      return Left(ServerFailure('Something went wrong. Please try again.'));
    }
  }
}
