// routes/propertyRoutes.js
const express = require('express');
const router = express.Router();

const {
    createProperty,
    getAllProperties,
    getOneProperty,
    updateProperty,
    deleteProperty
} = require('../controllers/worker/workerController');

const {
    authenticateUser,
    isworker,
    isPropertyOwner
} = require('../middlewares/authorizedUser');

const uploadPropertyMedia = require('../middlewares/worker/workerMediaUpload');

router.post(
    '/',
    authenticateUser,
    isworker,
    uploadPropertyMedia, // Middleware to handle file uploads
    createProperty
);

router.get('/', getAllProperties);
router.get('/:id', getOneProperty);

router.put(
    '/:id',
    authenticateUser,
    isworker,
    uploadPropertyMedia, // Middleware to handle new file uploads
    updateProperty
);

router.delete(
    '/:id',
    authenticateUser,
    isworker,
    deleteProperty // Delete logic is now in the controller
);

module.exports = router;