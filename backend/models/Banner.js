const mongoose = require('mongoose');

const BannerSchema = new mongoose.Schema({
    title: { type: String, required: true },
    description: { type: String },
    imageUrl: { type: String, required: true },
    ctaText: { type: String },
    targetType: { type: String, enum: ['category', 'workerList', 'externalLink'], required: true },
    targetValue: { type: String },
    startDate: { type: Date, required: true },
    endDate: { type: Date, required: true },
    isActive: { type: Boolean, default: true },
    createdBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    deletedAt: { type: Date, default: null }
}, { timestamps: true });

module.exports = mongoose.model('Banner', BannerSchema);
