import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skill_link/features/admin/domain/repository/admin_repository.dart';
import 'admin_state.dart';

class AdminCubit extends Cubit<AdminState> {
  final IAdminRepository _repository;

  AdminCubit(this._repository) : super(AdminInitial());

  Future<void> fetchDashboardStats() async {
    emit(AdminLoading());
    final result = await _repository.getDashboardStats();
    result.fold(
      (failure) => emit(AdminError(failure.message)),
      (stats) => emit(AdminDashboardLoaded(stats)),
    );
  }

  Future<void> fetchPendingWorkers() async {
    emit(AdminLoading());
    final result = await _repository.getPendingWorkers();
    result.fold(
      (failure) => emit(AdminError(failure.message)),
      (workers) => emit(AdminPendingWorkersLoaded(workers)),
    );
  }

  Future<void> verifyWorker(String workerId, String action, {String? reason}) async {
    emit(AdminLoading());
    final result = await _repository.verifyWorker(workerId, action, reason);
    result.fold(
      (failure) => emit(AdminError(failure.message)),
      (_) {
        emit(const AdminActionSuccess('Worker status updated successfully'));
        fetchPendingWorkers(); // Refresh list
      },
    );
  }

  Future<void> fetchAllUsers() async {
    emit(AdminLoading());
    final result = await _repository.getAllUsers();
    result.fold(
      (failure) => emit(AdminError(failure.message)),
      (users) => emit(AdminUsersLoaded(users)),
    );
  }

  Future<void> toggleUserSuspension(String userId) async {
    final result = await _repository.toggleUserSuspension(userId);
    result.fold(
      (failure) => emit(AdminError(failure.message)),
      (_) {
        emit(const AdminActionSuccess('User status updated'));
        fetchAllUsers(); // Refresh list
      },
    );
  }

  Future<void> toggleCategory(String categoryId) async {
    final result = await _repository.toggleCategoryStatus(categoryId);
    result.fold(
      (failure) => emit(AdminError(failure.message)),
      (_) {
        emit(const AdminActionSuccess('Category status updated'));
      },
    );
  }

  Future<void> fetchAllBookings() async {
    emit(AdminLoading());
    final result = await _repository.getAllBookings();
    result.fold(
      (failure) => emit(AdminError(failure.message)),
      (bookings) => emit(AdminBookingsLoaded(bookings)),
    );
  }
}
