// path: lib/features/auth/domain/usecases/login_params.dart
import 'package:equatable/equatable.dart';

class LoginParams extends Equatable {
  final String email;
  final String password;
  final String stakeholder;

  const LoginParams({
    required this.email,
    required this.password,
    required this.stakeholder,
  });

  // Initial state (if needed)
  const LoginParams.initial()
      : email = '',
        password = '',
        stakeholder = '';

  @override
  List<Object?> get props => [email, password, stakeholder];
}
