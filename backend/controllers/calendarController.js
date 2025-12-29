// SkillLink_backend/controllers/calendarController.js

const Availability = require('../models/calendar'); // Your Availability model
const Booking = require('../models/Booking'); // Your Booking model
const Worker = require('../models/Worker'); // Your Worker model
const User = require('../models/User');

const normalizeDateString = (dateInput) => {
    const d = new Date(dateInput);
    d.setUTCHours(0, 0, 0, 0); // Normalize to UTC midnight to avoid timezone issues
    return d.toISOString().split('T')[0]; // Return as 'YYYY-MM-DD' string
};


exports.createAvailability = async (req, res) => {
    const { workerListingId, date, timeSlots } = req.body;
    const workerId = req.user._id;

    if (!workerListingId || !date || !Array.isArray(timeSlots) || timeSlots.length === 0) {
        return res.status(400).json({ success: false, message: 'Worker Listing ID, date, and at least one time slot are required.' });
    }

    try {
        const normalizedDate = normalizeDateString(date);

        const workerListing = await Worker.findOne({ _id: workerListingId, worker: workerId });
        if (!workerListing) {
            return res.status(404).json({ success: false, message: 'Worker listing not found or does not belong to you.' });
        }

        let availability = await Availability.findOne({
            worker: workerId,
            workerListing: workerListingId,
            date: new Date(normalizedDate) // Query using Date object as stored in DB
        });

        if (availability) {
            // When updating, ensure we don't add slots that are currently booked
            const existingBookedSlots = await Booking.find({
                workerListing: workerListingId,
                date: normalizedDate, // Query using string as stored in Booking
                status: { $in: ['pending', 'confirmed'] }
            }).select('timeSlot -_id');
            const bookedTimeSlotSet = new Set(existingBookedSlots.map(b => b.timeSlot));

            let newSlotsToSave = new Set(availability.timeSlots); // Start with existing slots
            timeSlots.forEach(slot => {
                if (!bookedTimeSlotSet.has(slot)) { // Only add new slots if they aren't currently booked
                    newSlotsToSave.add(slot);
                }
            });

            availability.timeSlots = Array.from(newSlotsToSave).sort((a, b) => a.localeCompare(b)); // Sort alphabetically
            await availability.save();
            return res.status(200).json({ success: true, message: 'Availability updated successfully.', availability: availability.toObject() });
        } else {
            // When creating new availability, filter out any slots that might already be booked
            const existingBookedSlots = await Booking.find({
                workerListing: workerListingId,
                date: normalizedDate,
                status: { $in: ['pending', 'confirmed', 'Pending', 'Accepted', 'InProgress'] }
            }).select('timeSlot -_id');
            const bookedTimeSlotSet = new Set(existingBookedSlots.map(b => b.timeSlot));

            const initialTimeSlots = timeSlots.filter(slot => !bookedTimeSlotSet.has(slot)).sort((a, b) => a.localeCompare(b));

            if (initialTimeSlots.length === 0 && timeSlots.length > 0) {
                return res.status(400).json({ success: false, message: 'All provided time slots are already booked or invalid.' });
            }

            availability = new Availability({
                worker: workerId,
                workerListing: workerListingId,
                date: new Date(normalizedDate), // Store as Date object in DB
                timeSlots: initialTimeSlots
            });
            await availability.save();
            return res.status(201).json({ success: true, message: 'Availability created successfully.', availability: availability.toObject() });
        }
    } catch (error) {
        console.error('Error in createAvailability:', error);
        if (error.code === 11000) { // MongoDB duplicate key error (if compound unique index on Availability is hit)
            return res.status(409).json({ success: false, message: 'Availability for this listing and date already exists. Please update it instead.' });
        }
        res.status(500).json({ success: false, message: 'Server error creating or updating availability.', error: error.message });
    }
};

// @desc    Get all availability entries for the authenticated worker
// @route   GET /api/calendar/worker/availabilities
// @access  Private (worker)
exports.getworkerAvailabilities = async (req, res) => {
    const workerId = req.user._id;

    try {
        const availabilities = await Availability.find({ worker: workerId })
            .populate('workerListing', 'title location images')
            .sort({ date: 1, 'timeSlots': 1 }); // Sort by date and then time slots (lexicographically)

        // For consistency, convert date back to 'YYYY-MM-DD' string for frontend
        const formattedAvailabilities = availabilities.map(avail => ({
            ...avail.toObject(),
            date: normalizeDateString(avail.date), // Convert Date object back to string
            timeSlots: avail.timeSlots.sort((a, b) => a.localeCompare(b)) // Ensure sorted
        }));

        res.status(200).json({ success: true, availabilities: formattedAvailabilities });
    } catch (error) {
        console.error('Error in getworkerAvailabilities:', error);
        res.status(500).json({ success: false, message: 'Server error fetching worker availabilities.', error: error.message });
    }
};

// @desc    worker updates time slots for an existing availability entry.
// @route   PUT /api/calendar/availabilities/:id
// @access  Private (worker, and authorized by isOwnerOrRelatedResource middleware)
exports.updateAvailability = async (req, res) => {
    const { id } = req.params;
    const { timeSlots } = req.body;
    const workerId = req.user._id;

    if (!Array.isArray(timeSlots)) {
        return res.status(400).json({ success: false, message: 'Time slots must be an array.' });
    }

    try {
        const availability = await Availability.findById(id);
        if (!availability || availability.worker.toString() !== workerId.toString()) {
            return res.status(404).json({ success: false, message: 'Availability not found or does not belong to you.' });
        }

        const normalizedDate = normalizeDateString(availability.date);

        // Determine which slots are being removed
        const newTimeSlotsSet = new Set(timeSlots);
        const removedSlots = availability.timeSlots.filter(slot => !newTimeSlotsSet.has(slot));

        if (removedSlots.length > 0) {
            // Check for existing active bookings for the slots being removed
            const existingBookings = await Booking.countDocuments({
                workerListing: availability.workerListing,
                date: normalizedDate, // Query using normalized date string
                timeSlot: { $in: removedSlots },
                status: { $in: ['pending', 'confirmed'] }
            });

            if (existingBookings > 0) {
                return res.status(400).json({
                    success: false,
                    message: 'Cannot remove time slot(s) that already have pending or confirmed bookings.'
                });
            }
        }

        availability.timeSlots = Array.from(newTimeSlotsSet).sort((a, b) => a.localeCompare(b)); // Filter unique and sort
        await availability.save();

        res.status(200).json({ success: true, message: 'Availability updated successfully.', availability: availability.toObject() });
    } catch (error) {
        console.error('Error in updateAvailability:', error);
        res.status(500).json({ success: false, message: 'Server error updating availability.', error: error.message });
    }
};


exports.deleteAvailability = async (req, res) => {
    const { id } = req.params;
    const workerId = req.user._id;

    try {
        const availability = await Availability.findById(id);
        if (!availability || availability.worker.toString() !== workerId.toString()) {
            return res.status(404).json({ success: false, message: 'Availability not found or does not belong to you.' });
        }

        const normalizedDate = normalizeDateString(availability.date);

        // Check for existing active bookings for any slot on this date
        const existingBookings = await Booking.countDocuments({
            workerListing: availability.workerListing,
            date: normalizedDate, // Query using normalized date string
            status: { $in: ['pending', 'confirmed'] }
        });

        if (existingBookings > 0) {
            return res.status(400).json({
                success: false,
                message: 'Cannot delete availability because there are existing pending or confirmed bookings for this date. Please cancel bookings first.'
            });
        }

        await availability.deleteOne();
        res.status(200).json({ success: true, message: 'Availability deleted successfully.' });
    } catch (error) {
        console.error('Error in deleteAvailability:', error);
        res.status(500).json({ success: false, message: 'Server error deleting availability.', error: error.message });
    }
};

// --- Hirer Specific Controller Functions ---

exports.getAvailableSlotsForWorkerListing = async (req, res) => {
    const { workerListingId } = req.params;
    const { date } = req.query;

    if (!date) {
        return res.status(400).json({ success: false, message: 'Date is required to find available slots.' });
    }

    try {
        const normalizedDate = normalizeDateString(date);

        const availability = await Availability.findOne({
            workerListing: workerListingId,
            date: new Date(normalizedDate) // Query using Date object
        });

        if (!availability || availability.timeSlots.length === 0) {
            return res.status(200).json({ success: true, availableSlots: [], message: 'No availability found for this date.' });
        }

        // Find all active bookings for this listing and date
        const bookedSlots = await Booking.find({
            workerListing: workerListingId,
            date: normalizedDate, // Query using normalized date string
            status: { $in: ['pending', 'confirmed'] }
        }).select('timeSlot -_id');

        const bookedTimeSlots = new Set(bookedSlots.map(booking => booking.timeSlot));

        // Filter out booked slots
        const trulyAvailableSlots = availability.timeSlots.filter(
            slot => !bookedTimeSlots.has(slot)
        ).sort((a, b) => a.localeCompare(b)); // Sort for consistent order

        res.status(200).json({
            success: true,
            date: normalizedDate, // Return as string
            availableSlots: trulyAvailableSlots,
            workerListing: workerListingId
        });

    } catch (error) {
        console.error('Error in getAvailableSlotsForWorkerListing:', error);
        res.status(500).json({ success: false, message: 'Server error fetching available slots.', error: error.message });
    }
};

// @desc    Book a visit for a worker listing
// @route   POST /api/calendar/book-visit
// @access  Private (Hirer)
exports.bookVisit = async (req, res) => {
    const { workerListingId, date, timeSlot } = req.body;
    const HirerId = req.user._id;

    if (!workerListingId || !date || !timeSlot) {
        return res.status(400).json({ success: false, message: 'Worker Listing ID, date, and time slot are required.' });
    }

    try {
        const normalizedDate = normalizeDateString(date);

        // 1. Verify availability and get worker ID from Availability
        const availability = await Availability.findOne({
            workerListing: workerListingId,
            date: new Date(normalizedDate), // Query with Date object
            timeSlots: timeSlot // Check if the specific time slot is in the array
        });

        if (!availability) {
            return res.status(400).json({ success: false, message: 'The requested time slot is not available or does not exist on the worker\'s schedule.' });
        }
        const workerId = availability.worker; // Get worker from availability

        // 2. Check if the slot is already booked (pending, confirmed, or accepted)
        const existingActiveBooking = await Booking.findOne({
            workerListing: workerListingId,
            date: normalizedDate,
            timeSlot: timeSlot,
            status: { $in: ['pending', 'confirmed', 'Pending', 'Accepted'] }
        });

        if (existingActiveBooking) {
            return res.status(409).json({ success: false, message: 'This time slot is already booked. Please choose another.' });
        }

        // 3. Prevent Hirer from booking the same listing at the same time
        const HirerExistingBooking = await Booking.findOne({
            Hirer: HirerId,
            workerListing: workerListingId,
            date: normalizedDate,
            timeSlot: timeSlot,
            status: { $in: ['pending', 'confirmed', 'Pending', 'Accepted'] }
        });
        if (HirerExistingBooking) {
            return res.status(409).json({ success: false, message: 'You already have an active booking for this specific time slot.' });
        }

        // 4. Create the new booking
        const newBooking = new Booking({
            Hirer: HirerId,
            worker: workerId, // Assign worker ID from availability (the provider)
            workerListing: workerListingId,
            date: normalizedDate, // Store as string
            timeSlot: timeSlot,
            status: 'Pending' // Standardized to capital P
        });

        await newBooking.save();

        // 5. ⭐ IMPORTANT: Remove the booked time slot from the availability ⭐
        availability.timeSlots = availability.timeSlots.filter(slot => slot !== timeSlot);
        await availability.save();

        // 6. Notify Worker and Hirer
        const notificationService = require('../services/notificationService');
        await notificationService.sendNotification(
            workerId,
            'New Booking Request',
            `You have a new booking request for ${timeSlot} on ${normalizedDate}.`,
            'BOOKING_REQUEST',
            newBooking._id
        );
        await notificationService.sendNotification(
            HirerId,
            'Booking Sent',
            'Your booking request has been sent to the worker.',
            'BOOKING_SENT',
            newBooking._id
        );

        res.status(201).json({ success: true, message: 'Visit booked successfully! Awaiting worker confirmation.', booking: newBooking.toObject() });

    } catch (error) {
        console.error('Error in bookVisit:', error);
        if (error.code === 11000) { // MongoDB duplicate key error
            return res.status(409).json({ success: false, message: 'You already have an active booking for this specific time slot.' });
        }
        res.status(500).json({ success: false, message: 'Server error booking visit.', error: error.message });
    }
};


exports.getHirerBookings = async (req, res) => {
    const HirerId = req.user._id;

    try {
        const bookings = await Booking.find({ Hirer: HirerId })
            .populate('workerListing', 'title location images')
            .populate('worker', 'fullName email phoneNumber') // Populate worker (provider) details
            .sort({ date: 1, timeSlot: 1 });

        // Ensure date is returned as YYYY-MM-DD string
        const formattedBookings = bookings.map(booking => ({
            ...booking.toObject(),
            date: normalizeDateString(booking.date),
        }));

        res.status(200).json({ success: true, bookings: formattedBookings });
    } catch (error) {
        console.error('Error in getHirerBookings:', error);
        res.status(500).json({ success: false, message: 'Server error fetching Hirer bookings.', error: error.message });
    }
};

// --- Shared/worker Management Controller Functions for Bookings ---

// @desc    Get all bookings for the authenticated worker's listings
// @route   GET /api/calendar/worker/bookings
// @access  Private (worker)
exports.getworkerBookings = async (req, res) => {
    const userId = req.user._id;

    try {
        const bookings = await Booking.find({
            $or: [
                { worker: userId },
                { Hirer: userId }
            ]
        })
            .populate('Hirer', 'fullName email phoneNumber') // Populate Hirer details
            .populate('workerListing', 'title location images')
            .sort({ date: 1, timeSlot: 1 });

        // Ensure date is returned as YYYY-MM-DD string
        const formattedBookings = bookings.map(booking => ({
            ...booking.toObject(),
            date: normalizeDateString(booking.date),
        }));

        res.status(200).json({ success: true, bookings: formattedBookings });
    } catch (error) {
        console.error('Error in getworkerBookings:', error);
        res.status(500).json({ success: false, message: 'Server error fetching worker bookings.', error: error.message });
    }
};

exports.updateBookingStatus = async (req, res) => {
    const { id } = req.params;
    const { status, reason } = req.body;
    const workerId = req.user._id;

    // Frontend uses 'Confirmed', 'Rejected', 'Cancelled', 'InProgress', 'Completed'
    const validStatuses = ['pending', 'confirmed', 'accepted', 'rejected', 'cancelled', 'inprogress', 'completed'];
    const newStatus = status.toLowerCase();

    if (!validStatuses.includes(newStatus)) {
        return res.status(400).json({ success: false, message: 'Invalid booking status provided.' });
    }

    try {
        const booking = await Booking.findById(id).populate('workerListing');
        if (!booking || booking.worker.toString() !== workerId.toString()) {
            return res.status(404).json({ success: false, message: 'Booking not found or does not belong to your listings.' });
        }

        // Prevent reverting status from confirmed/rejected/cancelled back to pending
        if (booking.status === 'confirmed' && newStatus === 'pending') {
            return res.status(400).json({ success: false, message: 'Cannot revert confirmed booking to pending.' });
        }
        if ((booking.status === 'rejected' || booking.status === 'cancelled') && newStatus === 'pending') {
            return res.status(400).json({ success: false, message: 'Cannot revert cancelled/rejected booking to pending.' });
        }

        const oldStatus = booking.status;
        booking.status = newStatus;
        // Push a timeline entry recording this status change (include reason if provided)
        if (!booking.timeline) booking.timeline = [];
        const entry = { status: newStatus, timestamp: new Date(), actor: workerId, actorRole: req.user.role || 'worker' };
        if (reason) entry.reason = reason;
        booking.timeline.push(entry);
        if ((newStatus === 'rejected' || newStatus === 'cancelled') &&
            (oldStatus === 'pending' || oldStatus === 'confirmed')) {
            // Slot needs to be freed up
            const normalizedDate = normalizeDateString(booking.date);
            const availability = await Availability.findOne({
                workerListing: booking.workerListing,
                date: new Date(normalizedDate) // Query with Date object
            });

            if (availability) {
                // Only add if it's not already in timeSlots to prevent duplicates
                if (!availability.timeSlots.includes(booking.timeSlot)) {
                    availability.timeSlots.push(booking.timeSlot);
                    availability.timeSlots.sort((a, b) => a.localeCompare(b)); // Keep sorted
                    await availability.save();
                    console.log(`Slot ${booking.timeSlot} re-added to availability for listing ${booking.workerListing.title} on ${normalizedDate}.`);
                }
            } else {
                console.warn(`Availability for listing ${booking.workerListing._id} on ${normalizedDate} not found when updating booking status to ${newStatus}. Slot not re-added.`);
            }
        }

        // If rejected, notify hirer including reason
        if (newStatus === 'rejected') {
            try {
                const notificationService = require('../services/notificationService');
                const hirerId = booking.Hirer || booking.hirer || booking.hirerId;
                const msg = reason ? `Your booking request has been rejected. Reason: ${reason}` : 'Your booking request has been rejected.';
                await notificationService.sendNotification(hirerId, 'Booking Rejected', msg, 'BOOKING_REJECTED', booking._id);
            } catch (e) {
                console.warn('Failed to send rejection notification with reason:', e.message);
            }
        }

        await booking.save();

        res.status(200).json({ success: true, message: `Booking status updated to ${newStatus}.`, booking: booking.toObject() });
    } catch (error) {
        console.error('Error in updateBookingStatus:', error);
        res.status(500).json({ success: false, message: 'Server error updating booking status.', error: error.message });
    }
};

exports.deleteBooking = async (req, res) => {
    const { id } = req.params;
    const userId = req.user._id;

    try {
        const booking = await Booking.findById(id).populate('workerListing');

        if (!booking) {
            return res.status(404).json({ success: false, message: 'Booking not found.' });
        }

        if (booking.Hirer.toString() !== userId.toString() && booking.worker.toString() !== userId.toString()) {
            return res.status(403).json({ success: false, message: 'Access denied: You are not authorized to cancel this booking.' });
        }

        const oldStatus = booking.status;

        if (oldStatus === 'completed' || oldStatus === 'rejected' || oldStatus === 'cancelled') {
            return res.status(400).json({ success: false, message: `Booking cannot be cancelled from '${oldStatus}' status.` });
        }

        // Accept optional/mandatory reason from body when hirer cancels
        const { reason } = req.body;
        if (req.user.role === 'hirer' && !reason) {
            return res.status(400).json({ success: false, message: 'Cancellation reason is required when cancelled by hirer.' });
        }

        booking.status = 'cancelled'; // Set status to cancelled
        if (req.user.role === 'hirer') booking.cancellationReason = reason;
        if (!booking.timeline) booking.timeline = [];
        booking.timeline.push({ status: 'cancelled', timestamp: new Date(), actor: userId, actorRole: req.user.role || 'hirer', reason: reason || '' });
        await booking.save();

        if (oldStatus === 'pending' || oldStatus === 'confirmed') {
            const normalizedDate = normalizeDateString(booking.date);
            const availability = await Availability.findOne({
                workerListing: booking.workerListing._id,
                date: new Date(normalizedDate)
            });

            if (availability) {
                if (!availability.timeSlots.includes(booking.timeSlot)) {
                    availability.timeSlots.push(booking.timeSlot);
                    availability.timeSlots.sort((a, b) => a.localeCompare(b));
                    await availability.save();
                    console.log(`Slot ${booking.timeSlot} re-added availability.`);
                }
            }
        }

        res.status(200).json({ success: true, message: 'Booking cancelled successfully.' });

    } catch (error) {
        console.error('Error in deleteBooking:', error);
        res.status(500).json({ success: false, message: 'Server error cancelling booking.', error: error.message });
    }
};

// Hirer requests reschedule for a booking
exports.requestReschedule = async (req, res) => {
    const { id } = req.params; // booking id
    const { requestedDate, requestedTimeSlot } = req.body;
    const hirerId = req.user._id;

    if (!requestedDate || !requestedTimeSlot) {
        return res.status(400).json({ success: false, message: 'Requested date and time slot are required.' });
    }

    try {
        const booking = await Booking.findById(id).populate('workerListing');
        if (!booking) return res.status(404).json({ success: false, message: 'Booking not found.' });
        if (booking.Hirer.toString() !== hirerId.toString()) return res.status(403).json({ success: false, message: 'Not authorized.' });

        // Append reschedule request
        booking.rescheduleRequests = booking.rescheduleRequests || [];
        booking.rescheduleRequests.push({ requestedDate, requestedTimeSlot, requestedAt: new Date(), status: 'pending' });

        // Add timeline entry
        booking.timeline = booking.timeline || [];
        booking.timeline.push({ status: 'reschedule_requested', timestamp: new Date(), actor: hirerId, actorRole: req.user.role || 'hirer', reason: `${requestedDate} ${requestedTimeSlot}` });

        await booking.save();

        // Notify worker
        const notificationService = require('../services/notificationService');
        await notificationService.sendNotification(booking.worker, 'Reschedule Requested', `Hirer requested reschedule to ${requestedDate} ${requestedTimeSlot}`, 'RESCHEDULE_REQUEST', booking._id);

        res.status(200).json({ success: true, message: 'Reschedule request submitted.', booking: booking.toObject() });
    } catch (error) {
        console.error('Error in requestReschedule:', error);
        res.status(500).json({ success: false, message: 'Server error requesting reschedule.', error: error.message });
    }
};

// Worker responds to a reschedule request
exports.respondReschedule = async (req, res) => {
    const { id } = req.params; // booking id
    const { requestIndex, action, reason } = req.body; // action: 'accept' or 'reject'
    const workerId = req.user._id;

    if (!action || !['accept','reject'].includes(action)) return res.status(400).json({ success: false, message: 'Invalid action.' });

    try {
        const booking = await Booking.findById(id);
        if (!booking) return res.status(404).json({ success: false, message: 'Booking not found.' });
        if (booking.worker.toString() !== workerId.toString()) return res.status(403).json({ success: false, message: 'Not authorized.' });

        const idx = (typeof requestIndex === 'number') ? requestIndex : (booking.rescheduleRequests ? booking.rescheduleRequests.length -1 : -1);
        if (idx < 0 || !booking.rescheduleRequests || !booking.rescheduleRequests[idx]) return res.status(404).json({ success: false, message: 'Reschedule request not found.' });

        const reqItem = booking.rescheduleRequests[idx];
        if (reqItem.status !== 'pending') return res.status(400).json({ success: false, message: 'This request has already been responded to.' });

        if (action === 'reject') {
            reqItem.status = 'rejected';
            reqItem.workerResponseReason = reason || '';
            reqItem.respondedAt = new Date();
            booking.timeline = booking.timeline || [];
            booking.timeline.push({ status: 'reschedule_rejected', timestamp: new Date(), actor: workerId, actorRole: req.user.role || 'worker', reason: reason || '' });

            await booking.save();

            // Notify hirer
            const notificationService = require('../services/notificationService');
            await notificationService.sendNotification(booking.Hirer, 'Reschedule Rejected', `Worker rejected reschedule: ${reason || 'No reason provided'}`, 'RESCHEDULE_REJECTED', booking._id);

            return res.status(200).json({ success: true, message: 'Reschedule request rejected.', booking: booking.toObject() });
        }

        // action === 'accept'
        // Validate availability for requested slot
        const normalizedDate = normalizeDateString(reqItem.requestedDate);
        const Availability = require('../models/calendar');
        const availability = await Availability.findOne({ workerListing: booking.workerListing, date: new Date(normalizedDate) });
        // If availability exists and has the requested slot, remove it
        if (availability && availability.timeSlots.includes(reqItem.requestedTimeSlot)) {
            // Check for conflicting bookings
            const existingActiveBooking = await Booking.findOne({ workerListing: booking.workerListing, date: normalizedDate, timeSlot: reqItem.requestedTimeSlot, status: { $in: ['pending','confirmed','Accepted','InProgress'] } });
            if (existingActiveBooking) {
                return res.status(409).json({ success: false, message: 'Requested time slot is already booked.' });
            }

            // Update booking date/time
            booking.date = normalizedDate;
            booking.timeSlot = reqItem.requestedTimeSlot;
            reqItem.status = 'accepted';
            reqItem.respondedAt = new Date();
            booking.timeline = booking.timeline || [];
            booking.timeline.push({ status: 'reschedule_accepted', timestamp: new Date(), actor: workerId, actorRole: req.user.role || 'worker', reason: `${reqItem.requestedDate} ${reqItem.requestedTimeSlot}` });

            // Remove the slot from availability
            availability.timeSlots = availability.timeSlots.filter(s => s !== reqItem.requestedTimeSlot);
            await availability.save();

            await booking.save();

            const notificationService = require('../services/notificationService');
            await notificationService.sendNotification(booking.Hirer, 'Reschedule Accepted', `Worker accepted reschedule to ${reqItem.requestedDate} ${reqItem.requestedTimeSlot}`, 'RESCHEDULE_ACCEPTED', booking._id);

            return res.status(200).json({ success: true, message: 'Reschedule accepted and booking updated.', booking: booking.toObject() });
        } else {
            // If no availability object, still allow accepting but ensure no conflicting bookings
            const existingActiveBooking = await Booking.findOne({ workerListing: booking.workerListing, date: reqItem.requestedDate, timeSlot: reqItem.requestedTimeSlot, status: { $in: ['pending','confirmed','Accepted','InProgress'] } });
            if (existingActiveBooking) {
                return res.status(409).json({ success: false, message: 'Requested time slot is already booked.' });
            }

            booking.date = reqItem.requestedDate;
            booking.timeSlot = reqItem.requestedTimeSlot;
            reqItem.status = 'accepted';
            reqItem.respondedAt = new Date();
            booking.timeline = booking.timeline || [];
            booking.timeline.push({ status: 'reschedule_accepted', timestamp: new Date(), actor: workerId, actorRole: req.user.role || 'worker', reason: `${reqItem.requestedDate} ${reqItem.requestedTimeSlot}` });
            await booking.save();

            const notificationService = require('../services/notificationService');
            await notificationService.sendNotification(booking.Hirer, 'Reschedule Accepted', `Worker accepted reschedule to ${reqItem.requestedDate} ${reqItem.requestedTimeSlot}`, 'RESCHEDULE_ACCEPTED', booking._id);

            return res.status(200).json({ success: true, message: 'Reschedule accepted and booking updated.', booking: booking.toObject() });
        }

    } catch (error) {
        console.error('Error in respondReschedule:', error);
        res.status(500).json({ success: false, message: 'Server error responding to reschedule.', error: error.message });
    }
};