const paymentService = require('../services/paymentService');

class PaymentController {
    /**
     * Initiate Payment
     */
    async initiate(req, res) {
        try {
            const { bookingId, amount, gateway } = req.body;
            const hirerId = req.user._id;

            if (!bookingId || !amount || !gateway) {
                return res.status(400).json({ message: 'Missing required fields' });
            }

            let result;
            if (gateway === 'Khalti') {
                result = await paymentService.initializeKhalti(bookingId, amount, hirerId);
            } else if (gateway === 'eSewa') {
                result = await paymentService.initializeEsewa(bookingId, amount, hirerId);
            } else {
                return res.status(400).json({ message: 'Invalid payment gateway' });
            }

            res.status(200).json(result);
        } catch (error) {
            res.status(500).json({ message: error.message });
        }
    }

    /**
     * Verify Payment
     */
    async verify(req, res) {
        try {
            const { gateway, ...data } = req.body;

            let result;
            if (gateway === 'Khalti') {
                const { pidx, paymentId } = data;
                result = await paymentService.verifyKhalti(pidx, paymentId);
            } else if (gateway === 'eSewa') {
                const { encodedData } = data;
                result = await paymentService.verifyEsewa(encodedData);
            } else {
                return res.status(400).json({ message: 'Invalid payment gateway' });
            }

            if (result.success) {
                res.status(200).json({ message: 'Payment verified successfully', data: result.data });
            } else {
                res.status(400).json({ message: result.message });
            }
        } catch (error) {
            res.status(500).json({ message: error.message });
        }
    }

    /**
     * Get Payment History
     */
    async history(req, res) {
        try {
            const userId = req.params.userId;

            // Authorization: User can only see their own history
            if (req.user._id.toString() !== userId && req.user.role !== 'admin') {
                return res.status(403).json({ message: 'Unauthorized' });
            }

            const history = await paymentService.getPaymentHistory(userId);
            res.status(200).json(history);
        } catch (error) {
            res.status(500).json({ message: error.message });
        }
    }

    /**
     * Admin: Get all payments
     */
    async getAllPayments(req, res) {
        try {
            if (req.user.role !== 'admin') {
                return res.status(403).json({ message: 'Unauthorized' });
            }

            const { status, refundStatus } = req.query;
            const filters = {};
            if (status) filters.status = status;
            if (refundStatus) filters.refundStatus = refundStatus;

            const payments = await paymentService.getAllPayments(filters);
            // Return raw array for frontend compatibility
            res.status(200).json(payments);
        } catch (error) {
            res.status(500).json({ message: error.message });
        }
    }

    async requestRefund(req, res) {
        try {
            const paymentId = req.params.id;
            const { reason } = req.body;
            const hirerId = req.user._id;

            const payment = await paymentService.requestRefund(paymentId, hirerId, reason);
            res.status(200).json(payment);
        } catch (error) {
            res.status(400).json({ message: error.message });
        }
    }

    async processRefund(req, res) {
        try {
            if (req.user.role !== 'admin') return res.status(403).json({ message: 'Unauthorized' });
            const paymentId = req.params.id;
            const adminId = req.user._id;

            const payment = await paymentService.processRefund(paymentId, adminId);
            res.status(200).json(payment);
        } catch (error) {
            res.status(400).json({ message: error.message });
        }
    }

    async rejectRefund(req, res) {
        try {
            if (req.user.role !== 'admin') return res.status(403).json({ message: 'Unauthorized' });
            const paymentId = req.params.id;
            const { reason } = req.body;
            const adminId = req.user._id;

            const payment = await paymentService.rejectRefund(paymentId, adminId, reason);
            res.status(200).json(payment);
        } catch (error) {
            res.status(400).json({ message: error.message });
        }
    }
}

module.exports = new PaymentController();
