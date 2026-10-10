import 'package:flutter_test/flutter_test.dart';
import 'package:shop_lite/providers/cart_provider.dart';
import 'package:shop_lite/models/product.dart';

void main() {
  late CartProvider cart;

  const sampleProduct1 = Product(
    id: 1,
    name: 'Wireless Headphones',
    description: 'ANC Headphones',
    price: 100.00,
    category: 'Electronics',
    imageUrl: 'https://example.com/p1.jpg',
    rating: 4.8,
    stockQuantity: 5,
  );

  const sampleProduct2 = Product(
    id: 2,
    name: 'Denim Jacket',
    description: 'Cotton jacket',
    price: 50.00,
    category: 'Fashion',
    imageUrl: 'https://example.com/p2.jpg',
    rating: 4.5,
    stockQuantity: 3,
  );

  setUp(() {
    cart = CartProvider();
  });

  group('CartProvider Tests', () {
    test('Initial cart is empty', () {
      expect(cart.isEmpty, true);
      expect(cart.totalItemCount, 0);
      expect(cart.uniqueItemCount, 0);
      expect(cart.subtotal, 0.0);
      expect(cart.formattedTotal, '\$0.00');
    });

    test('Adding product adds to cart and updates calculations', () {
      final res = cart.addToCart(sampleProduct1, quantity: 2);

      expect(res.success, true);
      expect(cart.isEmpty, false);
      expect(cart.totalItemCount, 2);
      expect(cart.uniqueItemCount, 1);
      expect(cart.subtotal, 200.00);
      expect(cart.formattedTotal, '\$200.00');
    });

    test('Repeated additions merge quantities into single line item', () {
      cart.addToCart(sampleProduct1, quantity: 2);
      final res = cart.addToCart(sampleProduct1, quantity: 1);

      expect(res.success, true);
      expect(cart.uniqueItemCount, 1);
      expect(cart.totalItemCount, 3);
      expect(cart.getQuantity(1), 3);
      expect(cart.subtotal, 300.00);
    });

    test('Prevents adding more items than available stock', () {
      // sampleProduct1 has stockQuantity = 5
      cart.addToCart(sampleProduct1, quantity: 4);
      final overLimitRes = cart.addToCart(sampleProduct1, quantity: 2); // 4 + 2 = 6 > 5

      expect(overLimitRes.success, false);
      expect(overLimitRes.message, contains('Only 1 additional unit(s) available in stock.'));
      expect(cart.getQuantity(1), 4);
    });

    test('Increment and Decrement work and respect limits', () {
      cart.addToCart(sampleProduct2, quantity: 2); // stock is 3

      // Increment
      final incRes = cart.increment(sampleProduct2.id);
      expect(incRes.success, true);
      expect(cart.getQuantity(sampleProduct2.id), 3);

      // Try incrementing past stock
      final maxRes = cart.increment(sampleProduct2.id);
      expect(maxRes.success, false);
      expect(cart.getQuantity(sampleProduct2.id), 3);

      // Decrement
      cart.decrement(sampleProduct2.id);
      expect(cart.getQuantity(sampleProduct2.id), 2);

      cart.decrement(sampleProduct2.id);
      expect(cart.getQuantity(sampleProduct2.id), 1);

      // Decrementing from 1 removes the item
      cart.decrement(sampleProduct2.id);
      expect(cart.containsProduct(sampleProduct2.id), false);
      expect(cart.isEmpty, true);
    });

    test('Removing item updates subtotal and item count', () {
      cart.addToCart(sampleProduct1, quantity: 2); // 200
      cart.addToCart(sampleProduct2, quantity: 1); // 50
      expect(cart.subtotal, 250.00);

      cart.removeItem(sampleProduct1.id);
      expect(cart.containsProduct(sampleProduct1.id), false);
      expect(cart.uniqueItemCount, 1);
      expect(cart.totalItemCount, 1);
      expect(cart.subtotal, 50.00);
    });

    test('Clear empties all items', () {
      cart.addToCart(sampleProduct1, quantity: 1);
      cart.addToCart(sampleProduct2, quantity: 2);
      expect(cart.isEmpty, false);

      cart.clear();
      expect(cart.isEmpty, true);
      expect(cart.totalItemCount, 0);
      expect(cart.subtotal, 0.0);
    });
  });
}
