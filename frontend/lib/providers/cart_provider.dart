import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../models/cart_item.dart';

class CartProvider extends ChangeNotifier {
  final Map<int, CartItem> _items = {};

  List<CartItem> get items => _items.values.toList();

  bool get isEmpty => _items.isEmpty;

  bool get isNotEmpty => _items.isNotEmpty;

  /// Total sum of all item quantities (used for cart badge)
  int get totalItemCount =>
      _items.values.fold(0, (sum, item) => sum + item.quantity);

  /// Number of distinct products in cart
  int get uniqueItemCount => _items.length;

  /// Cart subtotal amount calculated from authoritative unit prices
  double get subtotal {
    final sum = _items.values.fold(0.0, (acc, item) => acc + item.lineTotal);
    return double.parse(sum.toStringAsFixed(2));
  }

  /// Final total amount (subtotal)
  double get total => subtotal;

  String get formattedSubtotal => '\$${subtotal.toStringAsFixed(2)}';
  String get formattedTotal => '\$${total.toStringAsFixed(2)}';

  bool containsProduct(int productId) => _items.containsKey(productId);

  int getQuantity(int productId) => _items[productId]?.quantity ?? 0;

  /// Add a product to the cart, merging quantity if already present and respecting stock limits.
  /// Returns a status result indicating success or reason for limit.
  ({bool success, String message}) addToCart(Product product, {int quantity = 1}) {
    if (quantity <= 0) {
      return (success: false, message: 'Quantity must be at least 1.');
    }

    if (product.stockQuantity <= 0) {
      return (success: false, message: 'This product is currently out of stock.');
    }

    final currentQty = _items[product.id]?.quantity ?? 0;
    final targetQty = currentQty + quantity;

    if (targetQty > product.stockQuantity) {
      final allowedAdd = product.stockQuantity - currentQty;
      if (allowedAdd <= 0) {
        return (
          success: false,
          message: 'Cannot add more. You already have the maximum available stock (${product.stockQuantity}) in your cart.'
        );
      }
      return (
        success: false,
        message: 'Only $allowedAdd additional unit(s) available in stock.'
      );
    }

    _items[product.id] = CartItem(
      product: product,
      quantity: targetQty,
    );

    notifyListeners();
    return (success: true, message: 'Added to cart');
  }

  /// Increment item quantity by 1, respecting stock
  ({bool success, String message}) increment(int productId) {
    final item = _items[productId];
    if (item == null) return (success: false, message: 'Item not in cart');

    if (item.quantity >= item.product.stockQuantity) {
      return (
        success: false,
        message: 'Reached maximum available stock (${item.product.stockQuantity})'
      );
    }

    _items[productId] = item.copyWith(quantity: item.quantity + 1);
    notifyListeners();
    return (success: true, message: 'Quantity increased');
  }

  /// Decrement item quantity by 1. If at 1, removes the item.
  void decrement(int productId) {
    final item = _items[productId];
    if (item == null) return;

    if (item.quantity > 1) {
      _items[productId] = item.copyWith(quantity: item.quantity - 1);
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  /// Remove item completely from cart
  void removeItem(int productId) {
    if (_items.remove(productId) != null) {
      notifyListeners();
    }
  }

  /// Clear all items from the cart (only after successful checkout confirmation)
  void clear() {
    if (_items.isNotEmpty) {
      _items.clear();
      notifyListeners();
    }
  }
}
