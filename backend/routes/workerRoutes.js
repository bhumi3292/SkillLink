// routes/workerRoutes.js
const express = require('express');
const router = express.Router();

const {
    createWorker,
    getAllWorkers,
    getOneWorker,
    updateWorker,
    deleteWorker,
    updateAvailability,
    updateWorkerProfile,
    getNearbyWorkers
} = require('../controllers/worker/workerController');

const {
    authenticateUser,
    isworker,
    isWorkerOwner // Logic currently checks role ownership
} = require('../middlewares/authorizedUser');

const uploadWorkerMedia = require('../middlewares/worker/workerMediaUpload');

router.put(
    '/update-availability',
    authenticateUser,
    isworker,
    updateAvailability
);

router.put(
    '/profile',
    authenticateUser,
    isworker,
    uploadWorkerMedia,
    updateWorkerProfile
);



router.post(
    '/',
    authenticateUser,
    isworker,
    uploadWorkerMedia, // Middleware to handle file uploads
    createWorker
);

router.get('/nearby', getNearbyWorkers);
router.get('/', getAllWorkers);
router.get('/:id', getOneWorker);

router.put(
    '/:id',
    authenticateUser,
    isworker,
    uploadWorkerMedia, // Middleware to handle new file uploads
    updateWorker
);

router.delete(
    '/:id',
    authenticateUser,
    isworker,
    deleteWorker // Delete logic is now in the controller
);

module.exports = router;
