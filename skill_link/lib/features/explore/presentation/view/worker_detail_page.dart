import 'package:flutter/material.dart';
import 'package:skill_link/features/explore/domain/entity/explore_worker_entity.dart';
import 'package:skill_link/cores/utils/image_url_helper.dart';
import 'package:skill_link/features/booking/presentation/widgets/booking_modal.dart';
import 'package:skill_link/features/booking/presentation/widgets/worker_manage_availability.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skill_link/features/profile/presentation/view_model/profile_view_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:skill_link/cores/network/api_service.dart';
import 'package:skill_link/features/chat/presentation/page/chat_page.dart';
import 'package:skill_link/app/service_locator/service_locator.dart';
import 'package:skill_link/features/chat/domain/use_case/chat_usecases.dart';
import 'package:skill_link/app/shared_pref/token_shared_prefs.dart';

class WorkerDetailPage extends StatefulWidget {
  final ExploreWorkerEntity worker;
  const WorkerDetailPage({super.key, required this.worker});

  @override
  State<WorkerDetailPage> createState() => _WorkerDetailPageState();
}

class _WorkerDetailPageState extends State<WorkerDetailPage> {
  Future<String?> _getUserIdFromPrefs() async {
    try {
      // Prefer in-memory profile if available (faster, more reliable)
      final profileState = context.read<ProfileViewModel>().state;
      final currentUser = profileState.user;
      if (currentUser != null && (currentUser.userId?.isNotEmpty ?? false)) {
        return currentUser.userId;
      }
    } catch (_) {
      // ignore if ProfileViewModel is not available in this context
    }

    final result = await serviceLocator<TokenSharedPrefs>().getUserId();
    return result.fold((failure) => null, (userId) => userId);
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.worker.images ?? [];
    final allMedia = images; // Add videos if you want
    final firstImage =
        allMedia.isNotEmpty
            ? ImageUrlHelper.constructImageUrl(allMedia[0])
            : '';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FB),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280.0,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF003366),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (firstImage.isNotEmpty)
                    Image.network(
                      firstImage,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (_, __, ___) => Container(color: Colors.grey),
                    )
                  else
                    Container(color: Colors.blueGrey),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
              title: Text(
                widget.worker.title ?? 'Worker Profile',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: () {},
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.favorite_border, color: Colors.white),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE65100),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '₹ ${widget.worker.price?.toStringAsFixed(0) ?? '-'} /hr',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.location_on,
                        color: Colors.grey[600],
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.worker.location ?? 'Location not available',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "About",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF003366),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.worker.description ?? "No description provided.",
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Primary Skill",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF003366),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Chip(
                    label: Text(widget.worker.categoryName ?? 'General'),
                    backgroundColor: const Color(0xFFE3F2FD),
                    labelStyle: const TextStyle(
                      color: Color(0xFF1565C0),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (widget.worker.skills != null &&
                      widget.worker.skills!.isNotEmpty) ...[
                    const Text(
                      "Skills",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF003366),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          widget.worker.skills!
                              .map(
                                (skill) => Chip(
                                  label: Text(skill),
                                  backgroundColor: Colors.grey[100],
                                  labelStyle: TextStyle(
                                    color: Colors.grey[800],
                                    fontSize: 13,
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                    const SizedBox(height: 24),
                  ],
                  if (widget.worker.images != null &&
                      widget.worker.images!.isNotEmpty) ...[
                    const Text(
                      "Portfolio",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF003366),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.worker.images!.length,
                        itemBuilder: (context, index) {
                          final imageUrl = ImageUrlHelper.constructImageUrl(
                            widget.worker.images![index],
                          );
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                imageUrl,
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (_, __, ___) => Container(
                                      width: 120,
                                      height: 120,
                                      color: Colors.grey[300],
                                      child: const Icon(
                                        Icons.broken_image,
                                        color: Colors.grey,
                                      ),
                                    ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.blueGrey[100],
                          child: const Icon(Icons.person, color: Colors.white),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.worker.workerName ?? "Worker Name",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Verified Professional",
                                style: TextStyle(
                                  color: Colors.green[600],
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.chat_bubble_outline,
                            color: Color(0xFF003366),
                          ),
                          onPressed: () {
                            _handleChat(context);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () {
                            final profileState =
                                context.read<ProfileViewModel>().state;
                            final currentUser = profileState.user;
                            final isworker =
                                currentUser != null &&
                                (widget.worker.workerId == currentUser.userId);

                            if (currentUser == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please log in.')),
                              );
                              return;
                            }

                            showDialog(
                              context: context,
                              builder:
                                  (context) =>
                                      isworker
                                          ? workerManageAvailability(
                                            propertyId: widget.worker.id ?? '',
                                          )
                                          : BookingModal(
                                            propertyId: widget.worker.id ?? '',
                                            propertyTitle:
                                                widget.worker.title ?? '',
                                            workerId:
                                                widget.worker.workerId ?? '',
                                          ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: const BorderSide(color: Color(0xFF003366)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Book Visit",
                            style: TextStyle(
                              color: Color(0xFF003366),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 1,
                        child: ElevatedButton(
                          onPressed: () {
                            _handleChat(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF003366),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Icon(Icons.chat, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 1,
                        child: ElevatedButton(
                          onPressed: () {
                            _handleCall(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Icon(Icons.call, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 100), // Bottom spacer
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleChat(BuildContext context) async {
    final workerId = widget.worker.workerId;
    final userId = await _getUserIdFromPrefs();

    if (!mounted) return;

    if (userId == null || workerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not initiate chat. User or worker ID is missing.',
          ),
        ),
      );
      return;
    }

    if (userId == workerId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You cannot start a chat with yourself.")),
      );
      return;
    }

    final createOrGetChatUsecase = serviceLocator<CreateOrGetChatUsecase>();

    try {
      final chat = await createOrGetChatUsecase.call(otherUserId: workerId);

      if (!mounted) return;

      final dynamic chatData = chat['data'] ?? chat;
      final String? chatId = chatData['_id'] as String?;

      if (chatId != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => ChatPage(preselectChatId: chatId, currentUserId: userId),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not get chat ID from response.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: ${e.toString()}')),
        );
      }
    }
  }

  void _handleCall(BuildContext context) async {
    String? phone = widget.worker.workerPhone;

    if ((phone == null || phone.isEmpty) && widget.worker.workerId != null) {
      try {
        final api = serviceLocator<ApiService>();
        final resp = await api.dio.get('workers/${widget.worker.workerId}');
        if (resp.statusCode == 200) {
          final data = resp.data;
          dynamic maybe = data;
          if (data is Map && data.containsKey('data')) maybe = data['data'];
          if (maybe is Map) {
            phone =
                maybe['phoneNumber']?.toString() ?? maybe['phone']?.toString();
            if ((phone == null || phone.isEmpty) &&
                maybe.containsKey('user') &&
                maybe['user'] is Map) {
              phone =
                  maybe['user']['phoneNumber']?.toString() ??
                  maybe['user']['phone']?.toString();
            }
          }
        }
      } catch (e) {
        // ignore: avoid_print
        print('Failed to fetch worker for phone: $e');
      }
    }

    if ((phone == null || phone.isEmpty) && widget.worker.id != null) {
      try {
        final api = serviceLocator<ApiService>();
        final resp = await api.dio.get('properties/${widget.worker.id}');
        if (resp.statusCode == 200) {
          final data = resp.data;
          dynamic maybe = data;
          if (data is Map && data.containsKey('data')) maybe = data['data'];
          if (maybe is Map) {
            final workerNode =
                maybe['worker'] ?? maybe['workers'] ?? maybe['owner'];
            if (workerNode is Map) {
              phone =
                  workerNode['phoneNumber']?.toString() ??
                  workerNode['phone']?.toString();
            }
          }
        }
      } catch (e) {
        // ignore: avoid_print
        print('Failed to fetch property/worker for phone: $e');
      }
    }

    if (phone == null || phone.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Phone number not available")),
        );
      }
      return;
    }

    phone = phone.replaceAll(RegExp(r'\s+'), '').replaceAll('-', '');
    if (phone.startsWith('++')) phone = phone.replaceFirst('++', '+');

    final Uri launchUri = Uri(scheme: 'tel', path: phone);
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Could not launch dialer")),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Call error: $e')));
      }
    }
  }
}
