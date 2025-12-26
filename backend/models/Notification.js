const mongoose = require('mongoose');

const notificationSchema = new mongoose.Schema({
    recipient: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    title: {
        type: String,
        required: true
    },
    message: {
        type: String,
        required: true
    },
    type: {
        type: String,
        enum: [
            'BOOKING_REQUEST',
            'BOOKING_ACCEPTED',
            'BOOKING_REJECTED',
            'WORKER_EN_ROUTE',
            'WORK_COMPLETED',
            'PAYMENT_SUCCESS',
            'SERVICE_STARTED',
            'SERVICE_COMPLETED',
            'BOOKING_CANCELLED',
            'PAYMENT_RECEIVED',
            'PAYMENT_SUCCESSFUL',
            'BOOKING_SENT'
        ],
        required: true
    },
    relatedId: {
        type: mongoose.Schema.Types.ObjectId,
        // Can ref Booking or Payment depending on type
    },
    read: {
        type: Boolean,
        default: false
    },
    createdAt: {
        type: Date,
        default: Date.now
    }
});

module.exports = mongoose.model('Notification', notificationSchema);
