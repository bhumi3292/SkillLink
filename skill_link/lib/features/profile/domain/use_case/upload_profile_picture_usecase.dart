import 'package:dartz/dartz.dart';
import 'package:skill_link/app/use_case/usecase.dart';
import 'package:skill_link/cores/error/failure.dart';
// Ensure correct path
import 'package:skill_link/features/auth/domain/repository/user_repository.dart'; // Still uses IUserRepository
import 'dart:io'; // For File




class UploadProfilePictureUsecase implements UsecaseWithParams<String, File> {
  final IUserRepository _userRepository;

  UploadProfilePictureUsecase({required IUserRepository userRepository})
      : _userRepository = userRepository;

  @override
  Future<Either<Failure, String>> call(File imageFile) {
    return _userRepository.uploadProfilePicture(imageFile);
  }
}