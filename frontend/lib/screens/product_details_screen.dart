import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../repositories/product_repository.dart';
import '../providers/cart_provider.dart';
import '../widgets/cart_badge.dart';
import '../widgets/loading_view.dart';
import '../widgets/error_view.dart';
import '../core/theme/app_theme.dart';
import '../core/errors/api_exception.dart';

class ProductDetailsScreen extends StatefulWidget {
  final int productId;

  const ProductDetailsScreen({
    super.key,
    required this.productId,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final ProductRepository _repository = ProductRepository();
  Product? _product;
  bool _isLoading = true;
  String? _errorMessage;
  int _selectedQuantity = 1;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final fetched = await _repository.getProductById(widget.productId);
      if (mounted) {
        setState(() {
          _product = fetched;
          _isLoading = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.userFriendlyMessage;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Could not load product details. Please check connection.';
          _isLoading = false;
        });
      }
    }
  }

  void _increaseQuantity() {
    if (_product == null) return;
    if (_selectedQuantity < _product!.stockQuantity) {
      setState(() => _selectedQuantity++);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cannot select more than ${_product!.stockQuantity} items in stock'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _decreaseQuantity() {
    if (_selectedQuantity > 1) {
      setState(() => _selectedQuantity--);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        actions: const [
          CartBadge(),
          SizedBox(width: 8),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: _product != null && _product!.inStock
          ? _buildBottomActionBar()
          : null,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingView(message: 'Loading product details...');
    }

    if (_errorMessage != null || _product == null) {
      return ErrorView(
        message: _errorMessage ?? 'Product not found.',
        onRetry: _loadProduct,
      );
    }

    final product = _product!;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Large Hero Product Image
          Container(
            height: 280,
            width: double.infinity,
            color: const Color(0xFFF1F3F5),
            child: product.imageUrl.isNotEmpty
                ? Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Center(
                      child: Icon(Icons.broken_image_rounded, size: 60, color: AppTheme.textMuted),
                    ),
                  )
                : const Center(
                    child: Icon(Icons.shopping_bag_outlined, size: 60, color: AppTheme.textMuted),
                  ),
          ),

          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category & Rating Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.softGreen,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        product.category,
                        style: const TextStyle(
                          color: AppTheme.primaryDark,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (product.rating > 0)
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: Color(0xFFFFB300), size: 18),
                          const SizedBox(width: 4),
                          Text(
                            product.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            '(Verified Rating)',
                            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                  ],
                ),

                const SizedBox(height: 12),

                // Product Name
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                    height: 1.25,
                  ),
                ),

                const SizedBox(height: 10),

                // Price & Stock Tag
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      product.formattedPrice,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: product.inStock ? Colors.green.shade50 : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: product.inStock ? Colors.green.shade200 : Colors.red.shade200,
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        product.inStock
                            ? '${product.stockQuantity} in stock'
                            : 'Out of stock',
                        style: TextStyle(
                          color: product.inStock ? AppTheme.primaryDark : AppTheme.danger,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const Divider(height: 32),

                // Description
                const Text(
                  'About this item',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  product.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                ),

                const Divider(height: 32),

                // Quantity Selector (if in stock)
                if (product.inStock) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Quantity:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, size: 18),
                              onPressed: _selectedQuantity > 1 ? _decreaseQuantity : null,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                '$_selectedQuantity',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, size: 18),
                              onPressed: _selectedQuantity < product.stockQuantity
                                  ? _increaseQuantity
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar() {
    final product = _product!;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: AppTheme.border, width: 0.8)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Price',
                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
                Text(
                  '\$${(product.price * _selectedQuantity).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  final cart = Provider.of<CartProvider>(context, listen: false);
                  final result = cart.addToCart(product, quantity: _selectedQuantity);

                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        result.success
                            ? 'Added $_selectedQuantity unit(s) to cart'
                            : result.message,
                      ),
                      backgroundColor:
                          result.success ? AppTheme.primary : AppTheme.danger,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.shopping_cart_checkout_rounded),
                label: const Text('Add to Cart'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
