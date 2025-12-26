const mongoose = require('mongoose');

const paymentSchema = new mongoose.Schema(
    {
        hirer: {
            type: mongoose.Schema.Types.ObjectId,
            ref: 'User',
            required: true,
        },
        worker: {
            type: mongoose.Schema.Types.ObjectId,
            ref: 'User',
            required: true,
        },
        booking: {
            type: mongoose.Schema.Types.ObjectId,
            ref: 'Booking',
            required: true,
        },
        method: {
            type: String,
            required: true,
            enum: ['khalti', 'esewa'],
        },
        amount: {
            type: Number,
            required: true,
        },
        status: {
            type: String,
            enum: ['Pending', 'Completed', 'Failed'],
            default: 'Pending',
        },
        transactionId: {
            type: String,
            required: false, // Initially null for initiate, filled on verify
        },
        pidx: {
            type: String, // Specifically for Khalti
            required: false,
        },
        verificationData: {
            type: mongoose.Schema.Types.Mixed,
            required: false,
        }
    },
    {
        timestamps: true,
    }
);

module.exports = mongoose.model('Payment', paymentSchema);