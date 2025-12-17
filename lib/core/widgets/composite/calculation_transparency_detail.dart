import 'package:flutter/material.dart';
import '../../theme/app_design_tokens.dart';

/// S24: 计算透明度详情样式
/// 显示计算的底层依据（基数、比例、税率），建立用户信任
///
/// **样式特征：**
/// - 使用 `AppDesignTokens.microCaption(context)`（10pt，次要灰色）
/// - 通常紧跟在 S23 ReadOnlyResultRow 之下
class CalculationTransparencyDetail extends StatelessWidget {
  /// 详情文本内容
  final String text;

  /// 自定义样式（默认使用 microCaption）
  final TextStyle? style;

  /// 顶部间距
  final double? topSpacing;

  const CalculationTransparencyDetail({
    super.key,
    required this.text,
    this.style,
    this.topSpacing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: topSpacing ?? AppDesignTokens.spacing8),
      child: Text(
        text,
        style: style ?? AppDesignTokens.microCaption(context),
      ),
    );
  }
}
