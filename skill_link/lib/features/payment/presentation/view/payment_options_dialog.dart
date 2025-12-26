import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/payment_bloc.dart';
import '../bloc/payment_event.dart';
import '../bloc/payment_state.dart';
import 'package:khalti/khalti.dart';
import 'package:esewa_flutter_sdk/esewa_flutter_sdk.dart';
import 'package:esewa_flutter_sdk/esewa_config.dart';
import 'package:esewa_flutter_sdk/esewa_payment.dart';
import 'package:esewa_flutter_sdk/esewa_payment_success_result.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentOptionsDialog extends StatelessWidget {
  final String bookingId;
  final double amount;

  const PaymentOptionsDialog({
    super.key,
    required this.bookingId,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<PaymentBloc, PaymentState>(
      listener: (context, state) {
        if (state is PaymentInitiated) {
          if (state.gateway == 'Khalti') {
            _launchKhalti(context, state.paymentData);
          } else if (state.gateway == 'eSewa') {
            _launchEsewa(context, state.paymentData);
          }
        } else if (state is PaymentSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context, true);
        } else if (state is PaymentFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              decoration: const BoxDecoration(
                color: Color(0xFF003366),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.account_balance_wallet, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  const Text(
                    'Checkout',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                  ),
                ],
              ),
            ),
            
            // Body
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Text(
                    'Select Payment Method',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Amount Display
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F5FA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF003366).withOpacity(0.1)),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'TOTAL AMOUNT',
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 1.2,
                            color: Color(0xFF003366),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'NPR ${amount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 28,
                            color: Color(0xFF003366),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Options
                  _buildPaymentCard(
                    context,
                    title: 'eSewa Mobile Wallet',
                    subtitle: 'Fast and secure payment via eSewa',
                    color: const Color(0xFF41A124),
                    icon: Icons.account_balance_wallet_rounded,
                    onTap: () {
                      context.read<PaymentBloc>().add(
                        InitiatePaymentEvent(
                          bookingId: bookingId,
                          amount: amount,
                          gateway: 'eSewa',
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildPaymentCard(
                    context,
                    title: 'Khalti Wallet',
                    subtitle: 'Pay easily using your Khalti account',
                    color: const Color(0xFF5C2D91),
                    icon: Icons.wallet_rounded,
                    onTap: () {
                      context.read<PaymentBloc>().add(
                        InitiatePaymentEvent(
                          bookingId: bookingId,
                          amount: amount,
                          gateway: 'Khalti',
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  const Text(
                    'Secured by SkillLink Payment Gateway',
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF333333),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchKhalti(BuildContext context, Map<String, dynamic> paymentData) async {
    final String? paymentUrl = paymentData['payment_url'];
    if (paymentUrl != null && await canLaunchUrl(Uri.parse(paymentUrl))) {
      await launchUrl(Uri.parse(paymentUrl), mode: LaunchMode.externalApplication);
      
      // Since Khalti is web-based here, we might need a way to verify later.
      // Usually, the return_url handles this, but for mobile, we might show a dialog.
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please complete payment in the browser.')),
        );
        Navigator.pop(context);
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open payment page: ${paymentUrl ?? 'URL missing'}')),
        );
      }
    }
  }

  void _launchEsewa(BuildContext context, Map<String, dynamic> paymentData) {
    try {
      // Official eSewa Development Credentials for Mobile SDK
      const String testClientId = 'JB0BBQ4aD0UqIThFJwAKBgAXEUkEGQUBBAwdOgABHD4DChwUAB0R';
      const String testSecret = 'BhwIWQQADhIYSxILExMcAgFXFhcOBwAKBgAXEQ==';

      EsewaFlutterSdk.initPayment(
        esewaConfig: EsewaConfig(
          environment: Environment.test,
          clientId: testClientId, 
          secretId: testSecret,
        ),
        esewaPayment: EsewaPayment(
          productId: paymentData['paymentId'] ?? bookingId,
          productName: "SkillLink Service",
          productPrice: amount.toInt().toString(), 
          callbackUrl: "https://example.com",
        ),
        onPaymentSuccess: (EsewaPaymentSuccessResult result) {
          context.read<PaymentBloc>().add(
            VerifyPaymentEvent(
              gateway: 'eSewa',
              data: {'encodedData': result.message},
            ),
          );
        },
        onPaymentFailure: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('eSewa Payment Failed'), backgroundColor: Colors.red),
          );
        },
        onPaymentCancellation: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('eSewa Payment Cancelled')),
          );
        },
      );
    } catch (e) {
      debugPrint('eSewa SDK Error: $e');
    }
  }
}

