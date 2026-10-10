const productRepository = require('../repositories/product_repository');

class ProductService {
  async getProducts(filters) {
    return await productRepository.findAll(filters);
  }

  async getProductById(id) {
    const product = await productRepository.findById(id);
    if (!product) {
      const err = new Error(`Product with ID ${id} was not found`);
      err.statusCode = 404;
      err.code = 'PRODUCT_NOT_FOUND';
      throw err;
    }
    return product;
  }
}

module.exports = new ProductService();
