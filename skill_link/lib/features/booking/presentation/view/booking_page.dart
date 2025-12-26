import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skill_link/features/booking/presentation/view/worker_navigation_page.dart';
import 'package:latlong2/latlong.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:skill_link/cores/utils/image_url_helper.dart';
import '../../../../app/service_locator/service_locator.dart';
import '../bloc/booking_bloc.dart';
import 'package:skill_link/features/profile/presentation/view_model/profile_view_model.dart';
import 'package:skill_link/features/profile/presentation/view_model/profile_state.dart';
import 'package:skill_link/features/profile/presentation/view_model/profile_event.dart';
import 'package:skill_link/core/services/location_service.dart';

class BookingPage extends StatelessWidget {
  const BookingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create:
              (context) =>
                  serviceLocator<BookingBloc>()..add(LoadUserBookingsEvent()),
        ),
        BlocProvider<ProfileViewModel>.value(
          value:
              serviceLocator<ProfileViewModel>()
                ..add(FetchUserProfileEvent(context: context)),
        ),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F8FA),
        body: SafeArea(
          child: Column(
            children: [
              // --- Custom Header ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(
                  top: 20,
                  bottom: 30,
                  left: 20,
                  right: 20,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFF003366),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'My Bookings',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Manage your service appointments and track progress',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: BlocConsumer<BookingBloc, BookingState>(
                  listener: (context, state) {
                    if (state is BookingError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                    if (state is PaymentInitiated) {
                      showDialog(
                        context: context,
                        builder:
                            (_) => AlertDialog(
                              title: const Text('Payment Initiated'),
                              content: Text(
                                'Please complete payment.\nData: ${state.paymentData}',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state is BookingLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is BookingsLoaded) {
                      final bookings = state.bookings;
                      if (bookings.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 60,
                                color: Colors.grey.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No bookings found.',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return RefreshIndicator(
                        onRefresh: () async {
                          context.read<BookingBloc>().add(
                            LoadUserBookingsEvent(),
                          );
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          itemCount: bookings.length,
                          itemBuilder: (context, index) {
                            final booking = bookings[index];
                            final otherParty = booking.hirer ?? booking.worker;
                            final otherPartyName =
                                otherParty != null
                                    ? otherParty['fullName'] ?? 'User'
                                    : 'Unknown';
                            final otherPartyImage =
                                otherParty != null
                                    ? otherParty['profilePicture']
                                    : null;

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 25,
                                          backgroundImage:
                                              otherPartyImage != null
                                                  ? CachedNetworkImageProvider(
                                                    ImageUrlHelper.constructImageUrl(
                                                      otherPartyImage,
                                                    ),
                                                  )
                                                  : const AssetImage(
                                                        'assets/images/fb.png',
                                                      )
                                                      as ImageProvider,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                otherPartyName,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              Text(
                                                'Booking #${booking.id.substring(0, 8)}',
                                                style: TextStyle(
                                                  color: Colors.grey.shade600,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getStatusColor(
                                              booking.status,
                                            ).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            booking.status,
                                            style: TextStyle(
                                              color: _getStatusColor(
                                                booking.status,
                                              ),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Divider(height: 24),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today,
                                          size: 16,
                                          color: Colors.blue.shade700,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          booking.date,
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                        const SizedBox(width: 16),
                                        Icon(
                                          Icons.access_time,
                                          size: 16,
                                          color: Colors.blue.shade700,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          booking.timeSlot,
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      ],
                                    ),
                                    if (booking.location != null &&
                                        booking.location['address'] !=
                                            null) ...[
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.location_on,
                                            size: 16,
                                            color: Colors.red.shade700,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              booking.location['address'],
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade700,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                    const SizedBox(height: 16),
                                    BlocBuilder<ProfileViewModel, ProfileState>(
                                      builder: (context, profileState) {
                                        final currentUser = profileState.user;
                                        if (currentUser == null)
                                          return const SizedBox.shrink();

                                        final isWorker =
                                            currentUser.userId ==
                                                booking.workerId ||
                                            currentUser.stakeholder
                                                    ?.toLowerCase() ==
                                                'worker' ||
                                            (currentUser.userId != null &&
                                                currentUser.userId ==
                                                    booking.workerId);

                                        final isHirer =
                                            currentUser.userId ==
                                                booking.hirerId ||
                                            currentUser.stakeholder
                                                    ?.toLowerCase() ==
                                                'hirer';

                                        final status =
                                            booking.status.toLowerCase();

                                        // Logging for debugging role mismatch
                                        print(
                                          'DEBUG: Booking #${booking.id} - Status: $status, isWorker: $isWorker, isHirer: $isHirer, currentUserId: ${currentUser.userId}, bookingWorkerId: ${booking.workerId}, bookingHirerId: ${booking.hirerId}',
                                        );

                                        return Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            // Worker specific buttons
                                            if (isWorker) ...[
                                              if (status == 'pending') ...[
                                                TextButton(
                                                  onPressed:
                                                      () => context
                                                          .read<BookingBloc>()
                                                          .add(
                                                            UpdateBookingStatusEvent(
                                                              bookingId:
                                                                  booking.id,
                                                              status:
                                                                  'Rejected',
                                                            ),
                                                          ),
                                                  child: const Text(
                                                    'Reject',
                                                    style: TextStyle(
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                ElevatedButton(
                                                  onPressed:
                                                      () => context
                                                          .read<BookingBloc>()
                                                          .add(
                                                            UpdateBookingStatusEvent(
                                                              bookingId:
                                                                  booking.id,
                                                              status:
                                                                  'Accepted',
                                                            ),
                                                          ),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            Colors.blue,
                                                      ),
                                                  child: const Text('Accept'),
                                                ),
                                              ],
                                              if (status == 'accepted' ||
                                                  status == 'confirmed' ||
                                                  status == 'inprogress')
                                                ElevatedButton.icon(
                                                  icon: const Icon(
                                                    Icons.navigation,
                                                    size: 18,
                                                  ),
                                                  label: const Text("Navigate"),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            Colors.blue,
                                                      ),
                                                  onPressed: () async {
                                                    // Show loading dialog immediately
                                                    showDialog(
                                                      context: context,
                                                      barrierDismissible: false,
                                                      builder: (context) => const Center(
                                                        child: CircularProgressIndicator(),
                                                      ),
                                                    );
                                                    
                                                    final locService = serviceLocator<LocationService>();
                                                    final pos = await locService.getCurrentPosition();
                                                    
                                                    if (context.mounted) Navigator.pop(context); // Close loading dialog
                                                    if (!context.mounted) return;
                                                    
                                                    LatLng workerLoc = const LatLng(27.7172, 85.3240); // Default
                                                    if (pos != null) {
                                                      workerLoc = LatLng(
                                                        pos.latitude,
                                                        pos.longitude,
                                                      );
                                                    }

                                                    LatLng dest = const LatLng(
                                                      27.7172,
                                                      85.3240,
                                                    ); // Default
                                                    if (booking.location !=
                                                            null &&
                                                        booking.location['coordinates'] !=
                                                            null) {
                                                      final coords =
                                                          booking
                                                              .location['coordinates'];
                                                      dest = LatLng(
                                                        coords[1],
                                                        coords[0],
                                                      );
                                                    } else if (booking.hirer !=
                                                            null &&
                                                        booking.hirer['location'] !=
                                                            null) {
                                                      final loc =
                                                          booking
                                                              .hirer['location'];
                                                      if (loc['coordinates'] !=
                                                          null) {
                                                        dest = LatLng(
                                                          loc['coordinates'][1],
                                                          loc['coordinates'][0],
                                                        );
                                                      }
                                                    }
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder:
                                                            (
                                                              _,
                                                            ) => WorkerNavigationPage(
                                                              workerInitialLocation:
                                                                  workerLoc,
                                                              hirerLocation:
                                                                  dest,
                                                            ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              if (status == 'accepted' ||
                                                  status == 'confirmed') ...[
                                                const SizedBox(width: 8),
                                                ElevatedButton(
                                                  onPressed:
                                                      () => context
                                                          .read<BookingBloc>()
                                                          .add(
                                                            UpdateBookingStatusEvent(
                                                              bookingId:
                                                                  booking.id,
                                                              status:
                                                                  'InProgress',
                                                            ),
                                                          ),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            Colors.orange,
                                                      ),
                                                  child: const Text(
                                                    'Start Work',
                                                  ),
                                                ),
                                              ],
                                              if (status == 'inprogress') ...[
                                                const SizedBox(width: 8),
                                                ElevatedButton(
                                                  onPressed:
                                                      () => context
                                                          .read<BookingBloc>()
                                                          .add(
                                                            UpdateBookingStatusEvent(
                                                              bookingId:
                                                                  booking.id,
                                                              status:
                                                                  'Completed',
                                                            ),
                                                          ),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            Colors.green,
                                                      ),
                                                  child: const Text('Complete'),
                                                ),
                                              ],
                                            ],
                                            // Hirer specific buttons
                                            if (isHirer) ...[
                                              if (status == 'pending')
                                                TextButton(
                                                  onPressed:
                                                      () => context
                                                          .read<BookingBloc>()
                                                          .add(
                                                            UpdateBookingStatusEvent(
                                                              bookingId:
                                                                  booking.id,
                                                              status:
                                                                  'Cancelled',
                                                            ),
                                                          ),
                                                  child: const Text(
                                                    'Cancel Request',
                                                    style: TextStyle(
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                ),
                                              if (status == 'completed')
                                                ElevatedButton(
                                                  onPressed:
                                                      () => _showPaymentOptions(
                                                        context,
                                                        booking.id,
                                                        1000.0,
                                                      ),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            Colors.green,
                                                      ),
                                                  child: const Text('Pay Now'),
                                                ),
                                              if (status == 'accepted' ||
                                                  status == 'inprogress' ||
                                                  status == 'confirmed')
                                                ElevatedButton.icon(
                                                  icon: const Icon(
                                                    Icons.navigation,
                                                    size: 18,
                                                  ),
                                                  label: const Text("Navigate"),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            Colors.blue,
                                                      ),
                                                  onPressed: () async {
                                                    // Show loading dialog immediately
                                                    showDialog(
                                                      context: context,
                                                      barrierDismissible: false,
                                                      builder: (context) => const Center(
                                                        child: CircularProgressIndicator(),
                                                      ),
                                                    );

                                                    final locService = serviceLocator<LocationService>();
                                                    final pos = await locService.getCurrentPosition();
                                                    
                                                    if (context.mounted) Navigator.pop(context); // Close loading dialog
                                                    if (!context.mounted) return;

                                                    LatLng hirerLoc = const LatLng(27.7172, 85.3240); // Default
                                                    if (pos != null) {
                                                      hirerLoc = LatLng(
                                                        pos.latitude,
                                                        pos.longitude,
                                                      );
                                                    }

                                                    LatLng dest = const LatLng(
                                                      27.7172,
                                                      85.3240,
                                                    ); // Default
                                                    if (booking.worker !=
                                                            null &&
                                                        booking.worker['location'] !=
                                                            null &&
                                                        booking.worker['location']['coordinates'] !=
                                                            null) {
                                                      final coords =
                                                          booking
                                                              .worker['location']['coordinates'];
                                                      dest = LatLng(
                                                        coords[1],
                                                        coords[0],
                                                      );
                                                    } else if (booking
                                                                .location !=
                                                            null &&
                                                        booking.location['coordinates'] !=
                                                            null) {
                                                      final coords =
                                                          booking
                                                              .location['coordinates'];
                                                      dest = LatLng(
                                                        coords[1],
                                                        coords[0],
                                                      );
                                                    } else {
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                            'Worker location not available',
                                                          ),
                                                        ),
                                                      );
                                                      return;
                                                    }

                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder:
                                                            (
                                                              _,
                                                            ) => WorkerNavigationPage(
                                                              workerInitialLocation:
                                                                  hirerLoc,
                                                              hirerLocation:
                                                                  dest,
                                                            ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              if (status == 'paid')
                                                const Chip(
                                                  label: Text('Paid'),
                                                  backgroundColor: Colors.teal,
                                                  labelStyle: TextStyle(
                                                    color: Colors.white,
                                                  ),
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
                          },
                        ),
                      );
                    } else if (state is BookingError) {
                      return Center(child: Text(state.message));
                    }
                    return const Center(
                      child: CircularProgressIndicator(),
                    ); // Initial loading state
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPaymentOptions(
    BuildContext context,
    String bookingId,
    double amount,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
          height: 250,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Select Payment Method",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              ListTile(
                leading: Icon(
                  Icons.account_balance_wallet,
                  color: Colors.purple,
                ),
                title: Text("Khalti"),
                onTap: () {
                  Navigator.pop(context);
                  _initiatePayment(context, bookingId, amount, 'khalti');
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.account_balance_wallet,
                  color: Colors.green,
                ),
                title: Text("eSewa"),
                onTap: () {
                  Navigator.pop(context);
                  _initiatePayment(context, bookingId, amount, 'esewa');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _initiatePayment(
    BuildContext context,
    String bookingId,
    double amount,
    String method,
  ) {
    context.read<BookingBloc>().add(
      InitiatePaymentEvent(
        bookingId: bookingId,
        amount: amount,
        method: method,
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
