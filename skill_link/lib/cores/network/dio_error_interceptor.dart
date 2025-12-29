// lib/cores/network/dio_error_interceptor.dart
import 'package:dio/dio.dart';

class DioErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    String errorMessage;

    if (err.response != null) {
      final statusCode = err.response?.statusCode ?? 0;
      if (statusCode >= 300) {
        final data = err.response?.data;
        if (data is Map<String, dynamic>) {
          errorMessage =
              data['message']?.toString() ??
              err.response?.statusMessage ??
              'Unknown server error';
        } else if (data is String) {
          errorMessage = data;
        } else {
          errorMessage = err.response?.statusMessage ?? 'Unknown server error';
        }
      } else {
        errorMessage =
            'Something went wrong with the response (unexpected status code).';
      }
    } else {
      switch (err.type) {
        case DioExceptionType.connectionError:
          errorMessage = 'Connection error. Check your internet connection.';
          break;
        case DioExceptionType.connectionTimeout:
          errorMessage = 'Connection timeout with the API server.';
          break;
        case DioExceptionType.sendTimeout:
          errorMessage = 'Send timeout in connection with the API server.';
          break;
        case DioExceptionType.receiveTimeout:
          errorMessage = 'Receive timeout in connection with the API server.';
          break;
        case DioExceptionType.badResponse:
          errorMessage = 'Bad response from server.';
          break;
        case DioExceptionType.cancel:
          errorMessage = 'Request to API server was cancelled.';
          break;
        case DioExceptionType.badCertificate:
          errorMessage = 'Bad SSL certificate.';
          break;
        case DioExceptionType.unknown:
          errorMessage = 'An unexpected error occurred.';
          break;
      }
    }

    final customError = DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      error: errorMessage,
      type: err.type,
    );

    super.onError(customError, handler);
  }
}
