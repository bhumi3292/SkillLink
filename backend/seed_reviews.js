const mongoose = require('mongoose');
const User = require('./models/User');
const Worker = require('./models/Worker');
const Booking = require('./models/Booking');
const Review = require('./models/Review');

const MONGO_URI = "mongodb://localhost:27017/skillLink_dv";

const seedReviews = async () => {
    try {
        await mongoose.connect(MONGO_URI);
        console.log('Connected to MongoDB');

        const workers = await Worker.find({});
        const hirers = await User.find({ role: 'hirer' });

        if (workers.length === 0 || hirers.length === 0) {
            console.log('No workers or hirers found. Run seed_data.js first.');
            process.exit(1);
        }

        const reviewComments = [
            "Great service, very professional.",
            "Average experience, could be better.",
            "Excellent work! Highly recommended.",
            "Arrived late but did the job.",
            "Outstanding skills, solved my issue quickly.",
            "Decent work for the price.",
            "Communication was a bit difficult, but work was good.",
            "Very polite and efficient.",
            "Would hire again.",
            "Satisfactory service."
        ];

        for (const workerListing of workers) {
            let totalRating = 0;
            let reviewCount = 0;

            // Generate 3 to 5 reviews per worker
            const numReviewsToAdd = Math.floor(Math.random() * 3) + 3;

            for (let i = 0; i < numReviewsToAdd; i++) {
                const hirer = hirers[Math.floor(Math.random() * hirers.length)];
                const rating = (Math.random() * (5 - 2) + 2).toFixed(1); // Random between 2.0 and 5.0
                const numericRating = parseFloat(rating);

                // Create a completed booking for this review
                const booking = await Booking.create({
                    workerListing: workerListing._id,
                    worker: workerListing.worker,
                    Hirer: hirer._id,
                    date: new Date(Date.now() - Math.floor(Math.random() * 1000000000)).toISOString().split('T')[0], // Random past date
                    timeSlot: '10:00 AM', // Generic time
                    status: 'Completed',
                    location: workerListing.location,
                    isRated: true
                });

                // Create the review
                await Review.create({
                    workerListing: workerListing._id,
                    hirer: hirer._id,
                    booking: booking._id,
                    rating: numericRating,
                    comment: reviewComments[Math.floor(Math.random() * reviewComments.length)]
                });

                totalRating += numericRating;
                reviewCount++;
                console.log(`Added review for ${workerListing.title}: ${numericRating} stars`);
            }

            // Update Worker Stats
            if (reviewCount > 0) {
                // If there were existing ratings (from manually added ones or previous runs), we should probably recalculate from scratch to be safe.
                // But for this seed script, let's just count what we currently have in DB.

                const allReviews = await Review.find({ workerListing: workerListing._id });
                const finalCount = allReviews.length;
                const finalSum = allReviews.reduce((sum, r) => sum + r.rating, 0);
                const finalAvg = finalCount > 0 ? (finalSum / finalCount) : 0;

                workerListing.numReviews = finalCount;
                workerListing.averageRating = parseFloat(finalAvg.toFixed(1));

                try {
                    await workerListing.save();
                    console.log(`Updated ${workerListing.title} -> Avg: ${workerListing.averageRating}, Count: ${workerListing.numReviews}`);
                } catch (saveErr) {
                    console.error(`Failed to update stats for worker ${workerListing.title}:`, saveErr.message);
                }
            }
        }

        console.log('Review Seeding Completed!');
        process.exit(0);

    } catch (error) {
        console.error('Seeding Global Error:', error);
        process.exit(1);
    }
};

seedReviews();
