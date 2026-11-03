import 'package:equatable/equatable.dart';
import 'package:golds_nuts/features/production/domain/entities/production_entity.dart';

abstract class WatchMonthlyProductionsState extends Equatable {
  const WatchMonthlyProductionsState();

  @override
  List<Object?> get props => [];
}

class WatchMonthlyProductionsInitial
    extends WatchMonthlyProductionsState {
  const WatchMonthlyProductionsInitial();
}

class WatchMonthlyProductionsLoading
    extends WatchMonthlyProductionsState {
  const WatchMonthlyProductionsLoading();
}

class WatchMonthlyProductionsSuccess
    extends WatchMonthlyProductionsState {
  final List<ProductionEntity> productions;

  const WatchMonthlyProductionsSuccess({
    required this.productions,
  });

  @override
  List<Object?> get props => [productions];
}

class WatchMonthlyProductionsFailure
    extends WatchMonthlyProductionsState {
  final String message;

  const WatchMonthlyProductionsFailure({
    required this.message,
  });

  @override
  List<Object?> get props => [message];
}