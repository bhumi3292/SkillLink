import 'dart:io';
import 'package:skill_link/app/constant/api_endpoints.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skill_link/app/service_locator/service_locator.dart';
import 'package:skill_link/features/add_property/domain/entity/category/category_entity.dart';
import 'package:skill_link/features/add_property/domain/use_case/category/get_all_categories_usecase.dart';
import 'package:skill_link/features/add_property/domain/use_case/category/add_category_usecase.dart';
import 'package:skill_link/cores/utils/image_url_helper.dart';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:skill_link/app/shared_pref/token_shared_prefs.dart';

class UpdatePropertyPage extends StatefulWidget {
  final String propertyId;
  final String initialTitle;
  final String initialLocation;
  final double initialPrice;
  final String initialDescription;
  final int initialBedrooms;
  final int initialBathrooms;
  final List<String> initialImages;
  final List<String> initialVideos;
  final String initialCategoryId;
  // Add more fields as needed

  const UpdatePropertyPage({
    super.key,
    required this.propertyId,
    required this.initialTitle,
    required this.initialLocation,
    required this.initialPrice,
    required this.initialDescription,
    required this.initialBedrooms,
    required this.initialBathrooms,
    this.initialImages = const [],
    this.initialVideos = const [],
    required this.initialCategoryId,
  });

  @override
  State<UpdatePropertyPage> createState() => _UpdatePropertyPageState();
}

class _UpdatePropertyPageState extends State<UpdatePropertyPage> {
  late TextEditingController _titleController;
  late TextEditingController _locationController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  late TextEditingController _bedroomsController;
  late TextEditingController _bathroomsController;
  String? _selectedCategoryId;
  List<CategoryEntity> _categories = [];
  final List<File> _selectedImages = [];
  final List<File> _selectedVideos = [];
  List<String> _existingImages = [];
  List<String> _existingVideos = [];
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;
  String? _errorMessage;
  final TextEditingController _newCategoryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _locationController = TextEditingController(text: widget.initialLocation);
    _priceController = TextEditingController(text: widget.initialPrice.toString());
    _descriptionController = TextEditingController(text: widget.initialDescription);
    _bedroomsController = TextEditingController(text: widget.initialBedrooms.toString());
    _bathroomsController = TextEditingController(text: widget.initialBathrooms.toString());
    _selectedCategoryId = widget.initialCategoryId;
    _fetchCategories();
    _existingImages = List<String>.from(widget.initialImages);
    _existingVideos = List<String>.from(widget.initialVideos);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    super.dispose();
  }

  Future<void> _fetchCategories() async {
    final usecase = serviceLocator<GetAllCategoriesUsecase>();
    final result = await usecase();
    result.fold(
      (failure) => setState(() => _categories = []),
      (cats) {
        setState(() {
          _categories = cats;
          _selectedCategoryId ??= widget.initialCategoryId;
        });
      },
    );
  }

  Future<void> _showAddCategoryDialog() async {
    _newCategoryController.clear();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New Category'),
        content: TextField(
          controller: _newCategoryController,
          decoration: InputDecoration(labelText: 'Category Name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final name = _newCategoryController.text.trim();
              if (name.isNotEmpty) {
                final addCategoryUsecase = serviceLocator<AddCategoryUsecase>();
                final result = await addCategoryUsecase(CategoryEntity(categoryName: name));
                result.fold(
                  (failure) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add category'))),
                  (_) async {
                    await _fetchCategories();
                    Navigator.pop(context);
                  },
                );
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImages() async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage();
    setState(() {
      _selectedImages.addAll(pickedFiles.map((x) => File(x.path)));
    });
    }

  Future<void> _pickVideos() async {
    final XFile? pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedVideos.add(File(pickedFile.path));
      });
    }
  }

  void _removeExistingImage(int index) {
    setState(() {
      _existingImages.removeAt(index);
    });
  }
  void _removeSelectedImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }
  void _removeExistingVideo(int index) {
    setState(() {
      _existingVideos.removeAt(index);
    });
  }
  void _removeSelectedVideo(int index) {
    setState(() {
      _selectedVideos.removeAt(index);
    });
  }

  bool _validate() {
    _errorMessage = null;
    if (_titleController.text.trim().isEmpty) {
      _errorMessage = 'Title is required';
    } else if (_locationController.text.trim().isEmpty) {
      _errorMessage = 'Location is required';
    } else if (_priceController.text.trim().isEmpty || double.tryParse(_priceController.text) == null || double.parse(_priceController.text) <= 0) {
      _errorMessage = 'Valid price is required';
    } else if (_descriptionController.text.trim().isEmpty) {
      _errorMessage = 'Description is required';
    } else if (_bedroomsController.text.trim().isEmpty || int.tryParse(_bedroomsController.text) == null || int.parse(_bedroomsController.text) < 0) {
      _errorMessage = 'Valid number of bedrooms is required';
    } else if (_bathroomsController.text.trim().isEmpty || int.tryParse(_bathroomsController.text) == null || int.parse(_bathroomsController.text) < 0) {
      _errorMessage = 'Valid number of bathrooms is required';
    } else if (_selectedCategoryId == null || _selectedCategoryId!.isEmpty) {
      _errorMessage = 'Category is required';
    } else if (_existingImages.isEmpty && _selectedImages.isEmpty) {
      _errorMessage = 'At least one image is required';
    }
    setState(() {});
    return _errorMessage == null;
  }

  Future<void> _submitUpdate() async {
    if (!_validate()) return;
    setState(() { _isSubmitting = true; });
    try {
      final dio = Dio(); // Or use your injected Dio instance
      final formData = FormData();
      // Add all text fields
      formData.fields
        ..add(MapEntry('title', _titleController.text.trim()))
        ..add(MapEntry('location', _locationController.text.trim()))
        ..add(MapEntry('price', _priceController.text.trim()))
        ..add(MapEntry('description', _descriptionController.text.trim()))
        ..add(MapEntry('bedrooms', _bedroomsController.text.trim()))
        ..add(MapEntry('bathrooms', _bathroomsController.text.trim()))
        ..add(MapEntry('categoryId', _selectedCategoryId ?? ''));
      // Add new images
      for (final file in _selectedImages) {
        formData.files.add(MapEntry(
          'images',
          await MultipartFile.fromFile(file.path, filename: file.path.split('/').last),
        ));
      }
      // Add new videos
      for (final file in _selectedVideos) {
        formData.files.add(MapEntry(
          'videos',
          await MultipartFile.fromFile(file.path, filename: file.path.split('/').last),
        ));
      }
      // Add existing images/videos to keep (as JSON string)
      formData.fields.add(MapEntry('existingImages', jsonEncode(_existingImages)));
      formData.fields.add(MapEntry('existingVideos', jsonEncode(_existingVideos)));
      final token = await _getToken();
      // Call your update API (using Dio)
      final response = await dio.put(
        ApiEndpoints.updateProperty(widget.propertyId),
        data: formData,
        options: Options(headers: {
          'contentType': 'multipart/form-data',
          'Authorization': 'Bearer $token'
        }),
      );
      setState(() { _isSubmitting = false; });
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Property updated successfully!'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update property: ${response.statusMessage}'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      setState(() { _isSubmitting = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update property: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<String?> _getToken() async {
    final tokenResult = await serviceLocator<TokenSharedPrefs>().getToken();
    return tokenResult.fold((failure) => null, (token) => token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Property'),
        backgroundColor: const Color(0xFF003366),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(_errorMessage!, style: TextStyle(color: Colors.red)),
              ),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: 'Location'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _bedroomsController,
              decoration: const InputDecoration(labelText: 'Bedrooms'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _bathroomsController,
              decoration: const InputDecoration(labelText: 'Bathrooms'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Category', style: TextStyle(fontWeight: FontWeight.bold)),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _showAddCategoryDialog,
                ),
              ],
            ),
            DropdownButtonFormField<String>(
              value: _selectedCategoryId,
              items: _categories.map((cat) => DropdownMenuItem(
                value: cat.id,
                child: Text(cat.categoryName),
              )).toList(),
              onChanged: (val) => setState(() => _selectedCategoryId = val),
              decoration: InputDecoration(labelText: 'Select Category'),
            ),
            const SizedBox(height: 24),
            Text('Existing Images', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (_existingImages.isNotEmpty)
              SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _existingImages.length,
                  itemBuilder: (context, i) => Stack(
                    children: [
                      Image.network(ImageUrlHelper.constructImageUrl(_existingImages[i]), width: 60, height: 60, fit: BoxFit.cover),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: GestureDetector(
                          onTap: () => _removeExistingImage(i),
                          child: Icon(Icons.close, color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Text('Add New Images', style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _pickImages,
                  icon: Icon(Icons.image),
                  label: Text('Pick Images'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
                ),
                const SizedBox(width: 12),
                if (_selectedImages.isNotEmpty)
                  Expanded(
                    child: SizedBox(
                      height: 60,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: _selectedImages.asMap().entries.map((entry) => Stack(
                          children: [
                            Image.file(entry.value, width: 60, height: 60, fit: BoxFit.cover),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: GestureDetector(
                                onTap: () => _removeSelectedImage(entry.key),
                                child: Icon(Icons.close, color: Colors.red),
                              ),
                            ),
                          ],
                        )).toList(),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Existing Videos', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (_existingVideos.isNotEmpty)
              SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _existingVideos.length,
                  itemBuilder: (context, i) => Stack(
                    children: [
                      Icon(Icons.videocam, size: 48, color: Colors.deepPurple),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: GestureDetector(
                          onTap: () => _removeExistingVideo(i),
                          child: Icon(Icons.close, color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Text('Add New Videos', style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _pickVideos,
                  icon: Icon(Icons.videocam),
                  label: Text('Pick Video'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
                ),
                const SizedBox(width: 12),
                if (_selectedVideos.isNotEmpty)
                  Expanded(
                    child: SizedBox(
                      height: 60,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: _selectedVideos.asMap().entries.map((entry) => Stack(
                          children: [
                            Icon(Icons.videocam, size: 48, color: Colors.deepPurple),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: GestureDetector(
                                onTap: () => _removeSelectedVideo(entry.key),
                                child: Icon(Icons.close, color: Colors.red),
                              ),
                            ),
                          ],
                        )).toList(),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitUpdate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF003366),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Update Property', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 