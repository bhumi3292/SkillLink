import 'package:dartz/dartz.dart';
import 'package:skill_link/cores/error/failure.dart';
import 'package:skill_link/features/explore/domain/entity/explore_property_entity.dart';

abstract class ExploreRepository {
  Future<Either<Failure, List<ExplorePropertyEntity>>> getAllProperties();
}
