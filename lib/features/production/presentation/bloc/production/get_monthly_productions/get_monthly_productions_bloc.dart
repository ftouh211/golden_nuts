
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:golds_nuts/features/production/domain/usecases/get_monthly_productions_usecase.dart';

import 'get_monthly_productions_event.dart';
import 'get_monthly_productions_state.dart';

class GetMonthlyProductionsBloc extends Bloc<
    GetMonthlyProductionsEvent,
    GetMonthlyProductionsState> {
  final GetMonthlyProductionsUseCase getMonthlyProductionsUseCase;

  GetMonthlyProductionsBloc({
    required this.getMonthlyProductionsUseCase,
  }) : super(const GetMonthlyProductionsInitial()) {
    on<GetMonthlyProductionsRequested>(_onGetMonthlyProductions);
  }

  Future<void> _onGetMonthlyProductions(
      GetMonthlyProductionsRequested event,
      Emitter<GetMonthlyProductionsState> emit,
      ) async {
    emit(const GetMonthlyProductionsLoading());

    final result = await getMonthlyProductionsUseCase(
      month: event.month,
      workerId: event.workerId,
    );

    result.fold(
          (failure) {
        emit(GetMonthlyProductionsFailure(
          message: failure.message,
        ));
      },
          (productions) {
        emit(GetMonthlyProductionsSuccess(
          productions: productions,
        ));
      },
    );
  }
}
