// lib/features/add_worker/domain/use_case/update_worker_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:skill_link/cores/error/failure.dart';
import 'package:skill_link/features/add_worker/domain/entity/worker/worker_entity.dart';
import 'package:skill_link/features/add_worker/domain/repository/worker_repository.dart';

class UpdateWorkerUsecase {
  final IWorkerRepository repository;

  UpdateWorkerUsecase(this.repository);

  Future<Either<Failure, void>> call(
    String workerId,
    WorkerEntity worker,
    List<String> newImagePaths,
    List<String> newVideoPaths,
    List<String> existingImages,
    List<String> existingVideos,
  ) async {
    return await repository.updateWorker(
      workerId,
      worker,
      newImagePaths,
      newVideoPaths,
      existingImages,
      existingVideos,
    );
  }
}
