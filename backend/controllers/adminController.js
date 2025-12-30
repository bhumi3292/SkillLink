const User = require("../models/User");
const Review = require("../models/Review");
const Worker = require("../models/Worker");
const Category = require("../models/Category");
const Booking = require("../models/Booking");
const Report = require("../models/Report");
const Payment = require("../models/Payment");
const axios = require('axios');

// --- DASHBOARD STATS ---
exports.getDashboardStats = async (req, res) => {
    try {
        const totalWorkers = await Worker.countDocuments();
        const pendingRequests = await Worker.countDocuments({ status: "pending" });
        const activeHirers = await User.countDocuments({ role: "hirer", isSuspended: false });
        const ongoingBookings = await Booking.countDocuments({ status: { $in: ["Pending", "Approved"] } });
        const openDisputes = await Report.countDocuments({ status: "open" });

        // Sum total amount of completed payments
        const totalPayments = await Payment.aggregate([
            { $match: { status: "Completed" } },
            { $group: { _id: null, total: { $sum: "$amount" } } }
        ]);
        const totalPaymentsAmount = totalPayments.length > 0 ? totalPayments[0].total : 0;

        res.status(200).json({
            success: true,
            data: {
                totalWorkers,
                pendingRequests,
                activeHirers,
                ongoingBookings,
                openDisputes,
                totalPaymentsAmount
            }
        });
    } catch (err) {
        res.status(500).json({ success: false, message: err.message });
    }
};

// --- WORKER VERIFICATION ---
exports.getPendingWorkers = async (req, res) => {
    try {
        const workers = await Worker.find({ status: "pending" })
            .populate("worker", "fullName email phoneNumber profilePicture")
            .populate("categoryId", "category_name");

        // Convert each mongoose doc to plain object and add helpful flags
        const out = await Promise.all(workers.map(async (w) => {
            const obj = w.toObject();

            const detectIsImageByExtension = (url) => {
                if (!url || typeof url !== 'string') return false;
                const lower = url.split('?')[0].toLowerCase();
                return lower.endsWith('.jpg') || lower.endsWith('.jpeg') || lower.endsWith('.png') || lower.endsWith('.gif') || lower.endsWith('.webp');
            };

            // Default by extension
            obj.licenseIsImage = detectIsImageByExtension(obj.licenseUrl);
            obj.identityIsImage = detectIsImageByExtension(obj.identityCardUrl);

            // If filenames suggest PDF but the stored file might actually be an image (wrong extension), try HEAD request to detect content-type
            const buildFull = (path) => {
                if (!path || typeof path !== 'string') return null;
                if (path.startsWith('http://') || path.startsWith('https://')) return path;
                const host = (typeof req.get === 'function') ? `${req.protocol}://${req.get('host')}` : (process.env.BACKEND_URL || 'http://localhost:3001');
                return `${host.replace(/\/$/, '')}/${path.replace(/^\//, '')}`;
            };

            try {
                if (obj.licenseUrl && !obj.licenseIsImage) {
                    const full = buildFull(obj.licenseUrl);
                    if (full) {
                        const head = await axios.head(full, { timeout: 3000 }).catch(() => null);
                        const ct = head?.headers?.['content-type'] || head?.headers?.['Content-Type'];
                        if (ct && typeof ct === 'string' && ct.startsWith('image/')) obj.licenseIsImage = true;
                    }
                }

                if (obj.identityCardUrl && !obj.identityIsImage) {
                    const full2 = buildFull(obj.identityCardUrl);
                    if (full2) {
                        const head2 = await axios.head(full2, { timeout: 3000 }).catch(() => null);
                        const ct2 = head2?.headers?.['content-type'] || head2?.headers?.['Content-Type'];
                        if (ct2 && typeof ct2 === 'string' && ct2.startsWith('image/')) obj.identityIsImage = true;
                    }
                }
            } catch (e) {
                // Non-fatal: keep earlier extension-based guess
            }

            // Add map link if coordinates present
            if (obj.location && Array.isArray(obj.location.coordinates) && obj.location.coordinates.length >= 2) {
                const lon = obj.location.coordinates[0];
                const lat = obj.location.coordinates[1];
                obj.locationMapLink = `https://www.google.com/maps/search/?api=1&query=${lat},${lon}`;
            }

            return obj;
        }));

        res.status(200).json({ success: true, data: out });
    } catch (err) {
        res.status(500).json({ success: false, message: err.message });
    }
};

exports.verifyWorker = async (req, res) => {
    const { workerId, action, rejectionReason } = req.body; // action: 'approve' or 'reject'
    try {
        const status = action === "approve" ? "approved" : "rejected";
        const update = { status };
        if (action === "approve") {
            update.rejectionReason = null;
            update.isActive = true;
        } else if (action === "reject") {
            if (!rejectionReason) return res.status(400).json({ success: false, message: "Rejection reason is mandatory." });
            update.rejectionReason = rejectionReason;
            update.isActive = false;
        }

        const worker = await Worker.findByIdAndUpdate(workerId, update, { new: true });
        if (!worker) return res.status(404).json({ success: false, message: "Worker not found." });

        res.status(200).json({ success: true, message: `Worker ${status} successfully.`, data: worker });
    } catch (err) {
        res.status(500).json({ success: false, message: err.message });
    }
};

// --- USER MANAGEMENT ---
exports.getAllUsers = async (req, res) => {
    try {
        const users = await User.find({ role: { $ne: "admin" } });
        res.status(200).json({ success: true, data: users });
    } catch (err) {
        res.status(500).json({ success: false, message: err.message });
    }
};

exports.toggleUserSuspension = async (req, res) => {
    const { userId } = req.params;
    try {
        const user = await User.findById(userId);
        if (!user) return res.status(404).json({ success: false, message: "User not found." });

        user.isSuspended = !user.isSuspended;
        await user.save();

        res.status(200).json({ success: true, message: `User ${user.isSuspended ? 'suspended' : 'reinstated'} successfully.`, data: user });
    } catch (err) {
        res.status(500).json({ success: false, message: err.message });
    }
};

// --- CATEGORY MANAGEMENT ---
exports.createCategory = async (req, res) => {
    try {
        const { category_name, description } = req.body;
        const category = await Category.create({ category_name, description });
        res.status(201).json({ success: true, data: category });
    } catch (err) {
        res.status(500).json({ success: false, message: err.message });
    }
};

exports.updateCategory = async (req, res) => {
    try {
        const { id } = req.params;
        const category = await Category.findByIdAndUpdate(id, req.body, { new: true });
        res.status(200).json({ success: true, data: category });
    } catch (err) {
        res.status(500).json({ success: false, message: err.message });
    }
};

exports.toggleCategoryStatus = async (req, res) => {
    try {
        const { id } = req.params;
        const category = await Category.findById(id);
        if (!category) return res.status(404).json({ success: false, message: "Category not found." });

        category.isActive = !category.isActive;
        await category.save();

        res.status(200).json({ success: true, data: category });
    } catch (err) {
        res.status(500).json({ success: false, message: err.message });
    }
};

// --- DISPUTE & REPORTING ---
exports.getReports = async (req, res) => {
    try {
        const reports = await Report.find()
            .populate("reporter", "fullName email")
            .populate("reportedUser", "fullName email")
            .populate("evidenceChat");
        res.status(200).json({ success: true, data: reports });
    } catch (err) {
        res.status(500).json({ success: false, message: err.message });
    }
};

exports.resolveReport = async (req, res) => {
    const { reportId, action } = req.body; // action: 'warning', 'suspension', 'ban', 'none'
    try {
        const report = await Report.findById(reportId);
        if (!report) return res.status(404).json({ success: false, message: "Report not found." });

        report.status = "resolved";
        report.adminActionTaken = action;
        await report.save();

        if (action === "suspension" || action === "ban") {
            await User.findByIdAndUpdate(report.reportedUser, { isSuspended: true });
        }

        res.status(200).json({ success: true, message: "Dispute resolved." });
    } catch (err) {
        res.status(500).json({ success: false, message: err.message });
    }
};

// --- BOOKINGS & PAYMENTS ---
exports.getAllBookings = async (req, res) => {
    try {
        const bookings = await Booking.find()
            .populate("Hirer", "fullName email")
            .populate("worker", "fullName email")
            .sort("-createdAt");
        res.status(200).json({ success: true, data: bookings });
    } catch (err) {
        res.status(500).json({ success: false, message: err.message });
    }
};

// --- ANALYTICS ---
exports.getAnalytics = async (req, res) => {
    try {
        // Total completed jobs
        const completedJobs = await Booking.countDocuments({ status: "Completed" });
        // Rating distribution (1-5)
        const ratingAgg = await Review.aggregate([
            { $group: { _id: "$rating", count: { $sum: 1 } } }
        ]);
        const ratingDistribution = {};
        ratingAgg.forEach(r => { ratingDistribution[r._id] = r.count; });
        // Cancellation rate (Cancelled / total bookings)
        const totalBookings = await Booking.countDocuments();
        const cancelledBookings = await Booking.countDocuments({ status: "Cancelled" });
        const cancellationRate = totalBookings > 0 ? (cancelledBookings / totalBookings) * 100 : 0;
        // Fraud flags placeholder (e.g., bookings with suspicious payment amounts)
        const fraudFlags = await Booking.find({ amount: { $gt: 10000 }, status: { $ne: "Completed" } })
            .select("_id hirer worker status amount");

        res.status(200).json({
            success: true,
            data: {
                completedJobs,
                ratingDistribution,
                cancellationRate,
                fraudFlags
            }
        });
    } catch (err) {
        res.status(500).json({ success: false, message: err.message });
    }
};
