const express = require('express');
const router = express.Router();
const productController = require('../controllers/product_controller');

router.get('/', productController.listProducts);
router.get('/:id', productController.getProduct);

module.exports = router;
