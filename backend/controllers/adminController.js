const User = require("../models/User");
const Review = require("../models/Review");
const Worker = require("../models/Worker");
const Category = require("../models/Category");
const Booking = require("../models/Booking");
const Report = require("../models/Report");
const Payment = require("../models/Payment");

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
        res.status(200).json({ success: true, data: workers });
    } catch (err) {
        res.status(500).json({ success: false, message: err.message });
    }
};

exports.verifyWorker = async (req, res) => {
    const { workerId, action, rejectionReason } = req.body; // action: 'approve' or 'reject'
    try {
        const status = action === "approve" ? "approved" : "rejected";
        const update = { status };
        if (action === "reject") {
            if (!rejectionReason) return res.status(400).json({ success: false, message: "Rejection reason is mandatory." });
            update.rejectionReason = rejectionReason;
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
