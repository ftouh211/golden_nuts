import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:golds_nuts/core/services/fcm_token_manager.dart';
import 'package:golds_nuts/features/auth/domain/usecases/logout_usecase.dart';
import 'logout_event.dart';
import 'logout_state.dart';

class LogoutBloc extends Bloc<LogoutEvent, LogoutState> {
  final LogoutUseCase logoutUseCase;
  final FcmTokenManager fcmTokenManager;

  LogoutBloc({required this.logoutUseCase, required this.fcmTokenManager})
    : super(LogoutInitial()) {
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<LogoutState> emit,
  ) async {
    emit(LogoutLoading());

    try {
      // 1. Remove current device FCM token.
      // Failure here must not prevent logout.
      try {
        await fcmTokenManager.unregisterDevice(uid: event.uid);
      } catch (_) {
        // Ignore notification errors.
      }

      // 2. Sign out from Firebase Authentication.
      final result = await logoutUseCase();

      result.fold(
        (failure) {
          emit(LogoutFailure(failure.message));
        },
        (_) {
          emit(LogoutSuccess());
        },
      );
    } catch (e) {
      emit(LogoutFailure('Something went wrong. Please try again.'));
    }
  }
}
