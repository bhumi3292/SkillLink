part of 'booking_bloc.dart';

abstract class BookingState extends Equatable {
  const BookingState();
  
  @override
  List<Object> get props => [];
}

class BookingInitial extends BookingState {}

class BookingLoading extends BookingState {}

class BookingSuccess extends BookingState {
  final BookingEntity booking;

  const BookingSuccess({required this.booking});

  @override
  List<Object> get props => [booking];
}

class BookingsLoaded extends BookingState {
  final List<BookingEntity> bookings;

  const BookingsLoaded({required this.bookings});

  @override
  List<Object> get props => [bookings];
}

class BookingError extends BookingState {
  final String message;

  const BookingError({required this.message});

  @override
  List<Object> get props => [message];
}

class BookingPaymentInitiated extends BookingState {
  final dynamic paymentData; // Contains url, pidx, etc.
  
  const BookingPaymentInitiated({required this.paymentData});

  @override
  List<Object> get props => [paymentData];
}
