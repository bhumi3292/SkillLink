import 'package:dio/dio.dart';
import '../../../../app/constant/api_endpoints.dart';
import '../../../../cores/network/api_service.dart';
import '../model/payment_api_model.dart';

abstract class PaymentRemoteDataSource {
  Future<Map<String, dynamic>> initiatePayment({
    required String bookingId,
    required double amount,
    required String gateway,
  });

  Future<bool> verifyPayment({
    required String gateway,
    required Map<String, dynamic> data,
  });

  Future<List<PaymentApiModel>> getPaymentHistory(String userId);
}

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final ApiService apiService;

  PaymentRemoteDataSourceImpl(this.apiService);

  @override
  Future<Map<String, dynamic>> initiatePayment({
    required String bookingId,
    required double amount,
    required String gateway,
  }) async {
    try {
      final response = await apiService.dio.post(
        ApiEndpoints.initiatePayment.replaceFirst(ApiEndpoints.baseUrl, ''),
        data: {
          'bookingId': bookingId,
          'amount': amount,
          'gateway': gateway,
        },
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to initiate payment');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<bool> verifyPayment({
    required String gateway,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await apiService.dio.post(
        ApiEndpoints.verifyPayment.replaceFirst(ApiEndpoints.baseUrl, ''),
        data: {
          'gateway': gateway,
          ...data,
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<List<PaymentApiModel>> getPaymentHistory(String userId) async {
    try {
      final response = await apiService.dio.get(
        ApiEndpoints.getPaymentHistory(userId)
            .replaceFirst(ApiEndpoints.baseUrl, ''),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((json) => PaymentApiModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch payment history');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
