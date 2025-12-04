import 'package:dio/dio.dart';
import 'package:skill_link/cores/network/api_service.dart';
import 'package:skill_link/features/add_property/data/model/property_model/property_api_model.dart';

abstract class DashboardRemoteDatasource {
  Future<List<PropertyApiModel>> getDashboardProperties();
}

class DashboardRemoteDatasourceImpl implements DashboardRemoteDatasource {
  final ApiService _apiService;

  DashboardRemoteDatasourceImpl({required ApiService apiService})
    : _apiService = apiService;

  @override
  Future<List<PropertyApiModel>> getDashboardProperties() async {
    try {
      final response = await _apiService.dio.get('/properties');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> propertiesJson = response.data['data'];
        return propertiesJson
            .map((json) => PropertyApiModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load dashboard properties');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
