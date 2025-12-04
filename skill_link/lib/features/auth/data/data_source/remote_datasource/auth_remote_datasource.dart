import 'package:dio/dio.dart';

class AuthRemoteDatasource {
  final Dio _dio;
  AuthRemoteDatasource(this._dio);

  // Request password reset link
  Future<void> requestPasswordResetLink(String email) async {
    final response = await _dio.post('/api/auth/request-reset/send-link', data: {'email': email});
    if (response.statusCode != 200) {
      throw Exception(response.data['message'] ?? 'Failed to send reset link');
    }
  }

  // Reset password with token
  Future<void> resetPassword({required String token, required String newPassword, required String confirmPassword}) async {
    final response = await _dio.post(
      '/api/auth/reset-password/$token',
      data: {'newPassword': newPassword, 'confirmPassword': confirmPassword},
    );
    if (response.statusCode != 200) {
      throw Exception(response.data['message'] ?? 'Failed to reset password');
    }
  }
} 