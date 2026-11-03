import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:golds_nuts/features/inventory/domain/usecases/get_inventory_use_case.dart';

import 'inventory_event.dart';
import 'inventory_state.dart';

class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  final GetInventoryUseCase getInventoryUseCase;

  InventoryBloc({
    required this.getInventoryUseCase,
  }) : super(InventoryInitial()) {
    on<GetInventoryEvent>(_onGetInventory);
  }

  Future<void> _onGetInventory(
      GetInventoryEvent event,
      Emitter<InventoryState> emit,
      ) async {
    emit(InventoryLoading());

    final result = await getInventoryUseCase();

    result.fold(
          (failure) {
        emit(InventoryError(message: failure.message));
      },
          (inventory) {
        emit(InventoryLoaded(inventory: inventory));
      },
    );
  }
}