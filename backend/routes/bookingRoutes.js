const express = require('express');
const router = express.Router();
const bookingController = require('../controllers/bookingController');
const calendarController = require('../controllers/calendarController');
const { authenticateUser } = require('../middlewares/auth');

// Protected Routes
router.use(authenticateUser);

router.post('/', bookingController.createBooking);
router.get('/', bookingController.getUserBookings);
router.patch('/:id/status', bookingController.updateBookingStatus);

// Allow deletion/cancellation via the bookings api as well (used by mobile client).
router.delete('/:id', calendarController.deleteBooking);

module.exports = router;
