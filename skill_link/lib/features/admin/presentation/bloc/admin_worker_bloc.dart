import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:skill_link/features/explore/domain/entity/explore_worker_entity.dart';
import 'package:skill_link/features/admin/domain/repository/admin_worker_repository.dart';

part 'admin_worker_event.dart';
part 'admin_worker_state.dart';

class AdminWorkerBloc extends Bloc<AdminWorkerEvent, AdminWorkerState> {
  final AdminWorkerRepository _repo = AdminWorkerRepository();

  AdminWorkerBloc() : super(AdminWorkerInitial()) {
    on<FetchPendingWorkers>((event, emit) async {
      emit(AdminWorkerLoading());
      try {
        final workers = await _repo.getPendingWorkers();
        emit(PendingWorkersLoaded(workers));
      } catch (e) {
        emit(AdminWorkerError(e.toString()));
      }
    });

    on<VerifyWorkerEvent>((event, emit) async {
      emit(AdminWorkerLoading());
      try {
        await _repo.verifyWorker(event.workerId, event.action, reason: event.reason);
        emit(WorkerVerificationSuccess());
        add(FetchPendingWorkers()); // Refresh list
      } catch (e) {
        emit(AdminWorkerError(e.toString()));
        add(FetchPendingWorkers()); // Refresh list anyway
      }
    });
  }
}
