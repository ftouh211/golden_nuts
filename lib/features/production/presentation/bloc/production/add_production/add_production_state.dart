
import 'package:equatable/equatable.dart';

abstract class AddProductionState extends Equatable {
  const AddProductionState();

  @override
  List<Object?> get props => [];
}

class AddProductionInitial extends AddProductionState {
  const AddProductionInitial();
}

class AddProductionLoading extends AddProductionState {
  const AddProductionLoading();
}

class AddProductionSuccess extends AddProductionState {
  final String documentId;

  const AddProductionSuccess({
    required this.documentId,
  });

  @override
  List<Object?> get props => [documentId];
}

class AddProductionFailure extends AddProductionState {
  final String message;

  const AddProductionFailure({
    required this.message,
  });

  @override
  List<Object?> get props => [message];
}
