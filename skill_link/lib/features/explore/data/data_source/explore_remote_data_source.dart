import 'package:dartz/dartz.dart';
import 'package:skill_link/cores/error/failure.dart';
import 'package:dio/dio.dart';
import 'package:skill_link/cores/network/api_service.dart';
import 'package:skill_link/features/explore/data/model/explore_worker_model.dart';
import 'package:skill_link/app/constant/api_endpoints.dart';

abstract class ExploreRemoteDataSource {
  Future<Either<Failure, List<ExploreWorkerModel>>> getAllWorkers();
  Future<Either<Failure, List<dynamic>>> getWorkerReviews(String workerListingId);
  Future<Either<Failure, bool>> submitReview({
    required String bookingId,
    required double rating,
    String? comment,
  });
}

class ExploreRemoteDataSourceImpl implements ExploreRemoteDataSource {
  final ApiService apiService;

  ExploreRemoteDataSourceImpl(this.apiService);

  @override
  Future<Either<Failure, List<ExploreWorkerModel>>> getAllWorkers() async {
    try {
      final response = await apiService.dio.get(ApiEndpoints.getAllWorkers.replaceFirst(ApiEndpoints.baseUrl, ''));

      if (response.statusCode == 200) {
        final responseData = response.data;
        List<dynamic> workerData = [];

        if (responseData is Map<String, dynamic>) {
          dynamic maybe = responseData.containsKey('data') ? responseData['data'] : responseData;
          if (maybe is List) workerData = maybe;
          else if (maybe is Map && maybe.containsKey('workers')) workerData = maybe['workers'];
        } else if (responseData is List) {
          workerData = responseData;
        }

        final properties = <ExploreWorkerModel>[];
        for (var item in workerData) {
          if (item is Map<String, dynamic>) {
            properties.add(ExploreWorkerModel.fromJson(item));
          }
        }
        return Right(properties);
      } else {
        return Left(ServerFailure(message: 'Failed to fetch workers'));
      }
    } catch (e) {
      return Left(NetworkFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<dynamic>>> getWorkerReviews(String workerListingId) async {
    try {
      final response = await apiService.dio.get(
        ApiEndpoints.getWorkerReviews(workerListingId).replaceFirst(ApiEndpoints.baseUrl, ''),
      );
      if (response.statusCode == 200) {
        return Right(response.data['data'] as List<dynamic>);
      }
      return Left(ServerFailure(message: 'Failed to fetch reviews'));
    } catch (e) {
      return Left(NetworkFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> submitReview({
    required String bookingId,
    required double rating,
    String? comment,
  }) async {
    try {
      final response = await apiService.dio.post(
        ApiEndpoints.submitReview.replaceFirst(ApiEndpoints.baseUrl, ''),
        data: {
          'bookingId': bookingId,
          'rating': rating,
          'comment': comment,
        },
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        return const Right(true);
      }
      return Left(ServerFailure(message: response.data['message'] ?? 'Failed to submit review'));
    } catch (e) {
      return Left(NetworkFailure(message: e.toString()));
    }
  }
}
