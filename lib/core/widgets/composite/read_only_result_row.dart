import 'package:flutter/material.dart';
import '../../theme/app_design_tokens.dart';

/// S23: 只读结果展示行样式（ReadOnlyResultRowStyle）
/// 用于展示系统自动计算的只读结果，如扣款金额
///
/// **重构后的样式特征：**
/// - 放弃背景色块，改为左侧标签 + 右侧结果
/// - 结果使用 subtitle (14pt) + SemiBold 字重
/// - 颜色使用 secondaryTextColor (深灰)，配合左侧的 bodyText 标签
/// - 实现柔和的层级区分，保持"清爽"的留白感
class ReadOnlyResultRow extends StatelessWidget {
  /// 左侧标题
  final String label;

  /// 右侧数值（会自动格式化为金额）
  final double? amount;

  /// 自定义数值显示文本（如果提供，将覆盖 amount）
  final String? customValueText;

  /// 数值颜色（默认使用 secondaryTextColor）
  final Color? valueColor;

  /// 标题样式
  final TextStyle? labelStyle;

  /// 数值样式
  final TextStyle? valueStyle;

  /// 行间距
  final double? spacing;

  const ReadOnlyResultRow({
    super.key,
    required this.label,
    this.amount,
    this.customValueText,
    this.valueColor,
    this.labelStyle,
    this.valueStyle,
    this.spacing,
  }) : assert(amount != null || customValueText != null,
            '必须提供 amount 或 customValueText');

  @override
  Widget build(BuildContext context) {
    final displayValue = customValueText ??
        (amount != null ? '¥${amount!.toStringAsFixed(2)}' : '');

    // 使用 secondaryTextColor (深灰) 作为结果颜色
    final effectiveValueColor =
        valueColor ?? AppDesignTokens.secondaryText(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 左侧标签（bodyText）
        Text(
          label,
          style: labelStyle ?? AppDesignTokens.body(context), // 使用正文样式（17pt）
        ),
        // 右侧结果（无背景色块，仅文字）
        Text(
          displayValue,
          style: valueStyle ??
              AppDesignTokens.subtitle(context).copyWith(
                fontWeight: FontWeight.w600, // 14pt SemiBold
                color: effectiveValueColor, // secondaryTextColor (深灰)
              ),
        ),
      ],
    );
  }
}
