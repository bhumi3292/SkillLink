import 'package:dartz/dartz.dart';
import 'package:skill_link/cores/error/failure.dart';
import 'package:skill_link/features/explore/data/data_source/explore_remote_data_source.dart';
import 'package:skill_link/features/explore/domain/entity/explore_property_entity.dart';
import 'package:skill_link/features/explore/domain/repository/explore_repository.dart';

class ExploreRepositoryImpl implements ExploreRepository {
  final ExploreRemoteDataSource remoteDataSource;

  ExploreRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<ExplorePropertyEntity>>>
  getAllProperties() async {
    final result = await remoteDataSource.getAllProperties();
    return result;
  }
}
