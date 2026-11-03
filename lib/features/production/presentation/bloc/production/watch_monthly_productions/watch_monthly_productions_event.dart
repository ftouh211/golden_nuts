import 'package:equatable/equatable.dart';

abstract class WatchMonthlyProductionsEvent extends Equatable {
  const WatchMonthlyProductionsEvent();

  @override
  List<Object?> get props => [];
}

class WatchMonthlyProductionsRequested
    extends WatchMonthlyProductionsEvent {
  final DateTime month;
  final String? workerId;

  const WatchMonthlyProductionsRequested({
    required this.month,
    this.workerId,
  });

  @override
  List<Object?> get props => [month, workerId];
}

class WatchMonthlyProductionsStopped
    extends WatchMonthlyProductionsEvent {
  const WatchMonthlyProductionsStopped();
}