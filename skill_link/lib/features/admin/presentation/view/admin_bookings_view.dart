import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skill_link/app/service_locator/service_locator.dart';
import 'package:skill_link/features/admin/presentation/view_model/admin_cubit.dart';
import 'package:skill_link/features/admin/presentation/view_model/admin_state.dart';

import 'package:skill_link/cores/utils/error_message_helper.dart';

class AdminBookingsView extends StatelessWidget {
  const AdminBookingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => serviceLocator<AdminCubit>()..fetchAllBookings(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bookings & Payments'),
          backgroundColor: const Color(0xFF003366),
        ),
        body: BlocBuilder<AdminCubit, AdminState>(
          builder: (context, state) {
            if (state is AdminLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is AdminError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    ErrorMessageHelper.getFriendlyMessage(state.message),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              );
            }

            List<dynamic> bookings = [];
            if (state is AdminBookingsLoaded) {
              bookings = state.bookings;
            }

            if (bookings.isEmpty) {
              return const Center(child: Text('No bookings found'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];
                return _buildBookingCard(booking);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildBookingCard(dynamic booking) {
    final status = booking['status'] ?? 'Unknown';
    final amount = booking['amount'] ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Booking ID: ${booking['_id'].substring(0, 8)}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                _buildStatusBadge(status),
              ],
            ),
            const Divider(),
            _buildInfoRow(Icons.person, 'Hirer', booking['Hirer']?['fullName'] ?? 'Unknown'),
            _buildInfoRow(Icons.engineering, 'Worker', booking['worker']?['fullName'] ?? 'Unknown'),
            _buildInfoRow(Icons.calendar_today, 'Date', booking['date'] ?? 'N/A'),
            _buildInfoRow(Icons.payments, 'Amount', 'Rs $amount'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = Colors.grey;
    if (status.toLowerCase() == 'paid') color = Colors.teal;
    if (status.toLowerCase() == 'completed') color = Colors.green;
    if (status.toLowerCase() == 'pending') color = Colors.orange;
    if (status.toLowerCase() == 'cancelled') color = Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(status.toUpperCase(),
          style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          Text(value, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}
