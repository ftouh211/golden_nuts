import 'package:equatable/equatable.dart';
import 'package:golds_nuts/features/inventory/domain/entities/inventory_entity.dart';

abstract class InventoryState extends Equatable {
  const InventoryState();

  @override
  List<Object?> get props => [];
}

class InventoryInitial extends InventoryState {}

class InventoryLoading extends InventoryState {}

class InventoryLoaded extends InventoryState {
  final List<InventoryEntity> inventory;

  const InventoryLoaded({required this.inventory});

  @override
  List<Object?> get props => [inventory];
}

class InventoryError extends InventoryState {
  final String message;

  const InventoryError({required this.message});

  @override
  List<Object?> get props => [message];
}