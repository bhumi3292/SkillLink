import 'package:dartz/dartz.dart';
import 'package:skill_link/cores/error/failure.dart';
import 'package:skill_link/features/explore/data/data_source/explore_remote_data_source.dart';
import 'package:skill_link/features/explore/domain/entity/explore_worker_entity.dart';
import 'package:skill_link/features/explore/domain/repository/explore_repository.dart';

class ExploreRepositoryImpl implements ExploreRepository {
  final ExploreRemoteDataSource remoteDataSource;

  ExploreRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<ExploreWorkerEntity>>> getAllWorkers() async {
    return await remoteDataSource.getAllWorkers();
  }

  @override
  Future<Either<Failure, List<dynamic>>> getWorkerReviews(String workerListingId) async {
    return await remoteDataSource.getWorkerReviews(workerListingId);
  }

  @override
  Future<Either<Failure, bool>> submitReview({
    required String bookingId,
    required double rating,
    String? comment,
  }) async {
    return await remoteDataSource.submitReview(
      bookingId: bookingId,
      rating: rating,
      comment: comment,
    );
  }
}
