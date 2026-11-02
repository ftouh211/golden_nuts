import 'package:dartz/dartz.dart';
import 'package:golds_nuts/core/exeptions/failures.dart';

import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, Unit>> logout();
}
