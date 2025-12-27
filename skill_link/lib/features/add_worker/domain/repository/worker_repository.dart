// lib/features/add_worker/domain/repository/worker_repository.dart

import 'package:dartz/dartz.dart';
import 'package:skill_link/cores/error/failure.dart';
import 'package:skill_link/features/add_worker/domain/entity/worker/worker_entity.dart';

/// Repository interface for Worker operations (was IWorkerRepository)
abstract interface class IWorkerRepository {
  Future<Either<Failure, void>> addWorker(
    WorkerEntity worker,
    List<String> imagePaths,
    List<String> videoPaths,
  );

  Future<Either<Failure, void>> deleteWorker(String workerId);
  Future<Either<Failure, List<WorkerEntity>>> getWorkers();
  Future<Either<Failure, WorkerEntity>> getWorkerById(String workerId);

  Future<Either<Failure, void>> updateWorker(
    String workerId,
    WorkerEntity updatedWorker,
    List<String> newImagePaths,
    List<String> newVideoPaths,
    List<String> existingImages,
    List<String> existingVideos,
  );
}
