const express = require('express');
const router = express.Router();
const Banner = require('../models/Banner');

// GET /api/banners/active
router.get('/active', async (req, res, next) => {
    try {
        const now = new Date();
        const banners = await Banner.find({
            isActive: true,
            deletedAt: null,
            startDate: { $lte: now },
            endDate: { $gte: now }
        }).sort({ createdAt: -1 }).limit(4);

        res.json({ success: true, data: banners });
    } catch (err) {
        next(err);
    }
});

module.exports = router;
