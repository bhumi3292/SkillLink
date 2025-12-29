const express = require('express');
const router = express.Router();
const reportController = require('../controllers/reportController');
const { authenticateUser } = require('../middlewares/auth');

router.use(authenticateUser);

router.post('/', reportController.createReport);

module.exports = router;
