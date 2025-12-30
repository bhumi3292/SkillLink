import 'package:equatable/equatable.dart';
import '../../domain/entity/payment_entity.dart';

class PaymentApiModel extends Equatable {
  final String? id;
  final dynamic bookingId; // Can be string or object
  final dynamic hirerId;
  final dynamic workerId; // Can be string or object
  final String paymentGateway;
  final double amount;
  final String? transactionId;
  final String status;
  final String? paymentDate;
  final String? refundStatus;
  final String? refundReason;

  const PaymentApiModel({
    this.id,
    required this.bookingId,
    required this.hirerId,
    required this.workerId,
    required this.paymentGateway,
    required this.amount,
    this.transactionId,
    required this.status,
    this.paymentDate,
    this.refundStatus,
    this.refundReason,
  });

  factory PaymentApiModel.fromJson(Map<String, dynamic> json) {
    return PaymentApiModel(
      id: json['_id'],
      bookingId: json['bookingId'],
      hirerId: json['hirerId'],
      workerId: json['workerId'],
      paymentGateway: json['paymentGateway'],
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      transactionId: json['transactionId'],
      status: json['status'],
      paymentDate: json['paymentDate'],
      refundStatus: json['refundStatus'],
      refundReason: json['refundReason'],
    );
  }

  PaymentEntity toEntity() {
    String? wName;
    String wId = '';
    if (workerId is Map) {
      wName = workerId['fullName'];
      wId = workerId['_id'];
    } else {
      wId = workerId;
    }

    String bId = '';
    if (bookingId is Map) {
      bId = bookingId['_id'];
    } else {
      bId = bookingId;
    }

    return PaymentEntity(
      id: id,
      bookingId: bId,
      hirerId: hirerId,
      workerId: wId,
      workerName: wName,
      paymentGateway: paymentGateway,
      amount: amount,
      transactionId: transactionId,
      status: status,
      paymentDate: paymentDate != null ? DateTime.parse(paymentDate!) : null,
      refundStatus: refundStatus,
      refundReason: refundReason,
    );
  }

  @override
  List<Object?> get props => [
    id,
    bookingId,
    hirerId,
    workerId,
    paymentGateway,
    amount,
    transactionId,
    status,
    paymentDate,
    refundStatus,
    refundReason,
  ];
}
