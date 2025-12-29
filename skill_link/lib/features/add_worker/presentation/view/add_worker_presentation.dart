import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:skill_link/app/service_locator/service_locator.dart';
import 'package:skill_link/features/add_worker/domain/entity/category/category_entity.dart';
import 'package:skill_link/features/add_worker/domain/entity/worker/worker_entity.dart';
import 'package:skill_link/features/add_worker/domain/use_case/category/add_category_usecase.dart';
import 'package:skill_link/features/add_worker/domain/use_case/category/get_all_categories_usecase.dart';
import 'package:skill_link/features/add_worker/domain/use_case/worker/add_worker_usecase.dart';
import 'package:skill_link/features/add_worker/presentation/widgets/location_picker_widget.dart';

class AddWorkerPresentation extends StatefulWidget {
  const AddWorkerPresentation({super.key});

  @override
  State<AddWorkerPresentation> createState() => _AddWorkerPresentationState();
}

class _AddWorkerPresentationState extends State<AddWorkerPresentation> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _skillController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _portfolioController = TextEditingController();
  List<CategoryEntity> _categories = [];
  String? _selectedCategoryId;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _newCategoryController = TextEditingController();
  bool _isLoadingCategories = true;
  String _rateUnit = 'per visit';
  LatLng? _pickedLatLng;
  String? _pickedAddress;
  final List<String> _selectedImagePaths = [];
  final List<String> _selectedVideoPaths = [];
  String? _licensePath;
  String? _identityCardPath;

  @override
  void dispose() {
    _nameController.dispose();
    _skillController.dispose();
    _experienceController.dispose();
    _rateController.dispose();
    _locationController.dispose();
    _portfolioController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoadingCategories = true);
    try {
      final usecase = serviceLocator<GetAllCategoriesUsecase>();
      final res = await usecase.call();
      res.fold(
        (f) {
          setState(() {
            _categories = [];
            _isLoadingCategories = false;
          });
        },
        (cats) {
          setState(() {
            _categories = cats;
            if (_categories.isNotEmpty && _selectedCategoryId == null) {
              _selectedCategoryId = _categories.first.id;
            }
            _isLoadingCategories = false;
          });
        },
      );
    } catch (_) {
      setState(() => _isLoadingCategories = false);
    }
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
            children: const [
              Icon(Icons.add_circle, color: Color(0xFF003366)),
              SizedBox(width: 8),
              Text('Add New Category'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _newCategoryController,
                decoration: const InputDecoration(
                  labelText: 'Category Name *',
                  hintText: 'e.g., Electrician, Plumber',
                  border: OutlineInputBorder(),
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
              const SizedBox(height: 12),
              const Text(
                'This category will be available for all workers.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
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
                final name = _newCategoryController.text.trim();
                if (name.isNotEmpty) {
                  await _addNewCategory(name);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a category name'),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF003366),
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
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );
      final addCategoryUsecase = serviceLocator<AddCategoryUsecase>();
      final result = await addCategoryUsecase.call(
        CategoryEntity(categoryName: categoryName),
      );
      Navigator.of(context).pop();
      result.fold(
        (failure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed: ${failure.message}')));
        },
        (_) async {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Category "$categoryName" added')),
          );
          await _loadCategories();
          try {
            final match = _categories.firstWhere(
              (c) => c.categoryName.toLowerCase() == categoryName.toLowerCase(),
              orElse:
                  () =>
                      _categories.isNotEmpty
                          ? _categories.first
                          : CategoryEntity(categoryName: ''),
            );
            if (match.id != null && match.id!.isNotEmpty) {
              setState(() {
                _selectedCategoryId = match.id;
              });
            }
          } catch (_) {}
        },
      );
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error adding category: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF003366),
        title: const Text('Add Worker'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Service Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Basic Information',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 12),

              _buildOutlinedField(_skillController, 'Primary Skill'),
              const SizedBox(height: 12),

              _buildOutlinedField(_experienceController, 'Experience'),
              const SizedBox(height: 12),

              _buildOutlinedField(
                _portfolioController,
                'Portfolio Link (Optional)',
              ),
              const SizedBox(height: 12),

              _buildOutlinedField(
                _descriptionController,
                'Description',
                maxLines: 4,
              ),
              const SizedBox(height: 12),

              _isLoadingCategories
                  ? const SizedBox(
                    height: 56,
                    child: Center(child: CircularProgressIndicator()),
                  )
                  : _categories.isEmpty
                  ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'No categories found',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: _showAddCategoryDialog,
                            icon: const Icon(Icons.add),
                            label: const Text('Add Category'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF003366),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Create a category to continue',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  )
                  : DropdownButtonFormField<String>(
                    initialValue: _selectedCategoryId,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                    ),
                    items:
                        _categories
                            .map(
                              (c) => DropdownMenuItem(
                                value: c.id,
                                child: Text(c.categoryName),
                              ),
                            )
                            .toList(),
                    onChanged: (v) => setState(() => _selectedCategoryId = v),
                    validator:
                        (v) => (v == null || v.isEmpty) ? 'Required' : null,
                  ),
              const SizedBox(height: 12),

              // Location picker
              GestureDetector(
                onTap: _openLocationPicker,
                child: AbsorbPointer(
                  child: _buildOutlinedField(_locationController, 'Location'),
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildOutlinedField(
                      _rateController,
                      'Rate/visit',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _rateUnit,
                          items: const [
                            DropdownMenuItem(
                              value: 'per visit',
                              child: Text('per visit'),
                            ),
                            DropdownMenuItem(
                              value: 'per hour',
                              child: Text('/hr'),
                            ),
                          ],
                          onChanged:
                              (v) =>
                                  setState(() => _rateUnit = v ?? 'per visit'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _pickImages,
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Pick Images'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _pickVideo,
                      icon: const Icon(Icons.video_library),
                      label: const Text('Pick Video'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Text('Images selected: ${_selectedImagePaths.length}'),
              Text('Videos selected: ${_selectedVideoPaths.length}'),
              const SizedBox(height: 12),

              const Text(
                'Verification Documents *',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _pickDoc(true),
                      icon: Icon(
                        Icons.description,
                        color:
                            _licensePath != null ? Colors.green : Colors.white,
                      ),
                      label: Text(
                        _licensePath != null ? 'License OK' : 'License',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF003366),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _pickDoc(false),
                      icon: Icon(
                        Icons.badge,
                        color:
                            _identityCardPath != null
                                ? Colors.green
                                : Colors.white,
                      ),
                      label: Text(
                        _identityCardPath != null ? 'ID OK' : 'ID Card',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF003366),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _onSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF003366),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Submit for Verification',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOutlinedField(
    TextEditingController controller,
    String label, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
      ),
      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
    );
  }

  void _onSubmit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    _submitToBackend();
  }

  Future<void> _submitToBackend() async {
    final skill = _skillController.text.trim();
    final name = skill.isNotEmpty ? skill : 'Worker';
    final experience = _experienceController.text.trim();
    final rate = double.tryParse(_rateController.text.trim()) ?? 0.0;
    final description = _descriptionController.text.trim();
    final portfolioUrl = _portfolioController.text.trim();

    final coordinates =
        _pickedLatLng != null
            ? jsonEncode([_pickedLatLng!.longitude, _pickedLatLng!.latitude])
            : null;

    final entity = WorkerEntity(
      name: name,
      primarySkill: skill,
      experience: experience,
      description: description,
      location: _pickedAddress ?? _locationController.text.trim(),
      rate: rate,
      portfolioUrl: portfolioUrl,
      categoryId: _selectedCategoryId,
      coordinates: coordinates,
    );

    final usecase = serviceLocator<AddWorkerUsecase>();
    final params = AddWorkerParams(
      worker: entity,
      imagePaths: _selectedImagePaths,
      videoPaths: _selectedVideoPaths,
      licensePath: _licensePath,
      identityCardPath: _identityCardPath,
    );

    if (_licensePath == null || _identityCardPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please upload all mandatory documents (License & ID Card)',
          ),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final result = await usecase.call(params);
      Navigator.of(context).pop(); // close progress
      result.fold(
        (failure) {
          final msg = failure.toString();
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed: $msg')));
        },
        (_) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Worker added')));
          Navigator.of(context).pop({'added': true});
        },
      );
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _openLocationPicker() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (_) => Scaffold(
              appBar: AppBar(
                title: const Text('Pick Location'),
                backgroundColor: const Color(0xFF003366),
              ),
              body: SafeArea(
                child: LocationPickerWidget(
                  onLocationPicked: (latLng, address) {
                    setState(() {
                      _pickedLatLng = latLng;
                      _pickedAddress = address;
                      _locationController.text = address;
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
      ),
    );
  }

  Future<void> _pickImages() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> files = await picker.pickMultiImage();
      if (files.isEmpty) return;
      setState(() {
        _selectedImagePaths.clear();
        _selectedImagePaths.addAll(files.map((f) => f.path));
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Image pick error: $e')));
    }
  }

  Future<void> _pickVideo() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? file = await picker.pickVideo(source: ImageSource.gallery);
      if (file == null) return;
      setState(() {
        _selectedVideoPaths.clear();
        _selectedVideoPaths.add(file.path);
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Video pick error: $e')));
    }
  }

  Future<void> _pickDoc(bool isLicense) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? file = await picker.pickImage(source: ImageSource.gallery);
      if (file == null) return;
      setState(() {
        if (isLicense) {
          _licensePath = file.path;
        } else {
          _identityCardPath = file.path;
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Document pick error: $e')));
    }
  }
}
