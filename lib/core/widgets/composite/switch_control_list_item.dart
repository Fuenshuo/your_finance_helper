import 'package:flutter/material.dart';
import 'package:your_finance_flutter/core/theme/app_design_tokens.dart';
import 'package:your_finance_flutter/core/widgets/app_selection_controls.dart';
import 'package:your_finance_flutter/core/widgets/composite/standard_list_item.dart';

/// 开关控制行 (SwitchControlListItemStyle)
/// 右侧是开关，标题字体应为 sectionTitle (18pt SemiBold)
///
/// **应用场景：**
/// - S26: 开启计划关联、通知设置开关
/// - 所有需要开关控制的设置项
class SwitchControlListItem extends StandardListItem {
  const SwitchControlListItem({
    required super.title,
    required this.value,
    super.key,
    super.leading,
    super.titleStyle,
    super.spacing,
    this.onChanged,
    this.enabled = true,
  });

  /// 开关的值
  final bool value;

  /// 开关值变化回调
  final ValueChanged<bool>? onChanged;

  /// 是否启用开关（默认 true）
  final bool enabled;

  @override
  Widget buildLeading(BuildContext context) {
    // 标题使用 sectionTitle (18pt SemiBold)
    final effectiveTitleStyle =
        titleStyle ?? AppDesignTokens.cardTitle(context);

    if (leading != null) {
      return Row(
        children: [
          leading!,
          const SizedBox(width: AppDesignTokens.spacing12),
          Expanded(
            child: Text(
              title,
              style: effectiveTitleStyle,
            ),
          ),
        ],
      );
    }
    return Text(
      title,
      style: effectiveTitleStyle,
    );
  }

  @override
  Widget buildTrailing(BuildContext context) => AppSwitch(
        value: value,
        onChanged: enabled ? onChanged : null,
      );
}
