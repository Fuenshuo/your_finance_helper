import 'package:flutter/material.dart';
import '../../theme/app_design_tokens.dart';
import 'standard_list_item.dart';

/// 可操作列表项 (ActionableListItemStyle)
/// 右侧有操作按钮（编辑、删除等），用于需要操作的列表项
/// 
/// **应用场景：**
/// - 奖金列表、福利列表等需要编辑/删除的列表项
/// - 所有需要操作按钮的列表项
class ActionableListItem extends StandardListItem {
  /// 右侧操作按钮列表
  final List<Widget> actions;
  
  /// 副标题（显示在标题下方）
  final String? subtitle;
  
  /// 副标题样式
  final TextStyle? subtitleStyle;

  const ActionableListItem({
    super.key,
    required super.title,
    super.leading,
    super.titleStyle,
    super.spacing,
    required this.actions,
    this.subtitle,
    this.subtitleStyle,
  });

  @override
  Widget buildLeading(BuildContext context) {
    if (subtitle == null) {
      return super.buildLeading(context);
    }
    
    // 当有 subtitle 时，需要自定义布局
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 标题行（图标 + 标题）
        Row(
          children: [
            if (leading != null) ...[
              leading!,
              SizedBox(width: AppDesignTokens.spacing12),
            ],
            Expanded(
              child: Text(
                title,
                style: titleStyle ?? AppDesignTokens.body(context),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        SizedBox(height: AppDesignTokens.spacing4),
        Text(
          subtitle!,
          style: subtitleStyle ?? AppDesignTokens.caption(context),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  @override
  Widget buildTrailing(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: actions,
    );
  }

  @override
  Widget build(BuildContext context) {
    // 如果有副标题，使用更大的最小高度，但不固定高度
    final minHeight = subtitle != null ? 80.0 : 56.0;
    
    return Container(
      constraints: BoxConstraints(
        minHeight: minHeight,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: AppDesignTokens.globalHorizontalPadding,
        vertical: subtitle != null ? AppDesignTokens.spacing12 : AppDesignTokens.spacingMedium,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: buildLeading(context),
          ),
          SizedBox(width: AppDesignTokens.spacing12),
          Padding(
            padding: EdgeInsets.only(top: subtitle != null ? AppDesignTokens.spacing4 : 0),
            child: buildTrailing(context),
          ),
        ],
      ),
    );
  }
}

