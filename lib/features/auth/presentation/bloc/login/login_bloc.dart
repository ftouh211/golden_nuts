import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:golds_nuts/features/auth/domain/usecases/login_usecase.dart';

import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginUseCase loginUseCase;

  LoginBloc(this.loginUseCase)
      : super(const LoginInitial()) {
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

      result.fold(
            (failure) {
          emit(LoginFailure(failure.message));
        },
            (user) {
          emit(LoginSuccess(user));
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