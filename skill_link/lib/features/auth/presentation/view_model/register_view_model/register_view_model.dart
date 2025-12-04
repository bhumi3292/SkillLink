import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skill_link/cores/common/snackbar/snackbar.dart';

import 'register_event.dart';
import 'register_state.dart';
import 'package:skill_link/features/auth/domain/use_case/user_register_usecase.dart';

class RegisterUserViewModel extends Bloc<RegisterUserEvent, RegisterUserState> {
  final UserRegisterUsecase _userRegisterUseCase;

  RegisterUserViewModel(this._userRegisterUseCase)
    : super(const RegisterUserState.initial()) {
    on<RegisterNewUserEvent>(_onRegisterUser);
    on<ClearRegisterMessageEvent>(_onClearMessage);
  }

  void _onClearMessage(
    ClearRegisterMessageEvent event,
    Emitter<RegisterUserState> emit,
  ) {
    emit(
      state.copyWith(
        errorMessage: null,
        successMessage: null,
        isSuccess: false,
      ),
    );
  }

  Future<void> _onRegisterUser(
    RegisterNewUserEvent event,
    Emitter<RegisterUserState> emit,
  ) async {
    print("calling from register viewmodel");
    emit(
      state.copyWith(
        isLoading: true,
        errorMessage: null,
        successMessage: null,
        isSuccess: false,
      ),
    );

    final result = await _userRegisterUseCase(
      RegisterUserParams(
        fullName: event.fullName,
        email: event.email,
        phoneNumber: event.phoneNumber,
        stakeholder: event.stakeholder,
        password: event.password,
        confirmPassword: event.confirmPassword,
      ),
    );

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
            isSuccess: false,
          ),
        );
        if (event.context != null) {
          showMySnackbar(
            context: event.context!,
            content: failure.message,
            isSuccess: false,
          );
        }
      },
      (_) {
        emit(
          state.copyWith(
            isLoading: false,
            successMessage: "User registration successful",
            isSuccess: true,
          ),
        );
        if (event.context != null) {
          showMySnackbar(
            context: event.context!,
            content: "User registration successful",
            isSuccess: true,
          );
        }
      },
    );
  }
}
