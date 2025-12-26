const express = require('express');
const router = express.Router();
const bookingController = require('../controllers/bookingController');
const { authenticateUser } = require('../middlewares/auth');

// Protected Routes
router.use(authenticateUser);

router.post('/', bookingController.createBooking);
router.get('/', bookingController.getUserBookings);
router.patch('/:id/status', bookingController.updateBookingStatus);

module.exports = router;
