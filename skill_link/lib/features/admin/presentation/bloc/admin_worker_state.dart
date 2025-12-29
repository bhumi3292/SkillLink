part of 'admin_worker_bloc.dart';

abstract class AdminWorkerState extends Equatable {
  const AdminWorkerState();
  @override
  List<Object?> get props => [];
}

class AdminWorkerInitial extends AdminWorkerState {}

class AdminWorkerLoading extends AdminWorkerState {}

class PendingWorkersLoaded extends AdminWorkerState {
  final List<ExploreWorkerEntity> workers;
  const PendingWorkersLoaded(this.workers);
  @override
  List<Object?> get props => [workers];
}

class WorkerVerificationSuccess extends AdminWorkerState {}

class AdminWorkerError extends AdminWorkerState {
  final String message;
  const AdminWorkerError(this.message);
  @override
  List<Object?> get props => [message];
}
