const express = require('express');
const { authenticate } = require('../middlewares/auth');

const router = express.Router();

// NOTE: Use lazy require wrappers for route handlers to avoid potential
// circular dependency or load-order problems that can make a handler
// undefined at registration time. Each wrapper simply forwards the
// request to the controller function at request time.

router.put('/read-all', authenticate, async (req, res, next) => {
    try {
        const controller = require('../controllers/notificationController');
        return controller.markAllAsRead(req, res, next);
    } catch (err) {
        next(err);
    }
});

router.get('/', authenticate, async (req, res, next) => {
    try {
        const controller = require('../controllers/notificationController');
        return controller.getNotifications(req, res, next);
    } catch (err) {
        next(err);
    }
});

router.put('/:notificationId/read', authenticate, async (req, res, next) => {
    try {
        const controller = require('../controllers/notificationController');
        return controller.markAsRead(req, res, next);
    } catch (err) {
        next(err);
    }
});

router.delete('/:notificationId', authenticate, async (req, res, next) => {
    try {
        const controller = require('../controllers/notificationController');
        return controller.deleteNotification(req, res, next);
    } catch (err) {
        next(err);
    }
});

module.exports = router;
