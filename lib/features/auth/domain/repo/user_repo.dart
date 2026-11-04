import 'package:dartz/dartz.dart';
import 'package:golds_nuts/core/exeptions/failures.dart';
import '../entities/user_entity.dart';

abstract class UserRepository {
  Future<Either<Failure, UserEntity>> getUserById({
    required String uid,
  });
}