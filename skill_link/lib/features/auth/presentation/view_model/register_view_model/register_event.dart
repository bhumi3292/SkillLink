import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class RegisterUserEvent extends Equatable {
  const RegisterUserEvent();

  @override
  List<Object?> get props => [];
}

class RegisterNewUserEvent extends RegisterUserEvent {
  final String fullName;
  final String email;
  final String phoneNumber;
  final String stakeholder;
  final String password;
  final String confirmPassword;
  final BuildContext? context;

  const RegisterNewUserEvent({
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.stakeholder,
    required this.password,
    required this.confirmPassword,
    this.context,
  });

  @override
  List<Object?> get props => [
    fullName,
    email,
    phoneNumber,
    stakeholder,
    password,
    confirmPassword,
    context,
  ];
}

class ClearRegisterMessageEvent extends RegisterUserEvent {
  const ClearRegisterMessageEvent();

  @override
  List<Object?> get props => [];
}