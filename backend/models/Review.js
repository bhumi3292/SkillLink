const mongoose = require('mongoose');

const ReviewSchema = new mongoose.Schema({
    workerListing: {
        type: mongoose.Schema.ObjectId,
        ref: 'Worker',
        required: true
    },
    hirer: {
        type: mongoose.Schema.ObjectId,
        ref: 'User',
        required: true
    },
    booking: {
        type: mongoose.Schema.ObjectId,
        ref: 'Booking',
        required: true,
        unique: true // One review per booking
    },
    rating: {
        type: Number,
        required: true,
        min: 1,
        max: 5
    },
    comment: {
        type: String,
        required: false
    },
    createdAt: {
        type: Date,
        default: Date.now
    }
}, {
    timestamps: true
});

module.exports = mongoose.model('Review', ReviewSchema);
