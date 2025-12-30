import 'package:dartz/dartz.dart';
import 'package:skill_link/cores/error/failure.dart';
import 'package:skill_link/features/explore/domain/entity/explore_worker_entity.dart';
import 'package:skill_link/features/profile/domain/repository/worker_profile_repository.dart';
import 'dart:io';

class UpdateWorkerProfileUseCase {
  final IWorkerProfileRepository repository;

  UpdateWorkerProfileUseCase(this.repository);

  Future<Either<Failure, ExploreWorkerEntity>> call(String id, Map<String, dynamic> data, List<File>? newImages) {
    return repository.updateWorker(id, data, newImages);
  }
}
