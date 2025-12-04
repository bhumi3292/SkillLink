// lib/features/add_property/presentation/property/category_view_model/add_category_state.dart

import 'package:equatable/equatable.dart';
import 'package:skill_link/features/add_property/domain/entity/category/category_entity.dart';

abstract class CategoryState extends Equatable {
  final List<CategoryEntity> categories;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;
  final bool isAddingCategory;

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
    String? errorMessage, // Make sure this is explicitly nullable here
    String? successMessage, // Make sure this is explicitly nullable here
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
    String? errorMessage, // This should be nullable
    String? successMessage, // This should be nullable
    bool? isAddingCategory,
  }) {
    return CategoryInitial(
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage, // Assign directly, allowing null to clear
      successMessage: successMessage, // Assign directly, allowing null to clear
      isAddingCategory: isAddingCategory ?? this.isAddingCategory,
    );
  }
}

class CategoryLoading extends CategoryState {
  const CategoryLoading({
    required super.categories,
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
      errorMessage: errorMessage, // Assign directly
      successMessage: successMessage, // Assign directly
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
      errorMessage: errorMessage, // Assign directly
      successMessage: successMessage, // Assign directly
      isAddingCategory: isAddingCategory ?? this.isAddingCategory,
    );
  }
}

class CategoryAddInProgress extends CategoryState {
  const CategoryAddInProgress({
    required super.categories,
    super.isLoading = false,
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
      errorMessage: errorMessage, // Assign directly
      successMessage: successMessage, // Assign directly
      isAddingCategory: isAddingCategory ?? this.isAddingCategory,
    );
  }
}

class CategoryAddSuccess extends CategoryState {
  const CategoryAddSuccess({
    required super.categories,
    required super.successMessage, // This should remain required to ensure it's always set on success
    super.isLoading = false,
    super.errorMessage,
    super.isAddingCategory = false,
  });

  @override
  CategoryAddSuccess copyWith({
    List<CategoryEntity>? categories,
    bool? isLoading,
    String? errorMessage,
    String? successMessage, // This should be nullable in copyWith for clearing
    bool? isAddingCategory,
  }) {
    return CategoryAddSuccess(
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage, // Assign directly
      successMessage: successMessage, // Assign directly, allowing null to clear
      isAddingCategory: isAddingCategory ?? this.isAddingCategory,
    );
  }
}

class CategoryError extends CategoryState {
  const CategoryError({
    required super.errorMessage, // This should remain required to ensure an error message is always set
    super.categories = const [],
    super.isLoading = false,
    super.successMessage,
    super.isAddingCategory = false,
  });

  @override
  CategoryError copyWith({
    List<CategoryEntity>? categories,
    bool? isLoading,
    String? errorMessage, // This should be nullable in copyWith for clearing
    String? successMessage,
    bool? isAddingCategory,
  }) {
    return CategoryError(
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage, // Assign directly, allowing null to clear
      successMessage: successMessage, // Assign directly
      isAddingCategory: isAddingCategory ?? this.isAddingCategory,
    );
  }
}