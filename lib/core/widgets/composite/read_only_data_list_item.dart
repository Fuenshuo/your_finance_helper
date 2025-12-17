import 'package:flutter/material.dart';
import 'package:your_finance_flutter/core/theme/app_design_tokens.dart';
import 'package:your_finance_flutter/core/widgets/composite/standard_list_item.dart';

/// 只读数据行 (ReadOnlyDataListItemStyle)
/// 无箭头，右侧数据使用 SemiBold + SecondaryTextColor 强调
///
/// **应用场景：**
/// - S27: 阅读净收入、表单中的计算结果、AI 解析结果
/// - 所有只读的数据展示行
class ReadOnlyDataListItem extends StandardListItem {
  const ReadOnlyDataListItem({
    required super.title,
    super.key,
    super.leading,
    super.titleStyle,
    super.spacing,
    this.amount,
    this.customValueText,
    this.valueColor,
    this.valueStyle,
  }) : assert(
          amount != null || customValueText != null,
          '必须提供 amount 或 customValueText',
        );

  /// 右侧数据值（会自动格式化为金额）
  final double? amount;

  /// 自定义数值显示文本（如果提供，将覆盖 amount）
  final String? customValueText;

  /// 数值颜色（默认使用 secondaryTextColor）
  final Color? valueColor;

  /// 自定义数值样式
  final TextStyle? valueStyle;

  @override
  Widget buildTrailing(BuildContext context) {
    final displayValue = customValueText ??
        (amount != null ? '¥${amount!.toStringAsFixed(2)}' : '');

    // 使用 secondaryTextColor (深灰) 作为结果颜色
    final effectiveValueColor =
        valueColor ?? AppDesignTokens.secondaryText(context);

    return Text(
      displayValue,
      style: valueStyle ??
          AppDesignTokens.subtitle(context).copyWith(
            fontWeight: FontWeight.w600, // 14pt SemiBold
            color: effectiveValueColor, // secondaryTextColor (深灰)
          ),
    );
  }
}
