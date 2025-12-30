import 'package:equatable/equatable.dart';

abstract class AdminState extends Equatable {
  const AdminState();

  @override
  List<Object?> get props => [];
}

class AdminInitial extends AdminState {}

class AdminLoading extends AdminState {}

class AdminDashboardLoaded extends AdminState {
  final Map<String, dynamic> stats;
  const AdminDashboardLoaded(this.stats);

  @override
  List<Object?> get props => [stats];
}

class AdminPendingWorkersLoaded extends AdminState {
  final List<dynamic> workers;
  const AdminPendingWorkersLoaded(this.workers);

  @override
  List<Object?> get props => [workers];
}

class AdminUsersLoaded extends AdminState {
  final List<dynamic> users;
  const AdminUsersLoaded(this.users);

  @override
  List<Object?> get props => [users];
}

class AdminError extends AdminState {
  final String message;
  const AdminError(this.message);

  @override
  List<Object?> get props => [message];
}

class AdminActionSuccess extends AdminState {
  final String message;
  const AdminActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class AdminBookingsLoaded extends AdminState {
  final List<dynamic> bookings;
  const AdminBookingsLoaded(this.bookings);

  @override
  List<Object?> get props => [bookings];
}

class AdminBannersLoaded extends AdminState {
  final List<dynamic> banners;
  const AdminBannersLoaded(this.banners);

  @override
  List<Object?> get props => [banners];
}

class AdminBannerActionSuccess extends AdminState {
  final String message;
  const AdminBannerActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
