const db = require('../config/database');

class ProductRepository {
  /**
   * Find products with optional search and category filters
   */
  async findAll({ search, category } = {}) {
    let sql = `
      SELECT id, name, description, price, category, image_url, rating, stock_quantity, created_at, updated_at
      FROM products
      WHERE 1=1
    `;
    const params = [];

    if (category) {
      sql += ' AND LOWER(category) = LOWER(?)';
      params.push(category);
    }

    if (search) {
      sql += ' AND (LOWER(name) LIKE LOWER(?) OR LOWER(description) LIKE LOWER(?))';
      const wildcard = `%${search}%`;
      params.push(wildcard, wildcard);
    }

    sql += ' ORDER BY id ASC';

    const rows = await db.query(sql, params);
    return rows.map(this._mapProduct);
  }

  /**
   * Find product by primary key ID
   */
  async findById(id) {
    const sql = `
      SELECT id, name, description, price, category, image_url, rating, stock_quantity, created_at, updated_at
      FROM products
      WHERE id = ?
    `;
    const rows = await db.query(sql, [id]);
    if (!rows || rows.length === 0) {
      return null;
    }
    return this._mapProduct(rows[0]);
  }

  /**
   * Lock product rows by IDs in ascending order inside a transaction
   */
  async findAndLockByIds(connection, productIds) {
    if (!productIds || productIds.length === 0) {
      return [];
    }

    // Sort IDs numerically ascending to guarantee predictable lock order across concurrent transactions
    const sortedIds = [...productIds].sort((a, b) => a - b);
    const placeholders = sortedIds.map(() => '?').join(', ');

    const sql = `
      SELECT id, name, description, price, category, image_url, rating, stock_quantity
      FROM products
      WHERE id IN (${placeholders})
      ORDER BY id ASC
      FOR UPDATE
    `;

    const [rows] = await connection.execute(sql, sortedIds);
    return rows.map(this._mapProduct);
  }

  /**
   * Decrease product stock quantity within a transaction
   */
  async decreaseStock(connection, productId, quantity) {
    const sql = `
      UPDATE products
      SET stock_quantity = stock_quantity - ?
      WHERE id = ?
    `;
    await connection.execute(sql, [quantity, productId]);
  }

  /**
   * Maps database row to standard typed product representation
   */
  _mapProduct(row) {
    return {
      id: Number(row.id),
      name: String(row.name),
      description: String(row.description),
      price: Number(row.price),
      category: String(row.category),
      imageUrl: String(row.image_url),
      rating: Number(row.rating || 0),
      stockQuantity: Number(row.stock_quantity),
      createdAt: row.created_at,
      updatedAt: row.updated_at
    };
  }
}

module.exports = new ProductRepository();
