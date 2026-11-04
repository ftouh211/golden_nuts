import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:golds_nuts/features/auth/domain/usecases/login_usecase.dart';
import 'package:golds_nuts/core/services/fcm_token_manager.dart';

import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginUseCase loginUseCase;
  final FcmTokenManager fcmTokenManager;

  LoginBloc({
    required this.loginUseCase,
    required this.fcmTokenManager,
  }) : super(const LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
  }

  Future<void> _onLoginSubmitted(
      LoginSubmitted event,
      Emitter<LoginState> emit,
      ) async {
    emit(const LoginLoading());

    try {
      final result = await loginUseCase(
        email: event.email,
        password: event.password,
      );

      await result.fold(
            (failure) async {
          emit(LoginFailure(failure.message));
        },
            (user) async {
          // Authentication succeeded.
          emit(LoginSuccess(user));

          // Notification registration is optional.
          // It must never affect authentication.
          try {
            await fcmTokenManager.registerDevice(
              uid: user.uid,
            );
          } catch (_) {
            // Ignore notification registration errors.
          }
        },
      );
    } catch (e) {
      emit(
        const LoginFailure(
          'Something went wrong. Please try again.',
        ),
      );
    }
  }
}