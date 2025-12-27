part of 'booking_bloc.dart';

abstract class BookingEvent extends Equatable {
  const BookingEvent();

  @override
  List<Object> get props => [];
}

class CreateBookingEvent extends BookingEvent {
  final String workerListingId;
  final String date;
  final String timeSlot;

  const CreateBookingEvent({required this.workerListingId, required this.date, required this.timeSlot});

  @override
  List<Object> get props => [workerListingId, date, timeSlot];
}

class LoadUserBookingsEvent extends BookingEvent {}

class UpdateBookingStatusEvent extends BookingEvent {
  final String bookingId;
  final String status;

  const UpdateBookingStatusEvent({required this.bookingId, required this.status});

  @override
  List<Object> get props => [bookingId, status];
}

class BookingInitiatePaymentEvent extends BookingEvent {
  final String bookingId;
  final double amount;
  final String method;

  const BookingInitiatePaymentEvent({required this.bookingId, required this.amount, required this.method});

  @override
  List<Object> get props => [bookingId, amount, method];
}

class GetBookingByIdEvent extends BookingEvent {
  final String bookingId;
  const GetBookingByIdEvent(this.bookingId);

  @override
  List<Object> get props => [bookingId];
}
