import 'package:flutter/material.dart';

import 'package:skill_link/app/constant/api_endpoints.dart';
import 'package:skill_link/cores/network/api_service.dart';
import 'package:skill_link/app/service_locator/service_locator.dart';
import 'package:skill_link/features/payment/data/model/payment_api_model.dart';
import 'package:skill_link/cores/utils/error_message_helper.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminPaymentsView extends StatefulWidget {
  const AdminPaymentsView({super.key});

  @override
  State<AdminPaymentsView> createState() => _AdminPaymentsViewState();
}

class _AdminPaymentsViewState extends State<AdminPaymentsView> {
  final ApiService _api = serviceLocator<ApiService>();
  List<PaymentApiModel> _allPayments = [];
  List<PaymentApiModel> _filteredPayments = [];
  bool _loading = true;
  String _currentFilter = 'All'; // All, Pending, Completed, Failed, Refunded
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadPayments();
    _searchCtrl.addListener(() {
      setState(() {
        _searchQuery = _searchCtrl.text.trim();
        _applyFilter();
      });
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadPayments() async {
    setState(() => _loading = true);
    try {
      final resp = await _api.dio.get(
        ApiEndpoints.adminPayments.replaceFirst(ApiEndpoints.baseUrl, ''),
      );
      if (resp.statusCode == 200) {
        final list =
            (resp.data as List)
                .map((e) => PaymentApiModel.fromJson(e as Map<String, dynamic>))
                .toList();

        // Sort by date desc (if available, otherwise natural order reversed)
        setState(() {
          _allPayments = list.reversed.toList();
          _applyFilter();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to load payments: ${ErrorMessageHelper.getFriendlyMessage(e)}',
            ),
          ),
        );
      }
    }
    setState(() => _loading = false);
  }

  void _applyFilter() {
    if (_currentFilter == 'All') {
      _filteredPayments = List.from(_allPayments);
    } else if (_currentFilter == 'Refund') {
      _filteredPayments =
          _allPayments
              .where((p) => p.refundStatus != null && p.refundStatus != 'none')
              .toList();
    } else {
      _filteredPayments =
          _allPayments
              .where(
                (p) => p.status.toLowerCase() == _currentFilter.toLowerCase(),
              )
              .toList();
    }

    // Apply search query (by ref, payer name, or amount)
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      _filteredPayments =
          _filteredPayments.where((p) {
            final ref = _safeId(p.bookingId).toLowerCase();
            final payer = _safeName(p.hirerId, 'Hirer').toLowerCase();
            final amount = p.amount.toString().toLowerCase();
            return ref.contains(q) || payer.contains(q) || amount.contains(q);
          }).toList();
    }
  }

  void _updateFilter(String filter) {
    setState(() {
      _currentFilter = filter;
      _applyFilter();
    });
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
            const SnackBar(
              content: Text('Refund processed successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ErrorMessageHelper.getFriendlyMessage(e)),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _rejectRefund(String paymentId) async {
    final TextEditingController ctrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Reject Refund'),
            content: TextField(
              controller: ctrl,
              decoration: const InputDecoration(
                hintText: 'Reason (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text(
                  'Reject',
                  style: TextStyle(color: Colors.white),
                ),
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
            const SnackBar(
              content: Text('Refund rejected successfully'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ErrorMessageHelper.getFriendlyMessage(e)),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // --- Helpers for Safe Value Extraction ---
  String _safeId(dynamic val) {
    if (val is Map) return val['_id']?.toString() ?? 'N/A';
    return val?.toString() ?? 'N/A';
  }

  String _safeName(dynamic val, [String defaultName = 'User']) {
    if (val is Map) return val['fullName']?.toString() ?? defaultName;
    return defaultName;
    // If it's a string ID, we can't guess name, so fallback
  }

  // --- UI Components ---

  @override
  Widget build(BuildContext context) {
    final double totalAmount = _allPayments
        .where(
          (p) =>
              p.status.toLowerCase() == 'completed' &&
              (p.refundStatus == null || p.refundStatus == 'none'),
        )
        .fold(0.0, (sum, p) => sum + (p.amount ?? 0));

    final int totalCount = _allPayments.length;
    final int pendingCount =
        _allPayments.where((p) => p.status.toLowerCase() == 'pending').length;
    final int completedCount =
        _allPayments.where((p) => p.status.toLowerCase() == 'completed').length;
    final int failedCount =
        _allPayments.where((p) => p.status.toLowerCase() == 'failed').length;
    final int refundedCount =
        _allPayments
            .where((p) => p.refundStatus != null && p.refundStatus != 'none')
            .length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payments Management'),
        backgroundColor: const Color(0xFF003366),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadPayments),
        ],
      ),
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          // 1. Summary Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Payments Summary',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF003366),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Total amount: NPR ${_formatCurrency(totalAmount)}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _smallStatBadge('All', totalCount, Colors.blue),
                      const SizedBox(width: 10),
                      _smallStatBadge('Pending', pendingCount, Colors.orange),
                      const SizedBox(width: 10),
                      _smallStatBadge(
                        'Completed',
                        completedCount,
                        Colors.green,
                      ),
                      const SizedBox(width: 10),
                      _smallStatBadge('Failed', failedCount, Colors.red),
                      const SizedBox(width: 10),
                      _smallStatBadge(
                        'Refund',
                        refundedCount,
                        Colors.purple,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.download_rounded, size: 18),
                      label: const Text('Export', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF003366),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.withOpacity(0.5)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: _loadPayments,
                        tooltip: 'Refresh',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Search + Filter Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Search by ref, payer or amount',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All', Colors.blue, totalCount),
                      const SizedBox(width: 6),
                      _buildFilterChip('Pending', Colors.orange, pendingCount),
                      const SizedBox(width: 6),
                      _buildFilterChip(
                        'Completed',
                        Colors.green,
                        completedCount,
                      ),
                      const SizedBox(width: 6),
                      _buildFilterChip('Failed', Colors.red, failedCount),
                      const SizedBox(width: 6),
                      _buildFilterChip(
                        'Refund',
                        Colors.purple,
                        refundedCount,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Payments List
          Expanded(
            child:
                _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredPayments.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.payment,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No ${_currentFilter.toLowerCase()} payments found',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _filteredPayments.length,
                      itemBuilder: (context, i) {
                        return _buildPaymentCard(_filteredPayments[i]);
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, Color? color, int? count) {
    final isSelected = _currentFilter == label;
    final baseColor = color ?? const Color(0xFF003366);
    final display = count != null ? '$label ($count)' : label;

    return FilterChip(
      label: Text(display),
      selected: isSelected,
      onSelected: (val) => _updateFilter(label),
      backgroundColor: Colors.white,
      selectedColor: baseColor.withOpacity(0.15),
      labelStyle: TextStyle(
        color: isSelected ? baseColor : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: isSelected ? baseColor : Colors.grey[300]!),
      ),
      checkmarkColor: baseColor,
    );
  }

  Widget _buildPaymentCard(PaymentApiModel p) {
    // Extract Names if possible from dynamic map
    final String bookingRef = _safeId(p.bookingId).substring(0, 8);
    final String hirerName = _safeName(p.hirerId, 'Hirer');
    final String workerName = _safeName(p.workerId, 'Worker');
    
    // Extract Location
    dynamic location;
    if (p.bookingId is Map && p.bookingId['location'] != null) {
      location = p.bookingId['location'];
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF003366),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.receipt,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Ref: #$bookingRef',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                _buildStatusBadge(p.status, p.refundStatus),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('From (Hirer)'),
                          const SizedBox(height: 4),
                          Text(
                            hirerName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 12),
                           _buildLabel('To (Worker)'),
                          const SizedBox(height: 4),
                          Text(
                            workerName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildLabel('Date'),
                          const SizedBox(height: 4),
                          Text(
                            p.paymentDate != null ? _formatDate(p.paymentDate!) : 'N/A',
                            style: const TextStyle(
                              color: Color(0xFF334155),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'Amount',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'NPR ${p.amount.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF003366),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                     Row(
                      children: [
                        Icon(
                          p.paymentGateway.toLowerCase().contains('esewa') ? Icons.account_balance_wallet : Icons.credit_card,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          p.paymentGateway.toUpperCase(),
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w600,
                            fontSize: 13
                          ),
                        ),
                      ],
                    ),
                    
                    Row(
                      children: [
                         if (location != null)
                          TextButton.icon(
                            onPressed: () => _openMap(location),
                            icon: const Icon(Icons.map, size: 16, color: Colors.blue),
                            label: const Text('View Map', style: TextStyle(color: Colors.blue)),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: () => _showPaymentDetails(p),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey.withOpacity(0.3)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                          child: const Text('Details', style: TextStyle(color: Color(0xFF0F172A))),
                        ),
                      ],
                    )
                  ],
                ),

                if (p.refundStatus != null && p.refundStatus != 'none') ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.info_outline, color: Colors.orange, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Refund Status: ${p.refundStatus!.toUpperCase()}',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange),
                            ),
                          ],
                        ),
                        if (p.refundStatus == 'requested') ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _processRefund(p.id ?? ''),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                  ),
                                  icon: const Icon(Icons.check, size: 16),
                                  label: const Text('Approve'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _rejectRefund(p.id ?? ''),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red,
                                    side: const BorderSide(color: Colors.red),
                                  ),
                                  icon: const Icon(Icons.close, size: 16),
                                  label: const Text('Reject'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: Color(0xFF94A3B8),
        letterSpacing: 0.5,
      ),
    );
  }

  Future<void> _openMap(dynamic locationData) async {
    // Expecting GeoJSON Point: { type: 'Point', coordinates: [long, lat] }
    // Or just a string address
    if (locationData is Map && locationData['coordinates'] is List) {
       final coords = locationData['coordinates'] as List;
       if (coords.length >= 2) {
         final lat = coords[1];
         final lng = coords[0];
         final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
         if (await canLaunchUrl(url)) {
           await launchUrl(url, mode: LaunchMode.externalApplication);
         } else {
           if(mounted) {
             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open map')));
           }
         }
         return;
       }
    } else if (locationData is String && locationData.isNotEmpty) {
        // Fallback for address strings
        final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(locationData)}');
         if (await canLaunchUrl(url)) {
           await launchUrl(url, mode: LaunchMode.externalApplication);
         }
         return;
    }
  }

  void _showPaymentDetails(PaymentApiModel p) {
    showDialog(
      context: context,
      builder:
          (_) => Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Payment Details',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 16),
                  
                  _buildDetailItem('Transaction ID', p.transactionId ?? 'N/A'),
                  _buildDetailItem('Reference', '#${_safeId(p.bookingId)}'),
                  _buildDetailItem('Payer Name', _safeName(p.hirerId, 'Hirer')),
                  _buildDetailItem('Worker Name', _safeName(p.workerId, 'Worker')),
                  _buildDetailItem('Amount', 'NPR ${p.amount.toStringAsFixed(2)}'),
                  _buildDetailItem('Date', p.paymentDate != null ? _formatDate(p.paymentDate!) : 'N/A'),
                  _buildDetailItem('Gateway', p.paymentGateway),
                  _buildDetailItem('Status', p.status.toUpperCase()),
                  
                  if (p.refundStatus != null)
                     _buildDetailItem('Refund Status', p.refundStatus!),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF1E293B),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _smallStatBadge(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double n) {
    final s = n.round().toString();
    final len = s.length;
    final buffer = StringBuffer();
    for (int i = 0; i < len; i++) {
      buffer.write(s[i]);
      final pos = len - i - 1;
      if (pos % 3 == 0 && i != len - 1) buffer.write(',');
    }
    return buffer.toString();
  }

  String _formatDate(String isoString) {
    try {
      final dt = DateTime.parse(isoString).toLocal();
      // Simple format: Dec 29, 2025 | 10:00 AM
      // Using basic list for months to avoid intl dependency if not present
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      final month = months[dt.month - 1];
      final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final ampm = dt.hour >= 12 ? 'PM' : 'AM';
      final minute = dt.minute.toString().padLeft(2, '0');
      return '$month ${dt.day}, ${dt.year} | $hour:$minute $ampm';
    } catch (e) {
      return isoString;
    }
  }

  Widget _buildStatusBadge(String status, String? refundStatus) {
    String label = status;
    Color color = Colors.grey;

    if (refundStatus != null && refundStatus != 'none') {
      label = refundStatus == 'requested' ? 'Refund Req.' : refundStatus;
      color = Colors.blueGrey;
    } else {
      if (status.toLowerCase() == 'completed') {
        color = Colors.green;
      } else if (status.toLowerCase() == 'pending')
        color = Colors.orange;
      else if (status.toLowerCase() == 'failed')
        color = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
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


}
