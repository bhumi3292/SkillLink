import 'package:skill_link/features/profile/data/repository/profile_repository_impl.dart';
import 'package:skill_link/features/auth/domain/entity/user_entity.dart';

class UpdateProfileUsecase {
  final ProfileRepositoryImpl repository;

  UpdateProfileUsecase({required this.repository});

  Future<UserEntity> call({
    required String fullName,
    required String email,
    String? phoneNumber,
    String? currentPassword,
    String? newPassword,
  }) {
    return repository.updateProfile(
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
} 