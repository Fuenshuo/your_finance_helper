import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/responsive_text_styles.dart';

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
    final card = Container(
      margin: margin ?? EdgeInsets.all(context.responsiveSpacing8),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(context.borderRadius),
        boxShadow: showShadow ? [context.cardShadow] : null,
      ),
      child: Padding(
        padding: padding ?? EdgeInsets.all(context.responsiveSpacing16),
        child: child,
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(context.borderRadius),
          child: card,
        ),
      );
    }

    return card;
  }
}

// 带标题的卡片
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
                style: context.responsiveHeadlineMedium,
              ),
              if (trailing != null) trailing!,
            ],
          ),
          SizedBox(height: context.responsiveSpacing16),
          child,
        ],
      ),
    );
  }
}

// 统计卡片
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
                  color: context.secondaryText,
                ),
                SizedBox(width: context.responsiveSpacing8),
              ],
              Expanded(
                child: Text(
                  title,
                  style: context.responsiveBodyMedium,
                ),
              ),
            ],
          ),
          SizedBox(height: context.responsiveSpacing8),
          Text(
            value,
            style: context.statCardAmountStyle(isPositive: valueColor == context.increaseColor).copyWith(
              color: valueColor ?? context.primaryText,
            ),
          ),
          if (subtitle != null) ...[
            SizedBox(height: context.responsiveSpacing4),
            Text(
              subtitle!,
              style: context.responsiveBodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}
