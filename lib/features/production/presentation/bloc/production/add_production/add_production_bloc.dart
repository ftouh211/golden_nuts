
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:golds_nuts/features/production/domain/usecases/add_production_usecase.dart';
import 'package:golds_nuts/features/production/presentation/bloc/production/add_production/add_production_event.dart';
import 'package:golds_nuts/features/production/presentation/bloc/production/add_production/add_production_state.dart';

class AddProductionBloc
    extends Bloc<AddProductionEvent, AddProductionState> {
  final AddProductionUseCase addProductionUseCase;

  AddProductionBloc({
    required this.addProductionUseCase,
  }) : super(const AddProductionInitial()) {
    on<AddProductionRequested>(_onAddProductionRequested);
  }

  Future<void> _onAddProductionRequested(
      AddProductionRequested event,
      Emitter<AddProductionState> emit,
      ) async {
    emit(const AddProductionLoading());

    final result = await addProductionUseCase(
      production: event.production,
    );

    result.fold(
          (failure) {
        emit(AddProductionFailure(
          message: failure.message,
        ));
      },
          (documentId) {
        emit(AddProductionSuccess(
          documentId: documentId,
        ));
      },
    );
  }
}
