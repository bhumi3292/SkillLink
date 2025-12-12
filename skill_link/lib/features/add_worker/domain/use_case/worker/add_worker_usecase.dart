import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:skill_link/app/use_case/usecase.dart';
import 'package:skill_link/cores/error/failure.dart';
import 'package:skill_link/features/add_worker/domain/entity/worker/worker_entity.dart';
import 'package:skill_link/features/add_worker/domain/repository/property_repository.dart';

class AddWorkerParams extends Equatable {
  final WorkerEntity worker;
  final List<String> imagePaths;
  final List<String> videoPaths;

  const AddWorkerParams({
    required this.worker,
    required this.imagePaths,
    required this.videoPaths,
  });

  @override
  List<Object?> get props => [worker, imagePaths, videoPaths];
}

class AddWorkerUsecase implements UsecaseWithParams<void, AddWorkerParams> {
  final IWorkerRepository repository;

  AddWorkerUsecase({required this.repository});

  @override
  Future<Either<Failure, void>> call(AddWorkerParams params) async {
    return await repository.addWorker(
      params.worker,
      params.imagePaths,
      params.videoPaths,
    );
  }
}
