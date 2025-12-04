import 'package:equatable/equatable.dart';

class RegisterUserState extends Equatable {
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;
  final String? successMessage;

  const RegisterUserState({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
    this.successMessage,
  });

  const RegisterUserState.initial()
      : isLoading = false,
        isSuccess = false,
        errorMessage = null,
        successMessage = null;

  RegisterUserState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
    String? successMessage,
  }) {
    return RegisterUserState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isSuccess,
    errorMessage,
    successMessage,
  ];
}