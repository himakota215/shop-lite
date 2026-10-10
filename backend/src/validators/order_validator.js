/**
 * Validates order creation payload
 */
function validateOrderPayload(body = {}) {
  const errors = [];

  if (!body || typeof body !== 'object') {
    return {
      isValid: false,
      errors: ['Request body must be a valid JSON object']
    };
  }

  const { customer, items } = body;

  // Validate customer
  if (!customer || typeof customer !== 'object') {
    errors.push('Customer details are required');
  } else {
    const name = typeof customer.name === 'string' ? customer.name.trim() : '';
    const phone = typeof customer.phone === 'string' ? customer.phone.trim() : '';
    const address = typeof customer.address === 'string' ? customer.address.trim() : '';

    if (!name || name.length < 2 || name.length > 150) {
      errors.push('Customer name is required and must be between 2 and 150 characters');
    }

    // Phone validation: allow +, digits, spaces, dashes, 7-20 characters
    const phonePattern = /^[+]?[(]?[0-9]{1,4}[)]?[-\s./0-9]{6,16}$/;
    if (!phone || !phonePattern.test(phone)) {
      errors.push('A valid phone number (between 7 and 20 digits/characters) is required');
    }

    if (!address || address.length < 5 || address.length > 500) {
      errors.push('Delivery address is required and must be between 5 and 500 characters');
    }
  }

  // Validate items
  if (!Array.isArray(items) || items.length === 0) {
    errors.push('Cart items array is required and must contain at least one item');
  } else {
    const consolidatedItems = new Map();

    for (let i = 0; i < items.length; i++) {
      const item = items[i];
      if (!item || typeof item !== 'object') {
        errors.push(`Item at index ${i} is invalid`);
        continue;
      }

      const rawProductId = item.productId ?? item.product_id;
      const productId = Number(rawProductId);
      if (!Number.isInteger(productId) || productId <= 0) {
        errors.push(`Item at index ${i} must have a valid positive integer productId`);
        continue;
      }

      const quantity = Number(item.quantity);
      if (!Number.isInteger(quantity) || quantity <= 0 || quantity > 999) {
        errors.push(`Item with productId ${productId} must have a positive integer quantity between 1 and 999`);
        continue;
      }

      // Consolidate duplicates
      if (consolidatedItems.has(productId)) {
        consolidatedItems.set(productId, consolidatedItems.get(productId) + quantity);
      } else {
        consolidatedItems.set(productId, quantity);
      }
    }

    if (errors.length === 0) {
      const sanitizedItems = Array.from(consolidatedItems.entries()).map(([productId, quantity]) => ({
        productId,
        quantity
      }));

      return {
        isValid: true,
        errors: [],
        data: {
          customer: {
            name: customer.name.trim(),
            phone: customer.phone.trim(),
            address: customer.address.trim()
          },
          items: sanitizedItems
        }
      };
    }
  }

  return {
    isValid: errors.length === 0,
    errors
  };
}

module.exports = {
  validateOrderPayload
};
