import 'package:dartz/dartz.dart';
import 'package:golds_nuts/core/exeptions/failures.dart';

abstract class FcmTokenRepository {
  Future<Either<Failure, Unit>> saveToken({
    required String uid,
    required String token,
    required String platform,
  });

  Future<Either<Failure, Unit>> deleteToken({
    required String uid,
    required String token,
  });
}