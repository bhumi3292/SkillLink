part of 'booking_bloc.dart';

abstract class BookingEvent extends Equatable {
  const BookingEvent();

  @override
  List<Object?> get props => [];
}

class CreateBookingEvent extends BookingEvent {
  final String workerListingId;
  final String date;
  final String timeSlot;

  const CreateBookingEvent({
    required this.workerListingId,
    required this.date,
    required this.timeSlot,
  });

  @override
  List<Object> get props => [workerListingId, date, timeSlot];
}

class LoadUserBookingsEvent extends BookingEvent {}

class UpdateBookingStatusEvent extends BookingEvent {
  final String bookingId;
  final String status;
  final String? reason;

  const UpdateBookingStatusEvent({
    required this.bookingId,
    required this.status,
    this.reason,
  });

  @override
  List<Object?> get props => [bookingId, status, reason];
}

class CancelBookingEvent extends BookingEvent {
  final String bookingId;
  final String reason;

  const CancelBookingEvent({required this.bookingId, required this.reason});

  @override
  List<Object> get props => [bookingId, reason];
}

class RequestRescheduleEvent extends BookingEvent {
  final String bookingId;
  final String requestedDate;
  final String requestedTimeSlot;

  const RequestRescheduleEvent({
    required this.bookingId,
    required this.requestedDate,
    required this.requestedTimeSlot,
  });

  @override
  List<Object> get props => [bookingId, requestedDate, requestedTimeSlot];
}

class RespondRescheduleEvent extends BookingEvent {
  final String bookingId;
  final int requestIndex;
  final String action; // 'accept' or 'reject'
  final String? reason;

  const RespondRescheduleEvent({
    required this.bookingId,
    required this.requestIndex,
    required this.action,
    this.reason,
  });

  @override
  List<Object?> get props => [bookingId, requestIndex, action, reason];
}

class BookingInitiatePaymentEvent extends BookingEvent {
  final String bookingId;
  final double amount;
  final String method;

  const BookingInitiatePaymentEvent({
    required this.bookingId,
    required this.amount,
    required this.method,
  });

  @override
  List<Object> get props => [bookingId, amount, method];
}

class GetBookingByIdEvent extends BookingEvent {
  final String bookingId;
  const GetBookingByIdEvent(this.bookingId);

  @override
  List<Object> get props => [bookingId];
}
