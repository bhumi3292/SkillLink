import 'package:dartz/dartz.dart';
import '../../../../cores/error/failure.dart';
import '../../domain/entities/booking_entity.dart';
import '../../domain/repositories/booking_repository.dart';
import '../data_sources/booking_remote_data_source.dart';

class BookingRepositoryImpl implements IBookingRepository {
  final BookingRemoteDataSource remoteDataSource;

  BookingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, BookingEntity>> createBooking(
    String workerListingId,
    String date,
    String timeSlot,
  ) async {
    try {
      final booking = await remoteDataSource.createBooking(
        workerListingId,
        date,
        timeSlot,
      );
      return Right(booking.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BookingEntity>>> getUserBookings() async {
    try {
      final bookings = await remoteDataSource.getUserBookings();
      return Right(bookings.map((e) => e.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, BookingEntity>> updateBookingStatus(
    String bookingId,
    String status, {
    String? reason,
  }) async {
    try {
      final booking = await remoteDataSource.updateBookingStatus(
        bookingId,
        status,
        reason: reason,
      );
      return Right(booking.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, BookingEntity>> requestReschedule(
    String bookingId,
    String requestedDate,
    String requestedTimeSlot,
  ) async {
    try {
      final booking = await remoteDataSource.requestReschedule(
        bookingId,
        requestedDate,
        requestedTimeSlot,
      );
      return Right(booking.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, BookingEntity>> respondReschedule(
    String bookingId,
    int requestIndex,
    String action,
    String? reason,
  ) async {
    try {
      final booking = await remoteDataSource.respondReschedule(
        bookingId,
        requestIndex,
        action,
        reason,
      );
      return Right(booking.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, BookingEntity>> cancelBooking(
    String bookingId,
    String reason,
  ) async {
    try {
      final booking = await remoteDataSource.cancelBooking(bookingId, reason);
      return Right(booking.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, dynamic>> initiatePayment(
    String bookingId,
    double amount,
    String method,
  ) async {
    try {
      final result = await remoteDataSource.initiatePayment(
        bookingId,
        amount,
        method,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, BookingEntity>> getBookingById(
    String bookingId,
  ) async {
    try {
      final booking = await remoteDataSource.getBookingById(bookingId);
      return Right(booking.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
