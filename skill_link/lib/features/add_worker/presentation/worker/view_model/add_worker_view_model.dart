// lib/features/add_worker/presentation/bloc/add_worker_bloc.dart

// Corrected imports - these are actual imports, not 'part' files
// For XFile
// For BuildContext and TextEditingController
// Assuming you have this


import 'package:flutter/material.dart';

class AddWorkerScreen extends StatefulWidget {
  const AddWorkerScreen({super.key});

  @override
  State<AddWorkerScreen> createState() => _AddWorkerScreenState();
}

class _AddWorkerScreenState extends State<AddWorkerScreen> {
  final TextEditingController skillController = TextEditingController();
  final TextEditingController experienceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  String? selectedRate;
  final List<String> rateOptions = [
    "Per Visit",
    "Per Hour",
    "Per Day",
    "Per Month",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: const Color(0xFF003B73),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "ADD",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Service Details",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              "Basic Information",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 10),

            // Primary Skill
            _buildInputField(
              controller: skillController,
              hint: "Primary Skill",
            ),

            const SizedBox(height: 12),

            // Experience
            _buildInputField(
              controller: experienceController,
              hint: "Experience",
            ),

            const SizedBox(height: 12),

            // Description Large Box
            _buildInputField(
              controller: descriptionController,
              hint: "Description",
              maxLines: 4,
            ),

            const SizedBox(height: 12),

            // Location
            _buildInputField(controller: locationController, hint: "Location"),

            const SizedBox(height: 12),

            // Dropdown Rate
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black38),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  hint: const Text("Rate/visit"),
                  value: selectedRate,
                  items:
                      rateOptions.map((value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedRate = value;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 30),

            // OK Button
            Center(
              child: SizedBox(
                width: 180,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF003B73),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  onPressed: () {
                    _submitForm();
                  },
                  child: const Text(
                    "OK",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Reusable Input Field
  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // Submit Logic
  void _submitForm() {
    if (skillController.text.isEmpty ||
        experienceController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        locationController.text.isEmpty ||
        selectedRate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Worker Added Successfully")));
  }
}
