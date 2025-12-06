import 'package:flutter/material.dart';
import 'package:skill_link/features/explore/domain/entity/explore_property_entity.dart';
import 'package:skill_link/cores/utils/image_url_helper.dart'; // Ensure this file uses ApiEndpoints
import 'package:skill_link/features/booking/presentation/widgets/booking_modal.dart';
import 'package:skill_link/features/booking/presentation/widgets/worker_manage_availability.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skill_link/features/profile/presentation/view_model/profile_view_model.dart';
import 'package:skill_link/features/add_property/presentation/view/update_property_page.dart';
import 'package:skill_link/features/add_property/domain/use_case/property/delete_property_usecase.dart';
import 'package:get_it/get_it.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_paypal/flutter_paypal.dart';
import 'package:skill_link/features/chat/presentation/page/chat_page.dart';
import 'package:skill_link/app/service_locator/service_locator.dart';
import 'package:skill_link/features/chat/domain/use_case/chat_usecases.dart';
import 'package:skill_link/app/shared_pref/token_shared_prefs.dart';

class PropertyDetailPage extends StatefulWidget {
  final ExplorePropertyEntity property;
  const PropertyDetailPage({super.key, required this.property});

  @override
  State<PropertyDetailPage> createState() => _PropertyDetailPageState();
}

class _PropertyDetailPageState extends State<PropertyDetailPage> {
  int _currentImage = 0;

  void _showPaymentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Payment Options'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Choose your payment method:'),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(
                        Icons.account_balance_wallet,
                        color: Colors.purple,
                      ),
                      label: const Text('Khalti'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple[50],
                        foregroundColor: Colors.purple[700],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: Colors.purple[300]!),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        // _processKhaltiPayment(); // Uncomment if you implement Khalti
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.payment, color: Colors.green),
                      label: const Text('eSewa'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[50],
                        foregroundColor: Colors.green[700],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: Colors.green[300]!),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        _processEsewaPayment();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _processPayPalPayment() {
    // Ensure price is converted to a string only once and is valid
    final String totalPrice =
        widget.property.price?.toStringAsFixed(2) ?? '0.00';

    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (BuildContext context) => UsePaypal(
              sandboxMode: true,
              clientId:
                  "AcnpbvL-nqay69eboBK-a2hcQLnkFTQZXbTF0f4UafVwhRYAXe11Z0B3PtFyWCTDH24INY6Cu2U0rhRC",
              secretKey:
                  "EGZXWncK71BKAfqH7ClPpldekK6kSKvO9yIk0Loz36CkdM7uLC_vuE5mjbGjRhJhBT5BeOYyBB-_p6WW",
              returnURL: "https://samplesite.com/return",
              cancelURL: "https://samplesite.com/cancel",
              transactions: [
                {
                  "amount": {
                    "total": totalPrice, // Use the pre-converted string
                    "currency": "USD",
                    "details": {
                      "subtotal": totalPrice, // Use the pre-converted string
                      "shipping": '0',
                      "shipping_discount": 0,
                    },
                  },
                  "description":
                      "Payment for property: ${widget.property.title}",
                  "item_list": {
                    "items": [
                      {
                        "name": widget.property.title,
                        "quantity": 1,
                        "price": totalPrice, // Use the pre-converted string
                        "currency": "USD",
                      },
                    ],
                  },
                },
              ],
              note: "Contact us for any questions on your order.",
              onSuccess: (Map params) async {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('PayPal payment successful!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  // Dispatch payment event or handle success logic here
                }
              },
              onError: (error) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('PayPal payment failed: $error'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              onCancel: (params) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('PayPal payment cancelled.'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
            ),
      ),
    );
  }

  void _processEsewaPayment() {
    // TODO: Implement eSewa payment integration
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('eSewa payment integration coming soon!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<String?> _getUserIdFromPrefs() async {
    final result = await serviceLocator<TokenSharedPrefs>().getUserId();
    return result.fold((failure) => null, (userId) => userId);
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.property.images ?? [];
    final allMedia = images; // Add videos if you want

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FB),
      appBar: AppBar(
        title: const Text('WorkerDetails'),
        backgroundColor: const Color(0xFF003366),
        foregroundColor: Colors.white,
        elevation: 2,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            elevation: 10,
            shadowColor: Colors.blueGrey.withOpacity(0.2), // <--- Corrected
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image gallery
                  if (allMedia.isNotEmpty)
                    Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.network(
                            ImageUrlHelper.constructImageUrl(
                              allMedia[_currentImage],
                            ), // Ensure this uses ApiEndpoints internally
                            height: 220,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) => Container(
                                  height: 220,
                                  width: double.infinity,
                                  color: Colors.grey[200],
                                  child: Icon(
                                    Icons.broken_image,
                                    color: Colors.grey[400],
                                    size: 50,
                                  ),
                                ),
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                height: 220,
                                width: double.infinity,
                                color: Colors.grey[100],
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value:
                                        loadingProgress.expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                            : null,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        if (allMedia.length > 1)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                allMedia.length,
                                (index) => GestureDetector(
                                  onTap:
                                      () =>
                                          setState(() => _currentImage = index),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    width: 14,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color:
                                          _currentImage == index
                                              ? const Color(0xFF003366)
                                              : Colors.grey[300],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  const SizedBox(height: 24),
                  Text(
                    widget.property.title ?? '',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF003366),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.property.location ?? '',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.blueGrey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Rs. ${widget.property.price?.toStringAsFixed(0) ?? '-'}',
                      style: const TextStyle(
                        fontSize: 24,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Divider(thickness: 1.2, color: Colors.blueGrey[100]),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.king_bed, color: Color(0xFF003366)),
                      const SizedBox(width: 4),
                      Text(
                        'Bedrooms: ${widget.property.bedrooms ?? '-'}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 18),
                      const Icon(Icons.bathtub, color: Color(0xFF003366)),
                      const SizedBox(width: 4),
                      Text(
                        'Bathrooms: ${widget.property.bathrooms ?? '-'}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.category, color: Color(0xFF003366)),
                      const SizedBox(width: 4),
                      Text(
                        'Category: ${widget.property.categoryName ?? '-'}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Divider(thickness: 1.2, color: Colors.blueGrey[100]),
                  const SizedBox(height: 10),
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Color(0xFF003366),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.property.description ?? 'No description provided.',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Divider(thickness: 1.2, color: Colors.blueGrey[100]),
                  const SizedBox(height: 10),
                  const Text(
                    'worker',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Color(0xFF003366),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Check if worker details are available
                  if (widget.property.workerName != null ||
                      widget.property.workerPhone != null ||
                      widget.property.workerEmail != null) ...[
                    if (widget.property.workerName != null)
                      Row(
                        children: [
                          const Icon(Icons.person, color: Color(0xFF003366)),
                          const SizedBox(width: 4),
                          Text(
                            (widget.property.workerName?.startsWith(
                                      'worker ID:',
                                    ) ??
                                    false)
                                ? 'worker Reference'
                                : widget.property.workerName!,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    if (widget.property.workerName != null)
                      const SizedBox(height: 4),
                    if (widget.property.workerPhone != null)
                      Row(
                        children: [
                          const Icon(Icons.phone, color: Color(0xFF003366)),
                          const SizedBox(width: 4),
                          Text(
                            widget.property.workerPhone!,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    if (widget.property.workerPhone != null)
                      const SizedBox(height: 4),
                    if (widget.property.workerEmail != null)
                      Row(
                        children: [
                          const Icon(Icons.email, color: Color(0xFF003366)),
                          const SizedBox(width: 4),
                          Text(
                            widget.property.workerEmail!,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    // --- Chat with worker Button ---
                    const SizedBox(height: 16),
                    Center(
                      child: ElevatedButton.icon(
                        icon: const Icon(
                          Icons.chat_bubble_outline,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Chat with worker',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 4,
                        ),
                        onPressed: () async {
                          final workerId = widget.property.workerId;
                          final propertyId = widget.property.id;
                          final userId = await _getUserIdFromPrefs();
                          if (userId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Unable to start chat: missing user info. Please log in.',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                          if (workerId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Unable to start chat: missing worker info.',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                          if (propertyId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Unable to start chat: missing Workerinfo.',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                          // Prevent user from chatting with themselves
                          if (userId == workerId) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('You cannot chat with yourself.'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                            return;
                          }

                          // Show a loading indicator
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Row(
                                children: [
                                  CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 16),
                                  Text('Starting chat...'),
                                ],
                              ),
                              duration: Duration(
                                seconds: 5,
                              ), // Keep it showing for a while
                            ),
                          );

                          try {
                            final createOrGetChatUsecase =
                                serviceLocator<CreateOrGetChatUsecase>();
                            final chat = await createOrGetChatUsecase(
                              otherUserId: workerId,
                              propertyId: propertyId,
                            );
                            final chatId = chat['_id'] ?? '';
                            // No need for chatTitle here, as ChatPage might determine it.
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => ChatPage(
                                      preselectChatId: chatId,
                                      currentUserId: userId,
                                    ),
                              ),
                            );
                            ScaffoldMessenger.of(
                              context,
                            ).hideCurrentSnackBar(); // Hide loading
                          } catch (e) {
                            debugPrint('Error starting chat: $e');
                            ScaffoldMessenger.of(
                              context,
                            ).hideCurrentSnackBar(); // Hide loading
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Failed to start chat: ${e.toString()}',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ] else ...[
                    // Show message when worker details are not available
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.grey[600],
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'worker contact information is not available for this property.',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'You can use the "Book a Visit" button above to schedule a viewing, or contact the worker through the booking system.',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  // Action buttons - Primary actions
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1), // <--- Corrected
                          spreadRadius: 1,
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Primary action buttons
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(
                                  Icons.calendar_today,
                                  size: 20,
                                ),
                                label: const Text(
                                  'Book a Visit',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF003366),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  elevation: 2,
                                ),
                                onPressed: () {
                                  final profileState =
                                      context.read<ProfileViewModel>().state;
                                  final currentUser = profileState.user;
                                  debugPrint(
                                    'Current userId: ${currentUser?.userId}, WorkerworkerId: ${widget.property.workerId}',
                                  );
                                  final isworker =
                                      currentUser != null &&
                                      (widget.property.workerId ==
                                          currentUser.userId);

                                  if (currentUser == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Please log in to book a visit.',
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }

                                  showDialog(
                                    context: context,
                                    builder:
                                        (context) =>
                                            isworker
                                                ? workerManageAvailability(
                                                  propertyId:
                                                      widget.property.id ?? '',
                                                )
                                                : BookingModal(
                                                  propertyId:
                                                      widget.property.id ?? '',
                                                  propertyTitle:
                                                      widget.property.title ??
                                                      '',
                                                ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.phone, size: 20),
                                label: const Text(
                                  'Contact',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  elevation: 2,
                                ),
                                onPressed: () async {
                                  final phone =
                                      widget
                                          .property
                                          .workerPhone; // Use actual worker phone
                                  if (phone == null || phone.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'worker phone number not available.',
                                        ),
                                        backgroundColor: Colors.orange,
                                      ),
                                    );
                                    return;
                                  }
                                  final Uri launchUri = Uri(
                                    scheme: 'tel',
                                    path:
                                        phone, // Use the actual worker's phone number
                                  );
                                  if (await canLaunchUrl(launchUri)) {
                                    await launchUrl(launchUri);
                                  } else {
                                    if (mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Could not launch phone dialer for $phone',
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Payment button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.payment, size: 20),
                            label: const Text(
                              'Make Payment',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[600],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 2,
                            ),
                            onPressed: () {
                              _processPayPalPayment();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Show Update and Delete buttons for worker only
                  Builder(
                    builder: (context) {
                      final profileState =
                          context.read<ProfileViewModel>().state;
                      final currentUser = profileState.user;
                      final isworker =
                          currentUser != null &&
                          (widget.property.workerId == currentUser.userId);
                      if (!isworker) return const SizedBox.shrink();

                      return Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.orange[50],
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.orange[200]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'WorkerManagement',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF003366),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      icon: const Icon(Icons.edit, size: 18),
                                      label: const Text(
                                        'Update Property',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.orange[600],
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) => UpdatePropertyPage(
                                                  propertyId:
                                                      widget.property.id ?? '',
                                                  initialTitle:
                                                      widget.property.title ??
                                                      '',
                                                  initialLocation:
                                                      widget
                                                          .property
                                                          .location ??
                                                      '',
                                                  initialPrice:
                                                      widget.property.price ??
                                                      0.0,
                                                  initialDescription:
                                                      widget
                                                          .property
                                                          .description ??
                                                      '',
                                                  initialBedrooms:
                                                      widget
                                                          .property
                                                          .bedrooms ??
                                                      0,
                                                  initialBathrooms:
                                                      widget
                                                          .property
                                                          .bathrooms ??
                                                      0,
                                                  initialImages:
                                                      widget.property.images ??
                                                      [],
                                                  initialVideos:
                                                      widget.property.videos ??
                                                      [],
                                                  initialCategoryId:
                                                      widget
                                                          .property
                                                          .categoryId ??
                                                      '',
                                                ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      icon: const Icon(Icons.delete, size: 18),
                                      label: const Text(
                                        'Delete Property',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red[600],
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                      ),
                                      onPressed: () async {
                                        final scaffoldMessenger =
                                            ScaffoldMessenger.of(context);
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder:
                                              (context) => AlertDialog(
                                                title: const Text(
                                                  'Delete Property',
                                                ),
                                                content: const Text(
                                                  'Are you sure you want to delete this property? This action cannot be undone.',
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed:
                                                        () => Navigator.of(
                                                          context,
                                                        ).pop(false),
                                                    child: const Text('Cancel'),
                                                  ),
                                                  TextButton(
                                                    onPressed:
                                                        () => Navigator.of(
                                                          context,
                                                        ).pop(true),
                                                    child: const Text(
                                                      'Delete',
                                                      style: TextStyle(
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                        );
                                        if (confirm != true) return;
                                        final deleteUsecase =
                                            GetIt.I<DeletePropertyUsecase>();
                                        showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder:
                                              (context) => const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              ),
                                        );
                                        final result = await deleteUsecase(
                                          widget.property.id ?? '',
                                        );
                                        Navigator.of(
                                          context,
                                        ).pop(); // Remove loading dialog
                                        result.fold(
                                          (failure) {
                                            scaffoldMessenger.showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Failed to delete property: ${failure.toString()}',
                                                ),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          },
                                          (_) {
                                            scaffoldMessenger.showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Workerdeleted successfully!',
                                                ),
                                                backgroundColor: Colors.green,
                                              ),
                                            );
                                            // Go back one page (to ExplorePage)
                                            Navigator.of(context).pop();
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
