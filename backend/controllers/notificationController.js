const Notification = require('../models/Notification');
const User = require('../models/User');

// Get all notifications for the authenticated user
exports.getNotifications = async (req, res) => {
    const userId = req.user._id;

    try {
        const notifications = await Notification.find({ recipient: userId })
            .populate('sender', 'fullName profilePicture')
            .populate('relatedId')
            .sort({ createdAt: -1 })
            .limit(50);

        res.status(200).json({
            success: true,
            notifications,
            unreadCount: notifications.filter(n => !n.isRead).length
        });
    } catch (error) {
        console.error('Error fetching notifications:', error);
        res.status(500).json({ success: false, message: 'Server error fetching notifications.' });
    }
};

// Mark notification as read
exports.markAsRead = async (req, res) => {
    const { notificationId } = req.params;
    const userId = req.user._id;

    try {
        const notification = await Notification.findById(notificationId);

        if (!notification || notification.recipient.toString() !== userId.toString()) {
            return res.status(404).json({ success: false, message: 'Notification not found.' });
        }

        notification.isRead = true;
        notification.readAt = new Date();
        await notification.save();

        res.status(200).json({ success: true, message: 'Notification marked as read.' });
    } catch (error) {
        console.error('Error marking notification as read:', error);
        res.status(500).json({ success: false, message: 'Server error.' });
    }
};

// Mark all notifications as read
exports.markAllAsRead = async (req, res) => {
    const userId = req.user._id;

    try {
        await Notification.updateMany(
            { recipient: userId, isRead: false },
            { $set: { isRead: true, readAt: new Date() } }
        );

        res.status(200).json({ success: true, message: 'All notifications marked as read.' });
    } catch (error) {
        console.error('Error marking all notifications as read:', error);
        res.status(500).json({ success: false, message: 'Server error.' });
    }
};

// Delete a notification
exports.deleteNotification = async (req, res) => {
    const { notificationId } = req.params;
    const userId = req.user._id;

    try {
        const notification = await Notification.findById(notificationId);

        if (!notification || notification.recipient.toString() !== userId.toString()) {
            return res.status(404).json({ success: false, message: 'Notification not found.' });
        }

        await notification.deleteOne();
        res.status(200).json({ success: true, message: 'Notification deleted.' });
    } catch (error) {
        console.error('Error deleting notification:', error);
        res.status(500).json({ success: false, message: 'Server error.' });
    }
};

// Create a notification (internal utility)
exports.createNotification = async (recipientId, type, title, message, senderId = null, relatedId = null, relatedModel = null, data = null) => {
    try {
        const notification = new Notification({
            recipient: recipientId,
            sender: senderId,
            type,
            title,
            message,
            relatedId,
            relatedModel,
            data
        });

        await notification.save();
        return notification;
    } catch (error) {
        console.error('Error creating notification:', error);
        return null;
    }
};
