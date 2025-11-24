import 'package:flutter/material.dart';
import '../theme/app_design_tokens.dart';
import '../theme/app_design_tokens.dart' show AppStyle;

/// 现代卡片组件
/// 特性：有色阴影、Surface 颜色、内容边距
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final bool showShadow;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.onTap,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    final currentStyle = AppDesignTokens.getCurrentStyle();
    final isSharpProfessional = currentStyle == AppStyle.SharpProfessional;
    
    // SharpProfessional: Elevation 2.0 的清晰阴影，确保卡片与背景分界明确
    // iOS Fintech: 使用原有的有色阴影
    final boxShadow = showShadow
        ? (isSharpProfessional
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08), // 略深，确保分界清晰
                  blurRadius: 8, // 清晰的模糊半径
                  offset: const Offset(0, 2), // Elevation 2.0
                  spreadRadius: 0, // 无扩散，保持紧凑
                ),
              ]
            : [
                AppDesignTokens.primaryShadow(context),
              ])
        : null;
    
    // 使用统一的水平边距，确保内容对齐
    final effectivePadding = padding ?? EdgeInsets.symmetric(
      horizontal: AppDesignTokens.globalHorizontalPadding,
      vertical: AppDesignTokens.spacing16,
    );
    
    final cardContent = Container(
      width: double.infinity,
      margin: margin ?? EdgeInsets.zero,
      padding: effectivePadding,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppDesignTokens.surface(context),
        borderRadius: BorderRadius.circular(AppDesignTokens.radiusMedium(context)),
        boxShadow: boxShadow,
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: cardContent,
      );
    }

    return cardContent;
  }
}

// 带标题的卡片（兼容旧代码）
class AppCardWithTitle extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;

  const AppCardWithTitle({
    super.key,
    required this.title,
    required this.child,
    this.trailing,
    this.padding,
    this.margin,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: padding,
      margin: margin,
      backgroundColor: backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppDesignTokens.headline(context),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          SizedBox(height: AppDesignTokens.spacing16),
          child,
        ],
      ),
    );
  }
}

// 统计卡片（兼容旧代码）
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final Color? valueColor;
  final IconData? icon;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.valueColor,
    this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 20,
                  color: AppDesignTokens.secondaryText(context),
                ),
                SizedBox(width: AppDesignTokens.spacing8),
              ],
              Expanded(
                child: Text(
                  title,
                  style: AppDesignTokens.body(context).copyWith(
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppDesignTokens.spacing8),
          Text(
            value,
            style: AppDesignTokens.title1(context).copyWith(
              color: valueColor ?? AppDesignTokens.primaryText(context),
            ),
          ),
          if (subtitle != null) ...[
            SizedBox(height: AppDesignTokens.spacing4),
            Text(
              subtitle!,
              style: AppDesignTokens.caption(context),
            ),
          ],
        ],
      ),
    );
  }
}
