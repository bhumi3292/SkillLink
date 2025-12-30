import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skill_link/app/service_locator/service_locator.dart';
import 'package:skill_link/features/explore/domain/entity/explore_worker_entity.dart';
import 'package:skill_link/features/profile/presentation/view_model/worker_profile_bloc.dart';
import 'package:skill_link/features/profile/presentation/view_model/worker_profile_event.dart';
import 'package:skill_link/features/profile/presentation/view_model/worker_profile_state.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:skill_link/features/add_worker/presentation/widgets/location_picker_widget.dart';

class EditWorkerProfilePage extends StatelessWidget {
  final String workerProfileId;

  const EditWorkerProfilePage({super.key, required this.workerProfileId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => serviceLocator<WorkerProfileBloc>()
        ..add(FetchWorkerProfileEvent(workerProfileId)),
      child: _EditWorkerProfileView(workerProfileId: workerProfileId),
    );
  }
}

class _EditWorkerProfileView extends StatefulWidget {
  final String workerProfileId;
  const _EditWorkerProfileView({required this.workerProfileId});

  @override
  State<_EditWorkerProfileView> createState() => _EditWorkerProfileViewState();
}

class _EditWorkerProfileViewState extends State<_EditWorkerProfileView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descriptionController;
  // Price controllers removed (Auto-pricing)

  late TextEditingController _experienceController;
  
  // Images
  List<File> _newImages = [];
  
  // Location
  ll.LatLng? _selectedCoordinates;
  String? _selectedAddress;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController();
    // Price controllers removed

    _experienceController = TextEditingController();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    // Price controllers removed

    _experienceController.dispose();
    super.dispose();
  }

  void _populateControllers(ExploreWorkerEntity worker) {
    if (_descriptionController.text.isEmpty) _descriptionController.text = worker.description ?? '';
    // Price controllers populated skipped

    if (_experienceController.text.isEmpty) _experienceController.text = worker.experience?.toString() ?? '';
    if (_selectedCoordinates == null && worker.coordinates != null) {
      _selectedCoordinates = worker.coordinates;
      _selectedAddress = worker.location;
    }
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _newImages.add(File(picked.path));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Service Details")),
      body: BlocConsumer<WorkerProfileBloc, WorkerProfileState>(
        listener: (context, state) {
          if (state.status == WorkerProfileStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(content: Text(state.successMessage ?? "Success"), backgroundColor: Colors.green),
            );
          } else if (state.status == WorkerProfileStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(content: Text(state.errorMessage ?? "Error"), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state.status == WorkerProfileStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final worker = state.worker;
          if (worker == null && state.status != WorkerProfileStatus.loading) {
             return const Center(child: Text("Failed to load profile."));
          }
          
          if(worker != null) {
             _populateControllers(worker);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   // Image Section
                   if ((worker?.images?.isNotEmpty ?? false) || _newImages.isNotEmpty)
                     SizedBox(
                       height: 200,
                       child: ListView(
                         scrollDirection: Axis.horizontal,
                         children: [
                           if (worker?.images != null)
                             ...worker!.images!.map((url) => Padding(
                               padding: const EdgeInsets.all(8.0),
                               child: Stack(
                                  children: [
                                    Image.network(url, width: 150, fit: BoxFit.cover),
                                    // Could add delete button for existing images if backend supports it
                                  ],
                               ),
                             )),
                           ..._newImages.map((file) => Padding(
                             padding: const EdgeInsets.all(8.0),
                             child: Stack(
                               children: [
                                  Image.file(file, width: 150, fit: BoxFit.cover),
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: IconButton(
                                      icon: const Icon(Icons.close, color: Colors.red),
                                      onPressed: () {
                                        setState(() {
                                          _newImages.remove(file);
                                        });
                                      },
                                    ),
                                  )
                               ],
                             ),
                           )),
                         ],
                       ),
                     ),
                   TextButton.icon(
                     onPressed: _pickImage,
                     icon: const Icon(Icons.add_a_photo),
                     label: const Text("Add Image"),
                   ),
                   const SizedBox(height: 16),
                   
                   TextFormField(
                     controller: _descriptionController,
                     decoration: const InputDecoration(labelText: "Description", border: OutlineInputBorder()),
                     maxLines: 3,
                     validator: (v) => v!.isEmpty ? "Required" : null,
                   ),
                   const SizedBox(height: 16),
                   
                   // Price inputs removed

                   const SizedBox(height: 16),
                   
                   TextFormField(
                     controller: _experienceController,
                     decoration: const InputDecoration(labelText: "Experience (Years)", border: OutlineInputBorder()),
                     keyboardType: TextInputType.number,
                     validator: (v) => v!.isEmpty ? "Required" : null,
                   ),
                   
                   const SizedBox(height: 24),
                   const Text("Service Location", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                   const SizedBox(height: 8),
                   if (_selectedAddress != null)
                      Text("Current: $_selectedAddress", style: const TextStyle(color: Colors.grey)),
                   const SizedBox(height: 8),
                   
                   // Location Picker
                   SizedBox(
                     height: 300,
                     child: LocationPickerWidget(
                       onLocationPicked: (latlng, address) {
                         setState(() {
                           _selectedCoordinates = latlng;
                           _selectedAddress = address;
                         });
                       },
                     ),
                   ),

                   const SizedBox(height: 24),
                   
                   SizedBox(
                     width: double.infinity,
                     child: ElevatedButton(
                       onPressed: () {
                         if (_formKey.currentState!.validate()) {
                            // Prepare data
                           final data = {
                             "description": _descriptionController.text,
                             // Prices are auto-managed

                             "experience": _experienceController.text,
                           };
                           
                           if (_selectedCoordinates != null) {
                             // Send as [long, lat] string as expected by backend parser
                             data["coordinates"] = "[${_selectedCoordinates!.longitude}, ${_selectedCoordinates!.latitude}]";
                           }
                           
                           context.read<WorkerProfileBloc>().add(
                             UpdateWorkerEvent(workerId: widget.workerProfileId, data: data, newImages: _newImages),
                           );
                         }
                       },
                       style: ElevatedButton.styleFrom(
                         padding: const EdgeInsets.symmetric(vertical: 16),
                       ),
                       child: const Text("Save Changes"),
                     ),
                   ),
                   
                   const SizedBox(height: 20),
                   const Divider(),
                   Center(
                     child: TextButton(
                       onPressed: () {
                          // Deactivate Logic
                          showDialog(context: context, builder: (context) => AlertDialog(
                            title: const Text("Deactivate Service?"),
                            content: const Text("Your service will be hidden from Explore page. You can reactivate it anytime."),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                              TextButton(onPressed: () {
                                 Navigator.pop(context);
                                 context.read<WorkerProfileBloc>().add(
                                   DeactivateWorkerEvent(widget.workerProfileId)
                                 );
                              }, child: const Text("Deactivate", style: TextStyle(color: Colors.red))),
                            ],
                          ));
                       },
                       child: const Text("Deactivate Service", style: TextStyle(color: Colors.red)),
                     ),
                   )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
