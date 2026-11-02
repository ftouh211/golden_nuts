import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:golds_nuts/features/product/domain/usecases/create_worker_usecase.dart';
import 'package:golds_nuts/features/product/presentation/bloc/worker/create_worker/create_worker_event.dart';

import 'create_worker_state.dart';

class CreateWorkerBloc
    extends Bloc<CreateWorkerEvent, CreateWorkerState> {
  final CreateWorkerUseCase createWorkerUseCase;

  CreateWorkerBloc({
    required this.createWorkerUseCase,
  }) : super(CreateWorkerInitial()) {
    on<CreateWorkerSubmitted>(_onCreateWorkerSubmitted);
  }

  Future<void> _onCreateWorkerSubmitted(
      CreateWorkerSubmitted event,
      Emitter<CreateWorkerState> emit,
      ) async {
    emit(CreateWorkerLoading());

    final result = await createWorkerUseCase(
      name: event.name,
      email: event.email,
      password: event.password,
    );

    result.fold(
          (failure) {
        emit(CreateWorkerFailure(failure.toString()));
      },
          (_) {
        emit(CreateWorkerSuccess());
      },
    );
  }
}