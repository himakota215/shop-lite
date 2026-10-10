const categoryService = require('../services/category_service');

async function listCategories(req, res, next) {
  try {
    const categories = await categoryService.getCategories();
    return res.status(200).json({
      success: true,
      count: categories.length,
      data: categories
    });
  } catch (err) {
    next(err);
  }
}

module.exports = {
  listCategories
};
