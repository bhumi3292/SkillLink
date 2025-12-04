import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:skill_link/features/dashbaord/domain/use_case/get_dashboard_properties_usecase.dart';
import 'package:skill_link/features/add_property/data/model/property_model/property_api_model.dart';

// Events
abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class LoadDashboardProperties extends DashboardEvent {
  const LoadDashboardProperties();
}

// States
abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

class DashboardLoaded extends DashboardState {
  final List<PropertyApiModel> properties;

  const DashboardLoaded(this.properties);

  @override
  List<Object?> get props => [properties];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}

// ViewModel/Bloc
class DashboardViewModel extends Bloc<DashboardEvent, DashboardState> {
  final GetDashboardPropertiesUsecase _getDashboardPropertiesUsecase;

  DashboardViewModel({
    required GetDashboardPropertiesUsecase getDashboardPropertiesUsecase,
  }) : _getDashboardPropertiesUsecase = getDashboardPropertiesUsecase,
       super(const DashboardInitial()) {
    on<LoadDashboardProperties>(_onLoadDashboardProperties);
  }

  Future<void> _onLoadDashboardProperties(
    LoadDashboardProperties event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoading());

    final result = await _getDashboardPropertiesUsecase();

    result.fold(
      (failure) => emit(DashboardError(failure.message)),
      (properties) => emit(DashboardLoaded(properties)),
    );
  }

  void loadProperties() {
    add(const LoadDashboardProperties());
  }
}
