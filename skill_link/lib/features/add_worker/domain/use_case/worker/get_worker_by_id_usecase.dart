// lib/features/add_worker/domain/use_case/get_worker_by_id_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:skill_link/app/use_case/usecase.dart';
import 'package:skill_link/cores/error/failure.dart';
import 'package:skill_link/features/add_worker/domain/entity/worker/worker_entity.dart';
import 'package:skill_link/features/add_worker/domain/repository/property_repository.dart';

class GetWorkerByIdUsecase implements UsecaseWithParams<WorkerEntity, String> {
  final IWorkerRepository repository;

  GetWorkerByIdUsecase(this.repository);

  @override
  Future<Either<Failure, WorkerEntity>> call(String workerId) async {
    return await repository.getWorkerById(workerId);
  }
}
