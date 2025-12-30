import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skill_link/features/profile/domain/use_case/deactivate_worker_usecase.dart';
import 'package:skill_link/features/profile/domain/use_case/get_worker_profile_usecase.dart';
import 'package:skill_link/features/profile/domain/use_case/update_worker_profile_usecase.dart';
import 'package:skill_link/features/profile/presentation/view_model/worker_profile_event.dart';
import 'package:skill_link/features/profile/presentation/view_model/worker_profile_state.dart';

class WorkerProfileBloc extends Bloc<WorkerProfileEvent, WorkerProfileState> {
  final GetWorkerProfileUseCase getWorkerProfileUseCase;
  final UpdateWorkerProfileUseCase updateWorkerProfileUseCase;
  final DeactivateWorkerUseCase deactivateWorkerUseCase;

  WorkerProfileBloc({
    required this.getWorkerProfileUseCase,
    required this.updateWorkerProfileUseCase,
    required this.deactivateWorkerUseCase,
  }) : super(const WorkerProfileState()) {
    on<FetchWorkerProfileEvent>(_onFetchWorkerProfile);
    on<UpdateWorkerEvent>(_onUpdateWorker);
    on<DeactivateWorkerEvent>(_onDeactivateWorker);
  }

  Future<void> _onFetchWorkerProfile(
    FetchWorkerProfileEvent event,
    Emitter<WorkerProfileState> emit,
  ) async {
    emit(state.copyWith(status: WorkerProfileStatus.loading));
    final result = await getWorkerProfileUseCase(event.workerId);
    result.fold(
      (failure) => emit(state.copyWith(
          status: WorkerProfileStatus.error, errorMessage: failure.message)),
      (worker) => emit(state.copyWith(
          status: WorkerProfileStatus.loaded, worker: worker)),
    );
  }

  Future<void> _onUpdateWorker(
    UpdateWorkerEvent event,
    Emitter<WorkerProfileState> emit,
  ) async {
    emit(state.copyWith(status: WorkerProfileStatus.loading));
    final result = await updateWorkerProfileUseCase(
        event.workerId, event.data, event.newImages);
    result.fold(
      (failure) => emit(state.copyWith(
          status: WorkerProfileStatus.error, errorMessage: failure.message)),
      (worker) => emit(state.copyWith(
          status: WorkerProfileStatus.success,
          worker: worker,
          successMessage: "Profile Updated Successfully")),
    );
  }

  Future<void> _onDeactivateWorker(
    DeactivateWorkerEvent event,
    Emitter<WorkerProfileState> emit,
  ) async {
    emit(state.copyWith(status: WorkerProfileStatus.loading));
    final result = await deactivateWorkerUseCase(event.workerId);
    result.fold(
      (failure) => emit(state.copyWith(
          status: WorkerProfileStatus.error, errorMessage: failure.message)),
      (_) => emit(state.copyWith(
          status: WorkerProfileStatus.success,
          successMessage: "Service Deactivated Successfully")),
    );
  }
}
