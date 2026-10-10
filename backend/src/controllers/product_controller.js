const productService = require('../services/product_service');
const { validateProductQuery } = require('../validators/product_query_validator');

async function listProducts(req, res, next) {
  try {
    const validation = validateProductQuery(req.query);
    if (!validation.isValid) {
      return res.status(400).json({
        error: 'Invalid query parameters',
        details: validation.errors
      });
    }

    const products = await productService.getProducts(validation.filters);
    return res.status(200).json({
      success: true,
      count: products.length,
      data: products
    });
  } catch (err) {
    next(err);
  }
}

async function getProduct(req, res, next) {
  try {
    const rawId = req.params.id;
    const id = Number(rawId);

    if (!Number.isInteger(id) || id <= 0) {
      return res.status(400).json({
        error: 'Invalid product ID',
        message: 'Product ID must be a positive integer'
      });
    }

    const product = await productService.getProductById(id);
    return res.status(200).json({
      success: true,
      data: product
    });
  } catch (err) {
    next(err);
  }
}

module.exports = {
  listProducts,
  getProduct
};
