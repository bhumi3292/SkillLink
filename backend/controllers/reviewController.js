const Review = require('../models/Review');
const Booking = require('../models/Booking');
const Worker = require('../models/Worker');
const mongoose = require('mongoose');

class ReviewController {
    /**
     * Submit a Review
     */
    async submitReview(req, res) {
        try {
            const { bookingId, rating, comment } = req.body;
            const hirerId = req.user._id;

            if (!bookingId || !rating) {
                return res.status(400).json({ success: false, message: 'Booking ID and Rating are mandatory' });
            }

            // 1. Validate Booking
            const booking = await Booking.findById(bookingId);
            if (!booking) {
                return res.status(404).json({ success: false, message: 'Booking not found' });
            }

            // 2. Check if already rated
            if (booking.isRated) {
                return res.status(400).json({ success: false, message: 'This booking has already been rated' });
            }

            // 3. Ensure booking is completed
            const statusLower = (booking.status || '').toLowerCase();
            if (statusLower !== 'completed' && statusLower !== 'paid') {
                return res.status(400).json({ success: false, message: 'You can only rate after work completion' });
            }

            // 4. Create Review
            const review = new Review({
                workerListing: booking.workerListing,
                hirer: hirerId,
                booking: bookingId,
                rating,
                comment
            });

            await review.save();

            // 5. Update Worker average rating and numReviews efficiently
            const workerListing = await Worker.findById(booking.workerListing);
            if (workerListing) {
                const newNumReviews = (workerListing.numReviews || 0) + 1;
                const newAverageRating = ((workerListing.averageRating || 0) * (workerListing.numReviews || 0) + rating) / newNumReviews;

                await Worker.findByIdAndUpdate(booking.workerListing, {
                    $set: {
                        averageRating: newAverageRating,
                        numReviews: newNumReviews
                    }
                });
            }

            // 6. Mark booking as rated and update status
            await Booking.findByIdAndUpdate(bookingId, {
                $set: {
                    isRated: true,
                    status: 'Rated'
                }
            });

            return res.status(201).json({ success: true, data: review });
        } catch (error) {
            console.error('Review Submission Error:', error);

            // Handle unique constraint error for duplicate ratings
            if (error.code === 11000) {
                return res.status(400).json({
                    success: false,
                    message: 'You have already submitted a review for this booking.'
                });
            }

            return res.status(500).json({ success: false, message: error.message });
        }
    }

    /**
     * Get Reviews for a Worker Listing
     */
    async getWorkerReviews(req, res) {
        try {
            const { workerListingId } = req.params;
            const reviews = await Review.find({ workerListing: workerListingId })
                .populate('hirer', 'fullName profilePicture')
                .sort({ createdAt: -1 });

            return res.status(200).json({ success: true, data: reviews });
        } catch (error) {
            return res.status(500).json({ success: false, message: error.message });
        }
    }
}

module.exports = new ReviewController();
