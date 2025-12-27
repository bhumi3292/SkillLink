import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skill_link/app/service_locator/service_locator.dart';
import 'package:skill_link/features/booking/domain/entities/booking_entity.dart';
import 'package:skill_link/features/explore/presentation/bloc/review_bloc.dart';
import 'package:skill_link/features/explore/domain/repository/explore_repository.dart';

class PayAndRatePage extends StatefulWidget {
  final BookingEntity booking;

  const PayAndRatePage({super.key, required this.booking});

  @override
  State<PayAndRatePage> createState() => _PayAndRatePageState();
}

class _PayAndRatePageState extends State<PayAndRatePage> {
  final _commentController = TextEditingController();
  double _rating = 5.0;
  bool _isRatingSubmitted = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _showRatingPopup() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text('rate_experience'.tr, textAlign: TextAlign.center),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(widget.booking.worker?['fullName'] ?? 'Worker', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < _rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 32,
                        ),
                        onPressed: () {
                          setState(() {
                            _rating = index + 1.0;
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'write_comment'.tr,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('cancel'.tr),
                ),
                ElevatedButton(
                  onPressed: () {
                    context.read<ReviewBloc>().add(SubmitReviewEvent(
                          bookingId: widget.booking.id,
                          rating: _rating,
                          comment: _commentController.text,
                        ));
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF003366)),
                  child: Text('submit'.tr, style: const TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ReviewBloc(repository: serviceLocator<ExploreRepository>()),
      child: Scaffold(
        appBar: AppBar(
          title: Text('payment_and_rating'.tr),
          backgroundColor: const Color(0xFF003366),
          foregroundColor: Colors.white,
        ),
        body: BlocListener<ReviewBloc, ReviewState>(
          listener: (context, state) {
            if (state is ReviewSuccess) {
              setState(() => _isRatingSubmitted = true);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Rating submitted successfully!'), backgroundColor: Colors.green),
              );
            } else if (state is ReviewError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green, size: 64),
                        const SizedBox(height: 16),
                        Text('pay_and_rate_desc'.tr, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
                        const Divider(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${'service_type'.tr}:', style: const TextStyle(color: Colors.grey)),
                            Text(widget.booking.workerListingId, style: const TextStyle(fontWeight: FontWeight.bold)), // Should ideally be category name
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${'worker'.tr}:', style: const TextStyle(color: Colors.grey)),
                            Text(widget.booking.worker?['fullName'] ?? 'Worker', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const Divider(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('total_payable'.tr, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const Text('₹ 500', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)), // Placeholder price
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Trigger payment logic
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('pay_now'.tr, style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _isRatingSubmitted || widget.booking.isRated ? null : _showRatingPopup,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Color(0xFF003366)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      _isRatingSubmitted || widget.booking.isRated ? 'Rating Submitted' : 'rate_worker'.tr,
                      style: const TextStyle(fontSize: 18, color: Color(0xFF003366), fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
