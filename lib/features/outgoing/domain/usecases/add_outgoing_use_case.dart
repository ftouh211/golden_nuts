import 'package:dartz/dartz.dart';
import 'package:golds_nuts/core/exeptions/failures.dart';
import 'package:golds_nuts/features/outgoing/domain/repo/outgoing_repository.dart';

class AddOutgoingUseCase {
  final OutgoingRepository repository;

  AddOutgoingUseCase({
    required this.repository,
  });

  Future<Either<Failure, String>> call({
    required Map<String, dynamic> data,
  }) async {
    return await repository.addOutgoing(data: data);
  }
}