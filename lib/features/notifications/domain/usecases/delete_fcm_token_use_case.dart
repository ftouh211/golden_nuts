import 'package:dartz/dartz.dart';

import 'package:golds_nuts/core/exeptions/failures.dart';
import 'package:golds_nuts/features/notifications/domain/repo/fcm_token_repository.dart';

class DeleteFcmTokenUseCase {
  final FcmTokenRepository repository;

  DeleteFcmTokenUseCase({
    required this.repository,
  });

  Future<Either<Failure, Unit>> call({
    required String uid,
    required String token,
  }) {
    return repository.deleteToken(
      uid: uid,
      token: token,
    );
  }
}