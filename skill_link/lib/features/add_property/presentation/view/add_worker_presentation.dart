import 'package:flutter/material.dart';
import 'add_property_presentation.dart';

/// Lightweight wrapper to provide a stable `AddWorkerPresentation` entrypoint
/// while most of the implementation remains in `AddPropertyPresentation`.
class AddWorkerPresentation extends StatelessWidget {
  const AddWorkerPresentation({super.key});

  @override
  Widget build(BuildContext context) {
    return const AddPropertyPresentation();
  }
}
