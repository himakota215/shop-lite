const db = require('../config/database');

class CategoryRepository {
  /**
   * Retrieve distinct categories with active product counts
   */
  async findAll() {
    const sql = `
      SELECT category AS name, COUNT(*) AS productCount
      FROM products
      GROUP BY category
      ORDER BY category ASC
    `;
    const rows = await db.query(sql);
    return rows.map((row) => ({
      name: String(row.name),
      productCount: Number(row.productCount)
    }));
  }
}

module.exports = new CategoryRepository();
