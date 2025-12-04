import 'package:equatable/equatable.dart';

class LoginState extends Equatable {
  final bool isLoading;
  final bool isSuccess;
  final String? error;
  final bool shouldNavigateToHome;
  final bool shouldNavigateToRegister;

  const LoginState({
    required this.isLoading,
    required this.isSuccess,
    this.error,
    this.shouldNavigateToHome = false,
    this.shouldNavigateToRegister = false,
  });

  const LoginState.initial()
      : isLoading = false,
        isSuccess = false,
        error = null,
        shouldNavigateToHome = false,
        shouldNavigateToRegister = false;

  LoginState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? error,
    bool? shouldNavigateToHome,
    bool? shouldNavigateToRegister,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error, // Note: overwrite even if null
      shouldNavigateToHome: shouldNavigateToHome ?? this.shouldNavigateToHome,
      shouldNavigateToRegister: shouldNavigateToRegister ?? this.shouldNavigateToRegister,
    );
  }

  @override
  List<Object?> get props => [isLoading, isSuccess, error, shouldNavigateToHome, shouldNavigateToRegister];
}