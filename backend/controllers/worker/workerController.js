const fs = require('fs').promises;
const path = require('path');
const Worker = require("../../models/Worker");
const Category = require("../../models/Category");
const User = require('../../models/User');

// Helper to extract file paths from Multer's `req.files`
const extractFilePaths = (files) => {
    if (!files) return [];
    return files.map(file => file.path);
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
exports.createWorker = async (req, res) => {
    const uploadedFilePaths = [];
    try {
        const { title, description, price, categoryId, coordinates } = req.body;

        if (req.files?.images) uploadedFilePaths.push(...extractFilePaths(req.files.images));
        if (req.files?.videos) uploadedFilePaths.push(...extractFilePaths(req.files.videos));

        if (!title || !description || !price || !categoryId || !coordinates) {
            throw new Error("Missing required fields.");
        }

        const category = await Category.findById(categoryId);
        if (!category) {
            throw new Error("Invalid category ID.");
        }

        const worker = new Worker({
            title, description, price, categoryId,
            location: {
                type: 'Point',
                coordinates: JSON.parse(coordinates),
            },
            images: extractFilePaths(req.files?.images),
            videos: extractFilePaths(req.files?.videos),
            worker: req.user._id,
        });

        await worker.save();

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
exports.getAllWorkers = async (req, res) => {
    try {
        const { lat, long } = req.query;

        let workers;

        if (lat && long) {
            const latitude = parseFloat(lat);
            const longitude = parseFloat(long);

            if (isNaN(latitude) || isNaN(longitude)) {
                return res.status(400).json({ success: false, message: "Invalid latitude or longitude." });
            }

            workers = await Worker.aggregate([
                {
                    $geoNear: {
                        near: {
                            type: "Point",
                            coordinates: [longitude, latitude]
                        },
                        distanceField: "dist.calculated",
                        spherical: true
                    }
                },
                {
                    $lookup: {
                        from: "categories",
                        localField: "categoryId",
                        foreignField: "_id",
                        as: "categoryId"
                    }
                },
                {
                    $unwind: "$categoryId"
                },
                {
                    $lookup: {
                        from: "users",
                        localField: "worker",
                        foreignField: "_id",
                        as: "worker"
                    }
                },
                {
                    $unwind: "$worker"
                }
            ]);

        } else {
            workers = await Worker.find({})
                .populate("categoryId", "category_name")
                .populate("worker", "fullName email phoneNumber profilePicture");
        }

        res.status(200).json({
            success: true,
            message: "Workers fetched successfully.",
            data: workers,
        });
    } catch (err) {
        console.error("Get workers error:", err.message);
        res.status(500).json({ success: false, message: "Server error" });
    }
};

// --- GET SINGLE WORKER ---
exports.getOneWorker = async (req, res) => {
    try {
        const worker = await Worker.findById(req.params.id)
            .populate("categoryId", "category_name")
            .populate("worker", "fullName email phoneNumber profilePicture");

        if (!worker) {
            return res.status(404).json({ success: false, message: "Worker not found" });
        }

        res.status(200).json({ success: true, data: worker });
    } catch (err) {
        console.error("Get worker error:", err.message);
        res.status(500).json({ success: false, message: "Server error" });
    }
};

// --- UPDATE WORKER ---
exports.updateWorker = async (req, res) => {
    const newlyUploadedFilePaths = [];
    try {
        const worker = await Worker.findById(req.params.id);
        if (!worker) {
            return res.status(404).json({ success: false, message: "Worker not found." });
        }

        if (worker.worker.toString() !== req.user._id.toString()) {
            if (req.files?.images) newlyUploadedFilePaths.push(...extractFilePaths(req.files.images));
            if (req.files?.videos) newlyUploadedFilePaths.push(...extractFilePaths(req.files.videos));
            await deleteFiles(newlyUploadedFilePaths);
            return res.status(403).json({ success: false, message: "Unauthorized access." });
        }

        const {
            title, description, price, categoryId, coordinates,
            existingImages, existingVideos,
        } = req.body;

        if (req.files?.images) newlyUploadedFilePaths.push(...extractFilePaths(req.files.images));
        if (req.files?.videos) newlyUploadedFilePaths.push(...extractFilePaths(req.files.videos));

        let existingImagesToKeep = existingImages ? JSON.parse(existingImages) : [];
        let existingVideosToKeep = existingVideos ? JSON.parse(existingVideos) : [];

        const filesToDelete = [];
        worker.images.forEach(oldPath => {
            if (!existingImagesToKeep.includes(oldPath)) filesToDelete.push(oldPath);
        });
        worker.videos.forEach(oldPath => {
            if (!existingVideosToKeep.includes(oldPath)) filesToDelete.push(oldPath);
        });
        await deleteFiles(filesToDelete);

        const newImages = extractFilePaths(req.files?.images);
        const newVideos = extractFilePaths(req.files?.videos);

        const updatedImages = [...existingImagesToKeep, ...newImages];
        const updatedVideos = [...existingVideosToKeep, ...newVideos];

        const updateData = {
            title, description, price,
            images: updatedImages,
            videos: updatedVideos,
        };

        if (coordinates) {
            updateData.location = {
                type: 'Point',
                coordinates: JSON.parse(coordinates),
            };
        }

        if (categoryId) {
            const category = await Category.findById(categoryId);
            if (!category) {
                await deleteFiles(newlyUploadedFilePaths);
                return res.status(400).json({ success: false, message: "Invalid category ID." });
            }
            updateData.categoryId = categoryId;
        }

        const updatedWorker = await Worker.findByIdAndUpdate(req.params.id, updateData, { new: true, runValidators: true });

        res.status(200).json({ success: true, message: "Worker updated successfully!", data: updatedWorker });
    } catch (err) {
        console.error("Update worker error:", err.message);
        if (newlyUploadedFilePaths.length > 0) {
            await deleteFiles(newlyUploadedFilePaths);
        }
        res.status(500).json({ success: false, message: "Server error." });
    }
};

// --- DELETE WORKER ---
exports.deleteWorker = async (req, res) => {
    try {
        const worker = await Worker.findById(req.params.id);
        if (!worker) {
            return res.status(404).json({ success: false, message: "Worker not found." });
        }

        if (worker.worker.toString() !== req.user._id.toString()) {
            return res.status(403).json({ success: false, message: "Unauthorized access." });
        }

        const allFilesToDelete = [...worker.images, ...worker.videos];

        await worker.deleteOne();
        await deleteFiles(allFilesToDelete);

        res.status(200).json({ success: true, message: "Worker deleted successfully!" });
    } catch (err) {
        console.error("Delete worker error:", err.message);
        res.status(500).json({ success: false, message: "Server error." });
    }
};
