// SkillLink_backend/models/Booking.js
const mongoose = require('mongoose');

const BookingSchema = new mongoose.Schema({
    workerListing: {
        type: mongoose.Schema.ObjectId,
        ref: 'Worker',
        required: true
    },
    Hirer: {
        type: mongoose.Schema.ObjectId,
        ref: 'User',
        required: true
    },
    worker: {
        type: mongoose.Schema.ObjectId,
        ref: 'User',
        required: true
    },
    date: {
        type: String, // Storing as 'YYYY-MM-DD' string for consistency with Availability
        required: true
    },
    timeSlot: {
        type: String, // e.g., "10:00 AM", "14:30"
        required: true
    },
    status: {
        type: String,
        enum: ['Pending', 'Accepted', 'InProgress', 'Completed', 'Paid', 'Cancelled', 'Rejected', 'confirmed', 'pending'],
        default: 'Pending'
    },
    location: {
        type: {
            type: String,
            enum: ['Point'],
            default: 'Point'
        },
        coordinates: {
            type: [Number],
            index: '2dsphere'
        },
        address: String
    },
    createdAt: {
        type: Date,
        default: Date.now
    }
}, {
    toJSON: { virtuals: true },
    toObject: { virtuals: true }
});

BookingSchema.index({ workerListing: 1, date: 1, timeSlot: 1, Hirer: 1 }, {
    unique: true,
    partialFilterExpression: {
        status: { $in: ['pending', 'confirmed', 'Pending', 'Accepted', 'InProgress'] }
    }
});

module.exports = mongoose.model('Booking', BookingSchema);