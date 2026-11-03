import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:golds_nuts/features/outgoing/domain/usecases/add_outgoing_use_case.dart';
import 'package:golds_nuts/features/outgoing/domain/usecases/get_outgoing_records_usecase.dart';

import 'outgoing_event.dart';
import 'outgoing_state.dart';

class OutgoingBloc extends Bloc<OutgoingEvent, OutgoingState> {
  final AddOutgoingUseCase addOutgoingUseCase;
  final GetOutgoingRecordsUseCase getOutgoingRecordsUseCase;

  OutgoingBloc({
    required this.addOutgoingUseCase,
    required this.getOutgoingRecordsUseCase,
  }) : super(OutgoingInitial()) {
    on<AddOutgoingEvent>(_onAddOutgoing);
    on<GetOutgoingRecordsEvent>(_onGetOutgoingRecords);
  }

  Future<void> _onAddOutgoing(
      AddOutgoingEvent event,
      Emitter<OutgoingState> emit,
      ) async {
    emit(OutgoingLoading());

    final result = await addOutgoingUseCase(
      data: event.data,
    );

    result.fold(
          (failure) {
        emit(OutgoingError(message: failure.message));
      },
          (recordId) {
        emit(OutgoingSuccess(recordId: recordId));
      },
    );
  }

  Future<void> _onGetOutgoingRecords(
      GetOutgoingRecordsEvent event,
      Emitter<OutgoingState> emit,
      ) async {
    emit(OutgoingRecordsLoading());

    final result = await getOutgoingRecordsUseCase();

    result.fold(
          (failure) {
        emit(OutgoingRecordsError(message: failure.message));
      },
          (records) {
        emit(OutgoingRecordsLoaded(records: records));
      },
    );
  }
}