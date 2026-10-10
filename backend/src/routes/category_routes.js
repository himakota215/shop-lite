const express = require('express');
const router = express.Router();
const categoryController = require('../controllers/category_controller');

router.get('/', categoryController.listCategories);

module.exports = router;
