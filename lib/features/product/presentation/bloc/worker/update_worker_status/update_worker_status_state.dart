import 'package:equatable/equatable.dart';

abstract class UpdateWorkerStatusState extends Equatable {
  const UpdateWorkerStatusState();

  @override
  List<Object?> get props => [];
}

class UpdateWorkerStatusInitial extends UpdateWorkerStatusState {}

class UpdateWorkerStatusLoading extends UpdateWorkerStatusState {}

class UpdateWorkerStatusSuccess extends UpdateWorkerStatusState {
  final bool isActive;

  const UpdateWorkerStatusSuccess({
    required this.isActive,
  });

  @override
  List<Object?> get props => [isActive];
}

class UpdateWorkerStatusFailure extends UpdateWorkerStatusState {
  final String message;

  const UpdateWorkerStatusFailure({
    required this.message,
  });

  @override
  List<Object?> get props => [message];
}