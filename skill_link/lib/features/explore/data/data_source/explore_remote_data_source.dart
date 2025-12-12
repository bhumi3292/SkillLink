import 'package:dartz/dartz.dart';
import 'package:skill_link/cores/error/failure.dart';
import 'package:skill_link/cores/network/api_service.dart';
import 'package:skill_link/features/explore/data/model/explore_property_model.dart';
import 'package:skill_link/features/add_worker/data/model/worker_model/worker_api_model.dart';
import 'package:skill_link/features/explore/presentation/utils/property_converter.dart';

abstract class ExploreRemoteDataSource {
  Future<Either<Failure, List<ExplorePropertyModel>>> getAllProperties();
}

class ExploreRemoteDataSourceImpl implements ExploreRemoteDataSource {
  final ApiService apiService;

  ExploreRemoteDataSourceImpl(this.apiService);

  @override
  Future<Either<Failure, List<ExplorePropertyModel>>> getAllProperties() async {
    try {
      // Fetch workers (previously properties). Backend exposes worker routes
      // at /api/workers (also kept /api/properties for compatibility).
      final response = await apiService.dio.get('/workers');

      if (response.statusCode == 200) {
        final responseData = response.data;
        print(
          'ExploreRemoteDataSource - Response data type: ${responseData.runtimeType}',
        );
        print('ExploreRemoteDataSource - Response data: $responseData');

        // Handle different response structures
        List<dynamic> propertiesData;
        if (responseData is Map<String, dynamic>) {
          // If response is a map, look for 'data' or 'properties' key
          if (responseData.containsKey('data')) {
            propertiesData = responseData['data'] as List<dynamic>;
            print(
              'ExploreRemoteDataSource - Found data key with ${propertiesData.length} items',
            );
          } else if (responseData.containsKey('properties')) {
            propertiesData = responseData['properties'] as List<dynamic>;
            print(
              'ExploreRemoteDataSource - Found properties key with ${propertiesData.length} items',
            );
          } else if (responseData.containsKey('results')) {
            propertiesData = responseData['results'] as List<dynamic>;
            print(
              'ExploreRemoteDataSource - Found results key with ${propertiesData.length} items',
            );
          } else {
            // If no specific key found, try to use the entire response as a list
            // This handles cases where the API might return the array directly
            print(
              'ExploreRemoteDataSource - No data/properties/results key found in response',
            );
            return Left(
              ServerFailure(
                message: 'Invalid response format: expected properties array',
              ),
            );
          }
        } else if (responseData is List<dynamic>) {
          // If response is directly a list
          propertiesData = responseData;
          print(
            'ExploreRemoteDataSource - Response is directly a list with ${propertiesData.length} items',
          );
        } else {
          print(
            'ExploreRemoteDataSource - Invalid response type: ${responseData.runtimeType}',
          );
          return Left(
            ServerFailure(
              message: 'Invalid response format: expected Map or List',
            ),
          );
        }

        final properties =
            propertiesData.map((json) {
              try {
                // If JSON matches the property shape, use the existing parser
                if (json is Map<String, dynamic> &&
                    (json.containsKey('title') ||
                        json.containsKey('bedrooms') ||
                        json.containsKey('price'))) {
                  return ExplorePropertyModel.fromJson(
                    json as Map<String, dynamic>,
                  );
                }

                // Fallback: treat response as Worker object and convert
                final workerApi = WorkerApiModel.fromJson(
                  (json as Map<String, dynamic>),
                );
                // Use the worker fields to build an ExplorePropertyModel
                return ExplorePropertyModel(
                  id: workerApi.id,
                  images: workerApi.images,
                  videos: workerApi.videos,
                  title: workerApi.title ?? workerApi.id,
                  location: workerApi.location,
                  bedrooms: null,
                  bathrooms: null,
                  categoryId: workerApi.categoryId,
                  categoryName: null,
                  price: workerApi.price,
                  description: workerApi.description,
                  workerId: workerApi.workerId,
                  workerName: 'Worker',
                  workerEmail: null,
                  workerPhone: null,
                );
              } catch (e) {
                // As a last resort, try property parser which may throw otherwise
                return ExplorePropertyModel.fromJson(
                  json as Map<String, dynamic>,
                );
              }
            }).toList();
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
      return Left(NetworkFailure(message: e.toString()));
    }
  }
}
