import 'package:dartz/dartz.dart';
import '../../../../cores/error/failure.dart';
import '../entity/payment_entity.dart';

abstract class IPaymentRepository {
  Future<Either<Failure, Map<String, dynamic>>> initiatePayment({
    required String bookingId,
    required double amount,
    required String gateway,
  });

  Future<Either<Failure, bool>> verifyPayment({
    required String gateway,
    required Map<String, dynamic> data,
  });

  Future<Either<Failure, List<PaymentEntity>>> getPaymentHistory(String userId);
}
