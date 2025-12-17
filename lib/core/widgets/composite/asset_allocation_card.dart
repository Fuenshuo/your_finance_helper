import 'package:flutter/material.dart';
import 'package:your_finance_flutter/core/theme/app_design_tokens.dart';
import 'package:your_finance_flutter/core/widgets/app_card.dart';

/// 资产配置卡片样式
/// 使用紧凑型水平堆叠条形图替代圆饼图
///
/// **样式特征：**
/// - 紧凑型水平堆叠条形图，信息转化率高
/// - 最重要的账户类型使用 PrimaryColor
/// - 次要的用 SecondaryColor 或柔和的 SurfaceColor
/// - 提供快速的比例认知
class AssetAllocationCard extends StatelessWidget {
  const AssetAllocationCard({
    required this.title,
    required this.allocationData,
    required this.totalAssets,
    super.key,
    this.colorMap,
    this.padding,
  });

  /// 标题
  final String title;

  /// 资产配置数据（账户类型 -> 金额）
  final Map<String, double> allocationData;

  /// 总资产（用于计算百分比）
  final double totalAssets;

  /// 自定义颜色映射（账户类型 -> 颜色）
  final Map<String, Color>? colorMap;

  /// 卡片内边距
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    if (allocationData.isEmpty || totalAssets <= 0) {
      return AppCard(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppDesignTokens.cardTitle(context),
            ),
            const SizedBox(height: AppDesignTokens.spacingMedium),
            Text(
              '暂无资产数据',
              style: AppDesignTokens.body(context),
            ),
          ],
        ),
      );
    }

    // 按金额排序，最重要的在前
    final sortedEntries = allocationData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return AppCard(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Text(
            title,
            style: AppDesignTokens.cardTitle(context), // 18pt SemiBold
          ),
          const SizedBox(height: AppDesignTokens.spacingMedium),
          // 紧凑型水平堆叠条形图
          _buildStackedBarChart(context, sortedEntries),
          const SizedBox(height: AppDesignTokens.spacingMedium),
          // 图例（紧凑布局）
          _buildLegend(context, sortedEntries),
        ],
      ),
    );
  }

  /// 构建堆叠条形图
  Widget _buildStackedBarChart(
    BuildContext context,
    List<MapEntry<String, double>> entries,
  ) =>
      Container(
        height: 8, // 紧凑的条形图高度
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: AppDesignTokens.inputFill(context), // 背景色
        ),
        child: Row(
          children: entries.map((entry) {
            final color = _getColorForCategory(context, entry.key);

            return Expanded(
              flex: (entry.value * 1000).round(), // 使用 flex 来分配宽度
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: _getBorderRadiusForSegment(entry, entries),
                ),
              ),
            );
          }).toList(),
        ),
      );

  /// 获取分段圆角（首尾需要圆角）
  BorderRadius _getBorderRadiusForSegment(
    MapEntry<String, double> current,
    List<MapEntry<String, double>> all,
  ) {
    final isFirst = all.first == current;
    final isLast = all.last == current;

    if (isFirst && isLast) {
      return BorderRadius.circular(4); // 唯一一个，全部圆角
    } else if (isFirst) {
      return const BorderRadius.only(
        topLeft: Radius.circular(4),
        bottomLeft: Radius.circular(4),
      );
    } else if (isLast) {
      return const BorderRadius.only(
        topRight: Radius.circular(4),
        bottomRight: Radius.circular(4),
      );
    }
    return BorderRadius.zero;
  }

  /// 构建图例
  Widget _buildLegend(
    BuildContext context,
    List<MapEntry<String, double>> entries,
  ) =>
      Wrap(
        spacing: AppDesignTokens.spacingMedium,
        runSpacing: AppDesignTokens.spacingMinor,
        children: entries.map((entry) {
          final percentage = (entry.value / totalAssets) * 100;
          final color = _getColorForCategory(context, entry.key);

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: AppDesignTokens.spacingMinor),
              Text(
                '${entry.key} ${percentage.toStringAsFixed(1)}%',
                style: AppDesignTokens.label(context), // 12pt Regular
              ),
            ],
          );
        }).toList(),
      );

  /// 获取账户类型的颜色
  /// 最重要的使用 PrimaryColor，次要的使用 SecondaryColor 或柔和的 SurfaceColor
  Color _getColorForCategory(BuildContext context, String category) {
    if (colorMap != null && colorMap!.containsKey(category)) {
      return colorMap![category]!;
    }

    // 默认颜色方案：最重要的使用 PrimaryColor
    final sortedEntries = allocationData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final index = sortedEntries.indexWhere((e) => e.key == category);

    if (index == 0) {
      // 最重要的账户类型：使用 PrimaryColor
      return AppDesignTokens.primaryAction(context);
    } else if (index == 1) {
      // 第二重要的：使用 SuccessColor（鲜草绿）
      return AppDesignTokens.successColor(context);
    } else {
      // 其他：使用柔和的 SurfaceColor 变体
      return AppDesignTokens.secondaryText(context).withValues(alpha: 0.3);
    }
  }
}
