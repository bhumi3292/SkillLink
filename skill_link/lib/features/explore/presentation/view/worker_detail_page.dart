import 'dart:convert';

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
  final int _currentImage = 0;

  Future<String?> _getUserIdFromPrefs() async {
    final result = await serviceLocator<TokenSharedPrefs>().getUserId();
    return result.fold((failure) => null, (userId) => userId);
  }

  @override
  Widget build(BuildContext context) {
    // Debug: show the worker fields we have when opening the page
    // ignore: avoid_print
    print(
      'WorkerDetailPage - workerId: ${widget.worker.workerId}, workerPhone: ${widget.worker.workerPhone}, workerName: ${widget.worker.workerName}',
    );
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
          // Hero Header with SliverAppBar
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
                  // Gradient Overlay for text readability
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

          // Content Body
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rate and Location Row
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

                  // Section: About
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

                  // Section: Skills / Category
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

                  // Section: Skills
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

                  // Section: Portfolio
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

                  // Section: Contact Info (Mocked if missing)
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

                  // Action Buttons
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () {
                            // Book Visit Logic
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
                            // Chat Logic
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
                            // Call Logic
                            _handleCall(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.green, // Different color for call
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
    final propertyId = widget.worker.id;
    final userId = await _getUserIdFromPrefs();

    if (!mounted) return;

    if (userId == null || workerId == null) return;
    if (userId == workerId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cannot chat with yourself")),
      );
      return;
    }

    final createOrGetChatUsecase = serviceLocator<CreateOrGetChatUsecase>();
    try {
      final dynamic chat = await createOrGetChatUsecase(
        otherUserId: workerId,
        workerId: propertyId,
      );
      // Debug: log the raw response so we can adapt to backend shapes
      // If chat still fails, paste this log into the issue
      // ignore: avoid_print
      print('CreateOrGetChat response: ${chat.runtimeType} => $chat');
      if (!mounted) return;

      // Defensive handling of response shape
      String chatId = '';
      if (chat is Map<String, dynamic>) {
        chatId =
            (chat['_id'] ??
                    chat['id'] ??
                    chat['chatId'] ??
                    chat['value']?['_id'] ??
                    '')
                ?.toString() ??
            '';
        if (chatId.isEmpty && chat.containsKey('data') && chat['data'] is Map) {
          final inner = chat['data'] as Map<String, dynamic>;
          chatId = (inner['_id'] ?? inner['id'] ?? '')?.toString() ?? '';
        }
      } else if (chat is List && chat.isNotEmpty) {
        final first = chat.first;
        if (first is Map<String, dynamic>) {
          chatId = (first['_id'] ?? first['id'] ?? '')?.toString() ?? '';
        }
      } else if (chat is String) {
        // try to parse JSON string
        try {
          final decoded = Map<String, dynamic>.from(jsonDecode(chat));
          chatId = (decoded['_id'] ?? decoded['id'] ?? '')?.toString() ?? '';
        } catch (_) {
          // ignore
        }
      }

      if (chatId.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to create or open chat')),
          );
        }
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => ChatPage(preselectChatId: chatId, currentUserId: userId),
        ),
      );
    } catch (e) {
      // ignore: avoid_print
      print('CreateOrGetChat error: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Chat error: $e')));
      }
    }
  }

  void _handleCall(BuildContext context) async {
    // Prefer using the worker data that the page already has (avoid failing backend calls)
    String? phone = widget.worker.workerPhone;

    // If phone not present, first try the dedicated `workers` schema by workerId
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
        print('Failed to fetch worker (workers schema) for phone: $e');
      }
    }

    // Fallback: if still missing, try fetching the property (older schema)
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

    // Sanitize number: Remove spaces, dashes, ensure single '+'
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
      // ignore: avoid_print
      print('Call launch error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Call error: $e')));
      }
    }
  }
}
