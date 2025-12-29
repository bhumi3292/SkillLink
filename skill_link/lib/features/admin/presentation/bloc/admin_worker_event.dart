part of 'admin_worker_bloc.dart';

abstract class AdminWorkerEvent extends Equatable {
  const AdminWorkerEvent();
  @override
  List<Object?> get props => [];
}

class FetchPendingWorkers extends AdminWorkerEvent {}

class VerifyWorkerEvent extends AdminWorkerEvent {
  final String workerId;
  final String action; // 'approve' or 'reject'
  final String? reason;

  const VerifyWorkerEvent({required this.workerId, required this.action, this.reason});

  @override
  List<Object?> get props => [workerId, action, reason];
}
