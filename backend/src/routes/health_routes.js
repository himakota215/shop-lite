const express = require('express');
const router = express.Router();
const healthController = require('../controllers/health_controller');

router.get('/', healthController.getHealth);

module.exports = router;
