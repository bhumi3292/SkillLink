import 'package:flutter/material.dart';
import 'package:skill_link/app/constant/api_endpoints.dart';
import 'package:skill_link/cores/network/api_service.dart';
import 'package:skill_link/app/service_locator/service_locator.dart';
import 'package:skill_link/features/payment/data/model/payment_api_model.dart';
import 'package:skill_link/cores/utils/error_message_helper.dart';

class AdminPaymentsView extends StatefulWidget {
  const AdminPaymentsView({super.key});

  @override
  State<AdminPaymentsView> createState() => _AdminPaymentsViewState();
}

class _AdminPaymentsViewState extends State<AdminPaymentsView> {
  final ApiService _api = serviceLocator<ApiService>();
  List<PaymentApiModel> _payments = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    setState(() => _loading = true);
    try {
      final resp = await _api.dio.get(
        ApiEndpoints.adminPayments.replaceFirst(ApiEndpoints.baseUrl, ''),
      );
      if (resp.statusCode == 200) {
        final list = (resp.data as List)
            .map((e) => PaymentApiModel.fromJson(e as Map<String, dynamic>))
            .toList();
        setState(() => _payments = list);
      }
    } catch (e) {
      // ignore
    }
    setState(() => _loading = false);
  }

  Future<void> _processRefund(String paymentId) async {
    try {
      final resp = await _api.dio.post(
        ApiEndpoints.adminProcessRefund(
          paymentId,
        ).replaceFirst(ApiEndpoints.baseUrl, ''),
      );
      if (resp.statusCode == 200) {
        await _loadPayments();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Refund processed successfully')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              ErrorMessageHelper.getFriendlyMessage(e),
            ),
          ),
        );
      }
    }
  }

  Future<void> _rejectRefund(String paymentId) async {
    final TextEditingController ctrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject Refund'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(hintText: 'Reason (optional)'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      final resp = await _api.dio.post(
        ApiEndpoints.adminRejectRefund(
          paymentId,
        ).replaceFirst(ApiEndpoints.baseUrl, ''),
        data: {'reason': ctrl.text},
      );
      if (resp.statusCode == 200) {
        await _loadPayments();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Refund rejected successfully')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              ErrorMessageHelper.getFriendlyMessage(e),
            ),
          ),
        );
      }
    }
  }

  String _truncateId(dynamic id) {
    if (id == null) return 'N/A';
    final str = id.toString();
    if (str.length > 8) {
      return '#${str.substring(0, 8)}...';
    }
    return str;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payments'),
        backgroundColor: const Color(0xFF003366),
      ),
      body: RefreshIndicator(
        onRefresh: _loadPayments,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _payments.length,
                itemBuilder: (context, i) {
                  final p = _payments[i];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      title: Text(
                        'Booking: ${_truncateId(p.bookingId)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text('Amount: NPR ${p.amount}'),
                          Text('Hirer: ${_truncateId(p.hirerId)}'),
                          Text('Status: ${p.status}'),
                          if (p.refundStatus != null)
                            Text(
                              'Refund: ${p.refundStatus}',
                              style: TextStyle(
                                color: p.refundStatus == 'requested'
                                    ? Colors.orange
                                    : Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          if (p.paymentGateway.isNotEmpty)
                             Text('Method: ${p.paymentGateway.toUpperCase()}'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (p.refundStatus == 'requested')
                            IconButton(
                              icon: const Icon(Icons.check, color: Colors.green),
                              onPressed: () => _processRefund(p.id ?? ''),
                              tooltip: 'Approve Refund',
                            ),
                          if (p.refundStatus == 'requested')
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () => _rejectRefund(p.id ?? ''),
                              tooltip: 'Reject Refund',
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
