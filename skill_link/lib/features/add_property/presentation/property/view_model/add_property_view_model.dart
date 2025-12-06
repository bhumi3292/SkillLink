// lib/features/add_property/presentation/bloc/add_property_bloc.dart

import 'package:bloc/bloc.dart';
import 'package:skill_link/features/add_property/domain/use_case/category/get_all_categories_usecase.dart';
// Corrected imports - these are actual imports, not 'part' files
import 'package:skill_link/features/add_property/presentation/property/view_model/add_property_event.dart';
import 'package:skill_link/features/add_property/presentation/property/view_model/add_property_state.dart';
import 'package:image_picker/image_picker.dart'; // For XFile
// For BuildContext and TextEditingController
import 'package:skill_link/cores/common/snackbar/snackbar.dart'; // Assuming you have this

import 'package:skill_link/features/add_property/domain/entity/property/property_entity.dart';
import 'package:skill_link/features/add_property/domain/entity/category/category_entity.dart';
import 'package:skill_link/features/add_property/domain/use_case/property/add_property_usecase.dart';
import 'package:skill_link/features/add_property/domain/use_case/property/update_property_usecase.dart';
import 'package:skill_link/app/shared_pref/token_shared_prefs.dart';

class AddPropertyBloc extends Bloc<AddPropertyEvent, AddPropertyState> {
  final AddPropertyUsecase _addPropertyUsecase;
  final UpdatePropertyUsecase _updatePropertyUsecase;
  final GetAllCategoriesUsecase _getAllCategoriesUsecase;
  final TokenSharedPrefs _tokenSharedPrefs;

  // Internal state for selected media and category ID
  // These will be updated by events and then copied into the emitted state.
  String? _selectedCategoryId;
  final List<XFile> _currentImages = [];
  final List<XFile> _currentVideos = [];
  List<CategoryEntity> _currentCategories = [];

  AddPropertyBloc({
    required AddPropertyUsecase addPropertyUsecase,
    required UpdatePropertyUsecase updatePropertyUsecase,
    required GetAllCategoriesUsecase getAllCategoriesUsecase,
    required TokenSharedPrefs tokenSharedPrefs,
  }) : _addPropertyUsecase = addPropertyUsecase,
       _updatePropertyUsecase = updatePropertyUsecase,
       _getAllCategoriesUsecase = getAllCategoriesUsecase,
       _tokenSharedPrefs = tokenSharedPrefs,
       super(const AddPropertyInitial()) {
    on<InitializeAddPropertyForm>(_onInitializeAddPropertyForm);
    on<SelectCategoryEvent>(_onSelectCategory);
    on<AddImageEvent>(_onAddImage);
    on<RemoveImageEvent>(_onRemoveImage);
    on<AddVideoEvent>(_onAddVideo);
    on<RemoveVideoEvent>(_onRemoveVideo);
    on<NewCategoryAddedEvent>(_onNewCategoryAdded);
    on<SubmitPropertyEvent>(_onSubmitProperty);
    on<SubmitUpdatePropertyEvent>(_onSubmitUpdateProperty);
    on<ClearAddPropertyMessageEvent>(_onClearAddPropertyMessage);
  }

  Future<void> _onInitializeAddPropertyForm(
    InitializeAddPropertyForm event,
    Emitter<AddPropertyState> emit,
  ) async {
    print('Initializing add Workerform...');
    emit(
      AddPropertyLoadingState(categories: _currentCategories),
    ); // Pass existing categories
    final result = await _getAllCategoriesUsecase();
    result.fold(
      (failure) {
        print('Failed to load categories: ${failure.message}');
        emit(
          AddPropertyErrorState(
            errorMessage: failure.message,
            categories: _currentCategories,
          ),
        );
      },
      (categories) {
        print('Successfully loaded ${categories.length} categories');
        _currentCategories = categories; // Update internal list
        emit(
          AddPropertyLoadedState(
            categories: _currentCategories,
            selectedCategoryId: _selectedCategoryId,
            selectedImages: List.from(_currentImages),
            selectedVideos: List.from(_currentVideos),
          ),
        );
      },
    );
  }

  void _onSelectCategory(
    SelectCategoryEvent event,
    Emitter<AddPropertyState> emit,
  ) {
    _selectedCategoryId = event.categoryId;
    // It's safer to always get the current state and then copy, rather than
    // casting to specific states, unless behavior differs greatly per state.
    // However, given your state structure, this is fine, but ensure `copyWith`
    // is robust in all states.
    emit(
      state.copyWith(
        selectedCategoryId: _selectedCategoryId,
        errorMessage: null, // Clear any previous error
      ),
    );
  }

  void _onAddImage(AddImageEvent event, Emitter<AddPropertyState> emit) {
    _currentImages.add(event.image);
    emit(
      state.copyWith(
        selectedImages: List.from(_currentImages),
        errorMessage: null, // Clear any previous error
      ),
    );
  }

  void _onRemoveImage(RemoveImageEvent event, Emitter<AddPropertyState> emit) {
    if (event.index >= 0 && event.index < _currentImages.length) {
      _currentImages.removeAt(event.index);
    }
    emit(
      state.copyWith(
        selectedImages: List.from(_currentImages),
        errorMessage: null, // Clear any previous error
      ),
    );
  }

  void _onAddVideo(AddVideoEvent event, Emitter<AddPropertyState> emit) {
    _currentVideos.add(event.video);
    emit(
      state.copyWith(
        selectedVideos: List.from(_currentVideos),
        errorMessage: null, // Clear any previous error
      ),
    );
  }

  void _onRemoveVideo(RemoveVideoEvent event, Emitter<AddPropertyState> emit) {
    if (event.index >= 0 && event.index < _currentVideos.length) {
      _currentVideos.removeAt(event.index);
    }
    emit(
      state.copyWith(
        selectedVideos: List.from(_currentVideos),
        errorMessage: null, // Clear any previous error
      ),
    );
  }

  void _onNewCategoryAdded(
    NewCategoryAddedEvent event,
    Emitter<AddPropertyState> emit,
  ) {
    _currentCategories.add(event.newCategory);
    _selectedCategoryId = event.newCategory.id; // Auto-select new category

    emit(
      state.copyWith(
        categories: List.from(_currentCategories),
        selectedCategoryId: _selectedCategoryId,
        errorMessage: null, // Clear any previous error
      ),
    );
  }

  Future<void> _onSubmitProperty(
    SubmitPropertyEvent event,
    Emitter<AddPropertyState> emit,
  ) async {
    emit(
      state.copyWith(
        isSubmitting: true,
        errorMessage: null,
        successMessage: null,
      ),
    );

    // Enhanced validation
    final validationErrors = <String>[];

    if (event.title.trim().isEmpty) {
      validationErrors.add('Workertitle is required');
    }
    if (event.location.trim().isEmpty) {
      validationErrors.add('Workerlocation is required');
    }
    if (event.price.trim().isEmpty) {
      validationErrors.add('Workerprice is required');
    } else {
      final price = double.tryParse(event.price);
      if (price == null || price <= 0) {
        validationErrors.add(
          'Workerprice must be a valid number greater than 0',
        );
      }
    }
    if (event.description.trim().isEmpty) {
      validationErrors.add('Workerdescription is required');
    }
    if (event.bedrooms.trim().isEmpty) {
      validationErrors.add('Number of bedrooms is required');
    } else {
      final bedrooms = int.tryParse(event.bedrooms);
      if (bedrooms == null || bedrooms < 0) {
        validationErrors.add('Bedrooms must be a valid number (0 or more)');
      }
    }
    if (event.bathrooms.trim().isEmpty) {
      validationErrors.add('Number of bathrooms is required');
    } else {
      final bathrooms = int.tryParse(event.bathrooms);
      if (bathrooms == null || bathrooms < 0) {
        validationErrors.add('Bathrooms must be a valid number (0 or more)');
      }
    }
    if (event.categoryId == null || event.categoryId!.isEmpty) {
      validationErrors.add('Workercategory is required');
    }
    if (_currentImages.isEmpty) {
      validationErrors.add('At least one Workerimage is required');
    }

    if (validationErrors.isNotEmpty) {
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: validationErrors.join('\n'),
        ),
      );
      if (event.context != null) {
        showMySnackbar(
          context: event.context!,
          content: validationErrors.join('\n'),
          isSuccess: false,
        );
      }
      return;
    }

    try {
      // For now, we'll use a default user ID or skip authentication
      // This allows Workercreation without login requirement
      String? userId;
      final userIdEither = await _tokenSharedPrefs.getUserId();
      userIdEither.fold((l) => null, (r) => userId = r);

      final property = PropertyEntity(
        id: null,
        title: event.title.trim(),
        location: event.location.trim(),
        price: double.parse(event.price),
        description: event.description.trim(),
        bedrooms: int.parse(event.bedrooms),
        bathrooms: int.parse(event.bathrooms),
        categoryId: event.categoryId!,
        workerId: userId, // Use user ID if available, otherwise null
        images: const [],
        videos: const [],
      );

      final imagePaths = _currentImages.map((file) => file.path).toList();
      final videoPaths = _currentVideos.map((file) => file.path).toList();

      print('Submitting Workerwith data:');
      print('Title: ${property.title}');
      print('Location: ${property.location}');
      print('Price: ${property.price}');
      print('Category: ${property.categoryId}');
      print(
        'worker ID: ${property.workerId ?? "No user ID (proceeding without auth)"}',
      );
      print('Images: ${imagePaths.length} files');
      print('Videos: ${videoPaths.length} files');

      final result = await _addPropertyUsecase(
        AddPropertyParams(
          property: property,
          imagePaths: imagePaths,
          videoPaths: videoPaths,
        ),
      );

      result.fold(
        (failure) {
          emit(
            state.copyWith(isSubmitting: false, errorMessage: failure.message),
          );
          if (event.context != null) {
            showMySnackbar(
              context: event.context!,
              content: failure.message,
              isSuccess: false,
            );
          }
        },
        (_) {
          // Reset local state after successful submission
          _selectedCategoryId = null;
          _currentImages.clear();
          _currentVideos.clear();
          // Keep _currentCategories for next form use
          emit(
            AddPropertySubmissionSuccess(
              successMessage: "Workeradded successfully to backend!",
              categories: List.from(
                _currentCategories,
              ), // Pass current categories
              selectedCategoryId: null, // Clear selected category
              selectedImages: [], // Clear selected images
              selectedVideos: [], // Clear selected videos
              isSubmitting: false,
            ),
          );
          if (event.context != null) {
            showMySnackbar(
              context: event.context!,
              content: "Workeradded successfully to backend!",
              isSuccess: true,
            );
          }
        },
      );
    } catch (e) {
      print('Exception in _onSubmitProperty: $e');
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: 'An unexpected error occurred: $e',
        ),
      );
      if (event.context != null) {
        showMySnackbar(
          context: event.context!,
          content: 'An unexpected error occurred: $e',
          isSuccess: false,
        );
      }
    }
  }

  Future<void> _onSubmitUpdateProperty(
    SubmitUpdatePropertyEvent event,
    Emitter<AddPropertyState> emit,
  ) async {
    emit(
      state.copyWith(
        isSubmitting: true,
        errorMessage: null,
        successMessage: null,
      ),
    );

    final validationErrors = <String>[];
    if (event.title.trim().isEmpty) {
      validationErrors.add('Workertitle is required');
    }
    if (event.location.trim().isEmpty) {
      validationErrors.add('Workerlocation is required');
    }
    if (event.price.trim().isEmpty) {
      validationErrors.add('Workerprice is required');
    } else {
      final price = double.tryParse(event.price);
      if (price == null || price <= 0) {
        validationErrors.add(
          'Workerprice must be a valid number greater than 0',
        );
      }
    }
    if (event.description.trim().isEmpty) {
      validationErrors.add('Workerdescription is required');
    }
    if (event.bedrooms.trim().isEmpty) {
      validationErrors.add('Number of bedrooms is required');
    } else {
      final bedrooms = int.tryParse(event.bedrooms);
      if (bedrooms == null || bedrooms < 0) {
        validationErrors.add('Bedrooms must be a valid number (0 or more)');
      }
    }
    if (event.bathrooms.trim().isEmpty) {
      validationErrors.add('Number of bathrooms is required');
    } else {
      final bathrooms = int.tryParse(event.bathrooms);
      if (bathrooms == null || bathrooms < 0) {
        validationErrors.add('Bathrooms must be a valid number (0 or more)');
      }
    }
    if (event.categoryId == null || event.categoryId!.isEmpty) {
      validationErrors.add('Workercategory is required');
    }
    if (event.existingImages.isEmpty && event.newImagePaths.isEmpty) {
      validationErrors.add('At least one Workerimage is required');
    }
    if (validationErrors.isNotEmpty) {
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: validationErrors.join('\n'),
        ),
      );
      if (event.context != null) {
        showMySnackbar(
          context: event.context!,
          content: validationErrors.join('\n'),
          isSuccess: false,
        );
      }
      return;
    }
    try {
      String? userId;
      final userIdEither = await _tokenSharedPrefs.getUserId();
      userIdEither.fold((l) => null, (r) => userId = r);

      final property = PropertyEntity(
        id: event.propertyId,
        title: event.title.trim(),
        location: event.location.trim(),
        price: double.parse(event.price),
        description: event.description.trim(),
        bedrooms: int.parse(event.bedrooms),
        bathrooms: int.parse(event.bathrooms),
        categoryId: event.categoryId!,
        workerId: userId,
        images: event.existingImages,
        videos: event.existingVideos,
      );
      final result = await _updatePropertyUsecase(
        event.propertyId,
        property,
        event.newImagePaths,
        event.newVideoPaths,
        event.existingImages,
        event.existingVideos,
      );
      result.fold(
        (failure) {
          emit(
            state.copyWith(isSubmitting: false, errorMessage: failure.message),
          );
          if (event.context != null) {
            showMySnackbar(
              context: event.context!,
              content: failure.message,
              isSuccess: false,
            );
          }
        },
        (_) {
          emit(
            AddPropertySubmissionSuccess(
              successMessage: "Workerupdated successfully!",
              categories: List.from(_currentCategories),
              selectedCategoryId: _selectedCategoryId,
              selectedImages: List.from(_currentImages),
              selectedVideos: List.from(_currentVideos),
              isSubmitting: false,
            ),
          );
          if (event.context != null) {
            showMySnackbar(
              context: event.context!,
              content: "Workerupdated successfully!",
              isSuccess: true,
            );
          }
        },
      );
    } catch (e) {
      print('Exception in _onSubmitUpdateProperty: $e');
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: 'An unexpected error occurred: $e',
        ),
      );
      if (event.context != null) {
        showMySnackbar(
          context: event.context!,
          content: 'An unexpected error occurred: $e',
          isSuccess: false,
        );
      }
    }
  }

  void _onClearAddPropertyMessage(
    ClearAddPropertyMessageEvent event,
    Emitter<AddPropertyState> emit,
  ) {
    emit(state.copyWith(errorMessage: null, successMessage: null));
  }
}
