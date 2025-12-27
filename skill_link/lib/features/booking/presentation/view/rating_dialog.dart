import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skill_link/app/service_locator/service_locator.dart';
import 'package:skill_link/features/booking/domain/entities/booking_entity.dart';
import 'package:skill_link/features/explore/presentation/bloc/review_bloc.dart';
import 'package:skill_link/features/explore/domain/repository/explore_repository.dart';

class RatingDialog extends StatefulWidget {
  final BookingEntity booking;

  const RatingDialog({super.key, required this.booking});

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  final _commentController = TextEditingController();
  double _rating = 0.0;
  bool _isRatingSubmitted = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ReviewBloc(repository: serviceLocator<ExploreRepository>()),
      child: BlocListener<ReviewBloc, ReviewState>(
        listener: (context, state) {
          if (state is ReviewSuccess) {
            setState(() => _isRatingSubmitted = true);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Thank you! Your rating has been submitted successfully.'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
            Navigator.pop(context, true); // Return true to trigger refresh
          } else if (state is ReviewError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
            // Don't pop on error, let the user try again or fix the issue
          }
        },
        child: Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Rate Service',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 10),
                  Text(
                    widget.booking.worker?['fullName'] ?? 'Worker',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const Text('How was your experience?', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 20),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 4,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < _rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 40,
                        ),
                        onPressed: () {
                          setState(() {
                            _rating = index + 1.0;
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Describe your experience (optional)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: BlocBuilder<ReviewBloc, ReviewState>(
                      builder: (context, state) {
                        return ElevatedButton(
                          onPressed: (state is ReviewLoading || _rating == 0)
                              ? null
                              : () {
                                  context.read<ReviewBloc>().add(SubmitReviewEvent(
                                        bookingId: widget.booking.id,
                                        rating: _rating,
                                        comment: _commentController.text,
                                      ));
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF003366),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: state is ReviewLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Text('Submit Review',
                                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        );
                      },
                    ),
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
