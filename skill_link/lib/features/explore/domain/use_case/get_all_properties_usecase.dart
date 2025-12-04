import 'package:dartz/dartz.dart';
import 'package:skill_link/cores/error/failure.dart';
import 'package:skill_link/features/explore/domain/entity/explore_property_entity.dart';
import 'package:skill_link/features/explore/domain/repository/explore_repository.dart';

class GetExplorePropertiesUsecase {
  final ExploreRepository repository;

  GetExplorePropertiesUsecase(this.repository);

  Future<Either<Failure, List<ExplorePropertyEntity>>> call() async {
    return await repository.getAllProperties();
  }
}
