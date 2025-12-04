
import 'package:dio/dio.dart';
import 'package:skill_link/app/constant/api_endpoints.dart';
import 'package:skill_link/app/shared_pref/token_shared_prefs.dart';
import 'package:skill_link/cores/network/dio_error_interceptor.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class ApiService {
  final Dio _dio;
  final TokenSharedPrefs _tokenSharedPrefs;

  Dio get dio => _dio;

  ApiService(this._dio, this._tokenSharedPrefs) {
    _dio
      ..options.baseUrl = ApiEndpoints.baseUrl
      ..options.connectTimeout = ApiEndpoints.connectionTimeout
      ..options.receiveTimeout = ApiEndpoints.receiveTimeout
      ..interceptors.add(DioErrorInterceptor())
      ..interceptors.add(
        QueuedInterceptorsWrapper(
          onRequest: (options, handler) async {
            print('API Request: ${options.method} ${options.path}');
            final tokenEither = await _tokenSharedPrefs.getToken();
            tokenEither.fold(
              (failure) => print('API Request: Failed to get token'),
              (token) {
                if (token != null && token.isNotEmpty) {
                  options.headers['Authorization'] = 'Bearer $token';
                  print('API Request: Token attached');
                } else {
                  print('API Request: No token available');
                }
              },
            );

            if (options.data is! FormData) {
              options.headers['Content-Type'] = 'application/json';
            }
            options.headers['Accept'] = 'application/json';

            return handler.next(options);
          },
          onResponse: (response, handler) {
            print(
                'API Response: ${response.statusCode} ${response.requestOptions.path}');
            return handler.next(response);
          },
          onError: (error, handler) async {
            print(
                'API Error: ${error.response?.statusCode} ${error.requestOptions.path} - ${error.message}');
            if (error.response?.statusCode == 401) {
              print('401 Unauthorized: Attempting to clear token and log out.');
              await _tokenSharedPrefs.deleteToken();
            }
            return handler.next(error);
          },
        ),
      )
      ..interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseHeader: true,
          responseBody: true,
          compact: true,
        ),
      );
  }
}
