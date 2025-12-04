import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String? userId;
  final String fullName;
  final String email;
  final String? phoneNumber; // Made nullable
  final String? stakeholder; // Made nullable
  final String? password; // ⭐ Made nullable ⭐
  final String? confirmPassword; // ⭐ Made nullable ⭐
  final String? profilePicture;


  const UserEntity({
    this.userId,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.stakeholder,
    this.password,
    this.confirmPassword,
    this.profilePicture,
  });

  UserEntity copyWith({
    String? userId,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? stakeholder,
    String? password,
    String? confirmPassword,
    String? profilePicture,
  }) {
    return UserEntity(
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      stakeholder: stakeholder ?? this.stakeholder,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      profilePicture: profilePicture ?? this.profilePicture,
    );
  }

  @override
  List<Object?> get props => [
    userId,
    fullName,
    email,
    phoneNumber,
    stakeholder,
    password,
    confirmPassword,
    profilePicture,
  ];
}