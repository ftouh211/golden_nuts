import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:golds_nuts/features/product/domain/usecases/update_worker_status_use_case.dart';

import 'update_worker_status_event.dart';
import 'update_worker_status_state.dart';

class UpdateWorkerStatusBloc
    extends Bloc<UpdateWorkerStatusEvent, UpdateWorkerStatusState> {
  final UpdateWorkerStatusUseCase updateWorkerStatusUseCase;

  UpdateWorkerStatusBloc({
    required this.updateWorkerStatusUseCase,
  }) : super(UpdateWorkerStatusInitial()) {
    on<UpdateWorkerStatusRequested>(_onUpdateWorkerStatus);
  }

  Future<void> _onUpdateWorkerStatus(
      UpdateWorkerStatusRequested event,
      Emitter<UpdateWorkerStatusState> emit,
      ) async {
    emit(UpdateWorkerStatusLoading());

    final result = await updateWorkerStatusUseCase(
      workerId: event.workerId,
      isActive: event.isActive,
    );

    result.fold(
          (failure) {
        emit(UpdateWorkerStatusFailure(
          message: failure.message,
        ));
      },
          (_) {
        emit(UpdateWorkerStatusSuccess(
          isActive: event.isActive,
        ));
      },
    );
  }
}