import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:skill_link/features/explore/domain/entity/explore_worker_entity.dart';
import 'package:skill_link/features/explore/domain/use_case/get_all_workers_usecase.dart';

// Events
abstract class ExploreEvent extends Equatable {
  const ExploreEvent();

  @override
  List<Object?> get props => [];
}

class GetWorkersEvent extends ExploreEvent {
  final double? lat;
  final double? long;

  const GetWorkersEvent({this.lat, this.long});

  @override
  List<Object?> get props => [lat, long];
}

class FilterWorkersEvent extends ExploreEvent {
  final String searchText;
  final String? categoryId;
  final double? minPrice;
  final double? maxPrice;

  const FilterWorkersEvent({
    required this.searchText,
    this.categoryId,
    this.minPrice,
    this.maxPrice,
  });

  @override
  List<Object?> get props => [
    searchText,
    categoryId,
    minPrice,
    maxPrice,
  ];
}

// States
abstract class ExploreState extends Equatable {
  const ExploreState();

  @override
  List<Object?> get props => [];
}

class ExploreInitial extends ExploreState {}

class ExploreLoading extends ExploreState {}

class ExploreLoaded extends ExploreState {
  final List<ExploreWorkerEntity> workers;
  final List<ExploreWorkerEntity> filteredWorkers;

  const ExploreLoaded({
    required this.workers,
    required this.filteredWorkers,
  });

  @override
  List<Object?> get props => [workers, filteredWorkers];
}

class ExploreError extends ExploreState {
  final String message;

  const ExploreError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class ExploreBloc extends Bloc<ExploreEvent, ExploreState> {
  final GetAllWorkersUsecase getAllWorkersUsecase;
  List<ExploreWorkerEntity> _allWorkers = [];

  ExploreBloc({required this.getAllWorkersUsecase})
    : super(ExploreInitial()) {
    on<GetWorkersEvent>(_onGetWorkers);
    on<FilterWorkersEvent>(_onFilterWorkers);
  }

  Future<void> _onGetWorkers(
    GetWorkersEvent event,
    Emitter<ExploreState> emit,
  ) async {
    emit(ExploreLoading());

    // If location is provided, fetch nearby workers. Otherwise fetch all.
    final result = await getAllWorkersUsecase(lat: event.lat, long: event.long);
    result.fold((failure) => emit(ExploreError(failure.message)), (workers) {
      _allWorkers = workers;
      emit(
        ExploreLoaded(workers: workers, filteredWorkers: workers),
      );
    });
  }

  void _onFilterWorkers(
    FilterWorkersEvent event,
    Emitter<ExploreState> emit,
  ) {
    final filteredWorkers =
        _allWorkers.where((worker) {
          // Search text filter - search in title, location, and description
          final searchLower = event.searchText.toLowerCase();
          final matchesSearch =
              event.searchText.isEmpty ||
              (worker.title?.toLowerCase().contains(searchLower) ?? false) ||
              (worker.location?.toLowerCase().contains(searchLower) ??
                  false) ||
              (worker.description?.toLowerCase().contains(searchLower) ??
                  false);

          // Category filter
          final matchesCategory =
              event.categoryId == null ||
              worker.categoryId == event.categoryId;

          // Price range filter
          final workerPrice = worker.price ?? 0;
          final matchesMinPrice =
              event.minPrice == null || workerPrice >= event.minPrice!;
          final matchesMaxPrice =
              event.maxPrice == null || workerPrice <= event.maxPrice!;

          return matchesSearch &&
              matchesCategory &&
              matchesMinPrice &&
              matchesMaxPrice;
        }).toList();

    emit(
      ExploreLoaded(
        workers: _allWorkers,
        filteredWorkers: filteredWorkers,
      ),
    );
  }
}
