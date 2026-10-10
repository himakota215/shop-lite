import 'package:flutter/material.dart';
import '../models/category.dart';
import '../core/theme/app_theme.dart';

class CategoryFilterBar extends StatelessWidget {
  final List<ProductCategory> categories;
  final String selectedCategory;
  final ValueChanged<String> onSelectCategory;

  const CategoryFilterBar({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onSelectCategory,
  });

  @override
  Widget build(BuildContext context) {
    // Ensure "All" is always first
    final List<String> allCategoryNames = ['All'];
    for (final cat in categories) {
      if (!allCategoryNames.any((c) => c.toLowerCase() == cat.name.toLowerCase())) {
        allCategoryNames.add(cat.name);
      }
    }

    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: allCategoryNames.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final catName = allCategoryNames[index];
          final isSelected = selectedCategory.toLowerCase() == catName.toLowerCase();

          return InkWell(
            onTap: () => onSelectCategory(catName),
            borderRadius: BorderRadius.circular(20),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppTheme.primary : AppTheme.border,
                  width: isSelected ? 1.5 : 1.0,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppTheme.primary.withAlpha(51),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              child: Center(
                child: Text(
                  catName,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.textPrimary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
