import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skill_link/cores/error/failure.dart';

class TokenSharedPrefs {
  final SharedPreferences _sharedPreferences;

  TokenSharedPrefs({required SharedPreferences sharedPreferences})
      : _sharedPreferences = sharedPreferences;

  Future<Either<Failure, void>> saveToken(String token) async {
    try {
      await _sharedPreferences.setString('token', token);
      return Right(null);
    } catch (e) {
      return Left(
        SharedPreferencesFailure(message: 'Failed to save token: $e'),
      );
    }
  }

  Future<Either<Failure, String?>> getToken() async {
    try {
      final token = _sharedPreferences.getString('token');
      return Right(token);
    } catch (e) {
      return Left(
        SharedPreferencesFailure(message: 'Failed to retrieve token: $e'),
      );
    }
  }

  Future<Either<Failure, void>> deleteToken() async {
    try {
      await _sharedPreferences.remove('token');
      return Right(null);
    } catch (e) {
      return Left(
        SharedPreferencesFailure(message: 'Failed to delete token: $e'),
      );
    }
  }

  Future<Either<Failure, void>> saveRole(String role) async {
    try {
      await _sharedPreferences.setString('role', role);
      return Right(null);
    } catch (e) {
      return Left(
        SharedPreferencesFailure(message: 'Failed to save role: $e'),
      );
    }
  }

  Future<Either<Failure, String?>> getRole() async {
    try {
      final role = _sharedPreferences.getString('role');
      return Right(role);
    } catch (e) {
      return Left(
        SharedPreferencesFailure(message: 'Failed to retrieve role: $e'),
      );
    }
  }

  Future<Either<Failure, void>> deleteRole() async {
    try {
      await _sharedPreferences.remove('role');
      return Right(null);
    } catch (e) {
      return Left(
        SharedPreferencesFailure(message: 'Failed to delete role: $e'),
      );
    }
  }

  Future<Either<Failure, void>> saveUserId(String userId) async {
    try {
      await _sharedPreferences.setString('userId', userId);
      return Right(null);
    } catch (e) {
      return Left(
        SharedPreferencesFailure(message: 'Failed to save userId: $e'),
      );
    }
  }

  Future<Either<Failure, String?>> getUserId() async {
    try {
      final userId = _sharedPreferences.getString('userId');
      return Right(userId);
    } catch (e) {
      return Left(
        SharedPreferencesFailure(message: 'Failed to retrieve userId: $e'),
      );
    }
  }

  Future<Either<Failure, void>> deleteUserId() async {
    try {
      await _sharedPreferences.remove('userId');
      return Right(null);
    } catch (e) {
      return Left(
        SharedPreferencesFailure(message: 'Failed to delete userId: $e'),
      );
    }
  }
}
