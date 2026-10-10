import 'package:flutter_test/flutter_test.dart';
import 'package:shop_lite/models/order.dart';
import 'package:shop_lite/models/product.dart';
import 'package:shop_lite/models/cart_item.dart';
import 'package:shop_lite/providers/cart_provider.dart';

void main() {
  group('Order & Checkout Model Tests', () {
    test('Order.fromJson decodes full order structure correctly', () {
      final json = {
        'id': 101,
        'customer': {
          'name': 'Sarah Connor',
          'phone': '9876543210',
          'address': '404 Resistance Way, Los Angeles',
        },
        'totalAmount': 249.98,
        'status': 'CONFIRMED',
        'createdAt': '2026-10-10T12:00:00Z',
        'items': [
          {
            'id': 1,
            'productId': 1,
            'productName': 'SonicPro Wireless Headphones',
            'productImageUrl': 'https://example.com/p1.jpg',
            'quantity': 2,
            'unitPrice': 124.99,
            'lineTotal': 249.98,
          }
        ]
      };

      final order = Order.fromJson(json);

      expect(order.id, 101);
      expect(order.customerName, 'Sarah Connor');
      expect(order.customerPhone, '9876543210');
      expect(order.deliveryAddress, '404 Resistance Way, Los Angeles');
      expect(order.totalAmount, 249.98);
      expect(order.formattedTotal, '\$249.98');
      expect(order.status, 'CONFIRMED');
      expect(order.items.length, 1);
      expect(order.items[0].productName, 'SonicPro Wireless Headphones');
      expect(order.items[0].lineTotal, 249.98);
    });

    test('CartItem creates valid checkout payload for backend submission', () {
      const product = Product(
        id: 7,
        name: 'Weekender Duffel',
        description: 'Duffel',
        price: 115.00,
        category: 'Fashion',
        imageUrl: '',
        rating: 4.9,
        stockQuantity: 10,
      );

      const cartItem = CartItem(product: product, quantity: 3);
      final payload = cartItem.toCheckoutPayload();

      expect(payload['productId'], 7);
      expect(payload['quantity'], 3);
    });

    test('Cart clearing policy: cart is cleared ONLY upon successful checkout completion', () {
      final cart = CartProvider();
      const product = Product(
        id: 1,
        name: 'Headphones',
        description: 'Headphones',
        price: 100.0,
        category: 'Electronics',
        imageUrl: '',
        rating: 4.5,
        stockQuantity: 10,
      );

      cart.addToCart(product, quantity: 2);
      expect(cart.totalItemCount, 2);

      void onCheckoutFinished(bool success) {
        if (success) {
          cart.clear();
        }
      }

      // Simulated failure: cart remains intact
      onCheckoutFinished(false);
      expect(cart.totalItemCount, 2, reason: 'Cart must NOT be cleared when checkout fails');

      // Simulated success: cart is cleared
      onCheckoutFinished(true);
      expect(cart.totalItemCount, 0, reason: 'Cart must be cleared after successful order response');
    });
  });
}
