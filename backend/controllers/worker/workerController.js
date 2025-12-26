const fs = require('fs').promises;
const path = require('path');
const Worker = require("../../models/Worker");
const Category = require("../../models/Category");
const User = require('../../models/User');
const workerService = require('../../services/workerService');

// Helper to extract and normalize file paths from Multer's `req.files`
const extractFilePaths = (files) => {
    if (!files) return [];
    // Normalize path separators to be web-compatible (forward slashes)
    return files.map(file => file.path.replace(/\\/g, '/'));
};

// Helper to delete files from the filesystem
const deleteFiles = async (filePaths) => {
    const deletionPromises = filePaths.map(async (filePath) => {
        const fullPath = path.join(process.cwd(), filePath);
        try {
            await fs.access(fullPath);
            await fs.unlink(fullPath);
        } catch (err) {
            if (err.code !== 'ENOENT') {
                console.error(`Error deleting file ${fullPath}:`, err);
            }
        }
    });
    await Promise.all(deletionPromises);
};

// --- CREATE WORKER ---
// --- CREATE WORKER ---
exports.createWorker = async (req, res) => {
    const uploadedFilePaths = [];
    try {
        if (req.files?.images) uploadedFilePaths.push(...extractFilePaths(req.files.images));
        if (req.files?.videos) uploadedFilePaths.push(...extractFilePaths(req.files.videos));

        const filePaths = {
            images: extractFilePaths(req.files?.images),
            videos: extractFilePaths(req.files?.videos)
        };

        const worker = await workerService.createWorker(req.body, req.user._id, filePaths);

        res.status(201).json({ success: true, message: "Worker created successfully!", data: worker });
    } catch (err) {
        console.error("Create worker error:", err.message);
        if (uploadedFilePaths.length > 0) {
            await deleteFiles(uploadedFilePaths);
        }
        res.status(500).json({ success: false, message: err.message || "Server error." });
    }
};

// --- GET ALL WORKERS (with Geospatial Search) ---
// --- GET ALL WORKERS (with Geospatial Search) ---
exports.getAllWorkers = async (req, res) => {
    try {
        const { lat, long } = req.query;
        let workers;

        if (lat && long) {
            workers = await workerService.getNearestWorkers(lat, long);
        } else {
            workers = await workerService.getAllWorkers({});
        }

        res.status(200).json({
            success: true,
            message: "Workers fetched successfully.",
            data: workers,
        });
    } catch (err) {
        console.error("Get workers error:", err.message);
        res.status(500).json({ success: false, message: err.message || "Server error" });
    }
};

// --- GET SINGLE WORKER ---
// --- GET SINGLE WORKER ---
exports.getOneWorker = async (req, res) => {
    try {
        const worker = await workerService.getWorkerById(req.params.id);
        res.status(200).json({ success: true, data: worker });
    } catch (err) {
        console.error("Get worker error:", err.message);
        if (err.message === "Worker not found") {
            return res.status(404).json({ success: false, message: "Worker not found" });
        }
        res.status(500).json({ success: false, message: err.message || "Server error" });
    }
};

// --- UPDATE WORKER ---
// --- UPDATE WORKER ---
exports.updateWorker = async (req, res) => {
    const newlyUploadedFilePaths = [];
    try {
        if (req.files?.images) newlyUploadedFilePaths.push(...extractFilePaths(req.files.images));
        if (req.files?.videos) newlyUploadedFilePaths.push(...extractFilePaths(req.files.videos));

        const newFiles = {
            images: extractFilePaths(req.files?.images),
            videos: extractFilePaths(req.files?.videos)
        };

        const result = await workerService.updateWorker(req.params.id, req.user._id, req.body, newFiles);

        // Delete old files returned by service
        if (result.filesToDelete && result.filesToDelete.length > 0) {
            await deleteFiles(result.filesToDelete);
        }

        res.status(200).json({ success: true, message: "Worker updated successfully!", data: result.worker });
    } catch (err) {
        console.error("Update worker error:", err.message);
        if (newlyUploadedFilePaths.length > 0) {
            await deleteFiles(newlyUploadedFilePaths);
        }
        res.status(500).json({ success: false, message: err.message || "Server error." });
    }
};

// --- DELETE WORKER ---
// --- DELETE WORKER ---
exports.deleteWorker = async (req, res) => {
    try {
        const result = await workerService.deleteWorker(req.params.id, req.user._id);

        if (result.success && result.filesToDelete.length > 0) {
            await deleteFiles(result.filesToDelete);
        }

        res.status(200).json({ success: true, message: "Worker deleted successfully!" });
    } catch (err) {
        console.error("Delete worker error:", err.message);
        res.status(500).json({ success: false, message: err.message || "Server error." });
    }
};

// ⭐ NEW: Update Worker Availability ⭐
exports.updateAvailability = async (req, res) => {
    const userId = req.user._id;
    const { availabilityStatus } = req.body;

    try {
        if (!["Available", "Booked", "Not Available"].includes(availabilityStatus)) {
            return res.status(400).json({ success: false, message: "Invalid availability status." });
        }

        const worker = await Worker.findOneAndUpdate(
            { worker: userId },
            { availabilityStatus },
            { new: true }
        );

        if (!worker) {
            return res.status(404).json({ success: false, message: "Worker profile not found." });
        }

        res.status(200).json({
            success: true,
            message: "Availability switched to " + availabilityStatus,
            data: worker
        });
    } catch (error) {
        console.error("Error in updateAvailability:", error);
        res.status(500).json({ success: false, message: "Server error during availability update." });
    }
};

