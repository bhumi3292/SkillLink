import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:skill_link/cores/error/failure.dart';
import 'package:skill_link/features/explore/domain/entity/explore_worker_entity.dart';
import 'package:skill_link/features/profile/data/data_source/worker_profile_remote_datasource.dart';
import 'package:skill_link/features/profile/domain/repository/worker_profile_repository.dart';
import 'dart:io';

class WorkerProfileRepositoryImpl implements IWorkerProfileRepository {
  final WorkerProfileRemoteDataSource _dataSource;

  WorkerProfileRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, void>> deactivateWorker(String id) async {
    try {
      await _dataSource.deactivateWorker(id);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.message ?? "Unknown Error"));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ExploreWorkerEntity>> getWorkerById(String id) async {
    try {
      final worker = await _dataSource.getWorkerById(id);
      return Right(worker);
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.message ?? "Unknown Error"));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ExploreWorkerEntity>> updateWorker(String id, Map<String, dynamic> data, List<File>? newImages) async {
    try {
      final worker = await _dataSource.updateWorker(id, data, newImages);
      return Right(worker);
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.message ?? "Unknown Error"));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
