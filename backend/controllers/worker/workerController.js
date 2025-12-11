const fs = require('fs').promises;
const path = require('path');
const Property = require("../../models/Property");
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

// --- CREATE PROPERTY ---
exports.createProperty = async (req, res) => {
    // Collect paths of newly uploaded files so they can be cleaned up on error
    const uploadedFilePaths = [];
    try {
        const { title, description, location, price, categoryId, bedrooms, bathrooms } = req.body;

        // Add newly uploaded file paths to the cleanup array
        if (req.files?.images) uploadedFilePaths.push(...extractFilePaths(req.files.images));
        if (req.files?.videos) uploadedFilePaths.push(...extractFilePaths(req.files.videos));

        // Basic validation
        if (!title || !description || !location || !price || !categoryId) {
            throw new Error("Missing required fields: title, description, location, price, categoryId.");
        }

        // Check if category exists
        const category = await Category.findById(categoryId);
        if (!category) {
            throw new Error("Invalid category ID provided.");
        }

        // Create a new property document
        const property = new Property({
            title, description, location, price, categoryId, bedrooms, bathrooms,
            images: extractFilePaths(req.files?.images),
            videos: extractFilePaths(req.files?.videos),
            worker: req.user._id, // Assumes `req.user` is set by your authentication middleware
        });

        await property.save();

        res.status(201).json({ success: true, message: "Property created successfully!", data: property });
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
        const properties = await Property.find({})
            .populate("categoryId", "category_name")
            .populate("worker", "fullName email phoneNumber profilePicture");

        res.status(200).json({
            success: true,
            message: "Properties fetched successfully.",
            data: properties,
        });
    } catch (err) {
        console.error("Get properties error:", err.message);
        res.status(500).json({ success: false, message: "Server error" });
    }
};

// --- GET SINGLE PROPERTY --- (No changes needed)
exports.getOneProperty = async (req, res) => {
    try {
        const property = await Property.findById(req.params.id)
            .populate("categoryId", "category_name")
            .populate("worker", "fullName email phoneNumber profilePicture");

        if (!property) {
            return res.status(404).json({ success: false, message: "Property not found" });
        }

        res.status(200).json({ success: true, data: property });
    } catch (err) {
        console.error("Get property error:", err.message);
        res.status(500).json({ success: false, message: "Server error" });
    }
};

// --- UPDATE PROPERTY --- (Improved error handling for file cleanup and validation)
exports.updateProperty = async (req, res) => {
    console.log(req.body)
    const newlyUploadedFilePaths = []; // Track files uploaded during this request for potential cleanup
    try {
        const property = await Property.findById(req.params.id);
        if (!property) {
            return res.status(404).json({ success: false, message: "Property not found." });
        }

        if (property.worker.toString() !== req.user._id.toString()) {
            // If unauthorized, clean up any newly uploaded files
            if (req.files?.images) newlyUploadedFilePaths.push(...extractFilePaths(req.files.images));
            if (req.files?.videos) newlyUploadedFilePaths.push(...extractFilePaths(req.files.videos));
            await deleteFiles(newlyUploadedFilePaths);
            return res.status(403).json({ success: false, message: "Unauthorized access: You do not own this property." });
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
        property.images.forEach(oldPath => {
            if (!existingImagesToKeep.includes(oldPath)) filesToDelete.push(oldPath);
        });
        property.videos.forEach(oldPath => {
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


        const updatedProperty = await Property.findByIdAndUpdate(
            req.params.id,
             updateData,
            { new: true, runValidators: true }
        );

        if (!updatedProperty) {
            // This might occur if property was deleted by another process
            return res.status(404).json({ success: false, message: "Update failed: Property not found or already removed." });
        }

        res.status(200).json({ success: true, message: "Property updated successfully!", data: updatedProperty });
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
        const property = await Property.findById(req.params.id);
        if (!property) {
            return res.status(404).json({ success: false, message: "Property not found." });
        }

        if (property.worker.toString() !== req.user._id.toString()) {
            return res.status(403).json({ success: false, message: "Unauthorized access: You do not own this property." });
        }

        const allFilesToDelete = [...property.images, ...property.videos];

        await property.deleteOne();

        await deleteFiles(allFilesToDelete);

        res.status(200).json({ success: true, message: "Property deleted successfully!" });
    } catch (err) {
        console.error("Delete property error:", err.message);
        res.status(500).json({ success: false, message: "Server error. Failed to delete property." });
    }
};