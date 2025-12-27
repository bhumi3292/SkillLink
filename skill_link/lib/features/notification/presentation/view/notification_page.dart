import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skill_link/app/service_locator/service_locator.dart';
import 'package:skill_link/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:skill_link/features/notification/presentation/bloc/notification_event.dart';
import 'package:skill_link/features/notification/presentation/bloc/notification_state.dart';
import 'package:intl/intl.dart';
import 'package:skill_link/features/booking/presentation/view/pay_and_rate_page.dart';
import 'package:skill_link/features/booking/presentation/bloc/booking_bloc.dart';
import 'package:skill_link/features/booking/domain/repositories/booking_repository.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => serviceLocator<NotificationBloc>()..add(LoadNotifications()),
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F8FA),
        appBar: AppBar(
          title: const Text(
            'Notifications',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFF003366),
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
        ),
        body: BlocBuilder<NotificationBloc, NotificationState>(
          builder: (context, state) {
            if (state is NotificationLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is NotificationError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${state.message}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<NotificationBloc>().add(LoadNotifications()),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            } else if (state is NotificationsLoaded) {
              if (state.notifications.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_none, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No notifications yet!',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<NotificationBloc>().add(LoadNotifications());
                },
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: state.notifications.length,
                  itemBuilder: (context, index) {
                    final notification = state.notifications[index];
                    return _NotificationTile(notification: notification);
                  },
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final dynamic notification; // Using dynamic for simplicity with NotificationModel

  const _NotificationTile({required this.notification});

  @override
  Widget build(BuildContext context) {
    final bool isUnread = !notification.isRead;
    final String formattedDate = DateHelper.formatDate(notification.createdAt);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isUnread ? Colors.blue.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: _getTypeColor(notification.type).withOpacity(0.1),
          child: Icon(
            _getTypeIcon(notification.type),
            color: _getTypeColor(notification.type),
          ),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
            fontSize: 15,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification.message,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              formattedDate,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 11,
              ),
            ),
          ],
        ),
        onTap: () {
          if (isUnread) {
            context.read<NotificationBloc>().add(MarkNotificationAsRead(notification.id));
          }
          if (notification.type == 'SERVICE_COMPLETED' && notification.relatedId != null) {
            _navigateToPayAndRate(context, notification.relatedId);
          }
        },
      ),
    );
  }

  void _navigateToPayAndRate(BuildContext context, String bookingId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    serviceLocator<IBookingRepository>().getBookingById(bookingId).then((result) {
      Navigator.pop(context); // Close loading
      result.fold(
        (failure) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message))),
        (booking) => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PayAndRatePage(booking: booking)),
        ),
      );
    });
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'BOOKING_REQUEST':
        return Icons.event_note;
      case 'BOOKING_ACCEPTED':
        return Icons.check_circle_outline;
      case 'BOOKING_REJECTED':
        return Icons.cancel_outlined;
      case 'WORKER_EN_ROUTE':
        return Icons.directions_run;
      case 'WORK_COMPLETED':
      case 'SERVICE_COMPLETED':
        return Icons.star_outline;
      case 'PAYMENT_SUCCESS':
        return Icons.payment;
      default:
        return Icons.notifications;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'BOOKING_REQUEST':
        return Colors.blue;
      case 'BOOKING_ACCEPTED':
        return Colors.green;
      case 'BOOKING_REJECTED':
        return Colors.red;
      case 'WORKER_EN_ROUTE':
        return Colors.orange;
      case 'WORK_COMPLETED':
      case 'SERVICE_COMPLETED':
        return Colors.purple;
      case 'PAYMENT_SUCCESS':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}

class DateHelper {
  static String formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }
}
