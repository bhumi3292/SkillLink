import 'package:dartz/dartz.dart';
import 'package:skill_link/cores/error/failure.dart';
import 'package:skill_link/features/explore/domain/entity/explore_worker_entity.dart';
import 'package:skill_link/features/explore/domain/repository/explore_repository.dart';

class GetAllWorkersUsecase {
  final ExploreRepository repository;

  GetAllWorkersUsecase(this.repository);

  Future<Either<Failure, List<ExploreWorkerEntity>>> call({double? lat, double? long}) async {
    return await repository.getAllWorkers(lat: lat, long: long);
  }
}
