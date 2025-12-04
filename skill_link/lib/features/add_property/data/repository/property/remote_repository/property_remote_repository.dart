// lib/features/add_property/data/repository/property_remote_repository.dart

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:skill_link/cores/error/failure.dart';
import 'package:skill_link/features/add_property/data/data_source/property/remote_datasource/property_remote_datasource.dart';
import 'package:skill_link/features/add_property/domain/entity/property/property_entity.dart';
import 'package:skill_link/features/add_property/domain/repository/property_repository.dart';

class PropertyRemoteRepository implements IPropertyRepository {
  final PropertyRemoteDatasource _remoteDataSource;

  PropertyRemoteRepository({required PropertyRemoteDatasource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  // Helper to convert DioException to Failure types
  Failure _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionError || e.type == DioExceptionType.sendTimeout || e.type == DioExceptionType.receiveTimeout) {
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
        } else if (statusCode >= 500) { // This is where the '>' null check was needed
          return ServerFailure(message: 'Server error: $errorMessage');
        }
      }
    }
    return UnknownFailure(message: e.message ?? 'An unknown network error occurred');
  }

  @override
  Future<Either<Failure, void>> addProperty(PropertyEntity property, List<String> imagePaths, List<String> videoPaths) async {
    try {
      await _remoteDataSource.addProperty(property, imagePaths, videoPaths);
      return const Right(null);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(RemoteDatabaseFailure(message: 'Failed to add property remotely: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProperty(String propertyId) async {
    try {
      await _remoteDataSource.deleteProperty(propertyId);
      return const Right(null);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(RemoteDatabaseFailure(message: 'Failed to delete property remotely: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<PropertyEntity>>> getProperties() async {
    try {
      final properties = await _remoteDataSource.getProperties();
      return Right(properties);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(RemoteDatabaseFailure(message: 'Failed to get properties remotely: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, PropertyEntity>> getPropertyById(String propertyId) async {
    try {
      final property = await _remoteDataSource.getPropertyById(propertyId);
      return Right(property);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(RemoteDatabaseFailure(message: 'Failed to get property by ID remotely: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> updateProperty(String propertyId, PropertyEntity property, List<String> newImagePaths, List<String> newVideoPaths, List<String> existingImages, List<String> existingVideos) async {
    try {
      await _remoteDataSource.updateProperty(propertyId, property, newImagePaths, newVideoPaths, existingImages, existingVideos);
      return const Right(null);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(RemoteDatabaseFailure(message: 'Failed to update property remotely:  [${e.toString()}'));
    }
  }
}