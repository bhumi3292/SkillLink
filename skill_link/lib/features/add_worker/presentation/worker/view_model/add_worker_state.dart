// lib/features/add_worker/presentation/bloc/add_worker_state.dart

import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

import 'package:skill_link/features/add_worker/domain/entity/category/category_entity.dart';

// lib/features/add_worker/presentation/bloc/add_worker_state.dart


abstract class AddWorkerState extends Equatable {
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;
  final List<CategoryEntity> categories;
  final String? selectedCategoryId;
  final List<XFile> selectedImages;
  final List<XFile> selectedVideos;
  final bool isSubmitting;

  const AddWorkerState({
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

  AddWorkerState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    List<CategoryEntity>? categories,
    String? selectedCategoryId,
    List<XFile>? selectedImages,
    List<XFile>? selectedVideos,
    bool? isSubmitting,
  });
}

// -----------------------------
// INITIAL STATE
// -----------------------------
class AddWorkerInitial extends AddWorkerState {
  const AddWorkerInitial({
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
  AddWorkerInitial copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    List<CategoryEntity>? categories,
    String? selectedCategoryId,
    List<XFile>? selectedImages,
    List<XFile>? selectedVideos,
    bool? isSubmitting,
  }) {
    return AddWorkerInitial(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
      categories: categories ?? this.categories,
      selectedCategoryId: selectedCategoryId,
      selectedImages: selectedImages ?? this.selectedImages,
      selectedVideos: selectedVideos ?? this.selectedVideos,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

// -----------------------------
// LOADING STATE
// -----------------------------
class AddWorkerLoadingState extends AddWorkerState {
  const AddWorkerLoadingState({
    required super.categories,
    super.isLoading = true,
    super.selectedCategoryId,
    super.selectedImages,
    super.selectedVideos,
    super.isSubmitting,
    super.errorMessage,
    super.successMessage,
  });

  @override
  AddWorkerLoadingState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    List<CategoryEntity>? categories,
    String? selectedCategoryId,
    List<XFile>? selectedImages,
    List<XFile>? selectedVideos,
    bool? isSubmitting,
  }) {
    return AddWorkerLoadingState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
      categories: categories ?? this.categories,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      selectedImages: selectedImages ?? this.selectedImages,
      selectedVideos: selectedVideos ?? this.selectedVideos,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

// -----------------------------
// LOADED STATE
// -----------------------------
class AddWorkerLoadedState extends AddWorkerState {
  const AddWorkerLoadedState({
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
  AddWorkerLoadedState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    List<CategoryEntity>? categories,
    String? selectedCategoryId,
    List<XFile>? selectedImages,
    List<XFile>? selectedVideos,
    bool? isSubmitting,
  }) {
    return AddWorkerLoadedState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
      categories: categories ?? this.categories,
      selectedCategoryId: selectedCategoryId,
      selectedImages: selectedImages ?? this.selectedImages,
      selectedVideos: selectedVideos ?? this.selectedVideos,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

// -----------------------------
// SUCCESS STATE
// -----------------------------
class AddWorkerSubmissionSuccess extends AddWorkerState {
  const AddWorkerSubmissionSuccess({
    required super.successMessage,
    required super.categories,
    super.isLoading = false,
    super.selectedCategoryId,
    super.selectedImages,
    super.selectedVideos,
    super.isSubmitting = false,
    super.errorMessage,
  });

  @override
  AddWorkerSubmissionSuccess copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    List<CategoryEntity>? categories,
    String? selectedCategoryId,
    List<XFile>? selectedImages,
    List<XFile>? selectedVideos,
    bool? isSubmitting,
  }) {
    return AddWorkerSubmissionSuccess(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage ?? this.successMessage,
      categories: categories ?? this.categories,
      selectedCategoryId: selectedCategoryId,
      selectedImages: selectedImages ?? this.selectedImages,
      selectedVideos: selectedVideos ?? this.selectedVideos,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

// -----------------------------
// ERROR STATE
// -----------------------------
class AddWorkerErrorState extends AddWorkerState {
  const AddWorkerErrorState({
    required super.errorMessage,
    super.categories = const [],
    super.isLoading = false,
    super.selectedCategoryId,
    super.selectedImages,
    super.selectedVideos,
    super.isSubmitting = false,
    super.successMessage,
  });

  @override
  AddWorkerErrorState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    List<CategoryEntity>? categories,
    String? selectedCategoryId,
    List<XFile>? selectedImages,
    List<XFile>? selectedVideos,
    bool? isSubmitting,
  }) {
    return AddWorkerErrorState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage,
      categories: categories ?? this.categories,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      selectedImages: selectedImages ?? this.selectedImages,
      selectedVideos: selectedVideos ?? this.selectedVideos,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}
