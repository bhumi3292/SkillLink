const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const User = require('./models/User');
const Worker = require('./models/Worker');
const Category = require('./models/Category');
const Booking = require('./models/Booking');
const Payment = require('./models/Payment');
const Chat = require('./models/chat'); // Note filename is lower case 'chat.js' in list_dir
const Notification = require('./models/Notification');
const Review = require('./models/Review'); // Add Review model if it exists, check list_dir: yes it does.

const MONGO_URI = "mongodb://localhost:27017/skillLink_dv";

const seedDemoData = async () => {
    try {
        await mongoose.connect(MONGO_URI);
        console.log('Connected to MongoDB');

        // --- 1. SETUP USERS ---
        const passwordHash = await bcrypt.hash('password123', 10);

        // Helper to upsert user
        const upsertUser = async (email, role, name, phone) => {
            let user = await User.findOne({ email });
            if (!user) {
                user = new User({
                    email,
                    role,
                    fullName: name,
                    phoneNumber: phone,
                    password: passwordHash, // Initial hash
                    location: { type: 'Point', coordinates: [85.3240, 27.7172] }, // Kathmandu
                    isVerified: true
                });
                await user.save();
                console.log(`Created User: ${email}`);
            } else {
                user.role = role;
                user.fullName = name;
                user.isVerified = true;
                user.password = passwordHash; // Reset password for demo access
                await user.save();
                console.log(`Updated User: ${email}`);
            }
            return user;
        };

        const workerUser = await upsertUser('worker1@skilllink.com', 'worker', 'Demo Worker One', '9801111111');
        const hirerUser = await upsertUser('hirer1@skilllink.com', 'hirer', 'Demo Hirer One', '9802222222');

        // --- 2. SETUP CATEGORY & SERVICE ---
        let category = await Category.findOne({ category_name: 'Demo Service' });
        if (!category) {
            category = await Category.create({
                category_name: 'Demo Service',
                basePrice: 1500,
                description: 'Service for demo purposes'
            });
            console.log('Created Demo Category');
        } else {
            // Ensure basePrice is set correctly as per new logic
            category.basePrice = 1500;
            await category.save();
        }

        // --- 3. SETUP WORKER LISTING ---
        let workerListing = await Worker.findOne({ worker: workerUser._id });
        if (!workerListing) {
            workerListing = new Worker({
                worker: workerUser._id,
                title: 'Professional Demo Service',
                description: 'High quality demo services for testing application flow.',
                categoryId: category._id,
                location: { type: 'Point', coordinates: [85.3240, 27.7172] },
                images: ['https://images.unsplash.com/photo-1581578731117-6d2744c68c17?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60'],
                experience: 5,
                licenseUrl: 'https://via.placeholder.com/150',
                identityCardUrl: 'https://via.placeholder.com/150',
                status: 'approved', // CRITICAL: Must be approved to be visible
                availabilityStatus: 'Available',
                minPrice: 0, // Ignored by new logic but required by schema
                maxPrice: 0, // Ignored by new logic but required by schema
                averageRating: 4.5,
                numReviews: 2,
                isActive: true
            });
            await workerListing.save();
            console.log('Created Worker Listing');
        } else {
            workerListing.status = 'approved';
            workerListing.isActive = true;
            workerListing.categoryId = category._id;
            workerListing.title = 'Professional Demo Service';
            await workerListing.save();
            console.log('Updated Worker Listing Status to Approved');
        }

        // --- 4. CLEANUP PREVIOUS DEMO DATA ---
        // To ensure a clean state for the demo flow
        await Booking.deleteMany({ Hirer: hirerUser._id, workerListing: workerListing._id });
        await Payment.deleteMany({ hirerId: hirerUser._id, workerId: workerUser._id });
        await Chat.deleteMany({ participants: { $all: [hirerUser._id, workerUser._id] } });
        await Notification.deleteMany({ userId: { $in: [hirerUser._id, workerUser._id] } });
        await Review.deleteMany({ hirer: hirerUser._id, workerListing: workerListing._id });

        console.log('Cleaned up old demo interactions');

        // --- 5. CREATE BOOKINGS & FLOWS ---

        // A. COMPLETED & RATED FLOW
        const bookingRated = await Booking.create({
            workerListing: workerListing._id,
            worker: workerUser._id,
            Hirer: hirerUser._id,
            date: '2025-01-01',
            timeSlot: '10:00 AM',
            status: 'Rated',
            price: category.basePrice,
            isRated: true,
            location: { type: 'Point', coordinates: [85.3240, 27.7172], address: 'Demo Address 1' },
            timeline: [
                { status: 'Pending', actor: hirerUser._id, actorRole: 'hirer' },
                { status: 'Accepted', actor: workerUser._id, actorRole: 'worker' },
                { status: 'Completed', actor: workerUser._id, actorRole: 'worker' },
                { status: 'Paid', actor: hirerUser._id, actorRole: 'hirer' },
                { status: 'Rated', actor: hirerUser._id, actorRole: 'hirer' }
            ]
        });

        await Payment.create({
            bookingId: bookingRated._id,
            hirerId: hirerUser._id,
            workerId: workerUser._id,
            amount: category.basePrice,
            status: 'Completed',
            paymentGateway: 'eSewa',
            transactionId: 'TXN_DEMO_01'
        });

        await Review.create({
            workerListing: workerListing._id,
            hirer: hirerUser._id,
            booking: bookingRated._id,
            rating: 5,
            comment: "Excellent service! Highly recommended for the demo."
        });

        // B. PAID (Pending Rating) FLOW
        const bookingPaid = await Booking.create({
            workerListing: workerListing._id,
            worker: workerUser._id,
            Hirer: hirerUser._id,
            date: '2025-01-02',
            timeSlot: '02:00 PM',
            status: 'Paid',
            price: category.basePrice,
            isRated: false,
            location: { type: 'Point', coordinates: [85.3240, 27.7172], address: 'Demo Address 2' },
            timeline: [
                { status: 'Pending', actor: hirerUser._id, actorRole: 'hirer' },
                { status: 'Completed', actor: workerUser._id, actorRole: 'worker' },
                { status: 'Paid', actor: hirerUser._id, actorRole: 'hirer' }
            ]
        });

        await Payment.create({
            bookingId: bookingPaid._id,
            hirerId: hirerUser._id,
            workerId: workerUser._id,
            amount: category.basePrice,
            status: 'Completed',
            paymentGateway: 'Khalti',
            transactionId: 'TXN_DEMO_02'
        });

        // C. PENDING FLOW
        const bookingPending = await Booking.create({
            workerListing: workerListing._id,
            worker: workerUser._id,
            Hirer: hirerUser._id,
            date: '2025-01-05',
            timeSlot: '09:00 AM',
            status: 'Pending',
            price: category.basePrice,
            location: { type: 'Point', coordinates: [85.3240, 27.7172], address: 'Demo Address 3' }
        });

        // D. REJECTED FLOW
        await Booking.create({
            workerListing: workerListing._id,
            worker: workerUser._id,
            Hirer: hirerUser._id,
            date: '2025-01-08',
            timeSlot: '11:00 AM',
            status: 'Rejected',
            price: category.basePrice,
            location: { type: 'Point', coordinates: [85.3240, 27.7172], address: 'Demo Address 4' },
            timeline: [
                { status: 'Pending', actor: hirerUser._id, actorRole: 'hirer' },
                { status: 'Rejected', actor: workerUser._id, actorRole: 'worker', reason: 'Unavailable at this time' }
            ]
        });

        // --- 6. SETUP CHAT ---
        await Chat.create({
            participants: [hirerUser._id, workerUser._id],
            messages: [
                { sender: hirerUser._id, text: "Hello, is the demo service available?", createdAt: new Date(Date.now() - 86400000) },
                { sender: workerUser._id, text: "Yes, it is fully functional for testing.", createdAt: new Date(Date.now() - 86000000) },
                { sender: hirerUser._id, text: "Great, I have booked a slot.", createdAt: new Date() }
            ],
            lastMessage: "Great, I have booked a slot.",
            updatedAt: new Date()
        });

        // --- 7. SETUP NOTIFICATIONS ---
        // Notify Hirer
        await Notification.create({
            recipient: hirerUser._id,
            title: 'Booking Accepted',
            message: 'Your booking for Demo Service has been accepted.',
            type: 'BOOKING_ACCEPTED',
            relatedId: bookingPaid._id, // Just linking one
            read: false
        });

        // Notify Worker
        await Notification.create({
            recipient: workerUser._id,
            title: 'New Booking Request',
            message: 'You have a new booking request from Demo Hirer.',
            type: 'BOOKING_REQUEST',
            relatedId: bookingPending._id,
            read: false
        });

        console.log('Demo Visibility Data Seeded Successfully!');
        process.exit(0);

    } catch (error) {
        console.error('Seeding Demo Data Failed:', error);
        process.exit(1);
    }
};

seedDemoData();
