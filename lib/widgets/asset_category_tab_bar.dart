import 'package:flutter/material.dart';
import 'package:your_finance_flutter/models/asset_item.dart';
import 'package:your_finance_flutter/theme/app_theme.dart';
import 'package:your_finance_flutter/theme/responsive_text_styles.dart';

class AssetCategoryTabBar extends StatelessWidget {
  const AssetCategoryTabBar({
    required this.selectedCategory,
    required this.onCategorySelected,
    super.key,
  });
  final AssetCategory? selectedCategory;
  final void Function(AssetCategory?) onCategorySelected;

  @override
  Widget build(BuildContext context) => Container(
        margin: EdgeInsets.symmetric(horizontal: context.responsiveSpacing16),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              // 全部资产标签
              _buildTab(
                context,
                '全部资产',
                null,
                selectedCategory == null,
                () => onCategorySelected(null),
              ),
              SizedBox(width: context.responsiveSpacing8),

              // 各个资产类别标签
              ...AssetCategory.values.map(
                (category) => Padding(
                  padding: EdgeInsets.only(right: context.responsiveSpacing8),
                  child: _buildTab(
                    context,
                    category.displayName,
                    category,
                    selectedCategory == category,
                    () => onCategorySelected(category),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildTab(
    BuildContext context,
    String label,
    AssetCategory? category,
    bool isSelected,
    VoidCallback onTap,
  ) =>
      GestureDetector(
        onTap: () {
          // 添加触觉反馈
          // HapticFeedback.lightImpact();
          onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
          padding: EdgeInsets.symmetric(
            horizontal: context.responsiveSpacing16,
            vertical: context.responsiveSpacing8,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? context.accentBackground
                : context.primaryBackground,
            borderRadius: BorderRadius.circular(context.borderRadius),
            border: Border.all(
              color: isSelected
                  ? context.primaryAction.withOpacity(0.3)
                  : context.dividerColor,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: context.primaryAction.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: context.mobileBody.copyWith(
              color: isSelected ? context.primaryText : context.secondaryText,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
            child: Text(label),
          ),
        ),
      );
}
