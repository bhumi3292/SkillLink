import 'package:dio/dio.dart';
import 'package:skill_link/app/constant/api_endpoints.dart';
import 'package:skill_link/cores/network/api_service.dart';
import 'package:skill_link/features/auth/data/data_source/user_data_source.dart';
import 'package:skill_link/features/auth/data/model/user_api_model.dart';
import 'package:skill_link/features/auth/domain/entity/user_entity.dart';
import 'dart:io';

import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserRemoteDatasource implements IUserDataSource {
  final ApiService _apiService;
  final SharedPreferences _sharedPreferences;

  UserRemoteDatasource({
    required ApiService apiService,
    required SharedPreferences sharedPreferences,
  }) : _apiService = apiService,
       _sharedPreferences = sharedPreferences;

  @override
  Future<void> registerUser(UserEntity user) async {
    try {
      final model = UserApiModel.fromEntity(user);
      print(model);
      final response = await _apiService.dio.post(
        ApiEndpoints.register,
        data: {
          "fullName": user.fullName,
          "email": user.email,
          "phoneNumber": user.phoneNumber,
          "stakeholder": user.stakeholder,
          "password": user.password,
          "confirmPassword": user.confirmPassword,
        },
      );
      print('DEBUG: Registration response: ${response.data}');
      if (response.statusCode != 201) {
        throw Exception(
          'Registration failed with status code: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Failed to register user: ${e.error}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  @override
  Future<String> loginUser(
    String email,
    String password,
    String stakeholder,
  ) async {
    try {
      final response = await _apiService.dio.post(
        ApiEndpoints.login,
        data: {
          "email": email,
          "password": password,
          "stakeholder": stakeholder,
        },
      );
      print('DEBUG: Login response: ${response.data}');
      if (response.statusCode == 200) {
        final token = response.data['token'];
        final userId = response.data['user']?['_id'];
        final role = response.data['user']?['stakeholder'] ?? stakeholder;
        if (token == null || (token as String).isEmpty) {
          throw Exception("Login successful but no token was received.");
        }
        return token;
      } else {
        print(response.statusCode);
        throw Exception(
          "Login failed: ${response.statusCode} ${response.statusMessage}",
        );
      }
    } on DioException catch (e) {
      print("error:$e");
      throw Exception('Failed to login: ${e.error}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  @override
  Future<UserEntity> getCurrentUser() async {
    try {
      final response = await _apiService.dio.get(ApiEndpoints.getCurrentUser);
      print('DEBUG: Full Response from /auth/me: ${response.data}');
      print('DEBUG: Type of response.data: ${response.data.runtimeType}');

      if (response.statusCode == 200) {
        final userApiModel = UserApiModel.fromJson(response.data['user']);
        return userApiModel.toEntity();
      } else {
        throw Exception(
          "Failed to fetch user: ${response.statusCode} ${response.statusMessage}",
        );
      }
    } on DioException catch (e) {
      print(
        'DEBUG ERROR: DioException in getCurrentUser: ${e.response?.data ?? e.message}',
      );
      throw Exception('Failed to fetch user: ${e.error}');
    } catch (e) {
      print('DEBUG ERROR: Unexpected error in getCurrentUser: $e');
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<String> uploadProfilePicture(File imageFile) async {
    try {
      final fileName = imageFile.path.split('/').last;
      final fileExtension = imageFile.path.split('.').last.toLowerCase();
      final contentType = (fileExtension == 'png') ? 'image/png' : 'image/jpeg';

      final formData = FormData.fromMap({
        'profilePicture': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
          contentType: MediaType.parse(contentType),
        ),
      });

      print('DEBUG: FormData fields: ${formData.fields}');
      print('DEBUG: FormData files: ${formData.files}');

      final response = await _apiService.dio.post(
        ApiEndpoints.uploadProfilePicture,
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );
      // print(response.data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Assuming backend returns new URL under 'profilePictureUrl' or similar
        return response.data['imageUrl'] as String;
      } else {
        throw Exception(
          "Failed to upload profile picture: ${response.statusCode} ${response.statusMessage}",
        );
      }
    } on DioException catch (e) {
      print(
        'DEBUG ERROR: DioException in uploadProfilePicture: ${e.response?.data ?? e.message}',
      );
      throw Exception('Failed to upload profile picture: ${e.error}');
    } catch (e) {
      print('DEBUG ERROR: Unexpected error in uploadProfilePicture: $e');
      throw Exception('An unexpected error occurred: $e');
    }
  }

  @override
  Future<UserEntity> updateUser(
    String fullName,
    String email,
    String? phoneNumber,
    String? currentPassword,
    String? newPassword,
  ) async {
    try {
      final requestBody = {
        'fullName': fullName,
        'email': email,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        if (currentPassword != null) 'currentPassword': currentPassword,
        if (newPassword != null) 'newPassword': newPassword,
      };

      final response = await _apiService.dio.put(
        ApiEndpoints.updateUser,
        data: requestBody,
      );

      print('DEBUG: Update user response: ${response.data}');

      if (response.statusCode == 200) {
        final userApiModel = UserApiModel.fromJson(response.data['user']);
        return userApiModel.toEntity();
      } else {
        throw Exception(
          "Failed to update user: ${response.statusCode} ${response.statusMessage}",
        );
      }
    } on DioException catch (e) {
      print(
        'DEBUG ERROR: DioException in updateUser: ${e.response?.data ?? e.message}',
      );
      throw Exception('Failed to update user: ${e.error}');
    } catch (e) {
      print('DEBUG ERROR: Unexpected error in updateUser: $e');
      throw Exception('An unexpected error occurred: $e');
    }
  }
}
