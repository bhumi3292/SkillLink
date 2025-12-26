const notificationService = require('../services/notificationService');

exports.getNotifications = async (req, res, next) => {
    try {
        const userId = req.user._id;
        const notifications = await notificationService.getUserNotifications(userId);
        res.status(200).json({
            success: true,
            data: notifications
        });
    } catch (error) {
        next(error);
    }
};

exports.markAsRead = async (req, res, next) => {
    try {
        const { id } = req.params;
        const notification = await notificationService.markAsRead(id);
        res.status(200).json({
            success: true,
            data: notification
        });
    } catch (error) {
        next(error);
    }
};
