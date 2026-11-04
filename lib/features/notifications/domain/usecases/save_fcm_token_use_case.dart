import 'package:dartz/dartz.dart';

import 'package:golds_nuts/core/exeptions/failures.dart';
import 'package:golds_nuts/features/notifications/domain/repo/fcm_token_repository.dart';

class SaveFcmTokenUseCase {
  final FcmTokenRepository repository;

  SaveFcmTokenUseCase({
    required this.repository,
  });

  Future<Either<Failure, Unit>> call({
    required String uid,
    required String token,
    required String platform,
  }) {
    return repository.saveToken(
      uid: uid,
      token: token,
      platform: platform,
    );
  }
}