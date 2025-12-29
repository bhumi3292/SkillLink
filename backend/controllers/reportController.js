const Report = require('../models/Report');
const User = require('../models/User');
const notificationService = require('../services/notificationService');

exports.createReport = async (req, res) => {
    try {
        const reporter = req.user._id;
        const { reportedUser, reason, evidenceChat, booking } = req.body;

        if (!reportedUser || !reason) return res.status(400).json({ success: false, message: 'reportedUser and reason are required.' });

        const report = new Report({ reporter, reportedUser, reason, evidenceChat, booking });
        await report.save();

        // Notify admins
        const admins = await User.find({ role: 'admin' }).select('_id');
        for (const a of admins) {
            await notificationService.sendNotification(a._id, 'New User Report', `A new report was submitted against a user.`, 'NEW_REPORT', report._id);
        }

        res.status(201).json({ success: true, message: 'Report submitted.', data: report });
    } catch (err) {
        console.error('Error creating report:', err);
        res.status(500).json({ success: false, message: 'Server error creating report.', error: err.message });
    }
};

module.exports = exports;
