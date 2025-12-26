import 'package:equatable/equatable.dart';
import '../../domain/entity/payment_entity.dart';

abstract class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object?> get props => [];
}

class PaymentInitial extends PaymentState {}

class PaymentLoading extends PaymentState {}

class PaymentSuccess extends PaymentState {
  final String message;
  const PaymentSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class PaymentInitiated extends PaymentState {
  final String gateway;
  final Map<String, dynamic> paymentData;
  const PaymentInitiated(this.gateway, this.paymentData);
  @override
  List<Object?> get props => [gateway, paymentData];
}

class PaymentHistoryLoaded extends PaymentState {
  final List<PaymentEntity> history;
  const PaymentHistoryLoaded(this.history);
  @override
  List<Object?> get props => [history];
}

class PaymentFailure extends PaymentState {
  final String message;
  const PaymentFailure(this.message);
  @override
  List<Object?> get props => [message];
}
