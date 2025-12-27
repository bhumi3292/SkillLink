// SkillLink_backend/middlewares/resourceAuthMiddleware.js

const Availability = require('../models/calendar');
const Booking = require('../models/Booking');
const Worker = require('../models/Worker');

const isOwnerOrRelatedResource = (Model, resourceIdParam) => async (req, res, next) => {
    try {
        const resourceId = req.params[resourceIdParam];
        const userId = req.user._id;

        const resource = await Model.findById(resourceId);

        if (!resource) {
            return res.status(404).json({ success: false, message: `${Model.modelName} not found.` });
        }

        // --- Authorization Logic ---

        // 1. Direct ownership (e.g. Availability.worker, Booking.worker/Hirer, Worker.worker)
        if (resource.worker && resource.worker.toString() === userId.toString()) {
            return next();
        }
        if (resource.Hirer && resource.Hirer.toString() === userId.toString()) {
            return next();
        }

        // 2. Indirect ownership via Worker Listing (e.g. Availability.workerListing -> Worker.worker)
        // Check if resource has 'workerListing' field (renamed from worker)
        if (resource.workerListing) {
            const listing = await Worker.findById(resource.workerListing);
            if (listing && listing.worker.toString() === userId.toString()) {
                return next();
            }
        }

        // 3. Fallback for potential legacy field name if not migrated everywhere yet, or if I missed one
        if (resource.worker) {
            const listing = await Worker.findById(resource.worker);
            if (listing && listing.worker.toString() === userId.toString()) {
                return next();
            }
        }


        res.status(403).json({ success: false, message: 'Access denied: You are not authorized to perform this action on this resource.' });

    } catch (error) {
        console.error('Resource Authorization middleware error:', error);
        res.status(500).json({ success: false, message: 'Server error during authorization.' });
    }
};

module.exports = {
    isOwnerOrRelatedResource
};