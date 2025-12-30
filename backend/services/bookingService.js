const Booking = require('../models/Booking');
const Worker = require('../models/Worker');
const User = require('../models/User');
const notificationService = require('./notificationService');

class BookingService {
    /**
     * Create a new booking
     * @param {string} hirerId - ID of the hirer (User)
     * @param {string} workerListingId - ID of the Worker listing
     * @param {string} date - Date of booking
     * @param {string} timeSlot - Time slot
     * @param {Object} location - Location {coordinates: [lng, lat], address: string}
     */
    async createBooking(hirerId, workerListingId, date, timeSlot, location) {
        // 1. Validate Worker Listing
        const workerListing = await Worker.findById(workerListingId);
        if (!workerListing) {
            throw new Error('Worker listing not found');
        }

        // 2. Fetch Category for Base Price
        const Category = require('../models/Category'); // Lazy load or move to top
        const category = await Category.findById(workerListing.categoryId);

        if (!category || !category.basePrice) {
            throw new Error('Booking blocked: Service base price is missing.');
        }

        // 3. Check for double booking
        const existingBooking = await Booking.findOne({
            workerListing: workerListingId,
            date: date,
            timeSlot: timeSlot,
            status: { $in: ['Pending', 'Accepted', 'InProgress'] }
        });

        if (existingBooking) {
            throw new Error('This time slot is already booked.');
        }

        // 4. Create Booking
        const booking = new Booking({
            workerListing: workerListingId,
            Hirer: hirerId,
            worker: workerListing.worker, // redundancy for easy access
            date,
            timeSlot,
            location,
            status: 'Pending',
            price: category.basePrice
        });

        await booking.save();

        // Notify Worker
        await notificationService.sendNotification(
            workerListing.worker,
            'New Booking Request',
            'You have received a new booking request.',
            'BOOKING_REQUEST',
            booking._id
        );

        return booking;
    }

    /**
     * Update Booking Status
     *Handles transitions: Pending -> Accepted/Rejected, Accepted -> InProgress, InProgress -> Completed, Completed -> Paid
     */
    async updateBookingStatus(bookingId, newStatus, userId, userRole, reason) {
        const booking = await Booking.findById(bookingId).populate('Hirer').populate('worker');
        if (!booking) {
            throw new Error('Booking not found');
        }

        const currentStatus = booking.status.toLowerCase();
        const normalizedNewStatus = newStatus.toLowerCase();

        // Map incoming status to canonical forms if needed
        let canonicalStatus = newStatus;
        if (normalizedNewStatus === 'inprogress') canonicalStatus = 'InProgress';
        if (normalizedNewStatus === 'completed') canonicalStatus = 'Completed';
        if (normalizedNewStatus === 'accepted' || normalizedNewStatus === 'confirmed') canonicalStatus = 'Accepted';
        if (normalizedNewStatus === 'rejected') canonicalStatus = 'Rejected';
        if (normalizedNewStatus === 'cancelled') canonicalStatus = 'Cancelled';
        if (normalizedNewStatus === 'paid') canonicalStatus = 'Paid';

        // Authorization & Logic
        if (userRole === 'worker') {
            // Worker transitions: Pending -> Accepted/Rejected, Accepted -> InProgress, InProgress -> Completed
            if ((currentStatus === 'pending' || currentStatus === 'Pending') &&
                (normalizedNewStatus === 'accepted' || normalizedNewStatus === 'confirmed' || normalizedNewStatus === 'rejected')) {
                // OK
            } else if ((currentStatus === 'accepted' || currentStatus === 'confirmed') && normalizedNewStatus === 'inprogress') {
                // OK
            } else if (currentStatus === 'inprogress' && normalizedNewStatus === 'completed') {
                // OK
            } else {
                throw new Error(`Worker cannot transition from ${booking.status} to ${newStatus}`);
            }
        } else if (userRole === 'hirer') {
            // Hirer transitions: Pending -> Cancelled, Completed -> Paid
            if ((currentStatus === 'pending' || currentStatus === 'Pending') && normalizedNewStatus === 'cancelled') {
                // OK
            } else if (currentStatus === 'completed' && normalizedNewStatus === 'paid') {
                // OK
            } else {
                throw new Error(`Hirer cannot transition from ${booking.status} to ${newStatus}`);
            }
        } else {
            throw new Error('Invalid Role');
        }

        // Update status using findByIdAndUpdate to avoid validation errors on unrelated fields (like workerListing)
        const updatedBooking = await Booking.findByIdAndUpdate(
            bookingId,
            { status: canonicalStatus },
            { new: true, runValidators: false }
        ).populate('Hirer').populate('worker');

        if (!updatedBooking) {
            throw new Error('Failed to update booking');
        }

        // Append timeline entry for this status change (include reason if provided)
        try {
            const timelineEntry = {
                status: canonicalStatus,
                timestamp: new Date(),
                actor: userId,
                actorRole: userRole
            };
            if (reason) timelineEntry.reason = reason;

            await Booking.findByIdAndUpdate(bookingId, {
                $push: {
                    timeline: timelineEntry
                }
            });
        } catch (e) {
            console.warn('Failed to append timeline entry:', e.message);
        }

        // --- Dual Notifications ---
        const hirerId = updatedBooking.Hirer._id || updatedBooking.Hirer;
        const workerId = updatedBooking.worker._id || updatedBooking.worker;

        if (normalizedNewStatus === 'accepted' || normalizedNewStatus === 'confirmed') {
            await notificationService.sendNotification(hirerId, 'Booking Accepted', 'Your booking has been accepted by the worker.', 'BOOKING_ACCEPTED', booking._id);
            await notificationService.sendNotification(workerId, 'Booking Update', 'You have accepted the booking.', 'BOOKING_ACCEPTED', booking._id);
        } else if (normalizedNewStatus === 'rejected') {
            const hirerMsg = reason ? `Your booking request has been rejected. Reason: ${reason}` : 'Your booking request has been rejected.';
            const workerMsg = reason ? `You rejected the booking request. Reason: ${reason}` : 'You rejected the booking request.';
            await notificationService.sendNotification(hirerId, 'Booking Rejected', hirerMsg, 'BOOKING_REJECTED', booking._id);
            await notificationService.sendNotification(workerId, 'Booking Update', workerMsg, 'BOOKING_REJECTED', booking._id);
        } else if (normalizedNewStatus === 'inprogress') {
            await notificationService.sendNotification(hirerId, 'Service Started', 'The worker has started the service. Live tracking initiated.', 'SERVICE_STARTED', booking._id);
            await notificationService.sendNotification(workerId, 'Job Started', 'You have started the work. Please navigate to the location.', 'SERVICE_STARTED', booking._id);
        } else if (normalizedNewStatus === 'completed') {
            const CompletionMsgEn = "Your service is completed. Please pay and rate the worker.";
            const CompletionMsgNp = "तपाईंको सेवा सम्पन्न भएको छ। कृपया भुक्तानी गर्नुहोस् र कामदारलाई मूल्याङ्कन गर्नुहोस्।";
            const combinedHirerMsg = `${CompletionMsgEn} / ${CompletionMsgNp}`;

            await notificationService.sendNotification(hirerId, 'Service Completed', combinedHirerMsg, 'SERVICE_COMPLETED', booking._id);
            await notificationService.sendNotification(workerId, 'Job Completed', 'You have completed the work. Waiting for payment from hirer.', 'SERVICE_COMPLETED', booking._id);
        } else if (normalizedNewStatus === 'cancelled') {
            await notificationService.sendNotification(workerId, 'Booking Cancelled', 'The hirer has cancelled the booking.', 'BOOKING_CANCELLED', booking._id);
            await notificationService.sendNotification(hirerId, 'Booking Cancelled', 'You have cancelled the booking.', 'BOOKING_CANCELLED', booking._id);
        } else if (normalizedNewStatus === 'paid') {
            await notificationService.sendNotification(workerId, 'Payment Received', 'The hirer has paid for the service.', 'PAYMENT_RECEIVED', booking._id);
            await notificationService.sendNotification(hirerId, 'Payment Successful', 'Your payment was successful. Thank you!', 'PAYMENT_SUCCESSFUL', booking._id);
        }

        return updatedBooking;
    }

    async getBookingsForUser(userId, role) {
        if (role === 'worker') {
            // Find bookings where this user is the worker
            return await Booking.find({ worker: userId }).populate('Hirer', 'fullName phoneNumber').populate('workerListing');
        } else {
            // Find bookings where this user is the hirer
            return await Booking.find({ Hirer: userId }).populate('worker', 'fullName phoneNumber').populate('workerListing');
        }
    }
}

module.exports = new BookingService();
