import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get_it/get_it.dart';
import 'package:get/get.dart';
import 'package:skill_link/features/add_property/presentation/property/view_model/add_property_view_model.dart';
import 'package:skill_link/features/add_property/presentation/property/view_model/add_property_event.dart';
import 'package:skill_link/features/add_property/presentation/property/view_model/add_property_state.dart';
import 'package:skill_link/features/add_property/domain/entity/category/category_entity.dart';
import 'package:skill_link/features/add_property/domain/use_case/category/add_category_usecase.dart';

class AddPropertyPresentation extends StatefulWidget {
  const AddPropertyPresentation({super.key});

  @override
  State<AddPropertyPresentation> createState() => _AddPropertyPresentationState();
}

class _AddPropertyPresentationState extends State<AddPropertyPresentation> {
  final _formKey = GlobalKey<FormState>();
  late final AddPropertyBloc _bloc;
  final ImagePicker _picker = ImagePicker();
  final AddCategoryUsecase _addCategoryUsecase = GetIt.instance<AddCategoryUsecase>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _bedroomsController = TextEditingController();
  final TextEditingController _bathroomsController = TextEditingController();
  final TextEditingController _newCategoryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bloc = GetIt.instance<AddPropertyBloc>();
    _bloc.add(const InitializeAddPropertyForm());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    _newCategoryController.dispose();
    _bloc.close();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final pickedFiles = await _picker.pickMultiImage(
        imageQuality: 70,
        maxWidth: 1920,
        maxHeight: 1080,
      );
      if (pickedFiles.isNotEmpty) {
        for (var file in pickedFiles) {
          _bloc.add(AddImageEvent(image: file));
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${pickedFiles.length} image(s) selected'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking images: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickVideos() async {
    try {
      final pickedFile = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 5), // Limit to 5 minutes
      );
      if (pickedFile != null) {
        _bloc.add(AddVideoEvent(video: pickedFile));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Video selected'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking video: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildCategoryDropdown(List<CategoryEntity> categories, String? selectedCategoryId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Category *',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF003366),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF003366),
                borderRadius: BorderRadius.circular(20),
              ),
              child: IconButton(
                onPressed: _showAddCategoryDialog,
                icon: const Icon(Icons.add, color: Colors.white, size: 20),
                tooltip: 'Add New Category',
                style: IconButton.styleFrom(
                  padding: const EdgeInsets.all(8),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonFormField<String>(
            value: selectedCategoryId,
            decoration: const InputDecoration(
              labelText: 'Select Category',
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF003366), width: 2),
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
            ),
            items: [
              const DropdownMenuItem(
                value: null, 
                child: Text(
                  'Select Category',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ...categories.map((cat) => DropdownMenuItem(
                value: cat.id, 
                child: Text(
                  cat.categoryName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              )),
            ],
            onChanged: (val) => _bloc.add(SelectCategoryEvent(categoryId: val)),
            validator: (val) => val == null ? 'Category is required' : null,
            icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF003366)),
            dropdownColor: Colors.white,
            style: const TextStyle(fontSize: 16, color: Colors.black),
          ),
        ),
        if (categories.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.orange[600]),
                const SizedBox(width: 8),
                Text(
                  'No categories available. Click + to add one.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange[600],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Future<void> _showAddCategoryDialog() async {
    _newCategoryController.clear();
    
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: [
              const Icon(Icons.add_circle, color: Color(0xFF003366)),
              const SizedBox(width: 8),
              const Text('Add New Category'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _newCategoryController,
                decoration: const InputDecoration(
                  labelText: 'Category Name *',
                  hintText: 'e.g., Apartment, House, Villa',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF003366), width: 2),
                  ),
                ),
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                onSubmitted: (value) async {
                  if (value.trim().isNotEmpty) {
                    await _addNewCategory(value.trim());
                    Navigator.of(context).pop();
                  }
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'This category will be available for all properties.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_newCategoryController.text.trim().isNotEmpty) {
                  await _addNewCategory(_newCategoryController.text.trim());
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a category name'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF003366),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Add Category'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addNewCategory(String categoryName) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('Adding category...'),
              ],
            ),
          );
        },
      );

      final newCategory = CategoryEntity(categoryName: categoryName);
      final result = await _addCategoryUsecase(newCategory);
      
      // Hide loading indicator
      Navigator.of(context).pop();
      
      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to add category: ${failure.message}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        },
        (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Category "$categoryName" added successfully!'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
          // Refresh categories in the form
          _bloc.add(const InitializeAddPropertyForm());
        },
      );
    } catch (e) {
      // Hide loading indicator
      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding category: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Property'),
        backgroundColor: const Color(0xFF003366),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: BlocProvider.value(
        value: _bloc,
        child: BlocConsumer<AddPropertyBloc, AddPropertyState>(
          listener: (context, state) {
            if (state.successMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.successMessage!),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 3),
                ),
              );
              _formKey.currentState?.reset();
              _titleController.clear();
              _locationController.clear();
              _priceController.clear();
              _descriptionController.clear();
              _bedroomsController.clear();
              _bathroomsController.clear();
              _bloc.add(const ClearAddPropertyMessageEvent());
              
              // Navigate back after successful submission
              Future.delayed(const Duration(seconds: 2), () {
                Get.back();
              });
            } else if (state.errorMessage != null) {
              print('Error in add property: ${state.errorMessage}');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 8),
                  action: SnackBarAction(
                    label: 'Dismiss',
                    textColor: Colors.white,
                    onPressed: () {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    },
                  ),
                ),
              );
              _bloc.add(const ClearAddPropertyMessageEvent());
            }
          },
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading categories...'),
                  ],
                ),
              );
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTextField(
                      _titleController, 
                      'Property Title *',
                      hintText: 'Enter property title',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Property title is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      _locationController, 
                      'Location *',
                      hintText: 'Enter property location',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Location is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      _priceController, 
                      'Price *',
                      keyboardType: TextInputType.number,
                      hintText: 'Enter price (e.g., 1500)',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Price is required';
                        }
                        final price = double.tryParse(value);
                        if (price == null || price <= 0) {
                          return 'Price must be a valid number greater than 0';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            _bedroomsController, 
                            'Bedrooms *',
                            keyboardType: TextInputType.number,
                            hintText: '0',
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Bedrooms is required';
                              }
                              final bedrooms = int.tryParse(value);
                              if (bedrooms == null || bedrooms < 0) {
                                return 'Bedrooms must be 0 or more';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            _bathroomsController, 
                            'Bathrooms *',
                            keyboardType: TextInputType.number,
                            hintText: '0',
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Bathrooms is required';
                              }
                              final bathrooms = int.tryParse(value);
                              if (bathrooms == null || bathrooms < 0) {
                                return 'Bathrooms must be 0 or more';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      _descriptionController, 
                      'Description *',
                      maxLines: 3,
                      hintText: 'Describe the property...',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Description is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildCategoryDropdown(state.categories, state.selectedCategoryId),
                    const SizedBox(height: 16),
                    _buildMediaSection(
                      'Images *', 
                      state.selectedImages, 
                      _pickImages, 
                      (i) => _bloc.add(RemoveImageEvent(index: i)),
                      isRequired: true,
                    ),
                    const SizedBox(height: 16),
                    _buildMediaSection(
                      'Videos (Optional)', 
                      state.selectedVideos, 
                      _pickVideos, 
                      (i) => _bloc.add(RemoveVideoEvent(index: i)),
                      isRequired: false,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: state.isSubmitting
                          ? null
                          : () {
                              if (_formKey.currentState?.validate() ?? false) {
                                _bloc.add(
                                  SubmitPropertyEvent(
                                    title: _titleController.text,
                                    location: _locationController.text,
                                    price: _priceController.text,
                                    description: _descriptionController.text,
                                    bedrooms: _bedroomsController.text,
                                    bathrooms: _bathroomsController.text,
                                    categoryId: state.selectedCategoryId,
                                    context: context,
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF003366),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: state.isSubmitting
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text('Adding Property...'),
                              ],
                            )
                          : const Text('Add Property', style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller, 
    String label, 
    {
      TextInputType keyboardType = TextInputType.text, 
      int maxLines = 1,
      String? hintText,
      String? Function(String?)? validator,
    }
  ) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        border: const OutlineInputBorder(),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF003366), width: 2),
        ),
        errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
      ),
      validator: validator ?? (value) => (value == null || value.isEmpty) ? 'Required' : null,
    );
  }

  Widget _buildMediaSection(
    String label, 
    List<XFile> files, 
    VoidCallback onAdd, 
    Function(int) onRemove,
    {bool isRequired = false}
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                if (isRequired)
                  const Text(
                    '*',
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: onAdd, 
                  icon: const Icon(Icons.add_a_photo),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFF003366),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
        if (files.isNotEmpty)
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: files.length,
              itemBuilder: (context, i) => Stack(
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(files[i].path),
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.error, color: Colors.red),
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => onRemove(i),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(4),
                        child: const Icon(Icons.close, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (files.isEmpty && isRequired)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'At least one $label.toLowerCase() is required',
              style: TextStyle(
                fontSize: 12,
                color: Colors.red[600],
              ),
            ),
          ),
      ],
    );
  }
} 