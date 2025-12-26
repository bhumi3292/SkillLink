import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/payment_bloc.dart';
import '../bloc/payment_event.dart';
import '../bloc/payment_state.dart';

class PaymentHistoryPage extends StatelessWidget {
  const PaymentHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment History',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1A1A1A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1A1A), Color(0xFF121212)],
          ),
        ),
        child: BlocBuilder<PaymentBloc, PaymentState>(
          builder: (context, state) {
            if (state is PaymentLoading) {
              return const Center(
                  child: CircularProgressIndicator(color: Color(0xFFFFD700)));
            } else if (state is PaymentFailure) {
              return Center(
                  child: Text(state.message,
                      style: const TextStyle(color: Colors.red)));
            } else if (state is PaymentHistoryLoaded) {
              if (state.history.isEmpty) {
                return const Center(
                    child: Text('No payments found',
                        style: TextStyle(color: Colors.white70)));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.history.length,
                itemBuilder: (context, index) {
                  final payment = state.history[index];
                  return Card(
                    color: const Color(0xFF252525),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'REF: ${payment.bookingId.toString().length > 8 ? payment.bookingId.toString().substring(payment.bookingId.toString().length - 8) : payment.bookingId.toString()}',
                                style: const TextStyle(
                                    color: Color(0xFFFFD700),
                                    fontWeight: FontWeight.bold),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: payment.status == 'Completed' ||
                                          payment.status == 'Paid'
                                      ? Colors.green.withValues(alpha: 0.2)
                                      : Colors.orange.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  payment.status,
                                  style: TextStyle(
                                    color: payment.status == 'Completed' ||
                                            payment.status == 'Paid'
                                        ? Colors.green
                                        : Colors.orange,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Worker: ${payment.workerName ?? "N/A"}',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Amount: NPR ${payment.amount}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Gateway: ${payment.paymentGateway}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                payment.paymentDate != null
                                    ? DateFormat('yyyy-MM-dd HH:mm')
                                        .format(payment.paymentDate!)
                                    : 'N/A',
                                style: const TextStyle(
                                    color: Colors.white54, fontSize: 12),
                              ),
                              if (payment.transactionId != null)
                                Expanded(
                                  child: Text(
                                    'TXN: ${payment.transactionId}',
                                    style: const TextStyle(
                                        color: Colors.white54, fontSize: 12),
                                    textAlign: TextAlign.end,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
            return const Center(
                child: Text('Search history...',
                    style: TextStyle(color: Colors.white70)));
          },
        ),
      ),
    );
  }
}
