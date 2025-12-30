const express = require('express');
const router = express.Router();
const adminBannerController = require('../controllers/adminBannerController');
const { authenticateUser, requireRole } = require('../middlewares/auth');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

// Ensure upload folder exists
const uploadDir = path.join(__dirname, '..', 'uploads', 'banners');
if (!fs.existsSync(uploadDir)) fs.mkdirSync(uploadDir, { recursive: true });

const storage = multer.diskStorage({
    destination: function (req, file, cb) {
        cb(null, uploadDir);
    },
    filename: function (req, file, cb) {
        const ext = path.extname(file.originalname);
        cb(null, `${Date.now()}-${Math.round(Math.random() * 1e9)}${ext}`);
    }
});

const fileFilter = (req, file, cb) => {
    if (!file.mimetype.startsWith('image/')) {
        return cb(new Error('Unsupported file type!'), false);
    }
    cb(null, true);
};

const upload = multer({ storage, fileFilter, limits: { fileSize: 5 * 1024 * 1024 } });

// All routes require admin
router.post('/', authenticateUser, requireRole('admin'), upload.single('image'), adminBannerController.createBanner);
router.get('/', authenticateUser, requireRole('admin'), adminBannerController.listBanners);
router.put('/:id', authenticateUser, requireRole('admin'), upload.single('image'), adminBannerController.updateBanner);
router.delete('/:id', authenticateUser, requireRole('admin'), adminBannerController.deleteBanner);

module.exports = router;
