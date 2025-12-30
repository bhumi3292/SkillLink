const Banner = require('../models/Banner');
const path = require('path');
const fs = require('fs');

// Create banner (image upload handled by Multer middleware before calling this)
exports.createBanner = async (req, res, next) => {
    try {
        const { title, description, ctaText, targetType, targetValue, startDate, endDate, isActive } = req.body;

        if (!title || !targetType || !startDate || !endDate) {
            return res.status(400).json({ success: false, message: 'Missing required fields.' });
        }

        const sDate = new Date(startDate);
        const eDate = new Date(endDate);
        if (isNaN(sDate) || isNaN(eDate) || sDate > eDate) {
            return res.status(400).json({ success: false, message: 'Invalid start or end date.' });
        }

        if (!req.file || !req.file.path) {
            return res.status(400).json({ success: false, message: 'Banner image is required.' });
        }

        const imageUrl = `/uploads/banners/${path.basename(req.file.path)}`;

        const banner = await Banner.create({
            title,
            description,
            imageUrl,
            ctaText,
            targetType,
            targetValue,
            startDate: sDate,
            endDate: eDate,
            isActive: isActive === 'false' || isActive === false ? false : true,
            createdBy: req.user._id
        });

        res.status(201).json({ success: true, data: banner });
    } catch (err) {
        next(err);
    }
};

// List all banners (admin)
exports.listBanners = async (req, res, next) => {
    try {
        const banners = await Banner.find({}).sort({ createdAt: -1 });
        res.json({ success: true, data: banners });
    } catch (err) {
        next(err);
    }
};

// Update banner
exports.updateBanner = async (req, res, next) => {
    try {
        const bannerId = req.params.id;
        const updates = req.body || {};

        if (updates.startDate) updates.startDate = new Date(updates.startDate);
        if (updates.endDate) updates.endDate = new Date(updates.endDate);

        if (updates.startDate && updates.endDate && updates.startDate > updates.endDate) {
            return res.status(400).json({ success: false, message: 'startDate must be before endDate.' });
        }

        const banner = await Banner.findById(bannerId);
        if (!banner) return res.status(404).json({ success: false, message: 'Banner not found.' });

        // If new file uploaded, replace imageUrl and delete old file
        if (req.file && req.file.path) {
            const oldPath = banner.imageUrl ? path.join(process.cwd(), banner.imageUrl.replace(/^\//, '')) : null;
            if (oldPath && fs.existsSync(oldPath)) {
                try { fs.unlinkSync(oldPath); } catch (e) { /* ignore */ }
            }
            updates.imageUrl = `/uploads/banners/${path.basename(req.file.path)}`;
        }

        Object.assign(banner, updates);
        await banner.save();
        res.json({ success: true, data: banner });
    } catch (err) {
        next(err);
    }
};

// Soft delete banner
exports.deleteBanner = async (req, res, next) => {
    try {
        const bannerId = req.params.id;
        const banner = await Banner.findById(bannerId);
        if (!banner) return res.status(404).json({ success: false, message: 'Banner not found.' });

        banner.deletedAt = new Date();
        banner.isActive = false;
        await banner.save();

        res.json({ success: true, message: 'Banner soft-deleted.' });
    } catch (err) {
        next(err);
    }
};
