import 'package:equatable/equatable.dart';
import 'package:skill_link/features/auth/domain/entity/user_entity.dart';

class ProfileState extends Equatable {
  final UserEntity? user;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;
  final bool isUploadingImage; // This is the property that exists
  final bool isLogoutSuccess;

  const ProfileState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
    this.isUploadingImage = false,
    this.isLogoutSuccess = false,
  });

  const ProfileState.initial()
      : user = null,
        isLoading = false,
        errorMessage = null,
        successMessage = null,
        isUploadingImage = false,
        isLogoutSuccess = false;

  ProfileState copyWith({
    UserEntity? user,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    bool? isUploadingImage,
    bool? isLogoutSuccess,
  }) {
    return ProfileState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
      isUploadingImage: isUploadingImage ?? this.isUploadingImage,
      isLogoutSuccess: isLogoutSuccess ?? this.isLogoutSuccess,
    );
  }

  @override
  List<Object?> get props => [
    user,
    isLoading,
    errorMessage,
    successMessage,
    isUploadingImage,
    isLogoutSuccess,
  ];
}