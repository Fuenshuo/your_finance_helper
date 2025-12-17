import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../theme/app_design_tokens.dart';
import 'standard_list_item.dart';

/// 导航/可编辑行 (NavigableListItemStyle)
/// 右侧有箭头 >，点击有波纹效果
///
/// **应用场景：**
/// - S27: 交易分类、账户选择、日期选择
/// - 所有需要导航到下一页或弹窗的列表项
class NavigableListItem extends StandardListItem {
  /// 右侧内容（可选，如果提供则显示在箭头前）
  final Widget? trailingContent;

  /// 点击回调
  final VoidCallback? onTap;

  /// 是否显示箭头（默认 true）
  final bool showArrow;

  const NavigableListItem({
    super.key,
    required super.title,
    super.leading,
    super.titleStyle,
    super.spacing,
    this.trailingContent,
    this.onTap,
    this.showArrow = true,
  });

  @override
  Widget buildTrailing(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (trailingContent != null) ...[
          trailingContent!,
          SizedBox(width: AppDesignTokens.spacing8),
        ],
        if (showArrow)
          Icon(
            CupertinoIcons.chevron_right,
            size: 16,
            color: AppDesignTokens.secondaryText(context),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = super.build(context);

    if (onTap == null) {
      return content;
    }

    return InkWell(
      onTap: onTap,
      child: content,
    );
  }
}
