import 'package:equatable/equatable.dart';

class LoginState extends Equatable {
  final bool isLoading;
  final bool isSuccess;
  final String? error;
  final bool shouldNavigateToHome;
  final bool shouldNavigateToRegister;
  final String? role;

  const LoginState({
    required this.isLoading,
    required this.isSuccess,
    this.error,
    this.shouldNavigateToHome = false,
    this.shouldNavigateToRegister = false,
    this.role,
  });

  const LoginState.initial()
      : isLoading = false,
        isSuccess = false,
        error = null,
        shouldNavigateToHome = false,
        shouldNavigateToRegister = false,
        role = null;

  LoginState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? error,
    bool? shouldNavigateToHome,
    bool? shouldNavigateToRegister,
    String? role,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error,
      shouldNavigateToHome: shouldNavigateToHome ?? this.shouldNavigateToHome,
      shouldNavigateToRegister:
          shouldNavigateToRegister ?? this.shouldNavigateToRegister,
      role: role ?? this.role,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isSuccess,
    error,
    shouldNavigateToHome,
    shouldNavigateToRegister,
    role,
  ];
}