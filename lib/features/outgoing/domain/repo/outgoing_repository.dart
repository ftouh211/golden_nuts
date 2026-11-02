import 'package:dartz/dartz.dart';
import 'package:golds_nuts/core/exeptions/failures.dart';


abstract class OutgoingRepository {
  Future<Either<Failure, String>> addOutgoing({
    required Map<String, dynamic> data,
  });
}