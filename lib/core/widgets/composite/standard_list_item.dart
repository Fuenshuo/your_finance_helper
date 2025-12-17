import 'package:flutter/material.dart';
import 'package:your_finance_flutter/core/theme/app_design_tokens.dart';

/// 基础列表行样式 (StandardListItemStyle)
/// 所有列表行的基类，定义了左右对齐、固定高度和间距
///
/// **样式特征：**
/// - 固定高度：56pt（标准列表行高度）
/// - 水平内边距：使用 globalHorizontalPadding (20pt)
/// - 垂直内边距：16pt
/// - 左右对齐：MainAxisAlignment.spaceBetween
abstract class StandardListItem extends StatelessWidget {
  const StandardListItem({
    required this.title,
    super.key,
    this.leading,
    this.titleStyle,
    this.spacing,
  });

  /// 左侧标题/标签
  final String title;

  /// 左侧图标（可选）
  final Widget? leading;

  /// 自定义标题样式
  final TextStyle? titleStyle;

  /// 行间距（用于列表中的多个项）
  final double? spacing;

  /// 构建左侧内容（标题 + 图标）
  Widget buildLeading(BuildContext context) {
    if (leading != null) {
      return Row(
        children: [
          leading!,
          const SizedBox(width: AppDesignTokens.spacing12),
          Expanded(
            child: Text(
              title,
              style: titleStyle ?? AppDesignTokens.body(context),
            ),
          ),
        ],
      );
    }
    return Text(
      title,
      style: titleStyle ?? AppDesignTokens.body(context),
    );
  }

  /// 构建右侧内容（由子类实现）
  Widget buildTrailing(BuildContext context);

  @override
  Widget build(BuildContext context) => Container(
        height: 56, // 固定高度：56pt
        padding: const EdgeInsets.symmetric(
          horizontal: AppDesignTokens.globalHorizontalPadding,
          vertical: AppDesignTokens.spacingMedium,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: buildLeading(context),
            ),
            const SizedBox(width: AppDesignTokens.spacing12),
            buildTrailing(context),
          ],
        ),
      );
}
