import 'package:dartz/dartz.dart';
import 'package:skill_link/cores/error/failure.dart';
import 'package:skill_link/features/profile/domain/repository/worker_profile_repository.dart';

class DeactivateWorkerUseCase {
  final IWorkerProfileRepository repository;

  DeactivateWorkerUseCase(this.repository);

  Future<Either<Failure, void>> call(String id) {
    return repository.deactivateWorker(id);
  }
}
