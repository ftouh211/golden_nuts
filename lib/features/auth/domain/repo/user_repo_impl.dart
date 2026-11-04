import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import 'package:golds_nuts/core/exeptions/failures.dart';
import 'package:golds_nuts/features/auth/data/datasources/user_remote_data_source.dart';
import 'package:golds_nuts/features/auth/domain/entities/user_entity.dart';
import 'package:golds_nuts/features/auth/domain/repo/user_repo.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;

  UserRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, UserEntity>> getUserById({
    required String uid,
  }) async {
    try {
      final user = await remoteDataSource.getUserData(uid);

      if (user == null) {
        return Left(AuthFailure('Worker not found'));
      }

      return Right(user);
    } on FirebaseException catch (e) {
      return Left(
        ServerFailure(e.message ?? 'A Firebase error occurred'),
      );
    } catch (e) {
      return Left(
        ServerFailure('Something went wrong. Please try again.'),
      );
    }
  }
}