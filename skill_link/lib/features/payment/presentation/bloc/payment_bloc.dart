import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entity/payment_entity.dart';
import '../../domain/use_case/payment_usecases.dart';
import 'payment_event.dart';
import 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final InitiatePaymentUseCase initiatePaymentUseCase;
  final VerifyPaymentUseCase verifyPaymentUseCase;
  final GetPaymentHistoryUseCase getPaymentHistoryUseCase;

  PaymentBloc({
    required this.initiatePaymentUseCase,
    required this.verifyPaymentUseCase,
    required this.getPaymentHistoryUseCase,
  }) : super(PaymentInitial()) {
    on<InitiatePaymentEvent>(_onInitiatePayment);
    on<VerifyPaymentEvent>(_onVerifyPayment);
    on<GetPaymentHistoryEvent>(_onGetPaymentHistory);
  }

  Future<void> _onInitiatePayment(
    InitiatePaymentEvent event,
    Emitter<PaymentState> emit,
  ) async {
    emit(PaymentLoading());
    final result = await initiatePaymentUseCase(
      bookingId: event.bookingId,
      amount: event.amount,
      gateway: event.gateway,
    );

    result.fold(
      (failure) => emit(PaymentFailure(failure.message)),
      (data) => emit(PaymentInitiated(event.gateway, data)),
    );
  }

  Future<void> _onVerifyPayment(
    VerifyPaymentEvent event,
    Emitter<PaymentState> emit,
  ) async {
    emit(PaymentLoading());
    final result = await verifyPaymentUseCase(
      gateway: event.gateway,
      data: event.data,
    );

    result.fold(
      (failure) => emit(PaymentFailure(failure.message)),
      (success) {
        if (success) {
          emit(const PaymentSuccess('Payment Verified Successfully'));
        } else {
          emit(const PaymentFailure('Payment Verification Failed'));
        }
      },
    );
  }

  Future<void> _onGetPaymentHistory(
    GetPaymentHistoryEvent event,
    Emitter<PaymentState> emit,
  ) async {
    emit(PaymentLoading());
    final result = await getPaymentHistoryUseCase(event.userId);

    result.fold(
      (failure) => emit(PaymentFailure(failure.message)),
      (history) => emit(PaymentHistoryLoaded(history.cast<PaymentEntity>())),
    );
  }
}
