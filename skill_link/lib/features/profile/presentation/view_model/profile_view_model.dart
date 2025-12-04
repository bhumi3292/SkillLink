import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:skill_link/cores/common/snackbar/snackbar.dart'; // No longer needed here if snackbar is handled in UI
import 'package:skill_link/features/auth/domain/use_case/user_get_current_usecase.dart';
import 'package:skill_link/features/auth/domain/use_case/update_user_profile_usecase.dart';
import 'package:skill_link/features/profile/domain/use_case/upload_profile_picture_usecase.dart';
import 'package:skill_link/features/profile/domain/use_case/update_profile_usecase.dart';
import 'package:skill_link/features/profile/presentation/view_model/profile_event.dart';
import 'package:skill_link/features/profile/presentation/view_model/profile_state.dart';
import 'package:skill_link/app/shared_pref/token_shared_prefs.dart';

class ProfileViewModel extends Bloc<ProfileEvent, ProfileState> {
  final UserGetCurrentUsecase userGetCurrentUsecase;
  final UploadProfilePictureUsecase uploadProfilePictureUsecase;
  final UpdateUserProfileUsecase updateUserProfileUsecase;
  final UpdateProfileUsecase updateProfileUsecase;
  final TokenSharedPrefs _tokenSharedPrefs;

  ProfileViewModel({
    required this.userGetCurrentUsecase,
    required this.uploadProfilePictureUsecase,
    required this.updateUserProfileUsecase,
    required this.updateProfileUsecase,
    required TokenSharedPrefs tokenSharedPrefs,
  }) : _tokenSharedPrefs = tokenSharedPrefs,
       super(const ProfileState.initial()) {
    on<FetchUserProfileEvent>(_onFetchUserProfile);
    on<UploadProfilePictureEvent>(_onUploadProfilePicture);
    on<UpdateLocalUserEvent>(_onUpdateLocalUser);
    on<LogoutEvent>(_onLogout);
    on<UpdateUserProfileEvent>(_onUpdateUserProfile);
  }

  Future<void> _onFetchUserProfile(
    FetchUserProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    print("FetchUserProfile - Starting fetch..."); // Debug print
    emit(
      state.copyWith(isLoading: true, errorMessage: null, successMessage: null),
    );

    final result = await userGetCurrentUsecase.call();

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false, errorMessage: failure.message));
        // Removed showMySnackbar here. UI will react to errorMessage.
      },
      (userEntity) {
        print(
          "FetchUserProfile - Retrieved user: ${userEntity.fullName}, email: ${userEntity.email}",
        ); // Debug print
        emit(
          state.copyWith(
            isLoading: false,
            user: userEntity,
            isLogoutSuccess: false,
            errorMessage: null,
            isUploadingImage: true,
            successMessage: "image uploaded success",
          ),
        );
        print(
          "FetchUserProfile - State emitted with user: ${userEntity.fullName}",
        ); // Debug print
      },
    );
  }

  Future<void> _onUploadProfilePicture(
    UploadProfilePictureEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(
      state.copyWith(
        isUploadingImage: true,
        errorMessage: null,
        successMessage: null,
      ),
    );

    final result = await uploadProfilePictureUsecase.call(event.imageFile);

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            isUploadingImage: false,
            errorMessage: failure.message,
            isLoading: false,
          ),
        );
      },
      (newProfilePictureUrl) {
        // Update the user with the new profile picture URL
        final updatedUser = state.user?.copyWith(
          profilePicture: newProfilePictureUrl,
        );
        emit(
          state.copyWith(
            isUploadingImage: false,
            user: updatedUser,
            successMessage: 'Profile picture updated successfully!',
            isLogoutSuccess: false,
            isLoading: false,
          ),
        );

        // Refresh user data to get the latest information
        _refreshUserData(emit);
      },
    );
  }

  Future<void> _refreshUserData(Emitter<ProfileState> emit) async {
    try {
      final result = await userGetCurrentUsecase.call();
      result.fold(
        (failure) {
          // Don't emit error here as the upload was successful
          print('Failed to refresh user data: ${failure.message}');
        },
        (userEntity) {
          emit(state.copyWith(user: userEntity));
        },
      );
    } catch (e) {
      print('Error refreshing user data: $e');
    }
  }

  void _onUpdateLocalUser(
    UpdateLocalUserEvent event,
    Emitter<ProfileState> emit,
  ) {
    if (event.profilePictureUrl != null && state.user != null) {
      final updatedUser = state.user!.copyWith(
        profilePicture: event.profilePictureUrl,
      );
      emit(state.copyWith(user: updatedUser));
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<ProfileState> emit) async {
    emit(
      state.copyWith(
        isLoading: true,
        errorMessage: null,
        successMessage: null,
        isLogoutSuccess: false,
      ),
    );
    try {
      await _tokenSharedPrefs.deleteToken();
      await _tokenSharedPrefs.deleteRole();
      await _tokenSharedPrefs.deleteUserId();

      emit(
        state.copyWith(
          isLoading: false,
          isLogoutSuccess: true,
          user: null, // Clear user data on logout
          successMessage: "Logged out successfully!",
        ),
      );
      // Removed showMySnackbar here. UI will react to isLogoutSuccess and successMessage.
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          isLogoutSuccess: false,
          errorMessage: 'Logout failed: $e',
        ),
      );
      // Removed showMySnackbar here. UI will react to errorMessage.
    }
  }

  Future<void> _onUpdateUserProfile(
    UpdateUserProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    print(
      "_onUpdateUserProfile called with name: ${event.fullName}, email: ${event.email}",
    ); // Debug print
    emit(
      state.copyWith(isLoading: true, errorMessage: null, successMessage: null),
    );

    final result = await updateUserProfileUsecase.call(
      event.fullName,
      event.email,
      event.phoneNumber,
      event.currentPassword,
      event.newPassword,
    );

    result.fold(
      (failure) {
        print("Update user failed: ${failure.message}"); // Debug print
        emit(state.copyWith(isLoading: false, errorMessage: failure.message));
      },
      (updatedUser) {
        print("Update user successful: ${updatedUser.fullName}"); // Debug print
        print(
          "Emitting new state with user: ${updatedUser.fullName}, email: ${updatedUser.email}",
        ); // Debug print
        emit(
          state.copyWith(
            isLoading: false,
            user: updatedUser,
            successMessage: 'Profile updated successfully!',
          ),
        );
        print("State emitted successfully"); // Debug print
      },
    );
  }

  Future<void> _onUpdateProfile(
    UpdateUserProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(
      state.copyWith(isLoading: true, errorMessage: null, successMessage: null),
    );
    try {
      final updatedUser = await updateProfileUsecase.call(
        fullName: event.fullName,
        email: event.email,
        phoneNumber: event.phoneNumber,
        currentPassword: event.currentPassword,
        newPassword: event.newPassword,
      );
      emit(
        state.copyWith(
          isLoading: false,
          user: updatedUser,
          successMessage: 'Profile updated successfully!',
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }
}
