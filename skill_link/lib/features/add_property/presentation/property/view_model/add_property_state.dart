// lib/features/add_property/presentation/bloc/add_property_state.dart

import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

import 'package:skill_link/features/add_property/domain/entity/category/category_entity.dart';

abstract class AddPropertyState extends Equatable {
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;
  final List<CategoryEntity> categories;
  final String? selectedCategoryId;
  final List<XFile> selectedImages;
  final List<XFile> selectedVideos;
  final bool isSubmitting;

  const AddPropertyState({
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
    this.categories = const [],
    this.selectedCategoryId,
    this.selectedImages = const [],
    this.selectedVideos = const [],
    this.isSubmitting = false,
  });

  @override
  List<Object?> get props => [
    isLoading,
    errorMessage,
    successMessage,
    categories,
    selectedCategoryId,
    selectedImages,
    selectedVideos,
    isSubmitting,
  ];

  AddPropertyState copyWith({
    bool? isLoading,
    String? errorMessage, // Nullable to clear
    String? successMessage, // Nullable to clear
    List<CategoryEntity>? categories,
    String? selectedCategoryId, // Nullable to clear
    List<XFile>? selectedImages,
    List<XFile>? selectedVideos,
    bool? isSubmitting,
  });
}

class AddPropertyInitial extends AddPropertyState {
  const AddPropertyInitial({
    super.isLoading = false,
    super.errorMessage,
    super.successMessage,
    super.categories = const [],
    super.selectedCategoryId,
    super.selectedImages = const [],
    super.selectedVideos = const [],
    super.isSubmitting = false,
  });

  @override
  AddPropertyInitial copyWith({
    bool? isLoading,
    String? errorMessage, // <--- Add this
    String? successMessage, // <--- Add this
    List<CategoryEntity>? categories,
    String? selectedCategoryId,
    List<XFile>? selectedImages,
    List<XFile>? selectedVideos,
    bool? isSubmitting,
  }) {
    return AddPropertyInitial(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage, // Pass to constructor
      successMessage: successMessage, // Pass to constructor
      categories: categories ?? this.categories,
      selectedCategoryId: selectedCategoryId,
      selectedImages: selectedImages ?? this.selectedImages,
      selectedVideos: selectedVideos ?? this.selectedVideos,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

class AddPropertyLoadingState extends AddPropertyState {
  const AddPropertyLoadingState({
    required super.categories,
    super.isLoading = true,
    super.selectedCategoryId,
    super.selectedImages,
    super.selectedVideos,
    super.isSubmitting,
    super.errorMessage, // Added here as well for consistency
    super.successMessage, // Added here as well for consistency
  });

  @override
  AddPropertyLoadingState copyWith({
    bool? isLoading,
    String? errorMessage, // <--- Add this
    String? successMessage, // <--- Add this
    List<CategoryEntity>? categories,
    String? selectedCategoryId,
    List<XFile>? selectedImages,
    List<XFile>? selectedVideos,
    bool? isSubmitting,
  }) {
    return AddPropertyLoadingState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage, // Pass to constructor
      successMessage: successMessage, // Pass to constructor
      categories: categories ?? this.categories,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      selectedImages: selectedImages ?? this.selectedImages,
      selectedVideos: selectedVideos ?? this.selectedVideos,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

class AddPropertyLoadedState extends AddPropertyState {
  const AddPropertyLoadedState({
    required super.categories,
    super.isLoading = false,
    super.errorMessage,
    super.successMessage,
    super.selectedCategoryId,
    super.selectedImages,
    super.selectedVideos,
    super.isSubmitting = false,
  });

  @override
  AddPropertyLoadedState copyWith({
    bool? isLoading,
    String? errorMessage, // <--- Add this
    String? successMessage, // <--- Add this
    List<CategoryEntity>? categories,
    String? selectedCategoryId,
    List<XFile>? selectedImages,
    List<XFile>? selectedVideos,
    bool? isSubmitting,
  }) {
    return AddPropertyLoadedState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage, // Pass to constructor
      successMessage: successMessage, // Pass to constructor
      categories: categories ?? this.categories,
      selectedCategoryId: selectedCategoryId, // Allow null to clear
      selectedImages: selectedImages ?? this.selectedImages,
      selectedVideos: selectedVideos ?? this.selectedVideos,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

class AddPropertySubmissionSuccess extends AddPropertyState {
  const AddPropertySubmissionSuccess({
    required super.successMessage,
    required super.categories,
    super.isLoading = false,
    super.selectedCategoryId,
    super.selectedImages,
    super.selectedVideos,
    super.isSubmitting = false,
    super.errorMessage, // Added here for consistency, though typically null on success
  });

  @override
  AddPropertySubmissionSuccess copyWith({
    bool? isLoading,
    String? errorMessage, // <--- Add this
    String? successMessage, // <--- Add this
    List<CategoryEntity>? categories,
    String? selectedCategoryId,
    List<XFile>? selectedImages,
    List<XFile>? selectedVideos,
    bool? isSubmitting,
  }) {
    return AddPropertySubmissionSuccess(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage, // Pass to constructor
      successMessage: successMessage ?? this.successMessage,
      categories: categories ?? this.categories,
      selectedCategoryId: selectedCategoryId,
      selectedImages: selectedImages ?? this.selectedImages,
      selectedVideos: selectedVideos ?? this.selectedVideos,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

class AddPropertyErrorState extends AddPropertyState {
  const AddPropertyErrorState({
    required super.errorMessage,
    super.categories = const [], // Keep categories if error is not category loading
    super.isLoading = false,
    super.selectedCategoryId,
    super.selectedImages,
    super.selectedVideos,
    super.isSubmitting = false,
    super.successMessage, // Added here for consistency, though typically null on error
  });

  @override
  AddPropertyErrorState copyWith({
    bool? isLoading,
    String? errorMessage, // <--- Add this
    String? successMessage, // <--- Add this
    List<CategoryEntity>? categories,
    String? selectedCategoryId,
    List<XFile>? selectedImages,
    List<XFile>? selectedVideos,
    bool? isSubmitting,
  }) {
    return AddPropertyErrorState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage, // Pass to constructor
      categories: categories ?? this.categories,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      selectedImages: selectedImages ?? this.selectedImages,
      selectedVideos: selectedVideos ?? this.selectedVideos,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}