// lib/features/add_worker/domain/use_case/get_all_worker_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:skill_link/app/use_case/usecase.dart';
import 'package:skill_link/cores/error/failure.dart';
import 'package:skill_link/features/add_worker/domain/entity/worker/worker_entity.dart';
import 'package:skill_link/features/add_worker/domain/repository/worker_repository.dart';

class GetAllWorkersUsecase implements UsecaseWithoutParams<List<WorkerEntity>> {
  final IWorkerRepository repository;

  GetAllWorkersUsecase(this.repository);

  @override
  Future<Either<Failure, List<WorkerEntity>>> call() async {
    return await repository.getWorkers();
  }
}
