// lib/features/add_worker/domain/use_case/delete_worker_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:skill_link/cores/error/failure.dart';
import 'package:skill_link/features/add_worker/domain/repository/property_repository.dart';

class DeleteWorkerUsecase {
  final IWorkerRepository repository;

  DeleteWorkerUsecase(this.repository);

  Future<Either<Failure, void>> call(String workerId) async {
    return await repository.deleteWorker(workerId);
  }
}
