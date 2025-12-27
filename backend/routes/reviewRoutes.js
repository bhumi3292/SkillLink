const express = require('express');
const router = express.Router();
const reviewController = require('../controllers/reviewController');
const { authenticateUser } = require('../middlewares/auth');

router.post('/submit', authenticateUser, reviewController.submitReview);
router.get('/worker/:workerListingId', reviewController.getWorkerReviews);

module.exports = router;
