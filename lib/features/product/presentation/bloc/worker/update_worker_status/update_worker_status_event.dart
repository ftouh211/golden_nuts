import 'package:equatable/equatable.dart';

abstract class UpdateWorkerStatusEvent extends Equatable {
  const UpdateWorkerStatusEvent();

  @override
  List<Object?> get props => [];
}

class UpdateWorkerStatusRequested extends UpdateWorkerStatusEvent {
  final String workerId;
  final bool isActive;

  const UpdateWorkerStatusRequested({
    required this.workerId,
    required this.isActive,
  });

  @override
  List<Object?> get props => [workerId, isActive];
}