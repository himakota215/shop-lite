import 'product.dart';

class CartItem {
  final Product product;
  final int quantity;

  const CartItem({
    required this.product,
    required this.quantity,
  });

  double get unitPrice => product.price;

  double get lineTotal => double.parse((unitPrice * quantity).toStringAsFixed(2));

  String get formattedLineTotal => '\$${lineTotal.toStringAsFixed(2)}';

  CartItem copyWith({
    Product? product,
    int? quantity,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toCheckoutPayload() {
    return {
      'productId': product.id,
      'quantity': quantity,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartItem && runtimeType == other.runtimeType && product.id == other.product.id;

  @override
  int get hashCode => product.id.hashCode;
}
