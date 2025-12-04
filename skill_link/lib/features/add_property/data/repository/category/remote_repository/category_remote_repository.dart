// lib/features/add_property/data/repository/category/remote_repository/category_remote_repository.dart

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:skill_link/cores/error/failure.dart';
import 'package:skill_link/features/add_property/data/data_source/category/remote_datasource/category_remote_datasource.dart';
import 'package:skill_link/features/add_property/domain/entity/category/category_entity.dart';
import 'package:skill_link/features/add_property/domain/repository/category_repository.dart';

class CategoryRemoteRepository implements ICategoryRepository {
  final CategoryRemoteDatasource _remoteDataSource;

  CategoryRemoteRepository({required CategoryRemoteDatasource remoteDataSource})
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
          return ServerFailure(message: 'Server error: $errorMessage');
        }
      }
    }
    return UnknownFailure(
      message: e.message ?? 'An unknown network error occurred',
    );
  }

  @override
  Future<Either<Failure, void>> addCategory(CategoryEntity category) async {
    try {
      await _remoteDataSource.addCategory(category);
      return const Right(null);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(
        RemoteDatabaseFailure(
          message: 'Failed to add category remotely: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deleteCategory(String categoryId) async {
    try {
      await _remoteDataSource.deleteCategory(categoryId);
      return const Right(null);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(
        RemoteDatabaseFailure(
          message: 'Failed to delete category remotely: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories() async {
    try {
      print(
        'CategoryRemoteRepository: Calling remoteDataSource.getCategories()',
      );
      final categories = await _remoteDataSource.getCategories();
      print(
        'CategoryRemoteRepository: Success - ${categories.length} categories',
      );
      return Right(categories);
    } on DioException catch (e) {
      print('CategoryRemoteRepository: DioException - ${e.message}');
      return Left(_handleDioError(e));
    } catch (e) {
      print('CategoryRemoteRepository: Exception - $e');
      return Left(
        RemoteDatabaseFailure(
          message: 'Failed to get categories remotely: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> updateCategory(CategoryEntity category) async {
    try {
      await _remoteDataSource.updateCategory(category);
      return const Right(null);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(
        RemoteDatabaseFailure(
          message: 'Failed to update category remotely: ${e.toString()}',
        ),
      );
    }
  }
}
