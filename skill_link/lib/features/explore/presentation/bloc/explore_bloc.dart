import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:skill_link/features/explore/domain/entity/explore_property_entity.dart';
import 'package:skill_link/features/explore/domain/use_case/get_all_properties_usecase.dart';

// Events
abstract class ExploreEvent extends Equatable {
  const ExploreEvent();

  @override
  List<Object?> get props => [];
}

class GetPropertiesEvent extends ExploreEvent {}

class FilterPropertiesEvent extends ExploreEvent {
  final String searchText;
  final String? categoryId;
  final double? minPrice;
  final double? maxPrice;
  final int? minBedrooms;
  final int? minBathrooms;

  const FilterPropertiesEvent({
    required this.searchText,
    this.categoryId,
    this.minPrice,
    this.maxPrice,
    this.minBedrooms,
    this.minBathrooms,
  });

  @override
  List<Object?> get props => [
    searchText,
    categoryId,
    minPrice,
    maxPrice,
    minBedrooms,
    minBathrooms,
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
  final List<ExplorePropertyEntity> properties;
  final List<ExplorePropertyEntity> filteredProperties;

  const ExploreLoaded({
    required this.properties,
    required this.filteredProperties,
  });

  @override
  List<Object?> get props => [properties, filteredProperties];
}

class ExploreError extends ExploreState {
  final String message;

  const ExploreError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class ExploreBloc extends Bloc<ExploreEvent, ExploreState> {
  final GetExplorePropertiesUsecase getAllPropertiesUsecase;
  List<ExplorePropertyEntity> _allProperties = [];

  ExploreBloc({required this.getAllPropertiesUsecase})
    : super(ExploreInitial()) {
    on<GetPropertiesEvent>(_onGetProperties);
    on<FilterPropertiesEvent>(_onFilterProperties);
  }

  Future<void> _onGetProperties(
    GetPropertiesEvent event,
    Emitter<ExploreState> emit,
  ) async {
    emit(ExploreLoading());

    final result = await getAllPropertiesUsecase();
    result.fold((failure) => emit(ExploreError(failure.message)), (properties) {
      _allProperties = properties;
      emit(
        ExploreLoaded(properties: properties, filteredProperties: properties),
      );
    });
  }

  void _onFilterProperties(
    FilterPropertiesEvent event,
    Emitter<ExploreState> emit,
  ) {
    final filteredProperties =
        _allProperties.where((property) {
          // Search text filter - search in title, location, and description
          final searchLower = event.searchText.toLowerCase();
          final matchesSearch =
              event.searchText.isEmpty ||
              (property.title?.toLowerCase().contains(searchLower) ?? false) ||
              (property.location?.toLowerCase().contains(searchLower) ??
                  false) ||
              (property.description?.toLowerCase().contains(searchLower) ??
                  false);

          // Category filter
          final matchesCategory =
              event.categoryId == null ||
              property.categoryId == event.categoryId;

          // Price range filter
          final propertyPrice = property.price ?? 0;
          final matchesMinPrice =
              event.minPrice == null || propertyPrice >= event.minPrice!;
          final matchesMaxPrice =
              event.maxPrice == null || propertyPrice <= event.maxPrice!;

          // Bedrooms filter
          final propertyBedrooms = property.bedrooms ?? 0;
          final matchesMinBedrooms =
              event.minBedrooms == null ||
              propertyBedrooms >= event.minBedrooms!;

          // Bathrooms filter
          final propertyBathrooms = property.bathrooms ?? 0;
          final matchesMinBathrooms =
              event.minBathrooms == null ||
              propertyBathrooms >= event.minBathrooms!;

          return matchesSearch &&
              matchesCategory &&
              matchesMinPrice &&
              matchesMaxPrice &&
              matchesMinBedrooms &&
              matchesMinBathrooms;
        }).toList();

    emit(
      ExploreLoaded(
        properties: _allProperties,
        filteredProperties: filteredProperties,
      ),
    );
  }
}
