import '../core/network/api_client.dart';
import '../models/product.dart';
import '../models/category.dart';

class ProductRepository {
  final ApiClient _apiClient;

  ProductRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Retrieve product catalog with optional search and category filters
  Future<List<Product>> getProducts({String? search, String? category}) async {
    final queryParams = <String, String>{};
    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }
    if (category != null && category.trim().isNotEmpty && category.toLowerCase() != 'all') {
      queryParams['category'] = category.trim();
    }

    final response = await _apiClient.get('/api/products', queryParams: queryParams);
    final data = response['data'] as List<dynamic>? ?? [];

    return data.map((json) => Product.fromJson(json as Map<String, dynamic>)).toList();
  }

  /// Retrieve single product details by ID
  Future<Product> getProductById(int id) async {
    final response = await _apiClient.get('/api/products/$id');
    final data = response['data'] as Map<String, dynamic>;
    return Product.fromJson(data);
  }

  /// Retrieve available category list
  Future<List<ProductCategory>> getCategories() async {
    final response = await _apiClient.get('/api/categories');
    final data = response['data'] as List<dynamic>? ?? [];

    return data
        .map((json) => ProductCategory.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
