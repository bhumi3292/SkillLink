const express = require('express');
const router = express.Router();
const paymentController = require('../controllers/paymentController');
const { authenticateUser } = require('../middlewares/authorizedUser'); // Use the correct middleware

router.post('/initiate', authenticateUser, paymentController.initiate);
router.post('/verify', authenticateUser, paymentController.verify);
router.get('/history/:userId', authenticateUser, paymentController.history);

module.exports = router;