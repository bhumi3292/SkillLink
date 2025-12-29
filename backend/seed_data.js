const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const User = require('./models/User');
const Worker = require('./models/Worker');
const Category = require('./models/Category');
const Booking = require('./models/Booking');
const Payment = require('./models/Payment'); // Verify Payment model filename
const Chat = require('./models/chat');

const MONGO_URI = "mongodb://localhost:27017/skillLink_dv";

const seedData = async () => {
    try {
        await mongoose.connect(MONGO_URI);
        console.log('Connected to MongoDB');

        // 1. Create Categories
        const categoriesData = [
            { category_name: 'Plumbing', types: ['Pipe Repair', 'Installation'] },
            { category_name: 'Electrical', types: ['Wiring', 'Lighting'] },
            { category_name: 'Cleaning', types: ['Deep Clean', 'Standard'] }
        ];

        let categories = [];
        for (const catData of categoriesData) {
            let cat = await Category.findOne({ category_name: catData.category_name });
            if (!cat) {
                cat = await Category.create(catData);
                console.log(`Created Category: ${cat.category_name}`);
            }
            categories.push(cat);
        }

        // 2. Create Users (Workers & Hirers)
        const passwordHash = await bcrypt.hash('password123', 10);

        const workers = [];
        const hirers = [];

        // Create 5 Workers
        for (let i = 1; i <= 5; i++) {
            const email = `worker${i}@skilllink.com`;
            let user = await User.findOne({ email });
            if (!user) {
                user = await User.create({
                    fullName: `Worker User ${i}`,
                    email,
                    phoneNumber: `980000000${i}`,
                    role: 'worker',
                    password: passwordHash,
                    location: { type: 'Point', coordinates: [85.3 + (i * 0.01), 27.7 + (i * 0.01)] }
                });
                console.log(`Created Worker User: ${user.fullName}`);
            }
            workers.push(user);
        }

        // Create 5 Hirers
        for (let i = 1; i <= 5; i++) {
            const email = `hirer${i}@skilllink.com`;
            let user = await User.findOne({ email });
            if (!user) {
                user = await User.create({
                    fullName: `Hirer User ${i}`,
                    email,
                    phoneNumber: `981111111${i}`,
                    role: 'hirer',
                    password: passwordHash,
                    location: { type: 'Point', coordinates: [85.32 + (i * 0.01), 27.72 + (i * 0.01)] }
                });
                console.log(`Created Hirer User: ${user.fullName}`);
            }
            hirers.push(user);
        }

        // 3. Create Worker Listings
        const workerListings = [];
        for (let i = 0; i < workers.length; i++) {
            const workerUser = workers[i];
            const category = categories[i % categories.length];

            let listing = await Worker.findOne({ worker: workerUser._id });
            if (!listing) {
                listing = await Worker.create({
                    worker: workerUser._id,
                    title: `Expert ${category.category_name} Service ${i + 1}`,
                    description: `Professional ${category.category_name} services with 5 years experience.`,
                    categoryId: category._id,
                    minPrice: 500 + (i * 100),
                    maxPrice: 1000 + (i * 100),
                    location: workerUser.location,
                    images: [`/uploads/worker${i + 1}.jpg`], // Placeholder
                    experience: 5,
                    licenseUrl: `/uploads/license${i + 1}.jpg`,
                    identityCardUrl: `/uploads/id${i + 1}.jpg`,
                    status: 'approved',
                    availabilityStatus: 'Available'
                });
                console.log(`Created Worker Listing for: ${workerUser.fullName}`);
            }
            workerListings.push(listing);
        }

        // 4. Create Bookings & Payments
        // Booking 1: Completed & Paid (Success)
        const booking1 = await Booking.create({
            workerListing: workerListings[0]._id,
            worker: workers[0]._id,
            Hirer: hirers[0]._id,
            date: '2025-01-10',
            timeSlot: '10:00 AM',
            status: 'Completed',
            location: { type: 'Point', coordinates: [85.32, 27.72], address: 'Kathmandu' }
        });

        await Payment.create({
            bookingId: booking1._id,
            hirerId: hirers[0]._id,
            workerId: workers[0]._id,
            paymentGateway: 'eSewa',
            amount: 1000,
            baseAmount: 1000,
            status: 'Completed',
            transactionId: `TXN${Date.now()}1`,
            paymentDate: new Date()
        });
        console.log('Created Completed Booking & Payment');

        // Booking 2: Failed Payment (or just Booking)
        const booking2 = await Booking.create({
            workerListing: workerListings[1]._id,
            worker: workers[1]._id,
            Hirer: hirers[1]._id,
            date: '2025-01-12',
            timeSlot: '02:00 PM',
            status: 'Pending', // Payment failed usually implies booking is still pending or cancelled
            location: { type: 'Point', coordinates: [85.33, 27.73], address: 'Lalitpur' }
        });

        await Payment.create({
            bookingId: booking2._id,
            hirerId: hirers[1]._id,
            workerId: workers[1]._id,
            paymentGateway: 'Khalti',
            amount: 1200,
            baseAmount: 1200,
            status: 'Failed',
            transactionId: `TXN${Date.now()}2`, // May or may not exist on failure
            paymentDate: new Date()
        });
        console.log('Created Booking with Failed Payment');

        // Booking 3: Pending (No Payment yet)
        await Booking.create({
            workerListing: workerListings[2]._id,
            worker: workers[2]._id,
            Hirer: hirers[2]._id,
            date: '2025-01-15',
            timeSlot: '09:00 AM',
            status: 'Pending',
            location: { type: 'Point', coordinates: [85.34, 27.74], address: 'Bhaktapur' }
        });
        console.log('Created Pending Booking');

        // 5. Create Chats
        await Chat.create({
            participants: [hirers[0]._id, workers[0]._id],
            messages: [
                { sender: hirers[0]._id, text: "Hi, are you available?", createdAt: new Date() },
                { sender: workers[0]._id, text: "Yes, I am!", createdAt: new Date() }
            ],
            lastMessage: "Yes, I am!",
            name: "Plumbing Project"
        });
        console.log('Created Chat 1');

        await Chat.create({
            participants: [hirers[1]._id, workers[1]._id],
            messages: [
                { sender: hirers[1]._id, text: "Can you fix my wiring?", createdAt: new Date() }
            ],
            lastMessage: "Can you fix my wiring?",
            name: "Wiring job"
        });
        console.log('Created Chat 2');

        console.log('Seeding Completed Successfully!');
        process.exit(0);

    } catch (error) {
        console.error('Seeding Failed:', error);
        process.exit(1);
    }
};

seedData();
