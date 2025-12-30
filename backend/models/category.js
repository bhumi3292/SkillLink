

const mongoose = require("mongoose");

const CategorySchema = new mongoose.Schema({
    category_name: {
        type: String,
        required: true,
        unique: true,
    },
    description: {
        type: String,
        required: false
    },
    isActive: {
        type: Boolean,
        default: true
    },
    basePrice: {
        type: Number,
        required: true,
        default: 1500 // Default base price if not specified
    }
}, { timestamps: true });

module.exports = mongoose.model("Category", CategorySchema);
