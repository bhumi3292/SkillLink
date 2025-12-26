import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../cores/error/failure.dart';
import '../models/booking_model.dart';

abstract class BookingRemoteDataSource {
  Future<BookingModel> createBooking(String workerListingId, String date, String timeSlot);
  Future<List<BookingModel>> getUserBookings();
  Future<BookingModel> updateBookingStatus(String bookingId, String status);
  Future<dynamic> initiatePayment(String bookingId, double amount, String method);
}

class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  final Dio dio;

  BookingRemoteDataSourceImpl({required this.dio});

  String get baseUrl => "http://192.168.1.6:3001/api/bookings"; 

  // Helper to get token (if Dio interceptor isn't already handling it)
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token'); // Adjust key as per your auth flow
  }

  @override
  Future<BookingModel> createBooking(String workerListingId, String date, String timeSlot) async {
    try {
      final token = await _getToken();
      final response = await dio.post(
        baseUrl, // Changed from '$baseUrl/create'
        data: {
          'workerListingId': workerListingId,
          'date': date,
          'timeSlot': timeSlot,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 201) {
        return BookingModel.fromJson(response.data['data']);
      } else {
        throw ServerFailure(message: response.data['message']);
      }
    } on DioException catch (e) {
      throw ServerFailure(message: e.response?.data['message'] ?? 'API Error');
    }
  }

  @override
  Future<List<BookingModel>> getUserBookings() async {
    try {
      final token = await _getToken();
      final response = await dio.get(
        baseUrl, // Changed from '$baseUrl/Hirer'
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => BookingModel.fromJson(json)).toList();
      } else {
        throw ServerFailure(message: response.data['message']);
      }
    } on DioException catch (e) {
      throw ServerFailure(message: e.response?.data['message'] ?? 'API Error');
    }
  }


  @override
  Future<BookingModel> updateBookingStatus(String bookingId, String status) async {
    try {
      final token = await _getToken();
      final response = await dio.patch(
        '$baseUrl/$bookingId/status',
        data: {
          'status': status,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        return BookingModel.fromJson(response.data['data']);
      } else {
        throw ServerFailure(message: response.data['message']);
      }
    } on DioException catch (e) {
      throw ServerFailure(message: e.response?.data['message'] ?? 'API Error');
    }
  }

  @override
  Future<dynamic> initiatePayment(String bookingId, double amount, String method) async {
    try {
      final token = await _getToken();
      final paymentUrl = baseUrl.replaceAll('/bookings', '/payments'); 
      
      final response = await dio.post(
        '$paymentUrl/initiate',
        data: {
          'bookingId': bookingId,
          'amount': amount,
          'method': method,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data['data']; 
      } else {
        throw ServerFailure(message: response.data['message']);
      }
    } on DioException catch (e) {
      throw ServerFailure(message: e.response?.data['message'] ?? 'Payment Initiation Failed');
    }
  }
}

