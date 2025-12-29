import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skill_link/app/service_locator/service_locator.dart';
import 'package:skill_link/features/admin/presentation/view_model/admin_cubit.dart';

class DisputeResolutionView extends StatelessWidget {
  const DisputeResolutionView({super.key});

  @override
  Widget build(BuildContext context) {
    // Note: AdminCubit doesn't have fetchReports yet, but we'll adapt it
    return BlocProvider(
      create: (context) => serviceLocator<AdminCubit>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dispute Resolution'),
          backgroundColor: const Color(0xFF1A237E),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.gavel, size: 80, color: Colors.grey),
              SizedBox(height: 20),
              Text('No active disputes reported', style: TextStyle(fontSize: 18, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}
