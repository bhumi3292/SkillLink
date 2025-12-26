import 'package:dartz/dartz.dart';
import '../../../../cores/error/failure.dart';
import '../../domain/entity/payment_entity.dart';
import '../../domain/repository/payment_repository.dart';
import '../data_source/payment_remote_data_source.dart';

class PaymentRepositoryImpl implements IPaymentRepository {
  final PaymentRemoteDataSource paymentRemoteDataSource;

  PaymentRepositoryImpl(this.paymentRemoteDataSource);

  @override
  Future<Either<Failure, Map<String, dynamic>>> initiatePayment({
    required String bookingId,
    required double amount,
    required String gateway,
  }) async {
    try {
      final result = await paymentRemoteDataSource.initiatePayment(
        bookingId: bookingId,
        amount: amount,
        gateway: gateway,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> verifyPayment({
    required String gateway,
    required Map<String, dynamic> data,
  }) async {
    try {
      final result = await paymentRemoteDataSource.verifyPayment(
        gateway: gateway,
        data: data,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PaymentEntity>>> getPaymentHistory(
      String userId) async {
    try {
      final models = await paymentRemoteDataSource.getPaymentHistory(userId);
      final entities = models.map((m) => m.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
