import 'package:dartz/dartz.dart';
import '../../../../cores/error/failure.dart';
import '../entity/payment_entity.dart';
import '../repository/payment_repository.dart';

class InitiatePaymentUseCase {
  final IPaymentRepository repository;

  InitiatePaymentUseCase(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call({
    required String bookingId,
    required double amount,
    required String gateway,
  }) {
    return repository.initiatePayment(
      bookingId: bookingId,
      amount: amount,
      gateway: gateway,
    );
  }
}

class VerifyPaymentUseCase {
  final IPaymentRepository repository;

  VerifyPaymentUseCase(this.repository);

  Future<Either<Failure, bool>> call({
    required String gateway,
    required Map<String, dynamic> data,
  }) {
    return repository.verifyPayment(
      gateway: gateway,
      data: data,
    );
  }
}

class GetPaymentHistoryUseCase {
  final IPaymentRepository repository;

  GetPaymentHistoryUseCase(this.repository);

  Future<Either<Failure, List<PaymentEntity>>> call(String userId) {
    return repository.getPaymentHistory(userId);
  }
}
