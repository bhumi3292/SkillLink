const express = require('express');
const { authenticateUser } = require('../middlewares/auth');
const router = express.Router();
const {
    initiatePayment,
    verifyKhaltiPayment,
    verifyEsewaPayment
} = require('../controllers/payment/paymentController');

router.post('/initiate', authenticateUser, initiatePayment);


router.post('/verify/khalti', verifyKhaltiPayment);


router.post('/verify/esewa', verifyEsewaPayment);

module.exports = router;