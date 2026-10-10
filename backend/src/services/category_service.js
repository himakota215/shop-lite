const categoryRepository = require('../repositories/category_repository');

class CategoryService {
  async getCategories() {
    return await categoryRepository.findAll();
  }
}

module.exports = new CategoryService();
