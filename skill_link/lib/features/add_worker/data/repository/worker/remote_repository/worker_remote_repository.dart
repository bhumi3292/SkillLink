// lib/features/add_worker/data/repository/worker_remote_repository.dart

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:skill_link/cores/error/failure.dart';
import 'package:skill_link/features/add_worker/data/data_source/worker/remote_datasource/worker_remote_datasource.dart';
import 'package:skill_link/features/add_worker/domain/entity/worker/worker_entity.dart';
import 'package:skill_link/features/add_worker/domain/repository/worker_repository.dart';

class WorkerRemoteRepository implements IWorkerRepository {
  final WorkerRemoteDatasource _remoteDataSource;

  WorkerRemoteRepository({required WorkerRemoteDatasource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  // Helper to convert DioException to Failure types
  Failure _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return NetworkFailure(message: 'No Internet Connection or Timeout');
    } else if (e.type == DioExceptionType.badResponse) {
      final statusCode = e.response?.statusCode;
      final errorMessage = e.response?.data['message'] ?? e.message;
      if (statusCode != null) {
        if (statusCode == 400) {
          return InputFailure(message: errorMessage);
        } else if (statusCode == 401) {
          return AuthFailure(message: errorMessage);
        } else if (statusCode == 403) {
          return ForbiddenFailure(message: errorMessage);
        } else if (statusCode == 404) {
          return NotFoundFailure(message: errorMessage);
        } else if (statusCode >= 500) {
          // This is where the '>' null check was needed
          return ServerFailure(message: 'Server error: $errorMessage');
        }
      }
    }
    return UnknownFailure(
      message: e.message ?? 'An unknown network error occurred',
    );
  }

  @override
  Future<Either<Failure, void>> addWorker(
    WorkerEntity worker,
    List<String> imagePaths,
    List<String> videoPaths,
  ) async {
    try {
      await _remoteDataSource.addWorker(worker, imagePaths, videoPaths);
      return const Right(null);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(
        RemoteDatabaseFailure(
          message: 'Failed to add Worker remotely: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deleteWorker(String workerId) async {
    try {
      await _remoteDataSource.deleteWorker(workerId);
      return const Right(null);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(
        RemoteDatabaseFailure(
          message: 'Failed to delete Worker remotely: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<WorkerEntity>>> getWorkers() async {
    try {
      final workers = await _remoteDataSource.getWorkers();
      return Right(workers);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(
        RemoteDatabaseFailure(
          message: 'Failed to get workers remotely: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, WorkerEntity>> getWorkerById(String workerId) async {
    try {
      final worker = await _remoteDataSource.getWorkerById(workerId);
      return Right(worker);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(
        RemoteDatabaseFailure(
          message: 'Failed to get Worker by ID remotely: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> updateWorker(
    String workerId,
    WorkerEntity worker,
    List<String> newImagePaths,
    List<String> newVideoPaths,
    List<String> existingImages,
    List<String> existingVideos,
  ) async {
    try {
      await _remoteDataSource.updateWorker(
        workerId,
        worker,
        newImagePaths,
        newVideoPaths,
        existingImages,
        existingVideos,
      );
      return const Right(null);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(
        RemoteDatabaseFailure(
          message: 'Failed to update Worker remotely:  [${e.toString()}',
        ),
      );
    }
  }
}
