import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
sealed class LoginEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class NavigateToRegisterViewEvent extends LoginEvent {
  @override
  List<Object?> get props => [];
}

class NavigateToHomeViewEvent extends LoginEvent {
  @override
  List<Object?> get props => [];
}

class LoginWithEmailAndPasswordEvent extends LoginEvent {
  final String username;
  final String password;
  final String stakeholder;

  LoginWithEmailAndPasswordEvent({
    required this.username,
    required this.password,
    required this.stakeholder,
  });

  @override
  List<Object?> get props => [username, password, stakeholder];
}