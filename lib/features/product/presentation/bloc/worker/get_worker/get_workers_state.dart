
import 'package:equatable/equatable.dart';
import 'package:golds_nuts/features/auth/domain/entities/user_entity.dart';

abstract class GetWorkersState extends Equatable {
  const GetWorkersState();

  @override
  List<Object?> get props => [];
}

// Initial
class GetWorkersInitial extends GetWorkersState {
  const GetWorkersInitial();
}

// Loading
class GetWorkersLoading extends GetWorkersState {
  const GetWorkersLoading();
}

// Success
class GetWorkersSuccess extends GetWorkersState {
  final List<UserEntity> workers;

  const GetWorkersSuccess(this.workers);

  @override
  List<Object?> get props => [workers];
}

// Failure
class GetWorkersFailure extends GetWorkersState {
  final String message;

  const GetWorkersFailure(this.message);

  @override
  List<Object?> get props => [message];
}
