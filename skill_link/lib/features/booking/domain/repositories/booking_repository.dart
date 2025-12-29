import 'package:dartz/dartz.dart';
import '../../../../cores/error/failure.dart';
import '../entities/booking_entity.dart';

abstract class IBookingRepository {
  Future<Either<Failure, BookingEntity>> createBooking(
    String workerListingId,
    String date,
    String timeSlot,
  );
  Future<Either<Failure, List<BookingEntity>>> getUserBookings();
  Future<Either<Failure, BookingEntity>> updateBookingStatus(
    String bookingId,
    String status, {
    String? reason,
  });
  Future<Either<Failure, BookingEntity>> requestReschedule(
    String bookingId,
    String requestedDate,
    String requestedTimeSlot,
  );
  Future<Either<Failure, BookingEntity>> respondReschedule(
    String bookingId,
    int requestIndex,
    String action,
    String? reason,
  );
  Future<Either<Failure, BookingEntity>> cancelBooking(
    String bookingId,
    String reason,
  );
  Future<Either<Failure, dynamic>> initiatePayment(
    String bookingId,
    double amount,
    String method,
  );
  Future<Either<Failure, BookingEntity>> getBookingById(String bookingId);
}
