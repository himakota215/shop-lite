import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../screens/checkout_screen.dart';
import '../widgets/empty_state.dart';
import '../core/theme/app_theme.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        actions: [
          Consumer<CartProvider>(
            builder: (context, cart, child) {
              if (cart.isEmpty) return const SizedBox.shrink();
              return TextButton.icon(
                onPressed: () {
                  _showClearCartDialog(context, cart);
                },
                icon: const Icon(Icons.delete_sweep_outlined, size: 20, color: AppTheme.danger),
                label: const Text(
                  'Clear',
                  style: TextStyle(color: AppTheme.danger, fontWeight: FontWeight.w600),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          if (cart.isEmpty) {
            return EmptyState(
              title: 'Your cart is empty',
              message: 'Looks like you haven\'t added any products to your shopping cart yet.',
              icon: Icons.remove_shopping_cart_outlined,
              buttonText: 'Browse Catalog',
              onAction: () => Navigator.of(context).pop(),
            );
          }

          return Column(
            children: [
              // Items List
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: cart.items.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    return _CartItemCard(item: item);
                  },
                ),
              ),

              // Bottom Order Summary Bar
              _buildCartSummaryBar(context, cart),
            ],
          );
        },
      ),
    );
  }

  void _showClearCartDialog(BuildContext context, CartProvider cart) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Shopping Cart?'),
        content: const Text('Are you sure you want to remove all items from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
            onPressed: () {
              cart.clear();
              Navigator.of(ctx).pop();
            },
            child: const Text('Clear Cart'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartSummaryBar(BuildContext context, CartProvider cart) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: AppTheme.border, width: 0.8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 8,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Subtotal (${cart.totalItemCount} items):',
                  style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                ),
                Text(
                  cart.formattedSubtotal,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Delivery (Demo standard):',
                  style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                ),
                Text(
                  'FREE',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
            const Divider(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Estimated:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                Text(
                  cart.formattedTotal,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                  );
                },
                icon: const Icon(Icons.arrow_forward_rounded),
                label: const Text('Proceed to Checkout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final dynamic item;

  const _CartItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context, listen: false);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppTheme.border, width: 0.8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 72,
                height: 72,
                color: const Color(0xFFF1F3F5),
                child: item.product.imageUrl.isNotEmpty
                    ? Image.network(
                        item.product.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.shopping_bag_outlined,
                          color: AppTheme.textMuted,
                        ),
                      )
                    : const Icon(Icons.shopping_bag_outlined, color: AppTheme.textMuted),
              ),
            ),
            const SizedBox(width: 14),

            // Info & Quantity
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Unit: \$${item.unitPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Quantity controls
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.border, width: 0.8),
                        ),
                        child: Row(
                          children: [
                            InkWell(
                              onTap: () => cart.decrement(item.product.id),
                              borderRadius: BorderRadius.circular(6),
                              child: const Padding(
                                padding: EdgeInsets.all(4.0),
                                child: Icon(Icons.remove, size: 16),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                '${item.quantity}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                final res = cart.increment(item.product.id);
                                if (!res.success) {
                                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(res.message),
                                      duration: const Duration(seconds: 1),
                                    ),
                                  );
                                }
                              },
                              borderRadius: BorderRadius.circular(6),
                              child: const Padding(
                                padding: EdgeInsets.all(4.0),
                                child: Icon(Icons.add, size: 16),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Line Total
                      Text(
                        item.formattedLineTotal,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
