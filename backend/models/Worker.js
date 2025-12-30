const mongoose = require("mongoose");

const workerSchema = new mongoose.Schema({
    images: {
        type: [String],
        required: true,
    },
    videos: {
        type: [String],
        required: false,
    },
    title: {
        type: String,
        required: true,
    },
    description: {
        type: String,
        required: true,
    },
    location: {
        type: {
            type: String,
            enum: ['Point'],
            required: true
        },
        coordinates: {
            type: [Number],
            required: true
        }
    },
    categoryId: {
        type: mongoose.Schema.ObjectId,
        ref: "Category",
        required: true
    },
    minPrice: {
        type: Number,
        required: true,
    },
    maxPrice: {
        type: Number,
        required: true,
    },
    worker: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "User",
        required: true
    },
    availabilityStatus: {
        type: String,
        enum: ["Available", "Booked", "Not Available"],
        default: "Available"
    },
    averageRating: {
        type: Number,
        default: 0
    },
    numReviews: {
        type: Number,
        default: 0
    },
    experience: {
        type: Number,
        required: true,
        default: 0
    },
    licenseUrl: {
        type: String,
        required: true,
    },
    identityCardUrl: {
        type: String,
        required: true,
    },
    status: {
        type: String,
        enum: ["pending", "approved", "rejected"],
        default: "pending"
    },
    rejectionReason: {
        type: String,
        default: null
    },
    viewCount: {
        type: Number,
        default: 0
    },
    isActive: {
        type: Boolean,
        default: false
    }
}, { timestamps: true });

workerSchema.index({ location: '2dsphere' });

const Worker = mongoose.model("Worker", workerSchema);

module.exports = Worker;
