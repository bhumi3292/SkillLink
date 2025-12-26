const Worker = require('../models/Worker');
const Category = require('../models/Category');
const mongoose = require('mongoose');

class WorkerService {
    async createWorker(workerData, userId, filePaths) {
        const { title, description, minPrice, maxPrice, price, categoryId, coordinates } = workerData;

        // Use min/max if available, otherwise fallback to price for backward compatibility if model allows
        // Assuming model has minPrice/maxPrice per previous edits

        const category = await Category.findById(categoryId);
        if (!category) {
            throw new Error("Invalid category ID.");
        }

        const worker = new Worker({
            title,
            description,
            minPrice: minPrice || price, // Fallback
            maxPrice: maxPrice || price, // Fallback
            categoryId,
            location: {
                type: 'Point',
                coordinates: JSON.parse(coordinates),
            },
            images: filePaths.images || [],
            videos: filePaths.videos || [],
            worker: userId,
        });

        await worker.save();
        return worker;
    }

    // ... (getNearestWorkers and getAllWorkers remain same, or I can just append below them)

    async updateWorker(workerId, userId, updateData, newFiles) {
        const worker = await Worker.findById(workerId);
        if (!worker) {
            throw new Error("Worker not found.");
        }

        if (worker.worker.toString() !== userId.toString()) {
            throw new Error("Unauthorized access.");
        }

        const {
            title, description, minPrice, maxPrice, categoryId, coordinates,
            existingImages, existingVideos
        } = updateData;

        // Handle File Logic
        let existingImagesToKeep = existingImages ? JSON.parse(existingImages) : [];
        let existingVideosToKeep = existingVideos ? JSON.parse(existingVideos) : [];
        if (!Array.isArray(existingImagesToKeep)) existingImagesToKeep = [existingImagesToKeep];
        if (!Array.isArray(existingVideosToKeep)) existingVideosToKeep = [existingVideosToKeep];

        const filesToDelete = [];
        worker.images.forEach(oldPath => {
            if (!existingImagesToKeep.includes(oldPath)) filesToDelete.push(oldPath);
        });
        worker.videos.forEach(oldPath => {
            if (!existingVideosToKeep.includes(oldPath)) filesToDelete.push(oldPath);
        });

        const newImages = newFiles.images || [];
        const newVideos = newFiles.videos || [];

        const updatedImages = [...existingImagesToKeep, ...newImages];
        const updatedVideos = [...existingVideosToKeep, ...newVideos];

        const dataToUpdate = {
            title, description, minPrice, maxPrice,
            images: updatedImages,
            videos: updatedVideos,
        };

        if (coordinates) {
            dataToUpdate.location = {
                type: 'Point',
                coordinates: JSON.parse(coordinates),
            };
        }

        if (categoryId) {
            const category = await Category.findById(categoryId);
            if (!category) throw new Error("Invalid category ID.");
            dataToUpdate.categoryId = categoryId;
        }

        const updatedWorker = await Worker.findByIdAndUpdate(workerId, dataToUpdate, { new: true, runValidators: true });

        return { worker: updatedWorker, filesToDelete };
    }

    async deleteWorker(workerId, userId) {
        const worker = await Worker.findById(workerId);
        if (!worker) {
            throw new Error("Worker not found.");
        }

        if (worker.worker.toString() !== userId.toString()) {
            throw new Error("Unauthorized access.");
        }

        const filesToDelete = [...worker.images, ...worker.videos];
        await worker.deleteOne();

        return { success: true, filesToDelete };
    }

    async getNearestWorkers(lat, long, categoryId = null, maxDistance = 500000) { // 500km default
        const latitude = parseFloat(lat);
        const longitude = parseFloat(long);

        if (isNaN(latitude) || isNaN(longitude)) {
            throw new Error("Invalid latitude or longitude.");
        }

        const geoNearOptions = {
            near: {
                type: "Point",
                coordinates: [longitude, latitude]
            },
            distanceField: "dist.calculated",
            maxDistance: maxDistance,
            spherical: true
        };

        if (categoryId) {
            geoNearOptions.query = { categoryId: new mongoose.Types.ObjectId(categoryId) };
        }

        return await Worker.aggregate([
            {
                $geoNear: geoNearOptions
            },
            {
                $lookup: {
                    from: "categories",
                    localField: "categoryId",
                    foreignField: "_id",
                    as: "categoryId"
                }
            },
            { $unwind: "$categoryId" },
            {
                $lookup: {
                    from: "users",
                    localField: "worker",
                    foreignField: "_id",
                    as: "worker"
                }
            },
            { $unwind: "$worker" }
        ]);
    }

    async getAllWorkers(filters) {
        // Implementation for regular fetch without geo, or combined
        return await Worker.find(filters)
            .populate("categoryId", "category_name")
            .populate("worker", "fullName email phoneNumber profilePicture");
    }

    async getWorkerById(id) {
        const worker = await Worker.findById(id)
            .populate("categoryId", "category_name")
            .populate("worker", "fullName email phoneNumber profilePicture");
        if (!worker) throw new Error("Worker not found");
        return worker;
    }
}

module.exports = new WorkerService();
