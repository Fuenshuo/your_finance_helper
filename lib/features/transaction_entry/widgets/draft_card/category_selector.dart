import 'package:flutter/material.dart';

/// 分类选择器组件
class CategorySelector extends StatelessWidget {
  const CategorySelector({
    required this.onCategorySelected,
    super.key,
    this.selectedCategoryId,
  });
  final String? selectedCategoryId;
  final ValueChanged<String?> onCategorySelected;

  // 临时分类数据 - 在实际应用中应该从服务获取
  static const List<Map<String, dynamic>> _categories = [
    {
      'id': 'food',
      'name': '餐饮',
      'icon': Icons.restaurant,
      'color': Colors.orange,
    },
    {
      'id': 'transport',
      'name': '交通',
      'icon': Icons.directions_car,
      'color': Colors.blue,
    },
    {
      'id': 'shopping',
      'name': '购物',
      'icon': Icons.shopping_bag,
      'color': Colors.purple,
    },
    {
      'id': 'entertainment',
      'name': '娱乐',
      'icon': Icons.movie,
      'color': Colors.pink,
    },
    {'id': 'other', 'name': '其他', 'icon': Icons.category, 'color': Colors.grey},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final selectedCategory = _categories.firstWhere(
      (cat) => cat['id'] == selectedCategoryId,
      orElse: () => _categories.first,
    );

    return InkWell(
      onTap: () => _showCategoryPicker(context),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: selectedCategoryId != null
                ? colorScheme.primary
                : colorScheme.outline.withValues(alpha: 0.3),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              selectedCategory['icon'] as IconData,
              size: 20,
              color: selectedCategoryId != null
                  ? colorScheme.primary
                  : colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                selectedCategoryId != null
                    ? selectedCategory['name'] as String
                    : '选择分类',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: selectedCategoryId != null
                      ? colorScheme.onSurface
                      : colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              size: 20,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryPicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '选择分类',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.map((category) {
                final isSelected = category['id'] == selectedCategoryId;
                return InkWell(
                  onTap: () {
                    onCategorySelected(category['id'] as String);
                    Navigator.of(context).pop();
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (category['color'] as Color).withValues(alpha: 0.2)
                          : Colors.transparent,
                      border: Border.all(
                        color: isSelected
                            ? category['color'] as Color
                            : Theme.of(context)
                                .colorScheme
                                .outline
                                .withValues(alpha: 0.3),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          category['icon'] as IconData,
                          size: 16,
                          color: isSelected
                              ? category['color'] as Color
                              : Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          category['name'] as String,
                          style: TextStyle(
                            color: isSelected
                                ? category['color'] as Color
                                : Theme.of(context).colorScheme.onSurface,
                            fontWeight: isSelected
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
