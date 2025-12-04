import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:skill_link/app/use_case/usecase.dart';
import 'package:skill_link/cores/error/failure.dart';
import 'package:skill_link/features/auth/domain/entity/user_entity.dart';
import 'package:skill_link/features/auth/domain/repository/user_repository.dart';

class RegisterUserParams extends Equatable {
  final String fullName;
  final String email;
  final String phoneNumber;
  final String stakeholder;
  final String password;
  final String confirmPassword;

  const RegisterUserParams({
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.stakeholder,
    required this.password,
    required this.confirmPassword,
  });

  @override
  List<Object?> get props => [
    fullName,
    email,
    phoneNumber,
    stakeholder,
    password,
    confirmPassword,
  ];
}

class UserRegisterUsecase
    implements UsecaseWithParams<void, RegisterUserParams> {
  final IUserRepository _userRepository;

  UserRegisterUsecase({required IUserRepository userRepository})
    : _userRepository = userRepository;

  @override
  Future<Either<Failure, void>> call(RegisterUserParams params) {
    print("calling from register usecase");

    // When registering, password and confirmPassword are required
    final userEntity = UserEntity(
      fullName: params.fullName,
      email: params.email,
      phoneNumber: params.phoneNumber,
      stakeholder: params.stakeholder,
      password: params.password,
      confirmPassword: params.confirmPassword,
    );
    return _userRepository.registerUser(userEntity);
  }
}
