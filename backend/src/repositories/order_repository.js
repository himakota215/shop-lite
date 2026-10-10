const db = require('../config/database');

class OrderRepository {
  /**
   * Insert a new order within a transaction
   */
  async createOrder(connection, { customerName, customerPhone, deliveryAddress, totalAmount, status = 'CONFIRMED' }) {
    const sql = `
      INSERT INTO orders (customer_name, customer_phone, delivery_address, total_amount, status)
      VALUES (?, ?, ?, ?, ?)
    `;
    const [result] = await connection.execute(sql, [
      customerName,
      customerPhone,
      deliveryAddress,
      totalAmount,
      status
    ]);
    return result.insertId;
  }

  /**
   * Insert order items in batch within a transaction
   */
  async createOrderItems(connection, orderId, items) {
    if (!items || items.length === 0) return;

    const sql = `
      INSERT INTO order_items (order_id, product_id, quantity, unit_price, line_total)
      VALUES (?, ?, ?, ?, ?)
    `;

    for (const item of items) {
      await connection.execute(sql, [
        orderId,
        item.productId,
        item.quantity,
        item.unitPrice,
        item.lineTotal
      ]);
    }
  }

  /**
   * Find order by primary key ID along with ordered items
   */
  async findById(orderId) {
    const orderSql = `
      SELECT id, customer_name, customer_phone, delivery_address, total_amount, status, created_at, updated_at
      FROM orders
      WHERE id = ?
    `;
    const orderRows = await db.query(orderSql, [orderId]);
    if (!orderRows || orderRows.length === 0) {
      return null;
    }

    const order = orderRows[0];

    const itemsSql = `
      SELECT 
        oi.id,
        oi.order_id,
        oi.product_id,
        oi.quantity,
        oi.unit_price,
        oi.line_total,
        p.name AS product_name,
        p.image_url AS product_image_url
      FROM order_items oi
      LEFT JOIN products p ON oi.product_id = p.id
      WHERE oi.order_id = ?
      ORDER BY oi.id ASC
    `;
    const itemRows = await db.query(itemsSql, [orderId]);

    return {
      id: Number(order.id),
      customer: {
        name: String(order.customer_name),
        phone: String(order.customer_phone),
        address: String(order.delivery_address)
      },
      totalAmount: Number(order.total_amount),
      status: String(order.status),
      createdAt: order.created_at,
      updatedAt: order.updated_at,
      items: itemRows.map((row) => ({
        id: Number(row.id),
        productId: Number(row.product_id),
        productName: row.product_name || 'Product',
        productImageUrl: row.product_image_url || '',
        quantity: Number(row.quantity),
        unitPrice: Number(row.unit_price),
        lineTotal: Number(row.line_total)
      }))
    };
  }
}

module.exports = new OrderRepository();
