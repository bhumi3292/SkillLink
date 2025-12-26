const axios = require('axios');
const Booking = require('../models/Booking');
const Payment = require('../models/Payment');
const notificationService = require('./notificationService');

class PaymentService {
    // KHALTI Integration
    async initiateKhaltiPayment(bookingId, amount, user) {
        const booking = await Booking.findById(bookingId).populate('worker');
        if (!booking) throw new Error("Booking not found");

        const payload = {
            "return_url": `${process.env.CLIENT_URL}/payment/khalti/callback`,
            "website_url": process.env.CLIENT_URL,
            "amount": amount * 100, // Khalti expects paisa
            "purchase_order_id": bookingId,
            "purchase_order_name": `Booking for ${booking.workerListing}`,
            "customer_info": {
                "name": user.fullName,
                "email": user.email,
                "phone": user.phoneNumber
            }
        };

        try {
            const response = await axios.post('https://a.khalti.com/api/v2/epayment/initiate/', payload, {
                headers: {
                    'Authorization': `Key ${process.env.KHALTI_SECRET_KEY}`
                }
            });

            // Save Payment Record
            const payment = new Payment({
                hirer: user._id,
                worker: booking.worker._id,
                booking: bookingId,
                method: 'khalti',
                amount: amount,
                pidx: response.data.pidx,
                status: 'Pending'
            });
            await payment.save();

            return response.data; // contains payment_url
        } catch (error) {
            console.error("Khalti Init Error:", error.response?.data || error.message);
            throw new Error('Khalti payment initiation failed');
        }
    }

    async verifyKhaltiPayment(pidx) {
        try {
            const response = await axios.post('https://a.khalti.com/api/v2/epayment/lookup/', { pidx }, {
                headers: {
                    'Authorization': `Key ${process.env.KHALTI_SECRET_KEY}`
                }
            });

            if (response.data.status === 'Completed') {
                const payment = await Payment.findOne({ pidx });
                if (payment) {
                    payment.status = 'Completed';
                    payment.transactionId = response.data.transaction_id;
                    payment.verificationData = response.data;
                    await payment.save();

                    // Update Booking Status
                    const booking = await Booking.findById(payment.booking);
                    if (booking) {
                        booking.status = 'Paid';
                        await booking.save();

                        // Notify
                        await notificationService.sendNotification(
                            booking.worker,
                            'Payment Received',
                            `You have received payment for booking ${booking._id}`,
                            'PAYMENT_RECEIVED',
                            booking._id
                        );
                        await notificationService.sendNotification(
                            booking.Hirer,
                            'Payment Successful',
                            `Your payment for booking ${booking._id} was successful`,
                            'PAYMENT_SUCCESS',
                            booking._id
                        );
                    }
                }
                return { success: true, transactionId: response.data.transaction_id };
            }
            return { success: false };
        } catch (error) {
            console.error("Khalti Verify Error:", error.message);
            throw new Error('Khalti verification failed');
        }
    }

    // eSewa Integration
    generateEsewaSignature(amount, transactionId) {
        const crypto = require('crypto');
        const secret = process.env.ESEWA_SECRET_KEY || '8g8M89dg877862g8';
        const message = `total_amount=${amount},transaction_uuid=${transactionId},product_code=${process.env.ESEWA_PRODUCT_CODE || 'EPAYTEST'}`;
        const hash = crypto.createHmac('sha256', secret).update(message).digest('base64');
        return hash;
    }

    async verifyEsewaPayment(encodedData) {
        try {
            // Decode data from eSewa
            const decoded = JSON.parse(Buffer.from(encodedData, 'base64').toString('utf-8'));
            // total_amount, transaction_uuid, status, transaction_code, etc.

            if (decoded.status === 'COMPLETE') {
                const bookingId = decoded.transaction_uuid;
                const booking = await Booking.findById(bookingId);
                if (booking && booking.status !== 'Paid') {
                    booking.status = 'Paid';
                    await booking.save();

                    const payment = new Payment({
                        hirer: booking.Hirer,
                        worker: booking.worker,
                        booking: bookingId,
                        method: 'esewa',
                        amount: booking.amount || parseFloat(decoded.total_amount.replace(/,/g, '')),
                        status: 'Completed',
                        transactionId: decoded.transaction_code,
                        verificationData: decoded
                    });
                    await payment.save();

                    // Notify
                    await notificationService.sendNotification(
                        booking.worker,
                        'Payment Received',
                        `You have received payment via eSewa for booking ${booking._id}`,
                        'PAYMENT_RECEIVED',
                        booking._id
                    );
                }
                return { success: true };
            }
            return { success: false };
        } catch (error) {
            console.error("eSewa Verify Error:", error.message);
            throw new Error('eSewa verification failed');
        }
    }
}

module.exports = new PaymentService();
