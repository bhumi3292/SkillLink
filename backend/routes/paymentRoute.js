const express = require('express');
const router = express.Router();
const paymentController = require('../controllers/paymentController');
const { authenticateUser } = require('../middlewares/authorizedUser'); // Use the correct middleware

router.post('/initiate', authenticateUser, paymentController.initiate);
router.post('/verify', authenticateUser, paymentController.verify);
router.get('/history/:userId', authenticateUser, paymentController.history);
router.get('/all', authenticateUser, paymentController.getAllPayments);
router.post('/:id/refund-request', authenticateUser, paymentController.requestRefund);
router.post('/:id/refund', authenticateUser, paymentController.processRefund);
router.post('/:id/refund-reject', authenticateUser, paymentController.rejectRefund);

module.exports = router;