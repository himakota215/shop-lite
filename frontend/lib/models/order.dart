class OrderItem {
  final int id;
  final int productId;
  final String productName;
  final String productImageUrl;
  final int quantity;
  final double unitPrice;
  final double lineTotal;

  const OrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productImageUrl,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
  });

  String get formattedUnitPrice => '\$${unitPrice.toStringAsFixed(2)}';
  String get formattedLineTotal => '\$${lineTotal.toStringAsFixed(2)}';

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: (json['id'] as num? ?? 0).toInt(),
      productId: (json['productId'] as num? ?? json['product_id'] as num? ?? 0).toInt(),
      productName: json['productName'] as String? ?? json['product_name'] as String? ?? 'Product',
      productImageUrl: json['productImageUrl'] as String? ?? json['product_image_url'] as String? ?? '',
      quantity: (json['quantity'] as num? ?? 1).toInt(),
      unitPrice: (json['unitPrice'] as num? ?? json['unit_price'] as num? ?? 0.0).toDouble(),
      lineTotal: (json['lineTotal'] as num? ?? json['line_total'] as num? ?? 0.0).toDouble(),
    );
  }
}

class Order {
  final int id;
  final String customerName;
  final String customerPhone;
  final String deliveryAddress;
  final double totalAmount;
  final String status;
  final DateTime? createdAt;
  final List<OrderItem> items;

  const Order({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.deliveryAddress,
    required this.totalAmount,
    required this.status,
    this.createdAt,
    required this.items,
  });

  String get formattedTotal => '\$${totalAmount.toStringAsFixed(2)}';

  factory Order.fromJson(Map<String, dynamic> json) {
    final customer = json['customer'] as Map<String, dynamic>? ?? {};

    DateTime? parsedDate;
    if (json['createdAt'] != null || json['created_at'] != null) {
      try {
        parsedDate = DateTime.parse((json['createdAt'] ?? json['created_at']).toString());
      } catch (_) {}
    }

    final rawItems = json['items'] as List<dynamic>? ?? [];
    final itemsList = rawItems
        .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
        .toList();

    return Order(
      id: (json['id'] as num).toInt(),
      customerName: customer['name'] as String? ?? json['customer_name'] as String? ?? '',
      customerPhone: customer['phone'] as String? ?? json['customer_phone'] as String? ?? '',
      deliveryAddress: customer['address'] as String? ?? json['delivery_address'] as String? ?? '',
      totalAmount: (json['totalAmount'] as num? ?? json['total_amount'] as num? ?? 0.0).toDouble(),
      status: json['status'] as String? ?? 'CONFIRMED',
      createdAt: parsedDate,
      items: itemsList,
    );
  }
}
