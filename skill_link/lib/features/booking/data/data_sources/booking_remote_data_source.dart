import 'package:skill_link/app/constant/api_endpoints.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../cores/error/failure.dart';
import '../models/booking_model.dart';

abstract class BookingRemoteDataSource {
  Future<BookingModel> createBooking(
    String workerListingId,
    String date,
    String timeSlot,
  );
  Future<List<BookingModel>> getUserBookings();
  Future<BookingModel> updateBookingStatus(
    String bookingId,
    String status, {
    String? reason,
  });
  Future<BookingModel> requestReschedule(
    String bookingId,
    String requestedDate,
    String requestedTimeSlot,
  );
  Future<BookingModel> respondReschedule(
    String bookingId,
    int requestIndex,
    String action,
    String? reason,
  );
  Future<BookingModel> cancelBooking(String bookingId, String reason);
  Future<dynamic> initiatePayment(
    String bookingId,
    double amount,
    String method,
  );
  Future<BookingModel> getBookingById(String bookingId);
}

class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  final Dio dio;

  BookingRemoteDataSourceImpl({required this.dio});

  String get baseUrl => ApiEndpoints.bookings;

  // Helper to get token (if Dio interceptor isn't already handling it)
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token'); // Adjust key as per your auth flow
  }

  @override
  Future<BookingModel> createBooking(
    String workerListingId,
    String date,
    String timeSlot,
  ) async {
    try {
      final token = await _getToken();
      final response = await dio.post(
        baseUrl, // Changed from '$baseUrl/create'
        data: {
          'workerListingId': workerListingId,
          'date': date,
          'timeSlot': timeSlot,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
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
        options: Options(headers: {'Authorization': 'Bearer $token'}),
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
  Future<BookingModel> updateBookingStatus(
    String bookingId,
    String status, {
    String? reason,
  }) async {
    try {
      final token = await _getToken();
      final response = await dio.patch(
        ApiEndpoints.updateBookingStatus(bookingId),
        data: {'status': status, if (reason != null) 'reason': reason},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
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
  Future<BookingModel> requestReschedule(
    String bookingId,
    String requestedDate,
    String requestedTimeSlot,
  ) async {
    try {
      final token = await _getToken();
      final response = await dio.post(
        ApiEndpoints.requestReschedule(bookingId),
        data: {
          'requestedDate': requestedDate,
          'requestedTimeSlot': requestedTimeSlot,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final bookingJson = response.data['booking'] ?? response.data['data'];
        return BookingModel.fromJson(bookingJson);
      } else {
        throw ServerFailure(message: response.data['message']);
      }
    } on DioException catch (e) {
      throw ServerFailure(message: e.response?.data['message'] ?? 'API Error');
    }
  }

  @override
  Future<BookingModel> respondReschedule(
    String bookingId,
    int requestIndex,
    String action,
    String? reason,
  ) async {
    try {
      final token = await _getToken();
      final response = await dio.post(
        ApiEndpoints.respondReschedule(bookingId),
        data: {
          'requestIndex': requestIndex,
          'action': action,
          'reason': reason ?? '',
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final bookingJson = response.data['booking'] ?? response.data['data'];
        return BookingModel.fromJson(bookingJson);
      } else {
        throw ServerFailure(message: response.data['message']);
      }
    } on DioException catch (e) {
      throw ServerFailure(message: e.response?.data['message'] ?? 'API Error');
    }
  }

  @override
  Future<BookingModel> cancelBooking(String bookingId, String reason) async {
    try {
      final token = await _getToken();
      final response = await dio.delete(
        ApiEndpoints.deleteBookingById(bookingId),
        data: {'reason': reason},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        // deleteBooking returns success message; try to return booking if present
        if (response.data['booking'] != null) {
          return BookingModel.fromJson(response.data['booking']);
        }
        // If no booking returned, fetch booking by id to return latest
        final bookingResp = await dio.get(
          ApiEndpoints.getBookingById(bookingId),
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        );
        return BookingModel.fromJson(bookingResp.data['data']);
      } else {
        throw ServerFailure(message: response.data['message']);
      }
    } on DioException catch (e) {
      throw ServerFailure(message: e.response?.data['message'] ?? 'API Error');
    }
  }

  @override
  Future<dynamic> initiatePayment(
    String bookingId,
    double amount,
    String method,
  ) async {
    try {
      final token = await _getToken();
      // Using ApiEndpoints directly for initiatePayment as baseUrl replacement might be tricky with regex
      // Or just use ApiEndpoints.initiatePayment which is clearer

      final response = await dio.post(
        ApiEndpoints.initiatePayment,
        data: {'bookingId': bookingId, 'amount': amount, 'method': method},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return response.data['data'];
      } else {
        throw ServerFailure(message: response.data['message']);
      }
    } on DioException catch (e) {
      throw ServerFailure(
        message: e.response?.data['message'] ?? 'Payment Initiation Failed',
      );
    }
  }

  @override
  Future<BookingModel> getBookingById(String bookingId) async {
    try {
      final token = await _getToken();
      final response = await dio.get(
        ApiEndpoints.getBookingById(bookingId),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
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
}
