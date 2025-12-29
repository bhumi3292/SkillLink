import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skill_link/features/admin/presentation/bloc/admin_worker_bloc.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

class WorkerVerificationListPage extends StatelessWidget {
  const WorkerVerificationListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AdminWorkerBloc()..add(FetchPendingWorkers()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pending Requests'),
          backgroundColor: const Color(0xFF003366),
        ),
        backgroundColor: const Color(0xFFF4F8FB),
        body: BlocBuilder<AdminWorkerBloc, AdminWorkerState>(
          builder: (context, state) {
            if (state is AdminWorkerLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is PendingWorkersLoaded) {
              if (state.workers.isEmpty) {
                return const Center(child: Text('No pending requests'));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.workers.length,
                itemBuilder: (context, index) {
                  final worker = state.workers[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(
                        worker.workerName ?? 'Unknown',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text('Category: ${worker.categoryName ?? "General"}'),
                          const SizedBox(height: 4),
                          Text(
                            'Submitted: ${DateFormat('yyyy-MM-dd').format(DateTime.now())}', // ideally check createAt
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                        ],
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange),
                        ),
                        child: const Text('Pending', style: TextStyle(color: Colors.orange, fontSize: 12)),
                      ),
                      onTap: () async {
                         await Get.toNamed('/admin/workers/detail', arguments: worker);
                         if (context.mounted) {
                           context.read<AdminWorkerBloc>().add(FetchPendingWorkers());
                         }
                      },
                    ),
                  );
                },
              );
            } else if (state is AdminWorkerError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
