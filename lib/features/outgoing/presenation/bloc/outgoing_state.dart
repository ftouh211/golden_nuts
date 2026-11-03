import 'package:equatable/equatable.dart';
import 'package:golds_nuts/features/outgoing/domain/entities/outgoing_entity.dart';

abstract class OutgoingState extends Equatable {
  const OutgoingState();

  @override
  List<Object?> get props => [];
}

// Add Outgoing States

class OutgoingInitial extends OutgoingState {}

class OutgoingLoading extends OutgoingState {}

class OutgoingSuccess extends OutgoingState {
  final String recordId;

  const OutgoingSuccess({
    required this.recordId,
  });

  @override
  List<Object?> get props => [recordId];
}

class OutgoingError extends OutgoingState {
  final String message;

  const OutgoingError({
    required this.message,
  });

  @override
  List<Object?> get props => [message];
}

// Get Outgoing Records States

class OutgoingRecordsLoading extends OutgoingState {}

class OutgoingRecordsLoaded extends OutgoingState {
  final List<OutgoingEntity> records;

  const OutgoingRecordsLoaded({
    required this.records,
  });

  @override
  List<Object?> get props => [records];
}

class OutgoingRecordsError extends OutgoingState {
  final String message;

  const OutgoingRecordsError({
    required this.message,
  });

  @override
  List<Object?> get props => [message];
}