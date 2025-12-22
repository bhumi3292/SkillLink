const jwt = require("jsonwebtoken");
const Worker = require("../models/Worker");

// Define authenticateUser function
const authenticateUser = (req, res, next) => {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith("Bearer ")) {
        return res.status(401).json({ success: false, message: "Access token missing or invalid" });
    }

    const token = authHeader.split(" ")[1];

    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        req.user = decoded;
        next();
    } catch (err) {
        if (err.name === "TokenExpiredError") {
            return res.status(401).json({ success: false, message: "Token expired. Please login again." });
        }
        if (err.name === "JsonWebTokenError") {
            return res.status(401).json({ success: false, message: "Invalid token. Please login again." });
        }
        return res.status(401).json({ success: false, message: "Authentication failed." });
    }
};

// Define isworker function
const isworker = (req, res, next) => {
    if (req.user && req.user.role === "worker") {
        return next();
    }
    return res.status(403).json({ success: false, message: "Access denied: worker only" });
};

// Define isWorkerOwner function
const isWorkerOwner = async (req, res, next) => {
    try {
        const worker = await Worker.findById(req.params.id);
        if (!worker) {
            return res.status(404).json({ success: false, message: "Worker profile not found" });
        }

        if (worker.worker.toString() !== req.user._id) {
            return res.status(403).json({ success: false, message: "Access denied: You do not own this worker profile" });
        }

        next();
    } catch (error) {
        console.error("Error in isWorkerOwner:", error);
        return res.status(500).json({ success: false, message: "Server error" });
    }
};

// Export the functions AFTER they have been defined
module.exports = {
    authenticateUser,
    isworker,
    isWorkerOwner,
};