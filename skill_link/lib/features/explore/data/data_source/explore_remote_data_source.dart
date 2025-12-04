import 'package:dartz/dartz.dart';
import 'package:skill_link/cores/error/failure.dart';
import 'package:skill_link/cores/network/api_service.dart';
import 'package:skill_link/features/explore/data/model/explore_property_model.dart';

abstract class ExploreRemoteDataSource {
  Future<Either<Failure, List<ExplorePropertyModel>>> getAllProperties();
}

class ExploreRemoteDataSourceImpl implements ExploreRemoteDataSource {
  final ApiService apiService;

  ExploreRemoteDataSourceImpl(this.apiService);

  @override
  Future<Either<Failure, List<ExplorePropertyModel>>> getAllProperties() async {
    try {
      final response = await apiService.dio.get('/properties');

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
              'ExploreRemoteDataSource - Found data key with ${propertiesData.length} properties',
            );
          } else if (responseData.containsKey('properties')) {
            propertiesData = responseData['properties'] as List<dynamic>;
            print(
              'ExploreRemoteDataSource - Found properties key with ${propertiesData.length} properties',
            );
          } else if (responseData.containsKey('results')) {
            propertiesData = responseData['results'] as List<dynamic>;
            print(
              'ExploreRemoteDataSource - Found results key with ${propertiesData.length} properties',
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
            'ExploreRemoteDataSource - Response is directly a list with ${propertiesData.length} properties',
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
            propertiesData
                .map((json) => ExplorePropertyModel.fromJson(json))
                .toList();
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
