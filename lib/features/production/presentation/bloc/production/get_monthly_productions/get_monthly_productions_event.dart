
import 'package:equatable/equatable.dart';

abstract class GetMonthlyProductionsEvent extends Equatable {
  const GetMonthlyProductionsEvent();

  @override
  List<Object?> get props => [];
}

class GetMonthlyProductionsRequested
    extends GetMonthlyProductionsEvent {
  final DateTime month;
  final String? workerId;

  const GetMonthlyProductionsRequested({
    required this.month,
    this.workerId,
  });

  @override
  List<Object?> get props => [month, workerId];
}
