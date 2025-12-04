const express = require("express");
const router = express.Router();

const {
    createBooking,
    getMyBookings,
    // getBookingsForProperty,
    // cancelBooking,
} = require("../controllers/bookingController");

const { protect } = require("../middlewares/auth");
const roleCheck = require("../middlewares/role");

const requireHirer = roleCheck("Hirer");
// const requireworker = roleCheck("worker"); // Uncomment when needed

// Routes
router.post("/create",requireHirer, createBooking);
router.get("/Hirer",requireHirer, getMyBookings);



module.exports = router;
