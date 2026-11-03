import 'package:dartz/dartz.dart';
import 'package:golds_nuts/core/exeptions/failures.dart';
import 'package:golds_nuts/features/outgoing/domain/entities/outgoing_entity.dart';
import 'package:golds_nuts/features/outgoing/domain/repo/outgoing_repository.dart';

class GetOutgoingRecordsUseCase {
  final OutgoingRepository repository;

  GetOutgoingRecordsUseCase({required this.repository});

  Future<Either<Failure, List<OutgoingEntity>>> call() {
    return repository.getOutgoingRecords();
  }
}
