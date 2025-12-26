import 'package:equatable/equatable.dart';

abstract class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object?> get props => [];
}

class InitiatePaymentEvent extends PaymentEvent {
  final String bookingId;
  final double amount;
  final String gateway;

  const InitiatePaymentEvent({
    required this.bookingId,
    required this.amount,
    required this.gateway,
  });

  @override
  List<Object?> get props => [bookingId, amount, gateway];
}

class VerifyPaymentEvent extends PaymentEvent {
  final String gateway;
  final Map<String, dynamic> data;

  const VerifyPaymentEvent({
    required this.gateway,
    required this.data,
  });

  @override
  List<Object?> get props => [gateway, data];
}

class GetPaymentHistoryEvent extends PaymentEvent {
  final String userId;

  const GetPaymentHistoryEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}
