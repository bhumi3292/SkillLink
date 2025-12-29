const axios = require('axios');
const crypto = require('crypto');
const Payment = require('../models/Payment');
const Booking = require('../models/Booking');
const bookingService = require('./bookingService');
const notificationService = require('./notificationService');
const User = require('../models/User');

class PaymentService {
    /**
     * Initialize Khalti Payment
     */
    async initializeKhalti(bookingId, amount, hirerId) {
        const booking = await Booking.findById(bookingId).populate('worker');
        if (!booking) throw new Error('Booking not found');

        // Compute simple breakdown (server authoritative)
        const baseAmount = Math.round(amount);
        const serviceFee = Math.round(baseAmount * 0.05); // 5%
        const taxAmount = Math.round((baseAmount + serviceFee) * 0.13); // 13% VAT
        const totalAmount = baseAmount + serviceFee + taxAmount;

        const payment = new Payment({
            bookingId,
            hirerId,
            workerId: booking.worker._id,
            paymentGateway: 'Khalti',
            amount: totalAmount,
            baseAmount,
            serviceFee,
            taxAmount,
            totalAmount,
            status: 'Pending'
        });

        await payment.save();

        try {
            const config = {
                headers: {
                    'Authorization': `Key ${process.env.KHALTI_SECRET_KEY || '605f5e781c0f4e26b88e1830ee0beeb9'}`
                }
            };

            const payload = {
                "return_url": `${process.env.FRONTEND_URL || 'http://localhost:5173'}/payment-verification`,
                "website_url": "http://localhost:5173",
                "amount": amount * 100, // paisa
                "purchase_order_id": payment._id,
                "purchase_order_name": `SkillLink Service - ${booking._id}`,
                "customer_info": {
                    "name": "SkillLink User",
                    "email": "user@skilllink.com",
                    "phone": "9800000000"
                }
            };

            const response = await axios.post('https://a.khalti.com/api/v2/epayment/initiate/', payload, config);

            return {
                paymentId: payment._id,
                baseAmount,
                serviceFee,
                taxAmount,
                totalAmount,
                payment_url: response.data.payment_url,
                pidx: response.data.pidx
            };
        } catch (error) {
            console.error('Khalti Initiation Error:', error.response?.data || error.message);
            throw new Error('Failed to initiate Khalti payment');
        }
    }

    /**
     * Verify Khalti Payment
     */
    async verifyKhalti(pidx, paymentId) {
        try {
            const config = {
                headers: {
                    'Authorization': `Key ${process.env.KHALTI_SECRET_KEY || '605f5e781c0f4e26b88e1830ee0beeb9'}`
                }
            };

            // Modern ePay v2 Lookup API
            const response = await axios.post('https://a.khalti.com/api/v2/epayment/lookup/', {
                pidx
            }, config);

            if (response.data && response.data.status === 'Completed') {
                const payment = await Payment.findById(paymentId);
                if (!payment) throw new Error('Payment record not found');

                payment.status = 'Completed';
                payment.transactionId = response.data.transaction_id;
                await payment.save();

                // Update Booking Status
                await bookingService.updateBookingStatus(payment.bookingId, 'Paid', payment.hirerId, 'hirer');

                return { success: true, data: response.data };
            }

            return { success: false, message: `Payment status: ${response.data?.status || 'Unknown'}` };
        } catch (error) {
            console.error('Khalti Verification Error:', error.response?.data || error.message);
            // Mark payment failed if we can find it
            try {
                const payment = await Payment.findById(paymentId);
                if (payment) {
                    payment.status = 'Failed';
                    await payment.save();
                    // Notify admins
                    const admins = await User.find({ role: 'admin' });
                    for (const a of admins) {
                        await notificationService.sendNotification(
                            a._id,
                            'Payment Failure',
                            `Payment ${payment._id} for booking ${payment.bookingId} failed during Khalti verification.`,
                            'PAYMENT_FAILURE',
                            payment._id
                        );
                    }
                }
            } catch (e) {
                console.error('Error marking payment failed:', e.message);
            }

            throw new Error('Khalti verification failed');
        }
    }

    /**
     * Generate eSewa Signature
     */
    generateEsewaSignature(amount, tax_amount, total_amount, transaction_uuid, product_code) {
        const secret = process.env.ESEWA_SECRET_KEY || '8gBm/:&EnhH.1/q';
        const data = `total_amount=${total_amount},transaction_uuid=${transaction_uuid},product_code=${product_code}`;
        const hash = crypto.createHmac('sha256', secret).update(data).digest('base64');
        return hash;
    }

    /**
     * Initialize eSewa Payment
     */
    async initializeEsewa(bookingId, amount, hirerId) {
        const booking = await Booking.findById(bookingId).populate('worker');
        if (!booking) throw new Error('Booking not found');

        // Compute breakdown
        const baseAmount = Math.round(amount);
        const serviceFee = Math.round(baseAmount * 0.05);
        const taxAmount = Math.round((baseAmount + serviceFee) * 0.13);
        const totalAmount = baseAmount + serviceFee + taxAmount;

        const payment = new Payment({
            bookingId,
            hirerId,
            workerId: booking.worker._id,
            paymentGateway: 'eSewa',
            amount: totalAmount,
            baseAmount,
            serviceFee,
            taxAmount,
            totalAmount,
            status: 'Pending'
        });

        await payment.save();

        const transaction_uuid = `${payment._id}`;
        const product_code = process.env.ESEWA_MERCHANT_CODE || 'EPAYTEST';

        // eSewa requires signature for the frontend form
        const signature = this.generateEsewaSignature(amount, 0, amount, transaction_uuid, product_code);

        return {
            paymentId: payment._id,
            baseAmount,
            serviceFee,
            taxAmount,
            totalAmount,
            transaction_uuid,
            product_code,
            signature,
            success_url: `${process.env.FRONTEND_URL}/payment-success`,
            failure_url: `${process.env.FRONTEND_URL}/payment-failure`
        };
    }

    /**
     * Verify eSewa Payment
     */
    async verifyEsewa(encodedData) {
        try {
            // The 'message' from SDK can be a direct JSON string or Base64 encoded JSON
            let data;
            try {
                // Check if it's JSON first
                if (encodedData.trim().startsWith('{')) {
                    data = JSON.parse(encodedData);
                } else {
                    // Try decoding as base64
                    const decodedString = Buffer.from(encodedData, 'base64').toString('utf-8');
                    data = JSON.parse(decodedString);
                }
            } catch (e) {
                console.error('Error parsing eSewa message:', e);
                // Fallback: maybe it's already an object if passed from some middle layer
                data = encodedData;
            }

            const refId = data.transactionDetails?.referenceId;
            if (!refId) throw new Error('Transaction reference ID missing');

            // Mobile SDK Transaction Verification API
            const url = `https://rc.esewa.com.np/mobile/transaction?txnRefId=${refId}`;

            const merchantId = process.env.ESEWA_CLIENT_ID || 'JB0BBQ4aD0UqIThFJwAKBgAXEUkEGQUBBAwdOgABHD4DChwUAB0R';
            const merchantSecret = process.env.ESEWA_CLIENT_SECRET || 'BhwIWQQADhIYSxILExMcAgFXFhcOBwAKBgAXEQ==';

            const response = await axios.get(url, {
                headers: {
                    'merchantId': merchantId,
                    'merchantSecret': merchantSecret,
                    'Content-Type': 'application/json'
                }
            });

            // The response is an array of transaction details
            if (response.data && response.data.length > 0) {
                const txn = response.data[0];
                if (txn.transactionDetails && txn.transactionDetails.status === 'COMPLETE') {
                    // The productId we passed was paymentId
                    const paymentId = txn.productId;
                    const payment = await Payment.findById(paymentId);

                    if (!payment) {
                        console.error('Payment record not found for ID:', paymentId);
                        throw new Error('Payment record not found');
                    }

                    if (payment.status !== 'Completed') {
                        payment.status = 'Completed';
                        payment.transactionId = txn.transactionDetails.referenceId;
                        await payment.save();

                        // Update Booking Status
                        await bookingService.updateBookingStatus(payment.bookingId, 'Paid', payment.hirerId, 'hirer');
                    }

                    return { success: true, data: txn };
                }
            }

            return { success: false, message: 'eSewa verification failed or transaction incomplete' };
        } catch (error) {
            console.error('eSewa Verification Error:', error.message);
            // Attempt to mark payment failed and notify admins
            try {
                // if possible, parse paymentId
                let paymentId;
                if (typeof encodedData === 'string') {
                    const parsed = encodedData.trim().startsWith('{') ? JSON.parse(encodedData) : JSON.parse(Buffer.from(encodedData, 'base64').toString('utf-8'));
                    paymentId = parsed?.productId || parsed?.paymentId;
                } else if (encodedData?.productId) {
                    paymentId = encodedData.productId;
                }

                if (paymentId) {
                    const payment = await Payment.findById(paymentId);
                    if (payment) {
                        payment.status = 'Failed';
                        await payment.save();
                        const admins = await User.find({ role: 'admin' });
                        for (const a of admins) {
                            await notificationService.sendNotification(
                                a._id,
                                'Payment Failure',
                                `Payment ${payment._id} for booking ${payment.bookingId} failed during eSewa verification.`,
                                'PAYMENT_FAILURE',
                                payment._id
                            );
                        }
                    }
                }
            } catch (e) {
                console.error('Error marking eSewa payment failed:', e.message);
            }

            throw new Error(error.message || 'eSewa verification failed');
        }
    }

    async getAllPayments() {
        return await Payment.find().populate('bookingId').populate('workerId', 'fullName').sort({ createdAt: -1 });
    }

    async requestRefund(paymentId, hirerId, reason) {
        const payment = await Payment.findById(paymentId);
        if (!payment) throw new Error('Payment not found');

        if (payment.hirerId.toString() !== hirerId.toString()) {
            throw new Error('Unauthorized refund request');
        }

        if (payment.status !== 'Completed' && payment.status !== 'Paid') {
            throw new Error('Only completed payments can be refunded');
        }

        payment.refundStatus = 'requested';
        payment.refundReason = reason || null;
        payment.refundRequestedBy = hirerId;
        await payment.save();

        // Notify admins
        const admins = await User.find({ role: 'admin' });
        for (const a of admins) {
            await notificationService.sendNotification(
                a._id,
                'Refund Requested',
                `Refund requested for payment ${payment._id} (booking ${payment.bookingId}). Reason: ${reason || 'N/A'}`,
                'REFUND_REQUEST',
                payment._id
            );
        }

        return payment;
    }

    async processRefund(paymentId, adminId) {
        const payment = await Payment.findById(paymentId);
        if (!payment) throw new Error('Payment not found');

        if (payment.refundStatus !== 'requested') {
            throw new Error('No refund requested for this payment');
        }

        payment.refundStatus = 'refunded';
        payment.refundProcessedBy = adminId;
        payment.refundProcessedAt = new Date();
        await payment.save();

        // Update booking status if applicable
        try {
            await bookingService.updateBookingStatus(payment.bookingId, 'Refunded', adminId, 'admin');
        } catch (e) {
            // Non-fatal
            console.error('Failed to update booking status on refund:', e.message);
        }

        // Notify hirer
        await notificationService.sendNotification(
            payment.hirerId,
            'Refund Processed',
            `Your refund for payment ${payment._id} has been processed.`,
            'REFUND_PROCESSED',
            payment._id
        );

        return payment;
    }

    async rejectRefund(paymentId, adminId, reason) {
        const payment = await Payment.findById(paymentId);
        if (!payment) throw new Error('Payment not found');

        if (payment.refundStatus !== 'requested') {
            throw new Error('No refund requested for this payment');
        }

        payment.refundStatus = 'rejected';
        payment.refundProcessedBy = adminId;
        payment.refundProcessedAt = new Date();
        // preserve refundReason requested by hirer; add admin note
        payment.refundAdminNote = reason || null;
        await payment.save();

        await notificationService.sendNotification(
            payment.hirerId,
            'Refund Rejected',
            `Your refund for payment ${payment._id} was rejected. Reason: ${reason || 'N/A'}`,
            'REFUND_REJECTED',
            payment._id
        );

        return payment;
    }

    async getPaymentHistory(userId) {
        return await Payment.find({ hirerId: userId })
            .populate('bookingId')
            .populate('workerId', 'fullName')
            .sort({ createdAt: -1 });
    }
}

module.exports = new PaymentService();
