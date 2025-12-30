import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:skill_link/cores/error/failure.dart';
import 'package:skill_link/features/auth/domain/entity/user_entity.dart';
import 'package:skill_link/features/auth/domain/repository/user_repository.dart';
import 'package:skill_link/features/auth/data/data_source/remote_datasource/user_remote_datasource.dart';
import 'package:skill_link/app/shared_pref/token_shared_prefs.dart';
import 'dart:io';

class UserRemoteRepository implements IUserRepository {
  final UserRemoteDatasource _remoteDataSource;
  final TokenSharedPrefs _tokenSharedPrefs;

  UserRemoteRepository({
    required UserRemoteDatasource dataSource,
    required TokenSharedPrefs tokenSharedPrefs,
  }) : _remoteDataSource = dataSource,
       _tokenSharedPrefs = tokenSharedPrefs;

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
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    try {
      final user = await _remoteDataSource.getCurrentUser();
      return Right(user);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(
        RemoteDatabaseFailure(message: 'Failed to get current user: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> loginUser(
    String email,
    String password,
    String stakeholder,
  ) async {
    try {
      final data = await _remoteDataSource.loginUser(
        email,
        password,
        stakeholder,
      );

      final token = data['token'] as String;

      // Persist token for later requests
      try {
        await _tokenSharedPrefs.saveToken(token);
      } catch (_) {}

      return Right(data);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(RemoteDatabaseFailure(message: 'Failed to login: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> registerUser(UserEntity user) async {
    try {
      await _remoteDataSource.registerUser(user);
      return const Right(null);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(RemoteDatabaseFailure(message: 'Failed to register: $e'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateUser(
    String fullName,
    String email,
    String? phoneNumber,
    String? currentPassword,
    String? newPassword,
  ) async {
    try {
      final user = await _remoteDataSource.updateUser(
        fullName,
        email,
        phoneNumber,
        currentPassword,
        newPassword,
      );
      return Right(user);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(RemoteDatabaseFailure(message: 'Failed to update user: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> uploadProfilePicture(File imageFile) async {
    try {
      final url = await _remoteDataSource.uploadProfilePicture(imageFile);
      return Right(url);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(
        RemoteDatabaseFailure(message: 'Failed to upload profile picture: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, NotificationPreferences>> updateNotificationPreferences(
    bool push,
    bool booking,
    bool chat,
  ) async {
    try {
      final prefs = await _remoteDataSource.updateNotificationPreferences(
        push,
        booking,
        chat,
      );
      return Right(prefs);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(
        RemoteDatabaseFailure(
          message: 'Failed to update notification preferences: $e',
        ),
      );
    }
  }
}
