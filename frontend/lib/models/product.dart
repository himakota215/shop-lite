class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final String category;
  final String imageUrl;
  final double rating;
  final int stockQuantity;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.imageUrl,
    required this.rating,
    required this.stockQuantity,
  });

  bool get inStock => stockQuantity > 0;

  String get formattedPrice => '\$${price.toStringAsFixed(2)}';

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
      category: json['category'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? json['image_url'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      stockQuantity: (json['stockQuantity'] as num? ?? json['stock_quantity'] as num? ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'imageUrl': imageUrl,
      'rating': rating,
      'stockQuantity': stockQuantity,
    };
  }

  Product copyWith({
    int? id,
    String? name,
    String? description,
    double? price,
    String? category,
    String? imageUrl,
    double? rating,
    int? stockQuantity,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      stockQuantity: stockQuantity ?? this.stockQuantity,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
