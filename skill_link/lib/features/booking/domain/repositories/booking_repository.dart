import 'package:dartz/dartz.dart';
import '../../../../cores/error/failure.dart';
import '../entities/booking_entity.dart';

abstract class IBookingRepository {
  Future<Either<Failure, BookingEntity>> createBooking(String workerListingId, String date, String timeSlot);
  Future<Either<Failure, List<BookingEntity>>> getUserBookings();
  Future<Either<Failure, BookingEntity>> updateBookingStatus(String bookingId, String status);
  Future<Either<Failure, dynamic>> initiatePayment(String bookingId, double amount, String method);
}

