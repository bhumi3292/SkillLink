import 'package:skill_link/features/profile/data/data_source/profile_remote_data_source.dart';
import 'package:skill_link/features/auth/domain/entity/user_entity.dart';

class ProfileRepositoryImpl {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  Future<UserEntity> updateProfile({
    required String fullName,
    required String email,
    String? phoneNumber,
    String? currentPassword,
    String? newPassword,
  }) {
    return remoteDataSource.updateProfile(
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
}

