import 'package:equatable/equatable.dart';
import 'package:skill_link/features/explore/domain/entity/explore_worker_entity.dart';

enum WorkerProfileStatus { initial, loading, loaded, error, success }

class WorkerProfileState extends Equatable {
  final WorkerProfileStatus status;
  final ExploreWorkerEntity? worker;
  final String? errorMessage;
  final String? successMessage;

  const WorkerProfileState({
    this.status = WorkerProfileStatus.initial,
    this.worker,
    this.errorMessage,
    this.successMessage,
  });

  WorkerProfileState copyWith({
    WorkerProfileStatus? status,
    ExploreWorkerEntity? worker,
    String? errorMessage,
    String? successMessage,
  }) {
    return WorkerProfileState(
      status: status ?? this.status,
      worker: worker ?? this.worker,
      errorMessage: errorMessage, // Reset unless provided
      successMessage: successMessage, // Reset unless provided
    );
  }

  @override
  List<Object?> get props => [status, worker, errorMessage, successMessage];
}
