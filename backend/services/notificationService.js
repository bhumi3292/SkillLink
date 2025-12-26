const Notification = require('../models/Notification');

class NotificationService {
    async sendNotification(recipientId, title, message, type, relatedId = null) {
        const notification = new Notification({
            recipient: recipientId,
            title,
            message,
            type,
            relatedId
        });

        await notification.save();

        if (global.io) {
            global.io.to(recipientId.toString()).emit('notification', notification);
        }

        return notification;
    }

    async getUserNotifications(userId) {
        return await Notification.find({ recipient: userId }).sort({ createdAt: -1 });
    }

    async markAsRead(notificationId) {
        return await Notification.findByIdAndUpdate(notificationId, { read: true }, { new: true });
    }
}

module.exports = new NotificationService();
