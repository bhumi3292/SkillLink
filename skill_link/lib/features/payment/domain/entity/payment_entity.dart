import 'package:equatable/equatable.dart';

class PaymentEntity extends Equatable {
  final String? id;
  final dynamic bookingId;
  final String hirerId;
  final dynamic workerId;
  final String? workerName;
  final String paymentGateway;
  final double amount;
  final String? transactionId;
  final String status;
  final DateTime? paymentDate;
  final String? refundStatus;
  final String? refundReason;

  const PaymentEntity({
    this.id,
    required this.bookingId,
    required this.hirerId,
    required this.workerId,
    this.workerName,
    required this.paymentGateway,
    required this.amount,
    this.transactionId,
    required this.status,
    this.paymentDate,
    this.refundStatus,
    this.refundReason,
  });

  @override
  List<Object?> get props => [
    id,
    bookingId,
    hirerId,
    workerId,
    workerName,
    paymentGateway,
    amount,
    transactionId,
    status,
    paymentDate,
    refundStatus,
    refundReason,
  ];
}
