const mongoose = require("mongoose");

const reportSchema = new mongoose.Schema({
    reporter: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "User",
        required: true
    },
    reportedUser: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "User",
        required: true
    },
    reason: {
        type: String,
        required: true
    },
    evidenceChat: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "Chat",
        required: false
    },
    booking: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "Booking",
        required: false
    },
    status: {
        type: String,
        enum: ["open", "resolved"],
        default: "open"
    },
    adminActionTaken: {
        type: String,
        enum: ["none", "warning", "suspension", "ban"],
        default: "none"
    }
}, { timestamps: true });

module.exports = mongoose.model("Report", reportSchema);
