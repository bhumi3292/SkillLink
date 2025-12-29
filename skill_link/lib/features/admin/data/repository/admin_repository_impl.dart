import 'package:dartz/dartz.dart';
import 'package:skill_link/cores/error/failure.dart';
import 'package:skill_link/features/admin/data/data_source/admin_remote_datasource.dart';
import 'package:skill_link/features/admin/domain/repository/admin_repository.dart';

class AdminRepositoryImpl implements IAdminRepository {
  final AdminRemoteDataSource _remoteDataSource;

  AdminRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, Map<String, dynamic>>> getDashboardStats() async {
    try {
      final stats = await _remoteDataSource.getDashboardStats();
      return Right(stats);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<dynamic>>> getPendingWorkers() async {
    try {
      final workers = await _remoteDataSource.getPendingWorkers();
      return Right(workers);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> verifyWorker(String workerId, String action, String? rejectionReason) async {
    try {
      await _remoteDataSource.verifyWorker(workerId, action, rejectionReason);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<dynamic>>> getAllUsers() async {
    try {
      final users = await _remoteDataSource.getAllUsers();
      return Right(users);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> toggleUserSuspension(String userId) async {
    try {
      await _remoteDataSource.toggleUserSuspension(userId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> toggleCategoryStatus(String categoryId) async {
    try {
      await _remoteDataSource.toggleCategoryStatus(categoryId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<dynamic>>> getAllBookings() async {
    try {
      final bookings = await _remoteDataSource.getAllBookings();
      return Right(bookings);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
