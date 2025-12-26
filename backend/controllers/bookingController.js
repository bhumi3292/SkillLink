const bookingService = require('../services/bookingService');

exports.createBooking = async (req, res) => {
    try {
        const { workerListingId, date, timeSlot, location } = req.body;
        const hirerId = req.user._id;

        if (!workerListingId || !date || !timeSlot) {
            return res.status(400).json({ success: false, message: 'Missing required fields' });
        }

        const booking = await bookingService.createBooking(hirerId, workerListingId, date, timeSlot, location);
        return res.status(201).json({ success: true, data: booking });
    } catch (error) {
        console.error("Create Booking Error:", error);
        return res.status(400).json({ success: false, message: error.message });
    }
};

exports.updateBookingStatus = async (req, res) => {
    try {
        const { id } = req.params;
        const { status } = req.body;
        const userId = req.user._id;
        const userRole = req.user.role; // Assuming auth middleware populates this

        if (!status) {
            return res.status(400).json({ success: false, message: 'Status is required' });
        }

        const updatedBooking = await bookingService.updateBookingStatus(id, status, userId, userRole);
        return res.status(200).json({ success: true, data: updatedBooking });
    } catch (error) {
        return res.status(400).json({ success: false, message: error.message });
    }
};

exports.getUserBookings = async (req, res) => {
    try {
        const userId = req.user._id;
        const role = req.user.role;

        const bookings = await bookingService.getBookingsForUser(userId, role);
        return res.status(200).json({ success: true, data: bookings });
    } catch (error) {
        return res.status(500).json({ success: false, message: error.message });
    }
};