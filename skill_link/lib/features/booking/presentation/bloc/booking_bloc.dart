import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/booking_entity.dart';
import '../../domain/repositories/booking_repository.dart';

part 'booking_event.dart';
part 'booking_state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final IBookingRepository bookingRepository;

  BookingBloc({required this.bookingRepository}) : super(BookingInitial()) {
    on<CreateBookingEvent>(_onCreateBooking);
    on<LoadUserBookingsEvent>(_onLoadUserBookings);
    on<UpdateBookingStatusEvent>(_onUpdateBookingStatus);
    on<InitiatePaymentEvent>(_onInitiatePayment);
  }

  Future<void> _onCreateBooking(CreateBookingEvent event, Emitter<BookingState> emit) async {
    emit(BookingLoading());
    final result = await bookingRepository.createBooking(event.workerListingId, event.date, event.timeSlot);
    result.fold(
      (failure) => emit(BookingError(message: failure.message)), // Assuming Failure has a message property
      (booking) => emit(BookingSuccess(booking: booking)),
    );
  }

  Future<void> _onLoadUserBookings(LoadUserBookingsEvent event, Emitter<BookingState> emit) async {
    emit(BookingLoading());
    final result = await bookingRepository.getUserBookings();
    result.fold(
      (failure) => emit(BookingError(message: failure.message)),
      (bookings) => emit(BookingsLoaded(bookings: bookings)),
    );
  }

  Future<void> _onUpdateBookingStatus(UpdateBookingStatusEvent event, Emitter<BookingState> emit) async {
    // Optimistic update or loading? Let's do loading for safety.
    emit(BookingLoading());
    final result = await bookingRepository.updateBookingStatus(event.bookingId, event.status);
    result.fold(
      (failure) => emit(BookingError(message: failure.message)),
      (booking) {
         // After successful update, we might want to reload the list or just emit success
         add(LoadUserBookingsEvent()); // Reload list to reflect changes
      },
    );
  }

  Future<void> _onInitiatePayment(InitiatePaymentEvent event, Emitter<BookingState> emit) async {
    emit(BookingLoading());
    final result = await bookingRepository.initiatePayment(event.bookingId, event.amount, event.method);
    result.fold(
      (failure) => emit(BookingError(message: failure.message)),
      (paymentData) {
        emit(PaymentInitiated(paymentData: paymentData));
        // Note: The UI should listener for this state and open the payment URL or handle data
        // After that, we might want to reload bookings if payment affects it immediately (it won't until callback)
      }
    );
  }
}
