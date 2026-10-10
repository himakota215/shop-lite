const db = require('../config/database');
const productRepository = require('../repositories/product_repository');
const orderRepository = require('../repositories/order_repository');
const emailService = require('./email_service');

class OrderService {
  /**
   * Transactionally validate products, verify stock, calculate authoritative prices,
   * insert order and items, and decrement stock.
   */
  async createOrder({ customer, items }) {
    const connection = await db.getConnection();
    await connection.beginTransaction();

    try {
      const productIds = items.map((item) => item.productId);

      // Lock products in consistent ascending ID order to prevent race conditions & deadlocks
      const lockedProducts = await productRepository.findAndLockByIds(connection, productIds);
      const productMap = new Map(lockedProducts.map((p) => [p.id, p]));

      // 1. Verify existence of all requested products
      for (const item of items) {
        if (!productMap.has(item.productId)) {
          const err = new Error(`Product with ID ${item.productId} was not found`);
          err.statusCode = 404;
          err.code = 'PRODUCT_NOT_FOUND';
          throw err;
        }
      }

      // 2. Verify stock availability
      for (const item of items) {
        const product = productMap.get(item.productId);
        if (product.stockQuantity < item.quantity) {
          const err = new Error(
            `Insufficient stock for "${product.name}". Available: ${product.stockQuantity}, Requested: ${item.quantity}`
          );
          err.statusCode = 400;
          err.code = 'INSUFFICIENT_STOCK';
          err.details = {
            productId: product.id,
            productName: product.name,
            availableStock: product.stockQuantity,
            requestedQuantity: item.quantity
          };
          throw err;
        }
      }

      // 3. Authoritative server-side price calculation
      let calculatedTotal = 0;
      const preparedItems = [];

      for (const item of items) {
        const product = productMap.get(item.productId);
        const unitPrice = Number(product.price);
        const lineTotal = Number((unitPrice * item.quantity).toFixed(2));
        calculatedTotal += lineTotal;

        preparedItems.push({
          productId: product.id,
          quantity: item.quantity,
          unitPrice,
          lineTotal
        });
      }

      const totalAmount = Number(calculatedTotal.toFixed(2));

      // 4. Insert order record
      const orderId = await orderRepository.createOrder(connection, {
        customerName: customer.name,
        customerPhone: customer.phone,
        deliveryAddress: customer.address,
        totalAmount,
        status: 'CONFIRMED'
      });

      // 5. Insert order items
      await orderRepository.createOrderItems(connection, orderId, preparedItems);

      // 6. Decrease stock for each item
      for (const item of items) {
        await productRepository.decreaseStock(connection, item.productId, item.quantity);
      }

      // 7. Commit database transaction
      await connection.commit();

      // Fetch newly saved order with item details
      const savedOrder = await orderRepository.findById(orderId);

      // 8. Automatically send order notification email (non-fatal, catches any failure)
      if (savedOrder) {
        try {
          await emailService.sendOrderNotification(savedOrder);
        } catch (err) {
          console.warn(`[OrderService] Email notification error: ${err.message}`);
        }
      }

      return savedOrder;
    } catch (error) {
      await connection.rollback();
      throw error;
    } finally {
      connection.release();
    }
  }

  /**
   * Retrieve an order by primary key ID
   */
  async getOrderById(id) {
    const order = await orderRepository.findById(id);
    if (!order) {
      const err = new Error(`Order #${id} was not found`);
      err.statusCode = 404;
      err.code = 'ORDER_NOT_FOUND';
      throw err;
    }
    return order;
  }
}

module.exports = new OrderService();
