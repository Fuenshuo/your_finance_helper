import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:your_finance_flutter/core/models/asset_item.dart';
import 'package:your_finance_flutter/core/providers/asset_provider.dart';

class AssetChartCard extends StatelessWidget {
  const AssetChartCard({super.key});

  @override
  Widget build(BuildContext context) => Consumer<AssetProvider>(
        builder: (context, assetProvider, child) {
          final categoryTotals = assetProvider.getAssetsByCategory();
          final totalAssets = assetProvider.calculateTotalAssets();

          // 过滤掉金额为0的分类
          final chartData = categoryTotals.entries
              .where((entry) => entry.value > 0)
              .map(
                (entry) => _ChartData(
                  category: entry.key,
                  amount: entry.value,
                  percentage:
                      totalAssets > 0 ? (entry.value / totalAssets) * 100 : 0,
                ),
              )
              .toList();

          if (chartData.isEmpty) {
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      '资产组成',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 20),
                    Icon(
                      Icons.pie_chart_outline,
                      size: 64,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '暂无数据',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '资产组成',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 20),

                  // 饼图
                  SizedBox(
                    height: 200,
                    child: PieChart(
                      PieChartData(
                        sections: chartData.asMap().entries.map((entry) {
                          final index = entry.key;
                          final data = entry.value;
                          return PieChartSectionData(
                            color: _getCategoryColor(data.category),
                            value: data.amount,
                            title: '${data.percentage.toStringAsFixed(1)}%',
                            radius: 80,
                            titleStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          );
                        }).toList(),
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 图例
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: chartData
                        .map(
                          (data) => Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: _getCategoryColor(data.category),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                data.category.displayName,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          );
        },
      );

  Color _getCategoryColor(AssetCategory category) {
    switch (category) {
      case AssetCategory.liquidAssets:
        return Colors.blue;
      case AssetCategory.realEstate:
        return Colors.green;
      case AssetCategory.investments:
        return Colors.orange;
      case AssetCategory.consumptionAssets:
        return Colors.teal;
      case AssetCategory.receivables:
        return Colors.purple;
      case AssetCategory.liabilities:
        return Colors.red;
    }
  }
}

class _ChartData {
  _ChartData({
    required this.category,
    required this.amount,
    required this.percentage,
  });
  final AssetCategory category;
  final double amount;
  final double percentage;
}
