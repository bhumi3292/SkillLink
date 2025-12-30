import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skill_link/cores/utils/image_url_helper.dart';
import 'package:skill_link/features/explore/domain/entity/explore_worker_entity.dart';
import 'package:skill_link/features/admin/presentation/bloc/admin_worker_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

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
              const SnackBar(
                content: Text('Worker status updated successfully'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          } else if (state is AdminWorkerError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AdminWorkerLoading;

          return Scaffold(
            appBar: AppBar(
              title: const Text('Worker Verification'),
              backgroundColor: const Color(0xFF003366),
              elevation: 0,
            ),
            backgroundColor: Colors.white,
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Header Card
                  _buildProfileHeader(worker),
                  const SizedBox(height: 24),

                  _sectionTitle('Service Details'),
                  _buildInfoCard(
                    children: [
                      _buildDetailRow(
                        Icons.description,
                        'Description',
                        worker.description ?? 'No description provided.',
                      ),
                      const Divider(),
                      _buildDetailRow(
                        Icons.work_history,
                        'Experience',
                        '${worker.experience ?? 0} Years',
                      ),
                      const Divider(),
                      _buildDetailRow(
                        Icons.location_on,
                        'Location',
                        (worker.location != null && worker.location!.isNotEmpty)
                            ? worker.location!
                            : (worker.coordinates != null
                                ? '${worker.coordinates!.latitude.toStringAsFixed(4)}, ${worker.coordinates!.longitude.toStringAsFixed(4)}'
                                : 'No location details'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  _sectionTitle('Verification Documents'),
                  const SizedBox(height: 8),

                  // License
                  const Text(
                    'Professional License / Certificate',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildDocumentViewer(
                    context,
                    worker.licenseUrl,
                    isImage: worker.licenseIsImage,
                  ),

                  const SizedBox(height: 20),

                  // ID Card
                  const Text(
                    'Government Identity Card',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildDocumentViewer(
                    context,
                    worker.identityCardUrl,
                    isImage: worker.identityIsImage,
                  ),

                  const SizedBox(height: 12),

                  if (worker.rejectionReason != null &&
                      worker.rejectionReason!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _sectionTitle('Rejection Reason'),
                    _buildInfoCard(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(worker.rejectionReason!),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 100), // Space for bottom bar
                ],
              ),
            ),
            bottomNavigationBar: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                child:
                    isLoading
                        ? const SizedBox(
                          height: 50,
                          child: Center(child: CircularProgressIndicator()),
                        )
                        : Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed:
                                    () => _showRejectDialog(
                                      context,
                                      worker.id ?? '',
                                    ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(color: Colors.red),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  backgroundColor: Colors.white,
                                ),
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.red,
                                ),
                                label: const Text(
                                  'Reject Application',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed:
                                    () => _confirmApprove(
                                      context,
                                      worker.id ?? '',
                                    ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  elevation: 2,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  'Approve Worker',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(ExploreWorkerEntity worker) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Hero(
            tag: 'worker_img_${worker.id}',
            child: CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey[300],
              backgroundImage:
                  worker.images != null && worker.images!.isNotEmpty
                      ? NetworkImage(
                        ImageUrlHelper.constructImageUrl(worker.images!.first),
                      )
                      : null,
              child:
                  worker.images == null || worker.images!.isEmpty
                      ? const Icon(Icons.person, size: 40, color: Colors.grey)
                      : null,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        worker.workerName ?? 'Unknown Name',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF003366),
                        ),
                      ),
                    ),
                    _buildStatusBadge(worker.status),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  worker.categoryName ?? 'No Category',
                  style: const TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber[700], size: 18),
                    const SizedBox(width: 4),
                    Text(
                      '${(worker.averageRating ?? 0.0).toStringAsFixed(1)} (${worker.numReviews} Reviews)',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String? status) {
    String label = 'Pending Verification';
    Color color = Colors.orange;
    if (status != null) {
      final s = status.toLowerCase();
      if (s == 'approved' || s == 'active') {
        label = 'Approved';
        color = Colors.green;
      } else if (s == 'rejected') {
        label = 'Rejected';
        color = Colors.red;
      } else if (s == 'pending') {
        label = 'Pending Verification';
        color = Colors.orange;
      } else {
        label = status;
        color = Colors.blueGrey;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color(0xFF64748B),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildInfoCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: const Color(0xFF003366)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 15,
                      color: onTap != null ? Colors.blue : Colors.black87,
                      decoration:
                          onTap != null
                              ? TextDecoration.underline
                              : TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentViewer(
    BuildContext context,
    String? url, {
    bool? isImage,
  }) {
    if (url == null || url.isEmpty) {
      return Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.withOpacity(0.3),
            style: BorderStyle.none,
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.upload_file, color: Colors.grey, size: 30),
              SizedBox(height: 8),
              Text(
                'No document uploaded',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    final fullUrl = ImageUrlHelper.constructImageUrl(url);
    final uri = Uri.parse(fullUrl);
    
    // Proper extension extraction handling query parameters
    final path = uri.path.toLowerCase();
    final extension = path.split('.').last;
    
    final bool isPdf = extension == 'pdf';
    
    // Fallback: If not PDF, assume image or use explicit flag if available and reliable
    // The previous logic inferred image from extensions which is good.
    // We will keep that but default to image for anything non-PDF.

    if (isPdf) {
      return InkWell(
        onTap: () async {
          if (await canLaunchUrl(uri)) {
            // Use inAppWebView to keep it inside the app context as a "viewer"
            // This is less likely to support direct download than external browser
            await launchUrl(uri, mode: LaunchMode.platformDefault);
          } else {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Could not open document')),
              );
            }
          }
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.red[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              const Icon(Icons.picture_as_pdf, color: Colors.red, size: 40),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PDF Document',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Tap to view PDF',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.visibility, color: Colors.red),
            ],
          ),
        ),
      );
    }

    // Image Viewer
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder:
              (_) => Dialog(
                backgroundColor: Colors.black,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    InteractiveViewer(
                      child: Image.network(fullUrl, fit: BoxFit.contain),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ),
        );
      },
      child: Container(
        height: 220,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                fullUrl,
                fit: BoxFit.cover,
                errorBuilder:
                    (_, __, ___) => const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.broken_image,
                            size: 40,
                            color: Colors.grey,
                          ),
                          Text(
                            'Image Load Error',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
              ),
              Positioned(
                right: 8,
                bottom: 8,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.zoom_in,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRejectDialog(BuildContext context, String workerId) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Reject Worker Application'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Please provide a specific reason for rejection. This will be sent to the worker.',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: reasonController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'e.g., Unclear ID photo, Invalid License',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (reasonController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Reason is required')),
                    );
                    return;
                  }
                  Navigator.pop(context);
                  context.read<AdminWorkerBloc>().add(
                    VerifyWorkerEvent(
                      workerId: workerId,
                      action: 'reject',
                      reason: reasonController.text.trim(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text(
                  'Confirm Rejection',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  void _confirmApprove(BuildContext context, String workerId) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 10),
                Text('Approve Worker'),
              ],
            ),
            content: const Text(
              'Are you sure you want to approve this worker?\n\nThey will immediately become visible to all hirers and can start accepting bookings.',
              style: TextStyle(height: 1.5),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.read<AdminWorkerBloc>().add(
                    VerifyWorkerEvent(workerId: workerId, action: 'approve'),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text(
                  'Approve & Verify',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }
}
