import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/asset_provider.dart';
import '../models/asset_item.dart';

class AssetDistributionCard extends StatelessWidget {
  const AssetDistributionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AssetProvider>(
      builder: (context, assetProvider, child) {
        final categoryTotals = assetProvider.getAssetsByCategory();
        final totalAssets = assetProvider.calculateTotalAssets();

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '资产分布',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                
                ...AssetCategory.values.map((category) {
                  final amount = categoryTotals[category] ?? 0.0;
                  if (amount <= 0) return const SizedBox.shrink();
                  
                  final percentage = totalAssets > 0 ? (amount / totalAssets) * 100 : 0.0;
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildDistributionRow(
                      context,
                      category,
                      amount,
                      percentage,
                      assetProvider.isAmountHidden,
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDistributionRow(
    BuildContext context,
    AssetCategory category,
    double amount,
    double percentage,
    bool isAmountHidden,
  ) {
    return Row(
      children: [
        // 分类名称
        SizedBox(
          width: 80,
          child: Text(
            category.displayName,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 12),
        
        // 进度条
        Expanded(
          child: Column(
            children: [
              LinearProgressIndicator(
                value: percentage / 100,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getCategoryColor(category),
                ),
                minHeight: 8,
              ),
              const SizedBox(height: 4),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        
        // 金额
        SizedBox(
          width: 80,
          child: Text(
            isAmountHidden ? '****' : '¥${amount.toStringAsFixed(0)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: category == AssetCategory.liabilities
                  ? Colors.red
                  : Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Color _getCategoryColor(AssetCategory category) {
    switch (category) {
      case AssetCategory.liquidAssets:
        return Colors.blue;
      case AssetCategory.fixedAssets:
        return Colors.green;
      case AssetCategory.investments:
        return Colors.orange;
      case AssetCategory.receivables:
        return Colors.purple;
      case AssetCategory.liabilities:
        return Colors.red;
    }
  }
}
