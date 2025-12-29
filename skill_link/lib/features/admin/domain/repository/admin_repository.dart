import 'package:dartz/dartz.dart';
import 'package:skill_link/cores/error/failure.dart';

abstract class IAdminRepository {
  Future<Either<Failure, Map<String, dynamic>>> getDashboardStats();
  Future<Either<Failure, List<dynamic>>> getPendingWorkers();
  Future<Either<Failure, void>> verifyWorker(String workerId, String action, String? rejectionReason);
  Future<Either<Failure, List<dynamic>>> getAllUsers();
  Future<Either<Failure, void>> toggleUserSuspension(String userId);
  Future<Either<Failure, void>> toggleCategoryStatus(String categoryId);
  Future<Either<Failure, List<dynamic>>> getAllBookings();
}
