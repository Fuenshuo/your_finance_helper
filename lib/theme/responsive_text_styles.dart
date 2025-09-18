import 'package:flutter/material.dart';
import 'package:your_finance_flutter/theme/app_theme.dart';

/// 响应式文本样式工具类
class ResponsiveTextStyles {
  static TextStyle getDisplayLarge(BuildContext context) => TextStyle(
        fontFamily: AppTheme.fontFamily,
        fontSize: AppTheme.getResponsiveFontSize(context, 34),
        fontWeight: FontWeight.w600,
        color: AppTheme.primaryText,
      );

  static TextStyle getDisplayMedium(BuildContext context) => TextStyle(
        fontFamily: AppTheme.fontFamily,
        fontSize: AppTheme.getResponsiveFontSize(context, 28),
        fontWeight: FontWeight.w700,
        color: AppTheme.primaryText,
      );

  static TextStyle getHeadlineMedium(BuildContext context) => TextStyle(
        fontFamily: AppTheme.fontFamily,
        fontSize: AppTheme.getResponsiveFontSize(context, 17),
        fontWeight: FontWeight.w600,
        color: AppTheme.primaryText,
      );

  static TextStyle getBodyLarge(BuildContext context) => TextStyle(
        fontFamily: AppTheme.fontFamily,
        fontSize: AppTheme.getResponsiveFontSize(context, 17),
        fontWeight: FontWeight.w400,
        color: AppTheme.primaryText,
      );

  static TextStyle getBodyMedium(BuildContext context) => TextStyle(
        fontFamily: AppTheme.fontFamily,
        fontSize: AppTheme.getResponsiveFontSize(context, 15),
        fontWeight: FontWeight.w400,
        color: AppTheme.secondaryText,
      );

  static TextStyle getLabelLarge(BuildContext context) => TextStyle(
        fontFamily: AppTheme.fontFamily,
        fontSize: AppTheme.getResponsiveFontSize(context, 15),
        fontWeight: FontWeight.w500,
        color: AppTheme.primaryText,
      );

  // 移动端优化的文本样式
  static TextStyle getMobileTitle(BuildContext context) => TextStyle(
        fontFamily: AppTheme.fontFamily,
        fontSize: AppTheme.getResponsiveFontSize(context, 20),
        fontWeight: FontWeight.w600,
        color: AppTheme.primaryText,
      );

  static TextStyle getMobileSubtitle(BuildContext context) => TextStyle(
        fontFamily: AppTheme.fontFamily,
        fontSize: AppTheme.getResponsiveFontSize(context, 16),
        fontWeight: FontWeight.w500,
        color: AppTheme.primaryText,
      );

  static TextStyle getMobileBody(BuildContext context) => TextStyle(
        fontFamily: AppTheme.fontFamily,
        fontSize: AppTheme.getResponsiveFontSize(context, 14),
        fontWeight: FontWeight.w400,
        color: AppTheme.primaryText,
      );

  static TextStyle getMobileCaption(BuildContext context) => TextStyle(
        fontFamily: AppTheme.fontFamily,
        fontSize: AppTheme.getResponsiveFontSize(context, 12),
        fontWeight: FontWeight.w400,
        color: AppTheme.secondaryText,
      );

  // 金额显示样式
  static TextStyle getAmountStyle(BuildContext context,
          {bool isPositive = true}) =>
      TextStyle(
        fontFamily: AppTheme.fontFamily,
        fontSize: AppTheme.getResponsiveFontSize(context, 18),
        fontWeight: FontWeight.w600,
        color: isPositive ? AppTheme.increaseColor : AppTheme.decreaseColor,
      );

  // 大金额显示样式
  static TextStyle getLargeAmountStyle(BuildContext context,
          {bool isPositive = true}) =>
      TextStyle(
        fontFamily: AppTheme.fontFamily,
        fontSize: AppTheme.getResponsiveFontSize(context, 24),
        fontWeight: FontWeight.w700,
        color: isPositive ? AppTheme.increaseColor : AppTheme.decreaseColor,
      );

  // StatCard专用金额样式（移动端优化）
  static TextStyle getStatCardAmountStyle(BuildContext context,
          {bool isPositive = true}) =>
      TextStyle(
        fontFamily: AppTheme.fontFamily,
        fontSize: AppTheme.getResponsiveFontSize(context, 16),
        fontWeight: FontWeight.w600,
        color: isPositive ? AppTheme.increaseColor : AppTheme.decreaseColor,
      );
}

/// 扩展方法，方便使用响应式文本样式
extension ResponsiveTextStylesExtension on BuildContext {
  TextStyle get responsiveDisplayLarge =>
      ResponsiveTextStyles.getDisplayLarge(this);
  TextStyle get responsiveDisplayMedium =>
      ResponsiveTextStyles.getDisplayMedium(this);
  TextStyle get responsiveHeadlineMedium =>
      ResponsiveTextStyles.getHeadlineMedium(this);
  TextStyle get responsiveBodyLarge => ResponsiveTextStyles.getBodyLarge(this);
  TextStyle get responsiveBodyMedium =>
      ResponsiveTextStyles.getBodyMedium(this);
  TextStyle get responsiveLabelLarge =>
      ResponsiveTextStyles.getLabelLarge(this);

  // 移动端优化样式
  TextStyle get mobileTitle => ResponsiveTextStyles.getMobileTitle(this);
  TextStyle get mobileSubtitle => ResponsiveTextStyles.getMobileSubtitle(this);
  TextStyle get mobileBody => ResponsiveTextStyles.getMobileBody(this);
  TextStyle get mobileCaption => ResponsiveTextStyles.getMobileCaption(this);

  // 金额样式
  TextStyle amountStyle({bool isPositive = true}) =>
      ResponsiveTextStyles.getAmountStyle(this, isPositive: isPositive);
  TextStyle largeAmountStyle({bool isPositive = true}) =>
      ResponsiveTextStyles.getLargeAmountStyle(this, isPositive: isPositive);
  TextStyle statCardAmountStyle({bool isPositive = true}) =>
      ResponsiveTextStyles.getStatCardAmountStyle(this, isPositive: isPositive);
}
