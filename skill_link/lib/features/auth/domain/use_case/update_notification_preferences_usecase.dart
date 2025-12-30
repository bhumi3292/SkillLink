import 'package:dartz/dartz.dart';
import 'package:skill_link/cores/error/failure.dart';
import 'package:skill_link/features/auth/domain/entity/user_entity.dart';
import 'package:skill_link/features/auth/domain/repository/user_repository.dart';

class UpdateNotificationPreferencesUseCase {
  final IUserRepository repository;

  UpdateNotificationPreferencesUseCase(this.repository);

  Future<Either<Failure, NotificationPreferences>> call({
    required bool push,
    required bool booking,
    required bool chat,
  }) {
    return repository.updateNotificationPreferences(push, booking, chat);
  }
}
