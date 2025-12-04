import 'package:dartz/dartz.dart';
import 'package:skill_link/cores/error/failure.dart';
import 'package:skill_link/features/auth/domain/entity/user_entity.dart';
import 'package:skill_link/features/auth/domain/repository/user_repository.dart';
import 'dart:io'; // For File, if you want to add uploadProfilePicture to local repo

class UserLocalRepository implements IUserRepository {
  UserLocalRepository();

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, String>> loginUser(
    String email,
    String password,
    String stakeholder,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> registerUser(UserEntity user) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, String>> uploadProfilePicture(File imageFile) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, UserEntity>> updateUser(
    String fullName,
    String email,
    String? phoneNumber,
    String? currentPassword,
    String? newPassword,
  ) async {
    throw UnimplementedError();
  }
}
