import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import 'package:golds_nuts/core/exeptions/failures.dart';
import 'package:golds_nuts/features/notifications/data/datasources/fcm_token_remote_data_source.dart';
import 'package:golds_nuts/features/notifications/domain/repo/fcm_token_repository.dart';

class FcmTokenRepositoryImpl implements FcmTokenRepository {
  final FcmTokenRemoteDataSource remoteDataSource;

  FcmTokenRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, Unit>> saveToken({
    required String uid,
    required String token,
    required String platform,
  }) async {
    try {
      await remoteDataSource.saveToken(
        uid: uid,
        token: token,
        platform: platform,
      );

      return const Right(unit);
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

  @override
  Future<Either<Failure, Unit>> deleteToken({
    required String uid,
    required String token,
  }) async {
    try {
      await remoteDataSource.deleteToken(
        uid: uid,
        token: token,
      );

      return const Right(unit);
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