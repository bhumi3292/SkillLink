const Worker = require('../models/Worker');
const Category = require('../models/Category');
const mongoose = require('mongoose');

class WorkerService {
    async createWorker(workerData, userId, filePaths) {
        const { title, description, minPrice, maxPrice, price, categoryId, coordinates, experience } = workerData;

        const category = await Category.findById(categoryId);
        if (!category) {
            throw new Error("Invalid category ID.");
        }

        const worker = new Worker({
            title,
            description,
            minPrice: minPrice || price,
            maxPrice: maxPrice || price,
            categoryId,
            experience: experience || 0,
            location: {
                type: 'Point',
                coordinates: typeof coordinates === 'string' ? JSON.parse(coordinates) : coordinates,
            },
            images: filePaths.images || [],
            videos: filePaths.videos || [],
            licenseUrl: filePaths.licenseUrl || "",
            identityCardUrl: filePaths.identityCardUrl || "",
            status: "pending",
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

        // Validation: Prevent editing service info while verification is pending
        // Basic info (Location) is allowed. User info (Name, Photo) is handled separately.
        if (worker.status === 'pending') {
            // If trying to update service fields
            if (title || description || minPrice || maxPrice || experience || categoryId) {
                throw new Error("Cannot edit service details while verification is pending. Only location can be updated.");
            }
        }

        const dataToUpdate = {
            images: updatedImages,
            videos: updatedVideos,
        };

        if (title) dataToUpdate.title = title;
        if (description) dataToUpdate.description = description;
        if (minPrice) dataToUpdate.minPrice = minPrice;
        if (maxPrice) dataToUpdate.maxPrice = maxPrice;
        if (experience) dataToUpdate.experience = experience;

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

        const filesToDelete = []; // Soft delete keeps files

        // Soft Delete
        worker.isActive = false;
        await worker.save();

        // await worker.deleteOne(); // Removed hard delete

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
            geoNearOptions.query = {
                categoryId: new mongoose.Types.ObjectId(categoryId),
                status: 'approved',
                isActive: true
            };
        } else {
            geoNearOptions.query = { status: 'approved', isActive: true };
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
                $match: { "categoryId.isActive": true } // Ensure category is active
            },
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
        const finalFilters = { ...filters, status: 'approved', isActive: true };
        const workers = await Worker.find(finalFilters)
            .populate("categoryId", "category_name isActive")
            .populate("worker", "fullName email phoneNumber profilePicture");

        // Filter out workers whose category is not active
        return workers.filter(w => w.categoryId && w.categoryId.isActive !== false);
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
