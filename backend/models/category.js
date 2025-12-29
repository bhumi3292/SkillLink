

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
    }
}, { timestamps: true });

module.exports = mongoose.model("Category", CategorySchema);
