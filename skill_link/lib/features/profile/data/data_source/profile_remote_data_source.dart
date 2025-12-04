import 'package:dio/dio.dart';
import 'package:skill_link/app/constant/api_endpoints.dart';
import 'package:skill_link/cores/network/api_service.dart';
import 'package:skill_link/features/auth/domain/entity/user_entity.dart';

class ProfileRemoteDataSource {
  final ApiService _apiService;

  ProfileRemoteDataSource({required ApiService apiService}) : _apiService = apiService;

  Future<UserEntity> updateProfile({
    required String fullName,
    required String email,
    String? phoneNumber,
    String? currentPassword,
    String? newPassword,
  }) async {
    try {
      final response = await _apiService.dio.put(
        ApiEndpoints.updateUser, // Corrected endpoint for updating user profile
        data: {
          'fullName': fullName,
          'email': email,
          'phoneNumber': phoneNumber,

        },
      );
      if (response.statusCode == 200) {
        // Assuming the updated user is returned in response.data['user']
        return UserEntity(
          userId: response.data['user']['userId'],
          fullName: response.data['user']['fullName'],
          email: response.data['user']['email'],
          phoneNumber: response.data['user']['phoneNumber'],
          stakeholder: response.data['user']['stakeholder'],
          profilePicture: response.data['user']['profilePicture'],
        );
      } else {
        throw Exception('Failed to update profile: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to update profile: ${e.error}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
}
