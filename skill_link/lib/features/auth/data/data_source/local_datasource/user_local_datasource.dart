import 'package:skill_link/features/auth/domain/entity/user_entity.dart';

class UserLocalDatasource {
  UserLocalDatasource();

  Future<String> loginUser(
    String email,
    String password,
    String stakeholder,
  ) async {
    throw UnimplementedError();
  }

  Future<void> registerUser(UserEntity user) async {
    throw UnimplementedError();
  }

  Future<UserEntity> getCurrentUser() async {
    throw UnimplementedError();
  }
}
