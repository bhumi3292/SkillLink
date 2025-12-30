import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skill_link/features/banner/data/models/banner_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skill_link/features/admin/presentation/view_model/admin_cubit.dart';
import 'package:skill_link/features/admin/presentation/view_model/admin_state.dart';
import 'package:skill_link/app/constant/api_endpoints.dart';
import 'package:intl/intl.dart';

class AdminBannerFormPage extends StatefulWidget {
  final BannerModel? banner;

  const AdminBannerFormPage({super.key, this.banner});

  @override
  State<AdminBannerFormPage> createState() => _AdminBannerFormPageState();
}

class _AdminBannerFormPageState extends State<AdminBannerFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _ctaCtrl = TextEditingController();
  File? _pickedImage;

  DateTime? _startDate;
  DateTime? _endDate;
  bool _isActive = true;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AdminCubit, AdminState>(
      listener: (context, state) {
        if (state is AdminLoading) {
          setState(() => _isSubmitting = true);
        } else if (state is AdminBannerActionSuccess || state is AdminActionSuccess) {
          setState(() => _isSubmitting = false);
          Navigator.of(context).pop(true);
        } else if (state is AdminError) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Create / Edit Banner')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 12),
              // Image picker
              GestureDetector(
                onTap: _pickImage,
                child: _buildImagePreview(),
              ),
              TextFormField(
                controller: _ctaCtrl,
                decoration: const InputDecoration(labelText: 'CTA Text'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _pickStartDate,
                      child: Text(_startDate == null
                          ? 'Pick Start Date'
                          : DateFormat.yMMMd().format(_startDate!)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _pickEndDate,
                      child: Text(_endDate == null
                          ? 'Pick End Date'
                          : DateFormat.yMMMd().format(_endDate!)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                value: _isActive,
                onChanged: (v) => setState(() => _isActive = v),
                title: const Text('Active'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? SizedBox(
                        height: 18,
                        width: 18,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    ));
  }

  Future<void> _pickStartDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (d != null) setState(() => _startDate = d);
  }

  Future<void> _pickEndDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (d != null) setState(() => _endDate = d);
  }

  @override
  void initState() {
    super.initState();
    if (widget.banner != null) {
      final b = widget.banner!;
      _titleCtrl.text = b.title;
      _descCtrl.text = b.description ?? '';
      _ctaCtrl.text = b.ctaText ?? '';
      _isActive =
          b.endDate.isAfter(DateTime.now()) &&
          b.startDate.isBefore(DateTime.now()) &&
          b.targetType.isNotEmpty;
      _startDate = b.startDate;
      _endDate = b.endDate;
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final x = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (x != null) setState(() => _pickedImage = File(x.path));
  }

  Widget _buildImagePreview() {
    if (_pickedImage != null) {
      return Image.file(
        _pickedImage!,
        height: 140,
        fit: BoxFit.cover,
      );
    }
    if (widget.banner != null && widget.banner!.imageUrl.isNotEmpty) {
      final url = widget.banner!.imageUrl.startsWith('http')
          ? widget.banner!.imageUrl
          : '${ApiEndpoints.imageUrl}${widget.banner!.imageUrl}';
      return Image.network(
        url,
        height: 140,
        fit: BoxFit.cover,
      );
    }
    return Container(
      height: 140,
      color: Colors.grey[200],
      child: const Center(child: Text('Tap to select image')),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select start and end dates')),
      );
      return;
    }
    if (_startDate!.isAfter(_endDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Start date must be before end date')),
      );
      return;
    }
    final body = {
      'title': _titleCtrl.text,
      'description': _descCtrl.text,
      'ctaText': _ctaCtrl.text,
      'targetType': 'externalLink',
      'targetValue': '',
      'startDate': _startDate!.toIso8601String(),
      'endDate': _endDate!.toIso8601String(),
      'isActive': _isActive.toString(),
    };

    if (widget.banner == null) {
      context
          .read<AdminCubit>()
          .createBanner(body, image: _pickedImage)
          .then((_) {
            Navigator.of(context).pop(true);
          })
          .catchError((e) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error: $e')));
          });
    } else {
      context
          .read<AdminCubit>()
          .updateBanner(widget.banner!.id, body, image: _pickedImage)
          .then((_) {
            Navigator.of(context).pop(true);
          })
          .catchError((e) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error: $e')));
          });
    }
  }
}
