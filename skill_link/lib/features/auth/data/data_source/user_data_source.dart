import 'package:skill_link/features/auth/domain/entity/user_entity.dart';

abstract interface class IUserDataSource {
  Future<void> registerUser(UserEntity userData);

  Future<Map<String, dynamic>> loginUser(
    String email,
    String password,
    String stakeholder,
  );
  Future<UserEntity> getCurrentUser();
  Future<UserEntity> updateUser(
    String fullName,
    String email,
    String? phoneNumber,
    String? currentPassword,
    String? newPassword,
  );
}
