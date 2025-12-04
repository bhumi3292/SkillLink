// lib/cores/error/failure.dart

import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure({required this.message});

  @override
  List<Object?> get props => [message];
}

class LocalDatabaseFailure extends Failure {
  const LocalDatabaseFailure({required super.message});
}

class RemoteDatabaseFailure extends Failure {
  final int? statusCode;
  const RemoteDatabaseFailure({this.statusCode, required super.message});
}

class SharedPreferencesFailure extends Failure {
  const SharedPreferencesFailure({required super.message});
}


class NetworkFailure extends Failure {
  const NetworkFailure({required super.message});
}

class InputFailure extends Failure {
  const InputFailure({required super.message});
}

class AuthFailure extends Failure {
  const AuthFailure({required super.message});
}

class ForbiddenFailure extends Failure {
  const ForbiddenFailure({required super.message});
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({required super.message});
}

class ServerFailure extends Failure {
  const ServerFailure({required super.message});
}

class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

class UnknownFailure extends Failure {
  const UnknownFailure({required super.message});
}