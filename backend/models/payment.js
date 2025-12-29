const mongoose = require('mongoose');

const paymentSchema = new mongoose.Schema({
    bookingId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Booking',
        required: true
    },
    hirerId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    workerId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    paymentGateway: {
        type: String,
        enum: ['eSewa', 'Khalti'],
        required: true
    },
    amount: {
        type: Number,
        required: true
    },
    baseAmount: {
        type: Number,
        default: 0
    },
    serviceFee: {
        type: Number,
        default: 0
    },
    taxAmount: {
        type: Number,
        default: 0
    },
    totalAmount: {
        type: Number,
        default: 0
    },
    transactionId: {
        type: String,
        unique: true,
        sparse: true // Only exist once it's completed
    },
    status: {
        type: String,
        enum: ['Pending', 'Completed', 'Failed', 'Cancelled'],
        default: 'Pending'
    },
    refundStatus: {
        type: String,
        enum: ['none', 'requested', 'refunded', 'rejected'],
        default: 'none'
    },
    refundReason: {
        type: String,
        default: null
    },
    refundRequestedBy: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        default: null
    },
    refundProcessedBy: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        default: null
    },
    refundProcessedAt: {
        type: Date,
        default: null
    },
    paymentDate: {
        type: Date,
        default: Date.now
    }
}, { timestamps: true });

module.exports = mongoose.model('Payment', paymentSchema);