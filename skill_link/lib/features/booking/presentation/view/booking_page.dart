import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:skill_link/core/services/location_service.dart';
import 'package:skill_link/cores/utils/image_url_helper.dart';
import 'package:skill_link/features/profile/presentation/view_model/profile_view_model.dart';
import 'package:skill_link/features/auth/presentation/view_model/login_view_model/login_view_model.dart';
import 'package:skill_link/features/auth/presentation/view_model/login_view_model/login_state.dart';
import 'package:skill_link/app/shared_pref/token_shared_prefs.dart';
import 'package:skill_link/app/service_locator/service_locator.dart';
import 'package:skill_link/features/booking/presentation/view/worker_navigation_page.dart';

import '../../../../app/constant/api_endpoints.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  List<Map<String, dynamic>> _bookings = [];
  bool _isLoading = true;
  String? _error;
  String? _userRole;
  final TokenSharedPrefs _tokenSharedPrefs = TokenSharedPrefs(
    sharedPreferences: serviceLocator(),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserInfo();
    });
  }

  Future<void> _loadUserInfo() async {
    final profileState = context.read<ProfileViewModel>().state;

    if (profileState.isLoading) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    final user = profileState.user;

    if (user != null) {
      setState(() {
        _userRole = user.stakeholder;
      });
      await _fetchBookings();
    } else {
      setState(() {
        _error = 'Please log in to view your bookings.';
        _isLoading = false;
      });
    }
  }

  Future<String?> _getToken() async {
    final tokenEither = await _tokenSharedPrefs.getToken();
    return tokenEither.fold((l) => null, (r) => r);
  }

  Future<void> _fetchBookings() async {
    if (_userRole == null) {
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        setState(() {
          _error = 'Please log in to view your bookings.';
          _isLoading = false;
        });
        return;
      }

      String endpoint;
      final role = _userRole?.toLowerCase();
      if (role == 'hirer') {
        endpoint = '${ApiEndpoints.baseUrl}calendar/hirer/bookings';
      } else if (role == 'worker') {
        endpoint = '${ApiEndpoints.baseUrl}calendar/worker/bookings';
      } else {
        setState(() {
          _error = 'Invalid user role.';
          _isLoading = false;
        });
        return;
      }

      final response = await Dio().get(
        endpoint,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.data['success']) {
        final bookings = List<Map<String, dynamic>>.from(
          response.data['bookings'] ?? [],
        );
        setState(() {
          _bookings = bookings;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response.data['message'] ?? 'Failed to fetch bookings.';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (e is DioException) {
        setState(() {
          _error =
              'Failed to load bookings. ${e.response?.data['message'] ?? e.message}';
        });
      } else {
        setState(() {
          _error = 'Failed to load bookings. Please try again.';
        });
      }
    } finally {
      if(mounted){
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _cancelBooking(String bookingId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text(
          'Are you sure you want to cancel this booking? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please log in to cancel booking.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      await Dio().delete(
        '${ApiEndpoints.baseUrl}calendar/bookings/$bookingId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking cancelled successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }

      await _fetchBookings(); // Refresh the list
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Failed to cancel booking.';
        if (e is DioException) {
          errorMessage =
              e.response?.data['message'] ?? e.message ?? errorMessage;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _updateBookingStatus(String bookingId, String status) async {
    final statusText =
        status == 'Confirmed'
            ? 'confirm'
            : status == 'Rejected'
                ? 'reject'
                : 'cancel';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$statusText Booking'),
        content: Text('Are you sure you want to $statusText this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Yes, $statusText'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please log in to update booking status.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      await Dio().put(
        '${ApiEndpoints.baseUrl}calendar/bookings/$bookingId/status',
        data: {'status': status},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking status updated to ${status.toLowerCase()}!'),
            backgroundColor: Colors.green,
          ),
        );
      }

      await _fetchBookings(); // Refresh the list
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Failed to update booking status.';
        if (e is DioException) {
          errorMessage =
              e.response?.data['message'] ?? e.message ?? errorMessage;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'rejected':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  Color _getStatusBackgroundColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange.shade50;
      case 'confirmed':
        return Colors.green.shade50;
      case 'cancelled':
        return Colors.red.shade50;
      case 'rejected':
        return Colors.grey.shade50;
      default:
        return Colors.blue.shade50;
    }
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    final property = booking['property'] ?? booking['worker'] ?? {};
    final hirer = booking['Hirer'];
    final worker = booking['worker'];
    final status = booking['status'] ?? 'pending';
    final date = booking['date'] ?? '';
    final timeSlot = booking['timeSlot'] ?? '';
    final bookingId = booking['_id'] ?? '';

    String? imageUrl;
    if (property is Map &&
        property['images'] != null &&
        (property['images'] as List).isNotEmpty) {
      final imagePath = property['images'][0];
      imageUrl = ImageUrlHelper.constructImageUrl(imagePath);
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (imageUrl != null && imageUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imageUrl,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.home,
                          color: Colors.grey,
                          size: 24,
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.home, color: Colors.grey, size: 24),
                  ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (property is Map ? property['title'] : 'Worker Service') ??
                            'Unknown Service',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF003366),
                        ),
                      ),
                      if (property is Map && property['location'] != null)
                        Text(
                          (property['location'] is Map ? property['location']['type'] : property['location']) ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 18,
                      color: Colors.blue.shade500,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Date: ',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    Text(
                      DateFormat('MMM dd, yyyy').format(DateTime.parse(date)),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 18,
                      color: Colors.blue.shade500,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Time: ',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    Text(
                      timeSlot,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                if (_userRole == 'worker' && hirer != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.person,
                        size: 18,
                        color: Colors.purple.shade500,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Booked by: ',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      Expanded(
                        child: Text(
                          '${hirer['fullName'] ?? 'N/A'} (${hirer['email'] ?? 'N/A'})',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (_userRole == 'Hirer' && worker != null && worker is Map) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.person,
                        size: 18,
                        color: Colors.purple.shade500,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'WorkerOwner: ',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      Expanded(
                        child: Text(
                          '${worker['fullName'] ?? 'N/A'} (${worker['email'] ?? 'N/A'})',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.info, size: 18, color: Colors.grey.shade500),
                    const SizedBox(width: 8),
                    const Text(
                      'Status: ',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusBackgroundColor(status),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(status),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (_userRole == 'worker' && status.toLowerCase() == 'confirmed')
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Center(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final locationService = serviceLocator<LocationService>();
                      final hasPermission = await locationService.requestPermission();
                      if (!hasPermission) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Location permission is required.')),
                          );
                        }
                        return;
                      }

                      final position = await locationService.getCurrentPosition();
                      if (position == null) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Could not get current location.')),
                          );
                        }
                        return;
                      }
                      final workerLocation = LatLng(position.latitude, position.longitude);

                      if (hirer != null &&
                          hirer['location'] != null &&
                          hirer['location']['coordinates'] is List &&
                          hirer['location']['coordinates'].length == 2) {
                        final coords = hirer['location']['coordinates'];
                        final hirerLocation = LatLng(coords[1], coords[0]);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => WorkerNavigationPage(
                              workerInitialLocation: workerLocation,
                              hirerLocation: hirerLocation,
                            ),
                          ),
                        );
                      } else {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Hirer location not available.')),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.navigation),
                    label: const Text('Start Navigation'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
      ),
      body: BlocListener<LoginViewModel, LoginState>(
        listener: (context, state) {
          // When the login state changes (e.g., after logout), reload user info.
          // A simple check for the initial state often works for this.
          if (state.runtimeType.toString() == 'LoginInitial') {
            _loadUserInfo();
          }
        },
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                      ),
                    ),
                  )
                : _bookings.isEmpty
                    ? const Center(
                        child: Text(
                          'You have no bookings yet.',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _fetchBookings,
                        child: ListView.builder(
                          itemCount: _bookings.length,
                          itemBuilder: (context, index) {
                            return _buildBookingCard(_bookings[index]);
                          },
                        ),
                      ),
      ),
    );
  }
}
