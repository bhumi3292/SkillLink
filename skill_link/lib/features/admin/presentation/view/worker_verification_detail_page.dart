import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skill_link/cores/utils/image_url_helper.dart';
import 'package:skill_link/features/explore/domain/entity/explore_worker_entity.dart';
import 'package:skill_link/features/admin/presentation/bloc/admin_worker_bloc.dart';

class WorkerVerificationDetailPage extends StatelessWidget {
  final ExploreWorkerEntity worker;

  const WorkerVerificationDetailPage({super.key, required this.worker});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AdminWorkerBloc(),
      child: BlocConsumer<AdminWorkerBloc, AdminWorkerState>(
        listener: (context, state) {
          if (state is WorkerVerificationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Worker status updated successfully')),
            );
            Navigator.pop(context);
          } else if (state is AdminWorkerError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AdminWorkerLoading;
          
          return Scaffold(
            appBar: AppBar(
              title: Text(worker.workerName ?? 'Worker Detail'),
              backgroundColor: const Color(0xFF003366),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Header
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: worker.images != null && worker.images!.isNotEmpty
                            ? NetworkImage(ImageUrlHelper.constructImageUrl(worker.images!.first))
                            : null,
                        child: worker.images == null || worker.images!.isEmpty
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              worker.workerName ?? 'Unknown Name',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              worker.categoryName ?? 'No Category',
                              style: TextStyle(color: Colors.grey[700], fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  _sectionTitle('Service Description'),
                  Text(worker.description ?? 'No description provided.',
                      style: const TextStyle(fontSize: 15, height: 1.5)),
                  const SizedBox(height: 16),

                  _sectionTitle('Experience'),
                  Text('${worker.experience ?? 0} Years', style: const TextStyle(fontSize: 15)),
                  const SizedBox(height: 16),

                  _sectionTitle('Location'),
                  Text(worker.location ?? 'No location', style: const TextStyle(fontSize: 15)),
                  const SizedBox(height: 24),

                  const Divider(),
                  const SizedBox(height: 16),
                  _sectionTitle('Verification Documents'),
                  const SizedBox(height: 8),
                  
                  // License
                  const Text('License Document:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _buildDocumentViewer(context, worker.licenseUrl),
                  
                  const SizedBox(height: 16),
                  
                  // ID Card
                  const Text('Identity Card:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _buildDocumentViewer(context, worker.identityCardUrl),
                  
                  const SizedBox(height: 40),

                  // Actions
                  if (isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _showRejectDialog(context, worker.id ?? ''),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.red),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('Reject', style: TextStyle(color: Colors.red)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _confirmApprove(context, worker.id ?? ''),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('Approve', style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF003366),
        ),
      ),
    );
  }

  Widget _buildDocumentViewer(BuildContext context, String? url) {
    if (url == null || url.isEmpty) {
      return Container(
        height: 150,
        decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
        child: const Center(child: Text('No document uploaded')),
      );
    }
    
    final fullUrl = ImageUrlHelper.constructImageUrl(url);
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => Dialog(
            child: InteractiveViewer(
              child: Image.network(fullUrl, fit: BoxFit.contain),
            ),
          ),
        );
      },
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            fullUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image)),
          ),
        ),
      ),
    );
  }

  void _showRejectDialog(BuildContext context, String workerId) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reject Worker'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide a reason for rejection:'),
            const SizedBox(height: 8),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.trim().isEmpty) {
                return;
              }
              Navigator.pop(context);
              context.read<AdminWorkerBloc>().add(
                VerifyWorkerEvent(workerId: workerId, action: 'reject', reason: reasonController.text.trim()),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject Worker', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmApprove(BuildContext context, String workerId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Approve Worker'),
        content: const Text('Are you sure you want to approve this worker? They will be publicly visible.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AdminWorkerBloc>().add(
                VerifyWorkerEvent(workerId: workerId, action: 'approve'),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Approve', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
