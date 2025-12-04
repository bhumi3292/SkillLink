import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skill_link/features/auth/domain/use_case/user_login_usecase.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginViewModel extends Bloc<LoginEvent, LoginState> {
  final UserLoginUsecase loginUserUseCase;

  LoginViewModel({required this.loginUserUseCase})
    : super(LoginState.initial()) {
    on<LoginWithEmailAndPasswordEvent>(_onLoginWithEmailAndPassword);
    on<NavigateToRegisterViewEvent>(_onNavigateToRegisterView);
    on<NavigateToHomeViewEvent>(_onNavigateToHomeView);
  }

  void _onLoginWithEmailAndPassword(
    LoginWithEmailAndPasswordEvent event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null)); // Clear previous error

    try {
      final result = await loginUserUseCase.call(
        LoginParams(
          email: event.username,
          password: event.password,
          stakeholder: event.stakeholder,
        ),
      );

      result.fold(
        (error) {
          emit(
            state.copyWith(
              isLoading: false,
              isSuccess: false,
              error: error.message,
            ),
          );
        },
        (success) {
          emit(
            state.copyWith(
              isLoading: false,
              isSuccess: true,
              shouldNavigateToHome: true,
            ),
          );
        },
      );
    } catch (e) {
      emit(
        state.copyWith(isLoading: false, isSuccess: false, error: e.toString()),
      );
    }
  }

  void _onNavigateToRegisterView(
    NavigateToRegisterViewEvent event,
    Emitter<LoginState> emit,
  ) {
    emit(state.copyWith(shouldNavigateToRegister: true));
  }

  void _onNavigateToHomeView(
    NavigateToHomeViewEvent event,
    Emitter<LoginState> emit,
  ) {
    emit(state.copyWith(shouldNavigateToHome: true));
  }
}
