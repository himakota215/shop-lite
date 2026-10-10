import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../repositories/product_repository.dart';
import '../core/errors/api_exception.dart';

class ProductCatalogProvider extends ChangeNotifier {
  final ProductRepository _repository;

  ProductCatalogProvider({ProductRepository? repository})
      : _repository = repository ?? ProductRepository();

  List<Product> _products = [];
  List<ProductCategory> _categories = [];
  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;

  List<Product> get products => _products;
  List<ProductCategory> get categories => _categories;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  bool get hasActiveFilters =>
      _searchQuery.isNotEmpty || _selectedCategory != 'All';

  /// Initial load or refresh of catalog
  Future<void> initCatalog() async {
    await Future.wait([
      fetchCategories(),
      fetchProducts(),
    ]);
  }

  /// Fetch all categories from backend API
  Future<void> fetchCategories() async {
    try {
      final fetchedCategories = await _repository.getCategories();
      _categories = fetchedCategories;
      notifyListeners();
    } catch (_) {
      // Categories error is non-fatal for catalog display
    }
  }

  /// Fetch products applying the current search and category criteria
  Future<void> fetchProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await _repository.getProducts(
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        category: _selectedCategory != 'All' ? _selectedCategory : null,
      );
      _products = results;
      _errorMessage = null;
    } on ApiException catch (e) {
      _errorMessage = e.userFriendlyMessage;
      _products = [];
    } catch (e) {
      _errorMessage = 'Failed to load products. Please check your backend connection.';
      _products = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Change active category filter
  void selectCategory(String category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    fetchProducts();
  }

  /// Update search text filter
  void setSearchQuery(String query) {
    final trimmed = query.trim();
    if (_searchQuery == trimmed) return;
    _searchQuery = trimmed;
    fetchProducts();
  }

  /// Clear all filters back to default
  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = 'All';
    fetchProducts();
  }
}
