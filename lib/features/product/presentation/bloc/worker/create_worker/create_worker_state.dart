import 'package:equatable/equatable.dart';

abstract class CreateWorkerState extends Equatable {
  const CreateWorkerState();

  @override
  List<Object?> get props => [];
}

class CreateWorkerInitial extends CreateWorkerState {}

class CreateWorkerLoading extends CreateWorkerState {}

class CreateWorkerSuccess extends CreateWorkerState {}

class CreateWorkerFailure extends CreateWorkerState {
  final String message;

  const CreateWorkerFailure(this.message);

  @override
  List<Object?> get props => [message];
}