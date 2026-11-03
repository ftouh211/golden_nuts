import 'package:dartz/dartz.dart';
import 'package:golds_nuts/core/exeptions/failures.dart';
import 'package:golds_nuts/features/outgoing/domain/entities/outgoing_entity.dart';


abstract class OutgoingRepository {
  Future<Either<Failure, String>> addOutgoing({
    required Map<String, dynamic> data,
  });
  Future<Either<Failure, List<OutgoingEntity>>> getOutgoingRecords();

}