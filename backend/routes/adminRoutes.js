const express = require("express");
const router = express.Router();
const adminController = require("../controllers/adminController");
const { authenticateUser, requireRole } = require("../middlewares/auth");

// --- Admin Dashboard & Stats ---
router.get("/dashboard-stats", authenticateUser, requireRole("admin"), adminController.getDashboardStats);
router.get("/analytics", authenticateUser, requireRole("admin"), adminController.getAnalytics);

// --- Worker Verification ---
router.get("/workers/pending", authenticateUser, requireRole("admin"), adminController.getPendingWorkers);
router.post("/workers/verify", authenticateUser, requireRole("admin"), adminController.verifyWorker);

// --- User Management ---
router.get("/users", authenticateUser, requireRole("admin"), adminController.getAllUsers);
router.patch("/users/:userId/toggle-suspension", authenticateUser, requireRole("admin"), adminController.toggleUserSuspension);

// --- Category Management ---
router.post("/categories", authenticateUser, requireRole("admin"), adminController.createCategory);
router.put("/categories/:id", authenticateUser, requireRole("admin"), adminController.updateCategory);
router.patch("/categories/:id/toggle-status", authenticateUser, requireRole("admin"), adminController.toggleCategoryStatus);

// --- Disputes & Reports ---
router.get("/reports", authenticateUser, requireRole("admin"), adminController.getReports);
router.post("/reports/resolve", authenticateUser, requireRole("admin"), adminController.resolveReport);

// --- Bookings ---
router.get("/bookings", authenticateUser, requireRole("admin"), adminController.getAllBookings);

module.exports = router;
