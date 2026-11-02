
import 'package:equatable/equatable.dart';
import 'package:golds_nuts/features/production/domain/entities/production_entity.dart';

abstract class GetMonthlyProductionsState extends Equatable {
  const GetMonthlyProductionsState();

  @override
  List<Object?> get props => [];
}

class GetMonthlyProductionsInitial extends GetMonthlyProductionsState {
  const GetMonthlyProductionsInitial();
}

class GetMonthlyProductionsLoading extends GetMonthlyProductionsState {
  const GetMonthlyProductionsLoading();
}

class GetMonthlyProductionsSuccess extends GetMonthlyProductionsState {
  final List<ProductionEntity> productions;

  const GetMonthlyProductionsSuccess({
    required this.productions,
  });

  @override
  List<Object?> get props => [productions];
}

class GetMonthlyProductionsFailure extends GetMonthlyProductionsState {
  final String message;

  const GetMonthlyProductionsFailure({
    required this.message,
  });

  @override
  List<Object?> get props => [message];
}
