class ProductCategory {
  final String name;
  final int productCount;

  const ProductCategory({
    required this.name,
    required this.productCount,
  });

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      name: json['name'] as String? ?? '',
      productCount: (json['productCount'] as num? ?? json['product_count'] as num? ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'productCount': productCount,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductCategory && runtimeType == other.runtimeType && name.toLowerCase() == other.name.toLowerCase();

  @override
  int get hashCode => name.toLowerCase().hashCode;
}
