import 'package:flutter_test/flutter_test.dart';
import 'package:shop_lite/models/product.dart';
import 'package:shop_lite/models/category.dart';

void main() {
  group('Product Model Tests', () {
    test('Product.fromJson parses valid JSON correctly', () {
      final json = {
        'id': 1,
        'name': 'SonicPro Wireless Headphones',
        'description': 'High fidelity ANC headphones',
        'price': 129.99,
        'category': 'Electronics',
        'imageUrl': 'https://images.unsplash.com/sample',
        'rating': 4.8,
        'stockQuantity': 35,
      };

      final product = Product.fromJson(json);

      expect(product.id, 1);
      expect(product.name, 'SonicPro Wireless Headphones');
      expect(product.price, 129.99);
      expect(product.formattedPrice, '\$129.99');
      expect(product.category, 'Electronics');
      expect(product.rating, 4.8);
      expect(product.stockQuantity, 35);
      expect(product.inStock, true);
    });

    test('Product.fromJson handles snake_case keys as fallback', () {
      final json = {
        'id': 2,
        'name': 'Classic Denim Jacket',
        'description': 'Rugged vintage jacket',
        'price': 64.0,
        'category': 'Fashion',
        'image_url': 'https://images.unsplash.com/jacket',
        'rating': 4.5,
        'stock_quantity': 0,
      };

      final product = Product.fromJson(json);

      expect(product.imageUrl, 'https://images.unsplash.com/jacket');
      expect(product.stockQuantity, 0);
      expect(product.inStock, false);
    });

    test('Product.copyWith creates updated copy without mutating original', () {
      const original = Product(
        id: 3,
        name: 'Keyboard',
        description: 'Gaming keyboard',
        price: 50.0,
        category: 'Electronics',
        imageUrl: '',
        rating: 4.0,
        stockQuantity: 10,
      );

      final updated = original.copyWith(stockQuantity: 5, price: 45.0);

      expect(updated.id, 3);
      expect(updated.stockQuantity, 5);
      expect(updated.price, 45.0);
      expect(original.stockQuantity, 10);
      expect(original.price, 50.0);
    });
  });

  group('Category Model Tests', () {
    test('ProductCategory.fromJson parses properly', () {
      final json = {
        'name': 'Electronics',
        'productCount': 4,
      };

      final category = ProductCategory.fromJson(json);

      expect(category.name, 'Electronics');
      expect(category.productCount, 4);
    });
  });
}
