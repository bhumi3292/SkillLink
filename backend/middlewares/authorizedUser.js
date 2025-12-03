const jwt = require("jsonwebtoken");
const Property = require("../models/Property");

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

// Define isLandlord function
const isLandlord = (req, res, next) => {
    if (req.user && req.user.role === "Landlord") {
        return next();
    }
    return res.status(403).json({ success: false, message: "Access denied: Landlord only" });
};

// Define isPropertyOwner function
const isPropertyOwner = async (req, res, next) => {
    try {
        const property = await Property.findById(req.params.id);
        if (!property) {
            return res.status(404).json({ success: false, message: "Property not found" });
        }

        if (property.landlord.toString() !== req.user._id) {
            return res.status(403).json({ success: false, message: "Access denied: You do not own this property" });
        }

        next();
    } catch (error) {
        console.error("Error in isPropertyOwner:", error);
        return res.status(500).json({ success: false, message: "Server error" });
    }
};

// Export the functions AFTER they have been defined
module.exports = {
    authenticateUser,
    isLandlord,
    isPropertyOwner,
};