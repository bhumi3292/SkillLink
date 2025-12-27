import 'package:dartz/dartz.dart';
import 'package:skill_link/cores/error/failure.dart';
import 'package:skill_link/features/explore/domain/entity/explore_worker_entity.dart';

abstract class ExploreRepository {
  Future<Either<Failure, List<ExploreWorkerEntity>>> getAllWorkers();
  Future<Either<Failure, List<dynamic>>> getWorkerReviews(String workerListingId);
  Future<Either<Failure, bool>> submitReview({
    required String bookingId,
    required double rating,
    String? comment,
  });
}
