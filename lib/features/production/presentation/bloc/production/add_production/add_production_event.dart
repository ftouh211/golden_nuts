
import 'package:equatable/equatable.dart';
import 'package:golds_nuts/features/production/domain/entities/production_entity.dart';

abstract class AddProductionEvent extends Equatable {
  const AddProductionEvent();

  @override
  List<Object?> get props => [];
}

class AddProductionRequested extends AddProductionEvent {
  final ProductionEntity production;

  const AddProductionRequested({
    required this.production,
  });

  @override
  List<Object?> get props => [production];
}
