
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:golds_nuts/features/product/domain/usecases/get_workers_usecase.dart';

import 'get_workers_event.dart';
import 'get_workers_state.dart';

class GetWorkersBloc extends Bloc<GetWorkersEvent, GetWorkersState> {
  final GetWorkersUseCase getWorkersUseCase;

  GetWorkersBloc({
    required this.getWorkersUseCase,
  }) : super(const GetWorkersInitial()) {
    on<GetWorkersRequested>(_onGetWorkersRequested);
  }

  Future<void> _onGetWorkersRequested(
      GetWorkersRequested event,
      Emitter<GetWorkersState> emit,
      ) async {
    emit(const GetWorkersLoading());

    final result = await getWorkersUseCase();

    result.fold(
          (failure) {
        emit(GetWorkersFailure(failure.toString()));
      },
          (workers) {
        emit(GetWorkersSuccess(workers));
      },
    );
  }
}
