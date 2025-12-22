import 'package:dartz/dartz.dart';
import 'package:skill_link/cores/error/failure.dart';
import 'package:dio/dio.dart';
import 'package:skill_link/cores/network/api_service.dart';
import 'package:skill_link/features/explore/data/model/explore_worker_model.dart';
import 'package:skill_link/features/add_worker/data/model/worker_model/worker_api_model.dart';
import 'package:skill_link/app/constant/api_endpoints.dart';

abstract class ExploreRemoteDataSource {
  Future<Either<Failure, List<ExploreWorkerModel>>> getAllWorkers();
}

class ExploreRemoteDataSourceImpl implements ExploreRemoteDataSource {
  final ApiService apiService;

  ExploreRemoteDataSourceImpl(this.apiService);

  @override
  Future<Either<Failure, List<ExploreWorkerModel>>> getAllWorkers() async {
    try {
      // Fetch workers (previously properties). Backend exposes worker routes
      // at /api/properties (aliased to workers in frontend constants).
      final response = await apiService.dio.get(ApiEndpoints.getAllWorkers.replaceFirst(ApiEndpoints.baseUrl, ''));

      if (response.statusCode == 200) {
        final responseData = response.data;
        print(
          'ExploreRemoteDataSource - Response data type: ${responseData.runtimeType}',
        );
        print('ExploreRemoteDataSource - Response data: $responseData');

        // Normalize the response to extract a List<dynamic> of workers
        List<dynamic> workerData = [];

        try {
          if (responseData is Map<String, dynamic>) {
            dynamic maybe = responseData;
            if (responseData.containsKey('data')) {
              maybe = responseData['data'];
            } else if (responseData.containsKey('properties'))
              maybe = responseData['properties'];
            else if (responseData.containsKey('results'))
              maybe = responseData['results'];

            if (maybe is List) {
              workerData = maybe;
            } else if (maybe is Map<String, dynamic>) {
              // Look for common container keys
              if (maybe.containsKey('workers') && maybe['workers'] is List) {
                workerData = maybe['workers'];
              } else if (maybe.containsKey('items') && maybe['items'] is List) {
                workerData = maybe['items'];
              } else if (maybe.containsKey('docs') && maybe['docs'] is List) {
                workerData = maybe['docs'];
              } else {
                // Not a list container — try treating the map itself as a single item
                workerData = [maybe];
              }
            } else {
              // unexpected shape, leave workerData empty
              workerData = [];
            }
          } else if (responseData is List) {
            workerData = responseData;
          }
        } catch (e) {
          print('ExploreRemoteDataSource - normalization error: $e');
          workerData = [];
        }

        final properties = <ExploreWorkerModel>[];
        for (var item in workerData) {
          try {
            if (item is Map<String, dynamic>) {
              properties.add(ExploreWorkerModel.fromJson(item));
            } else if (item is String) {
              // If the backend returns a JSON string, try to parse it defensively
              print(
                'ExploreRemoteDataSource - unexpected string item, skipping: $item',
              );
            } else {
              print(
                'ExploreRemoteDataSource - skipped unsupported item type: ${item.runtimeType}',
              );
            }
          } catch (e) {
            print('ExploreRemoteDataSource - failed to parse worker item: $e');
          }
        }

        return Right(properties);
      } else {
        return Left(
          ServerFailure(
            message: 'Failed to fetch properties: ${response.statusCode}',
          ),
        );
      }
    } catch (e) {
      print('ExploreRemoteDataSource Error: $e');
      // Provide more details for Dio errors
      try {
        if (e is DioException) {
          print('DioException type: ${e.type}');
          print(
            'Request Options: ${e.requestOptions.method} ${e.requestOptions.path}',
          );
          print('DioException message: ${e.message}');
          print(
            'DioException response: ${e.response?.statusCode} ${e.response?.data}',
          );
        }
      } catch (logErr) {
        print('Error logging DioException details: $logErr');
      }
      return Left(NetworkFailure(message: e.toString()));
    }
  }
}
