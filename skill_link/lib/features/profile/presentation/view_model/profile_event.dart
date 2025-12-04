import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'dart:io';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class FetchUserProfileEvent extends ProfileEvent {
  final BuildContext context;

  const FetchUserProfileEvent({required this.context});

  @override
  List<Object?> get props => [context];
}

class UploadProfilePictureEvent extends ProfileEvent {
  final File imageFile;
  final BuildContext context;

  const UploadProfilePictureEvent({
    required this.imageFile,
    required this.context,
  });

  @override
  List<Object?> get props => [imageFile, context];
}

class UpdateLocalUserEvent extends ProfileEvent {
  final String? profilePictureUrl;
  final BuildContext context;

  const UpdateLocalUserEvent({this.profilePictureUrl, required this.context});

  @override
  List<Object?> get props => [profilePictureUrl, context];
}

class LogoutEvent extends ProfileEvent {
  final BuildContext context;

  const LogoutEvent({required this.context});

  @override
  List<Object?> get props => [context];
}

class UpdateUserProfileEvent extends ProfileEvent {
  final BuildContext context;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String? currentPassword;
  final String? newPassword;

  const UpdateUserProfileEvent({
    required this.context,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.currentPassword,
    this.newPassword,
  });

  @override
  List<Object?> get props => [context, fullName, email, phoneNumber, currentPassword, newPassword];
}