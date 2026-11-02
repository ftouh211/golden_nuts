import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:golds_nuts/features/auth/domain/usecases/logout_usecase.dart';

import 'logout_event.dart';
import 'logout_state.dart';

class LogoutBloc extends Bloc<LogoutEvent, LogoutState> {
  final LogoutUseCase logoutUseCase;

  LogoutBloc({required this.logoutUseCase})
      : super(LogoutInitial()) {
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLogoutRequested(
      LogoutRequested event,
      Emitter<LogoutState> emit,
      ) async {
    emit(LogoutLoading());

    final result = await logoutUseCase();

    result.fold(
          (failure) => emit(LogoutFailure(failure.message)),
          (_) => emit(LogoutSuccess()),
    );
  }
}