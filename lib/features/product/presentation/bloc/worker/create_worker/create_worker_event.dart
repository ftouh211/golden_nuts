import 'package:equatable/equatable.dart';

abstract class CreateWorkerEvent extends Equatable {
  const CreateWorkerEvent();

  @override
  List<Object?> get props => [];
}

class CreateWorkerSubmitted extends CreateWorkerEvent {
  final String name;
  final String email;
  final String password;

  const CreateWorkerSubmitted({
    required this.name,
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [name, email, password];
}