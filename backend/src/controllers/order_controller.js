const orderService = require('../services/order_service');
const { validateOrderPayload } = require('../validators/order_validator');

async function createOrder(req, res, next) {
  try {
    const validation = validateOrderPayload(req.body);
    if (!validation.isValid) {
      return res.status(400).json({
        success: false,
        error: 'Validation failed',
        details: validation.errors
      });
    }

    const order = await orderService.createOrder(validation.data);
    return res.status(201).json({
      success: true,
      message: 'Order placed successfully',
      data: order
    });
  } catch (err) {
    next(err);
  }
}

async function getOrder(req, res, next) {
  try {
    const rawId = req.params.id;
    const id = Number(rawId);

    if (!Number.isInteger(id) || id <= 0) {
      return res.status(400).json({
        success: false,
        error: 'Invalid order ID',
        message: 'Order ID must be a positive integer'
      });
    }

    const order = await orderService.getOrderById(id);
    return res.status(200).json({
      success: true,
      data: order
    });
  } catch (err) {
    next(err);
  }
}

module.exports = {
  createOrder,
  getOrder
};
