import 'package:dartz/dartz.dart';

import 'package:golds_nuts/core/exeptions/failures.dart';
import 'package:golds_nuts/features/auth/domain/entities/user_entity.dart';
import 'package:golds_nuts/features/auth/domain/repo/user_repo.dart';

class GetUserByIdUseCase {
  final UserRepository repository;

  GetUserByIdUseCase({
    required this.repository,
  });

  Future<Either<Failure, UserEntity>> call({
    required String uid,
  }) {
    return repository.getUserById(uid: uid);
  }
}