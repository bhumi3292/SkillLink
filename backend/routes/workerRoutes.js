// routes/workerRoutes.js
const express = require('express');
const router = express.Router();

const {
    createWorker,
    getAllWorkers,
    getOneWorker,
    updateWorker,
    deleteWorker,
    updateAvailability
} = require('../controllers/worker/workerController');

const {
    authenticateUser,
    isworker,
    isPropertyOwner // Rename this later if needed, but logic currently checks role ownership
} = require('../middlewares/authorizedUser');

router.put(
    '/update-availability',
    authenticateUser,
    isworker,
    updateAvailability
);

const uploadWorkerMedia = require('../middlewares/worker/workerMediaUpload');

router.post(
    '/',
    authenticateUser,
    isworker,
    uploadWorkerMedia, // Middleware to handle file uploads
    createWorker
);

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
