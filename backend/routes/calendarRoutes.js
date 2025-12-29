// SkillLink_backend/routes/calendarRoutes.js

const express = require('express');
const router = express.Router();
const calendarController = require('../controllers/calendarController');
const { authenticateUser, requireRole } = require('../middlewares/auth'); // Your consolidated auth & role middleware

const { isOwnerOrRelatedResource } = require('../middlewares/resourceAuthMiddleware');

const Availability = require('../models/calendar');
const Booking = require('../models/Booking');


router.use(authenticateUser); // Apply authenticateUser to all routes within this router

// --- worker Calendar Routes ---


router.post('/availabilities',
    requireRole('worker'), // Ensures only users with 'worker' role can access
    calendarController.createAvailability
);

router.get('/worker/availabilities',
    requireRole('worker'),
    calendarController.getworkerAvailabilities
);


router.put('/availabilities/:id',
    requireRole('worker'),
    // Ensures the authenticated worker is the owner of this specific availability resource
    isOwnerOrRelatedResource(Availability, 'id'),
    calendarController.updateAvailability
);
router.delete('/availabilities/:id',
    requireRole('worker'),
    // Ensures the authenticated worker is the owner of this specific availability resource
    isOwnerOrRelatedResource(Availability, 'id'),
    calendarController.deleteAvailability
);

// --- Hirer Calendar Routes ---

// Updated to match rename: properties -> workers (or workerListing)
router.get('/workers/:workerListingId/available-slots',
    calendarController.getAvailableSlotsForWorkerListing
);

router.post('/book-visit',
    calendarController.bookVisit
);

router.get('/Hirer/bookings',
    requireRole('Hirer'),
    calendarController.getHirerBookings
);


// --- General Booking Management Routes (Accessible by workers primarily) ---

router.get('/worker/bookings',
    requireRole('worker'),
    calendarController.getworkerBookings
);

router.put('/bookings/:id/status',
    requireRole('worker'),
    // Ensures the authenticated worker is the owner of the workerListing associated with this booking
    isOwnerOrRelatedResource(Booking, 'id'),
    calendarController.updateBookingStatus
);


router.delete('/bookings/:id',
    isOwnerOrRelatedResource(Booking, 'id'),
    calendarController.deleteBooking
);

// Reschedule endpoints
router.post('/bookings/:id/reschedule',
    requireRole('hirer'),
    isOwnerOrRelatedResource(Booking, 'id'),
    calendarController.requestReschedule
);

router.post('/bookings/:id/reschedule/respond',
    requireRole('worker'),
    isOwnerOrRelatedResource(Booking, 'id'),
    calendarController.respondReschedule
);

module.exports = router;