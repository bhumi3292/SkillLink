import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:skill_link/cores/utils/image_url_helper.dart';
import 'package:skill_link/app/service_locator/service_locator.dart';
import 'package:skill_link/features/booking/presentation/bloc/booking_bloc.dart';
import 'package:skill_link/features/booking/presentation/view/worker_navigation_page.dart';
import 'package:skill_link/features/profile/presentation/view_model/profile_view_model.dart';
import 'package:skill_link/features/profile/presentation/view_model/profile_state.dart';
import 'package:skill_link/features/profile/presentation/view_model/profile_event.dart';
import 'package:skill_link/core/services/location_service.dart';
import 'package:skill_link/features/payment/presentation/bloc/payment_bloc.dart';
import 'package:skill_link/features/payment/presentation/bloc/payment_state.dart';
import 'package:skill_link/features/payment/presentation/view/payment_options_dialog.dart';
import 'package:skill_link/features/booking/domain/entities/booking_entity.dart';

class BookingPage extends StatelessWidget {
  const BookingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<BookingBloc>(
          create:
              (_) =>
                  serviceLocator<BookingBloc>()..add(LoadUserBookingsEvent()),
        ),
        BlocProvider<ProfileViewModel>.value(
          value:
              serviceLocator<ProfileViewModel>()
                ..add(FetchUserProfileEvent(context: context)),
        ),
        BlocProvider<PaymentBloc>(create: (_) => serviceLocator<PaymentBloc>()),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F8FA),
        body: SafeArea(
          child: Column(
            children: [_buildHeader(), Expanded(child: _buildBody(context))],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 20, bottom: 20, left: 20, right: 20),
      decoration: const BoxDecoration(
        color: Color(0xFF003366),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'My Bookings',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Manage your service appointments and track progress',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<BookingBloc, BookingState>(
          listener: (context, state) {
            if (state is BookingError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
        BlocListener<PaymentBloc, PaymentState>(
          listener: (context, state) {
            if (state is PaymentSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
              context.read<BookingBloc>().add(LoadUserBookingsEvent());
            } else if (state is PaymentFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
      ],
      child: BlocBuilder<BookingBloc, BookingState>(
        builder: (context, state) {
          if (state is BookingLoading)
            return const Center(child: CircularProgressIndicator());
          if (state is BookingsLoaded) {
            final bookings = state.bookings;
            if (bookings.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 56,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No bookings found.',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh:
                  () async =>
                      context.read<BookingBloc>().add(LoadUserBookingsEvent()),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: bookings.length,
                itemBuilder:
                    (context, index) =>
                        _buildBookingCard(context, bookings[index]),
              ),
            );
          }
          if (state is BookingError) return Center(child: Text(state.message));
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildBookingCard(BuildContext context, BookingEntity booking) {
    final otherParty = booking.hirer ?? booking.worker;
    final name =
        otherParty != null ? (otherParty['fullName'] ?? 'User') : 'Unknown';
    final image = otherParty != null ? otherParty['profilePicture'] : null;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage:
                      image != null
                          ? CachedNetworkImageProvider(
                            ImageUrlHelper.constructImageUrl(image),
                          )
                          : const AssetImage('assets/images/fb.png')
                              as ImageProvider,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Booking #${booking.id.length > 8 ? booking.id.substring(0, 8) : booking.id}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Chip(
                  label: Text(
                    booking.status,
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: _getStatusColor(booking.status),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: Colors.blue.shade700,
                ),
                const SizedBox(width: 6),
                Text(booking.date),
                const SizedBox(width: 14),
                Icon(Icons.access_time, size: 14, color: Colors.blue.shade700),
                const SizedBox(width: 6),
                Text(booking.timeSlot),
              ],
            ),
            const SizedBox(height: 8),
            Builder(
              builder: (ctx) {
                final profileState =
                    ctx.read<ProfileViewModel>().state as ProfileState?;
                final currentUser = profileState?.user;
                final isWorker =
                    currentUser != null &&
                    (currentUser.userId == booking.workerId ||
                        (currentUser.stakeholder ?? '').toLowerCase() ==
                            'worker');
                final isHirer =
                    currentUser != null &&
                    (currentUser.userId == booking.hirerId ||
                        (currentUser.stakeholder ?? '').toLowerCase() ==
                            'hirer');

                final status = booking.status.toLowerCase();

                return Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (isWorker && status == 'pending') ...[
                      TextButton(
                        onPressed:
                            () => ctx.read<BookingBloc>().add(
                              UpdateBookingStatusEvent(
                                bookingId: booking.id,
                                status: 'Rejected',
                              ),
                            ),
                        child: const Text(
                          'Reject',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed:
                            () => ctx.read<BookingBloc>().add(
                              UpdateBookingStatusEvent(
                                bookingId: booking.id,
                                status: 'Accepted',
                              ),
                            ),
                        child: const Text('Accept'),
                      ),
                    ],
                    if (isWorker &&
                        (status == 'accepted' ||
                            status == 'confirmed' ||
                            status == 'inprogress')) ...[
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed:
                            () =>
                                _navigateToParty(ctx, booking, forWorker: true),
                        icon: const Icon(Icons.navigation, size: 16),
                        label: const Text('Navigate'),
                      ),
                    ],
                    if (isHirer && status == 'completed') ...[
                      ElevatedButton(
                        onPressed:
                            () => _showPaymentOptionsDialog(
                              ctx,
                              booking.id,
                              1500.0,
                            ),
                        child: const Text('Pay Now'),
                      ),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _navigateToParty(
    BuildContext context,
    BookingEntity booking, {
    required bool forWorker,
  }) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    final locService = serviceLocator<LocationService>();
    final pos = await locService.getCurrentPosition();
    if (context.mounted) Navigator.pop(context);

    LatLng start = const LatLng(27.7172, 85.3240);
    if (pos != null) start = LatLng(pos.latitude, pos.longitude);

    LatLng dest = const LatLng(27.7172, 85.3240);
    try {
      final coords =
          (forWorker
              ? booking.worker
              : booking.hirer)?['location']?['coordinates'];
      if (coords != null && coords is List && coords.length >= 2)
        dest = LatLng(coords[1], coords[0]);
    } catch (_) {}

    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (_) => WorkerNavigationPage(
              workerInitialLocation: start,
              hirerLocation: dest,
            ),
      ),
    );
  }

  void _showPaymentOptionsDialog(
    BuildContext context,
    String bookingId,
    double amount,
  ) {
    showDialog(
      context: context,
      builder:
          (ctx) => BlocProvider.value(
            value: serviceLocator<PaymentBloc>(),
            child: PaymentOptionsDialog(bookingId: bookingId, amount: amount),
          ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
      case 'confirmed':
        return Colors.blue;
      case 'inprogress':
        return Colors.purple;
      case 'completed':
        return Colors.green;
      case 'paid':
        return Colors.teal;
      case 'cancelled':
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
