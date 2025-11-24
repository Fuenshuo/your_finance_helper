import 'package:flutter/material.dart';
import '../../theme/app_design_tokens.dart';
import '../app_card.dart';

/// S22: 核心数据卡片样式（LargeDataDisplayCardStyle）
/// 用于展示最高层级的关键结果（KPI）
/// 
/// **重构后的样式特征：**
/// - 数据居中显示，最大化视觉冲击力
/// - 顶部 3px PrimaryColor 强调线，提供视觉锚点
/// - 底部可选迷你折线图，赋予数据生命力
/// - 主数值使用 dataDisplayLarge (28pt Bold)
class CoreDataCard extends StatelessWidget {
  /// 副标题/描述文字
  final String subtitle;
  
  /// 主数值（会自动格式化为金额）
  final double value;
  
  /// 自定义数值显示文本（如果提供，将覆盖 value）
  final String? customValueText;
  
  /// 数值颜色（默认使用主题色）
  final Color? valueColor;
  
  /// 自定义数值样式
  final TextStyle? valueStyle;
  
  /// 副标题样式
  final TextStyle? subtitleStyle;
  
  /// 卡片内边距
  final EdgeInsetsGeometry? padding;
  
  /// 点击回调
  final VoidCallback? onTap;
  
  /// 趋势数据（用于底部迷你折线图）
  /// 如果提供，将在底部显示趋势图
  final List<double>? trendData;
  
  /// 是否显示顶部强调线（默认 true）
  final bool showTopAccent;

  const CoreDataCard({
    super.key,
    required this.subtitle,
    required this.value,
    this.customValueText,
    this.valueColor,
    this.valueStyle,
    this.subtitleStyle,
    this.padding,
    this.onTap,
    this.trendData,
    this.showTopAccent = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AppCard(
          onTap: onTap,
          padding: padding ?? EdgeInsets.symmetric(
            horizontal: AppDesignTokens.globalHorizontalPadding,
            vertical: AppDesignTokens.spacing24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center, // 居中显示
            children: [
              // 副标题
              Text(
                subtitle,
                style: subtitleStyle ?? AppDesignTokens.subtitle(context), // 14pt Regular
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppDesignTokens.spacingMedium),
              // 主数值（居中，最大化）
              Text(
                customValueText ?? '￥${value.toStringAsFixed(2)}',
                style: valueStyle ?? AppDesignTokens.primaryValue(context).copyWith(
                  fontSize: 28, // dataDisplayLarge: 28pt Bold
                  fontWeight: FontWeight.w700,
                  color: valueColor ?? AppDesignTokens.primaryAction(context),
                ),
                textAlign: TextAlign.center,
              ),
              // 底部趋势图（如果提供数据）
              if (trendData != null && trendData!.isNotEmpty) ...[
                SizedBox(height: AppDesignTokens.spacingMedium),
                _buildTrendChart(context, trendData!),
              ],
            ],
          ),
        ),
        // 顶部 3px PrimaryColor 强调线
        if (showTopAccent)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 3,
              decoration: BoxDecoration(
                color: AppDesignTokens.primaryAction(context),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppDesignTokens.radiusMedium(context)),
                  topRight: Radius.circular(AppDesignTokens.radiusMedium(context)),
                ),
              ),
            ),
          ),
      ],
    );
  }
  
  /// 构建迷你折线图（趋势图）
  Widget _buildTrendChart(BuildContext context, List<double> data) {
    if (data.isEmpty) return const SizedBox.shrink();
    
    final maxValue = data.reduce((a, b) => a > b ? a : b);
    final minValue = data.reduce((a, b) => a < b ? a : b);
    final range = maxValue - minValue;
    
    return SizedBox(
      height: 40, // 紧凑的迷你图表高度
      child: CustomPaint(
        painter: _TrendChartPainter(
          data: data,
          maxValue: maxValue,
          minValue: minValue,
          range: range > 0 ? range : 1,
          color: AppDesignTokens.secondaryText(context).withOpacity(0.3), // 浅灰色线条
        ),
        size: Size.infinite,
      ),
    );
  }
}

/// 趋势图绘制器
class _TrendChartPainter extends CustomPainter {
  final List<double> data;
  final double maxValue;
  final double minValue;
  final double range;
  final Color color;

  _TrendChartPainter({
    required this.data,
    required this.maxValue,
    required this.minValue,
    required this.range,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;
    
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    final path = Path();
    final stepX = size.width / (data.length - 1);
    
    for (var i = 0; i < data.length; i++) {
      final x = i * stepX;
      final normalizedValue = (data[i] - minValue) / range;
      final y = size.height - (normalizedValue * size.height);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_TrendChartPainter oldDelegate) =>
      oldDelegate.data != data ||
      oldDelegate.maxValue != maxValue ||
      oldDelegate.minValue != minValue;
}

