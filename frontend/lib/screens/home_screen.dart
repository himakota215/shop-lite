import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_catalog_provider.dart';
import '../widgets/cart_badge.dart';
import '../widgets/search_bar.dart';
import '../widgets/category_filter.dart';
import '../widgets/product_card.dart';
import '../widgets/loading_view.dart';
import '../widgets/error_view.dart';
import '../widgets/empty_state.dart';
import '../core/theme/app_theme.dart';
import '../core/config/app_config.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ProductCatalogProvider>(context, listen: false);
      if (provider.products.isEmpty && !provider.isLoading && !provider.hasError) {
        provider.initCatalog();
      }
    });
  }

  void _showApiSettingsDialog() {
    final controller = TextEditingController(text: AppConfig.baseUrl);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('API Base URL Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Change the API host URL for local network testing (e.g. Physical Android phone):',
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Backend URL',
                hintText: 'http://192.168.1.50:3000',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Emulator: http://10.0.2.2:3000\nChrome Web: http://localhost:3000',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              AppConfig.resetCustomBaseUrl();
              Navigator.of(ctx).pop();
              Provider.of<ProductCatalogProvider>(context, listen: false).initCatalog();
            },
            child: const Text('Reset Default'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                AppConfig.setCustomBaseUrl(controller.text.trim());
              }
              Navigator.of(ctx).pop();
              Provider.of<ProductCatalogProvider>(context, listen: false).initCatalog();
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.shopping_bag_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  AppConfig.appName,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: AppTheme.primaryDark,
                  ),
                ),
                Text(
                  'Modern E-Commerce',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, size: 22),
            tooltip: 'Server Connection Settings',
            onPressed: _showApiSettingsDialog,
          ),
          const CartBadge(),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<ProductCatalogProvider>(
        builder: (context, catalog, child) {
          return Column(
            children: [
              // Search input
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                child: CustomSearchBar(
                  initialValue: catalog.searchQuery,
                  onChanged: (val) => catalog.setSearchQuery(val),
                  onClear: () => catalog.setSearchQuery(''),
                ),
              ),

              // Categories bar
              if (catalog.categories.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: CategoryFilterBar(
                    categories: catalog.categories,
                    selectedCategory: catalog.selectedCategory,
                    onSelectCategory: (category) => catalog.selectCategory(category),
                  ),
                ),

              // Main content: Loading, Error, Empty, or Product Grid
              Expanded(
                child: RefreshIndicator(
                  color: AppTheme.primary,
                  onRefresh: () => catalog.initCatalog(),
                  child: _buildMainContent(catalog),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMainContent(ProductCatalogProvider catalog) {
    if (catalog.isLoading && catalog.products.isEmpty) {
      return const LoadingView(message: 'Connecting to catalog...');
    }

    if (catalog.hasError && catalog.products.isEmpty) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: ErrorView(
            message: catalog.errorMessage ?? 'Failed to load products.',
            onRetry: () => catalog.fetchProducts(),
          ),
        ),
      );
    }

    if (catalog.products.isEmpty) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: EmptyState(
            title: 'No products found',
            message: catalog.hasActiveFilters
                ? 'No items match your active search or category filters.'
                : 'The store catalog is currently empty.',
            buttonText: catalog.hasActiveFilters ? 'Clear Filters' : 'Refresh Catalog',
            onAction: () => catalog.clearFilters(),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Two columns for phones, responsive scaling for tablets/web
        final crossAxisCount = constraints.maxWidth > 700 ? 3 : 2;
        final aspectRatio = constraints.maxWidth > 700 ? 0.75 : 0.68;

        return GridView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: aspectRatio,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
          ),
          itemCount: catalog.products.length,
          itemBuilder: (context, index) {
            final product = catalog.products[index];
            return ProductCard(product: product);
          },
        );
      },
    );
  }
}
