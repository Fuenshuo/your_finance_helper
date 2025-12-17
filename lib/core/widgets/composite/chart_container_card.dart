import 'package:flutter/material.dart';
import '../../theme/app_design_tokens.dart';
import '../app_card.dart';
import '../app_selection_controls.dart';

/// S27: 图表容器卡片样式
/// 承载复杂的可视化内容
///
/// **样式特征：**
/// - 卡片顶部有标题/时间切换器，下方是图表区域
/// - 纯白色或浅灰色背景，12pt 圆角，带有轻微阴影
class ChartContainerCard<T extends Object> extends StatelessWidget {
  /// 标题文本
  final String title;

  /// 图表内容
  final Widget chart;

  /// 图表高度
  final double chartHeight;

  /// 分段选择器配置（可选）
  final Map<T, Widget>? segmentedControlChildren;

  /// 分段选择器当前值
  final T? segmentedControlValue;

  /// 分段选择器值变化回调
  final ValueChanged<T?>? onSegmentedControlChanged;

  /// 自定义标题样式
  final TextStyle? titleStyle;

  /// 卡片内边距
  final EdgeInsetsGeometry? padding;

  const ChartContainerCard({
    super.key,
    required this.title,
    required this.chart,
    this.chartHeight = 200,
    this.segmentedControlChildren,
    this.segmentedControlValue,
    this.onSegmentedControlChanged,
    this.titleStyle,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: padding ?? const EdgeInsets.all(AppDesignTokens.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (segmentedControlChildren != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: titleStyle ??
                        AppDesignTokens.subtitle(context), // 使用副标题样式（14pt），降低权重
                  ),
                ),
                const SizedBox(width: AppDesignTokens.spacing16),
                AppSegmentedControl<T>(
                  children: segmentedControlChildren!,
                  groupValue: segmentedControlValue,
                  onValueChanged: onSegmentedControlChanged ?? (_) {},
                ),
              ],
            )
          else
            Text(
              title,
              style: titleStyle ??
                  AppDesignTokens.subtitle(context), // 使用副标题样式（14pt），降低权重
            ),
          const SizedBox(height: AppDesignTokens.spacing16),
          // 图表区域
          SizedBox(
            height: chartHeight,
            child: chart,
          ),
        ],
      ),
    );
  }
}
