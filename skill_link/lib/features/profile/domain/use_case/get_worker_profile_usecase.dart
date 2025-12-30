import 'package:dartz/dartz.dart';
import 'package:skill_link/cores/error/failure.dart';
import 'package:skill_link/features/explore/domain/entity/explore_worker_entity.dart';
import 'package:skill_link/features/profile/domain/repository/worker_profile_repository.dart';

class GetWorkerProfileUseCase {
  final IWorkerProfileRepository repository;

  GetWorkerProfileUseCase(this.repository);

  Future<Either<Failure, ExploreWorkerEntity>> call(String id) {
    return repository.getWorkerById(id);
  }
}
