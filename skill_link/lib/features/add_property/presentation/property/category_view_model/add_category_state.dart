// lib/features/add_property/presentation/bloc/add_property_state.dart

import 'package:equatable/equatable.dart';
import 'package:skill_link/features/add_property/domain/entity/category/category_entity.dart';

abstract class CategoryState extends Equatable {
  final List<CategoryEntity> categories;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;
  final bool isAddingCategory; // New flag for category submission

  const CategoryState({
    this.categories = const [],
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
    this.isAddingCategory = false,
  });

  @override
  List<Object?> get props => [
    categories,
    isLoading,
    errorMessage,
    successMessage,
    isAddingCategory,
  ];

  CategoryState copyWith({
    List<CategoryEntity>? categories,
    bool? isLoading,
    String? errorMessage, // Nullable to clear
    String? successMessage, // Nullable to clear
    bool? isAddingCategory,
  });
}

class CategoryInitial extends CategoryState {
  const CategoryInitial({
    super.categories = const [],
    super.isLoading = false,
    super.errorMessage,
    super.successMessage,
    super.isAddingCategory = false,
  });

  @override
  CategoryInitial copyWith({
    List<CategoryEntity>? categories,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    bool? isAddingCategory,
  }) {
    return CategoryInitial(
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage, // Allow null to clear
      successMessage: successMessage, // Allow null to clear
      isAddingCategory: isAddingCategory ?? this.isAddingCategory,
    );
  }
}

class CategoryLoading extends CategoryState {
  const CategoryLoading({
    required super.categories, // Pass existing categories during loading
    super.isLoading = true,
    super.errorMessage,
    super.successMessage,
    super.isAddingCategory = false,
  });

  @override
  CategoryLoading copyWith({
    List<CategoryEntity>? categories,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    bool? isAddingCategory,
  }) {
    return CategoryLoading(
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
      isAddingCategory: isAddingCategory ?? this.isAddingCategory,
    );
  }
}

class CategoryLoaded extends CategoryState {
  const CategoryLoaded({
    required super.categories,
    super.isLoading = false,
    super.errorMessage,
    super.successMessage,
    super.isAddingCategory = false,
  });

  @override
  CategoryLoaded copyWith({
    List<CategoryEntity>? categories,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    bool? isAddingCategory,
  }) {
    return CategoryLoaded(
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
      isAddingCategory: isAddingCategory ?? this.isAddingCategory,
    );
  }
}

class CategoryAddInProgress extends CategoryState {
  const CategoryAddInProgress({
    required super.categories,
    super.isLoading = false, // Not loading categories, but adding one
    super.errorMessage,
    super.successMessage,
    super.isAddingCategory = true,
  });

  @override
  CategoryAddInProgress copyWith({
    List<CategoryEntity>? categories,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    bool? isAddingCategory,
  }) {
    return CategoryAddInProgress(
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
      isAddingCategory: isAddingCategory ?? this.isAddingCategory,
    );
  }
}

class CategoryAddSuccess extends CategoryState {
  const CategoryAddSuccess({
    required super.categories,
    required super.successMessage,
    super.isLoading = false,
    super.errorMessage,
    super.isAddingCategory = false,
  });

  @override
  CategoryAddSuccess copyWith({
    List<CategoryEntity>? categories,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    bool? isAddingCategory,
  }) {
    return CategoryAddSuccess(
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage ?? this.successMessage, // Keep success message if not explicitly cleared
      isAddingCategory: isAddingCategory ?? this.isAddingCategory,
    );
  }
}


class CategoryError extends CategoryState {
  const CategoryError({
    required super.errorMessage,
    super.categories = const [], // Keep categories if it's not a loading error
    super.isLoading = false,
    super.successMessage,
    super.isAddingCategory = false,
  });

  @override
  CategoryError copyWith({
    List<CategoryEntity>? categories,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    bool? isAddingCategory,
  }) {
    return CategoryError(
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage, // Keep error message if not explicitly cleared
      successMessage: successMessage,
      isAddingCategory: isAddingCategory ?? this.isAddingCategory,
    );
  }
}