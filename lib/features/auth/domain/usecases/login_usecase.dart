import 'package:dartz/dartz.dart';

import 'package:golds_nuts/core/exeptions/failures.dart';

import '../entities/user_entity.dart';
import '../repo/auth_repo.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase({
    required this.repository,
  });

  Future<Either<Failure, UserEntity>> call({
    required String email,
    required String password,
  }) {
    return repository.login(
      email: email,
      password: password,
    );
  }
}