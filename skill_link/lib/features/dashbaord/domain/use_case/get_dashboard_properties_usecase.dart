import 'package:dartz/dartz.dart';
import 'package:skill_link/app/use_case/usecase.dart';
import 'package:skill_link/cores/error/failure.dart';
import 'package:skill_link/features/dashbaord/domain/repository/dashboard_repository.dart';
import 'package:skill_link/features/add_worker/data/model/worker_model/worker_api_model.dart';

class GetDashboardPropertiesUsecase
    implements UsecaseWithoutParams<List<WorkerApiModel>> {
  final DashboardRepository _repository;

  GetDashboardPropertiesUsecase({required DashboardRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, List<WorkerApiModel>>> call() async {
    try {
      final properties = await _repository.getDashboardProperties();
      return Right(properties);
    } catch (e) {
      return Left(NetworkFailure(message: e.toString()));
    }
  }
}
