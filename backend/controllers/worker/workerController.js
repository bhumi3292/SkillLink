const fs = require('fs').promises;
const path = require('path');
const Worker = require("../../models/Worker");
const Category = require("../../models/Category");
const User = require('../../models/User'); // Ensure this is needed/used or remove if not

// Helper to extract file paths from Multer's `req.files`
const extractFilePaths = (files) => {
    if (!files) return [];
    // Multer's file.path is relative to the project root where 'uploads' is.
    return files.map(file => file.path);
};

// Helper to delete files from the filesystem
const deleteFiles = async (filePaths) => {
    const deletionPromises = filePaths.map(async (filePath) => {

        const fullPath = path.join(process.cwd(), filePath);
        try {
            await fs.access(fullPath); // Check if file exists
            await fs.unlink(fullPath); // Delete the file
            console.log(`Successfully deleted file: ${fullPath}`);
        } catch (err) {
            if (err.code === 'ENOENT') {
                console.warn(`File not found, skipping deletion: ${fullPath}`);
            } else {
                console.error(`Error deleting file ${fullPath}:`, err);
            }
        }
    });
    await Promise.all(deletionPromises);
};

// --- CREATE WORKER ---
exports.createProperty = async (req, res) => {
    // Collect paths of newly uploaded files so they can be cleaned up on error
    const uploadedFilePaths = [];
    try {
        // Accept several possible field names to be tolerant of frontend variations
        const title = req.body.title || req.body.name || '';
        const description = req.body.description || req.body.desc || '';
        const location = req.body.location || req.body.address || '';
        const priceRaw = req.body.price || req.body.rate || '';
        const categoryId = req.body.categoryId || req.body.category || '';
        const bedrooms = req.body.bedrooms;
        const bathrooms = req.body.bathrooms;
        // Normalize price to a Number if possible
        const price = priceRaw === '' ? null : Number(priceRaw);

        // Add newly uploaded file paths to the cleanup array
        if (req.files?.images) uploadedFilePaths.push(...extractFilePaths(req.files.images));
        if (req.files?.videos) uploadedFilePaths.push(...extractFilePaths(req.files.videos));

        // Basic validation with improved messaging
        const missing = [];
        if (!title || title.toString().trim() === '') missing.push('title');
        if (!description || description.toString().trim() === '') missing.push('description');
        if (!location || location.toString().trim() === '') missing.push('location');
        if (price === null || Number.isNaN(price)) missing.push('price');
        if (!categoryId || categoryId.toString().trim() === '') missing.push('categoryId');

        if (missing.length > 0) {
            throw new Error(`Missing required fields: ${missing.join(', ')}.`);
        }

        // Check if category exists
        const category = await Category.findById(categoryId);
        if (!category) {
            throw new Error("Invalid category ID provided.");
        }

        // Create a new worker document (schema shared with Property for now)
        const worker = new Worker({
            title: title.toString(),
            description: description.toString(),
            location: location.toString(),
            price: price,
            categoryId,
            bedrooms: bedrooms ? Number(bedrooms) : undefined,
            bathrooms: bathrooms ? Number(bathrooms) : undefined,
            images: extractFilePaths(req.files?.images),
            videos: extractFilePaths(req.files?.videos),
            worker: req.user._id, // Assumes `req.user` is set by your authentication middleware
        });

        await worker.save();

        // Debug: log where the document was saved (model and collection)
        try {
            console.log('DEBUG: Saved worker document. model=', worker.constructor && worker.constructor.modelName, 'collection=', worker.collection && worker.collection.name, 'id=', worker._id?.toString());
        } catch (logErr) {
            console.warn('DEBUG: failed to log saved worker info', logErr);
        }

        res.status(201).json({ success: true, message: "Worker created successfully!", data: worker });
    } catch (err) {
        console.error("Create property error:", err.message);
        // Clean up uploaded files if something goes wrong before saving to DB
        if (uploadedFilePaths.length > 0) {
            await deleteFiles(uploadedFilePaths);
        }
        // Use a more specific error message if it's a validation type error
        const statusCode = err.message.includes("required fields") || err.message.includes("Invalid category") ? 400 : 500;
        res.status(statusCode).json({ success: false, message: err.message || "Server error. Failed to create property." });
    }
};

// --- GET ALL PROPERTIES --- (No changes needed)
exports.getAllProperties = async (req, res) => {
    try {
        // Debug: log model and collection info before query
        try {
            console.log('DEBUG: Worker modelName=', Worker.modelName || Worker.constructor && Worker.constructor.modelName);
            console.log('DEBUG: Worker collection=', Worker.collection && Worker.collection.name);
        } catch (dbgErr) {
            console.warn('DEBUG: failed to log Worker model/collection', dbgErr);
        }

        const workers = await Worker.find({})
            .populate("categoryId", "category_name")
            .populate("worker", "fullName email phoneNumber profilePicture");

        // Debug: log number of documents returned and sample document collection
        try {
            console.log('DEBUG: Workers fetched count=', Array.isArray(workers) ? workers.length : 0);
            if (Array.isArray(workers) && workers.length > 0) {
                const first = workers[0];
                console.log('DEBUG: first doc model=', first.constructor && first.constructor.modelName, 'collection=', first.collection && first.collection.name, 'id=', first._id?.toString());
            }
        } catch (dbgErr) {
            console.warn('DEBUG: failed to log fetched workers info', dbgErr);
        }

        res.status(200).json({ success: true, message: "Workers fetched successfully.", data: workers });
    } catch (err) {
        console.error("Get workers error:", err.message);
        res.status(500).json({ success: false, message: "Server error" });
    }
};

// --- GET SINGLE PROPERTY --- (No changes needed)
exports.getOneProperty = async (req, res) => {
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

// --- UPDATE PROPERTY --- (Improved error handling for file cleanup and validation)
exports.updateProperty = async (req, res) => {
    console.log(req.body)
    const newlyUploadedFilePaths = []; // Track files uploaded during this request for potential cleanup
    try {
        const worker = await Worker.findById(req.params.id);
        if (!worker) {
            return res.status(404).json({ success: false, message: "Worker not found." });
        }

        if (worker.worker.toString() !== req.user._id.toString()) {
            // If unauthorized, clean up any newly uploaded files
            if (req.files?.images) newlyUploadedFilePaths.push(...extractFilePaths(req.files.images));
            if (req.files?.videos) newlyUploadedFilePaths.push(...extractFilePaths(req.files.videos));
            await deleteFiles(newlyUploadedFilePaths);
            return res.status(403).json({ success: false, message: "Unauthorized access: You do not own this worker." });
        }

        const {
            title, description, location, price, bedrooms, bathrooms, categoryId,
            existingImages,
            existingVideos,
        } = req.body;

        // Add newly uploaded files to cleanup array if an error occurs later
        if (req.files?.images) newlyUploadedFilePaths.push(...extractFilePaths(req.files.images));
        if (req.files?.videos) newlyUploadedFilePaths.push(...extractFilePaths(req.files.videos));


        let existingImagesToKeep = [];
        let existingVideosToKeep = [];
        try {
            existingImagesToKeep = existingImages ? JSON.parse(existingImages) : [];
            existingVideosToKeep = existingVideos ? JSON.parse(existingVideos) : [];
        } catch (parseError) {
            console.error("Failed to parse existing files array:", parseError.message);
            await deleteFiles(newlyUploadedFilePaths); // Clean up new files on JSON parse error
            return res.status(400).json({ success: false, message: `Invalid JSON format for existing media: ${parseError.message}` });
        }

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
            title, description, location, price, bedrooms, bathrooms,
            images: updatedImages,
            videos: updatedVideos,
        };

        if (categoryId) {
            const category = await Category.findById(categoryId);
            if (!category) {
                await deleteFiles(newlyUploadedFilePaths); // Clean up new files if category ID is invalid
                return res.status(400).json({ success: false, message: "Invalid category ID." });
            }
            updateData.categoryId = categoryId; // Only set if valid category is found
        } else if (req.body.hasOwnProperty('categoryId')) { // Allow removal of categoryId if explicitly set to null/empty string
            updateData.categoryId = null;
        }


        const updatedWorker = await Worker.findByIdAndUpdate(
            req.params.id,
             updateData,
            { new: true, runValidators: true }
        );

        if (!updatedWorker) {
            // This might occur if worker was deleted by another process
            return res.status(404).json({ success: false, message: "Update failed: Worker not found or already removed." });
        }

        res.status(200).json({ success: true, message: "Worker updated successfully!", data: updatedWorker });
    } catch (err) {
        console.error("Update property error:", err.message);
        // Clean up newly uploaded files if any other error occurs during the update process
        if (newlyUploadedFilePaths.length > 0) {
            await deleteFiles(newlyUploadedFilePaths);
        }
        res.status(500).json({ success: false, message: "Server error. Failed to update property." });
    }
};

// --- DELETE PROPERTY --- (No changes needed)
exports.deleteProperty = async (req, res) => {
    try {
        const worker = await Worker.findById(req.params.id);
        if (!worker) {
            return res.status(404).json({ success: false, message: "Worker not found." });
        }

        if (worker.worker.toString() !== req.user._id.toString()) {
            return res.status(403).json({ success: false, message: "Unauthorized access: You do not own this worker." });
        }

        const allFilesToDelete = [...worker.images, ...worker.videos];

        await worker.deleteOne();

        await deleteFiles(allFilesToDelete);

        res.status(200).json({ success: true, message: "Worker deleted successfully!" });
    } catch (err) {
        console.error("Delete worker error:", err.message);
        res.status(500).json({ success: false, message: "Server error. Failed to delete worker." });
    }
};

// Provide alias exports using "Worker" naming so other parts of the codebase can
// call createWorker/getAllWorkers/getOneWorker/updateWorker/deleteWorker if needed.
exports.createWorker = exports.createProperty;
exports.getAllWorkers = exports.getAllProperties;
exports.getOneWorker = exports.getOneProperty;
exports.updateWorker = exports.updateProperty;
exports.deleteWorker = exports.deleteProperty;