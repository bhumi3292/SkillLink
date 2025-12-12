const mongoose = require('mongoose');

const notificationSchema = new mongoose.Schema(
    {
        recipient: {
            type: mongoose.Schema.ObjectId,
            ref: 'User',
            required: true
        },
        sender: {
            type: mongoose.Schema.ObjectId,
            ref: 'User',
            required: false
        },
        type: {
            type: String,
            enum: ['booking_request', 'booking_confirmed', 'booking_rejected', 'booking_cancelled', 'message', 'profile_update'],
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
        relatedId: {
            type: mongoose.Schema.ObjectId,
            required: false // Can reference booking ID, chat ID, or property ID
        },
        relatedModel: {
            type: String,
            enum: ['Booking', 'Chat', 'Worker', null],
            required: false
        },
        isRead: {
            type: Boolean,
            default: false
        },
        readAt: {
            type: Date,
            default: null
        },
        data: {
            type: mongoose.Schema.Types.Mixed,
            required: false // Additional metadata
        }
    },
    {
        timestamps: true
    }
);

// Index for efficient querying
notificationSchema.index({ recipient: 1, isRead: 1 });
notificationSchema.index({ recipient: 1, createdAt: -1 });

module.exports = mongoose.model('Notification', notificationSchema);
