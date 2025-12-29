import 'package:skill_link/app/constant/api_endpoints.dart';
import 'package:skill_link/cores/network/api_service.dart';

class AdminRemoteDataSource {
  final ApiService _apiService;

  AdminRemoteDataSource(this._apiService);

  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await _apiService.dio.get(ApiEndpoints.adminDashboardStats);
      if (response.statusCode == 200) {
        return response.data['data'];
      }
      throw Exception('Failed to load stats');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<dynamic>> getPendingWorkers() async {
    try {
      final response = await _apiService.dio.get(ApiEndpoints.adminPendingWorkers);
      if (response.statusCode == 200) {
        return response.data['data'];
      }
      throw Exception('Failed to load pending workers');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> verifyWorker(String workerId, String action, String? rejectionReason) async {
    try {
      final response = await _apiService.dio.post(
        ApiEndpoints.adminVerifyWorker,
        data: {
          'workerId': workerId,
          'action': action, // 'approve' or 'reject'
          if (rejectionReason != null) 'rejectionReason': rejectionReason,
        },
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to verify worker');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<dynamic>> getAllUsers() async {
    try {
      final response = await _apiService.dio.get(ApiEndpoints.adminAllUsers);
      if (response.statusCode == 200) {
        return response.data['data'];
      }
      throw Exception('Failed to load users');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> toggleUserSuspension(String userId) async {
    try {
      final response = await _apiService.dio.patch(ApiEndpoints.toggleUserSuspension(userId));
      if (response.statusCode != 200) {
        throw Exception('Failed to toggle suspension');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> toggleCategoryStatus(String categoryId) async {
    try {
      final response = await _apiService.dio.patch(ApiEndpoints.toggleCategoryStatus(categoryId));
      if (response.statusCode != 200) {
        throw Exception('Failed to toggle category status');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<dynamic>> getAllBookings() async {
    try {
      final response = await _apiService.dio.get(ApiEndpoints.adminAllBookings);
      if (response.statusCode == 200) {
        return response.data['data'];
      }
      throw Exception('Failed to load bookings');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
