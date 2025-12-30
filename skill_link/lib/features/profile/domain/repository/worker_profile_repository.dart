import 'package:dartz/dartz.dart';
import 'package:skill_link/cores/error/failure.dart';
import 'package:skill_link/features/explore/domain/entity/explore_worker_entity.dart';
import 'dart:io';

abstract interface class IWorkerProfileRepository {
  Future<Either<Failure, ExploreWorkerEntity>> getWorkerById(String id);
  Future<Either<Failure, ExploreWorkerEntity>> updateWorker(String id, Map<String, dynamic> data, List<File>? newImages);
  Future<Either<Failure, void>> deactivateWorker(String id);
}
