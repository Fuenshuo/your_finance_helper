import 'package:flutter/material.dart';

class AppTheme {
  // 色彩规范 - 按照UI_UX设计文档
  static const Color primaryBackground = Color(0xFFF7F7FA); // 淡雅灰
  static const Color accentBackground = Color(0xFFEAEAFB); // 温柔紫
  static const Color primaryAction = Color(0xFF007AFF); // 活力蓝
  static const Color primaryText = Color(0xFF1C1C1E); // 深邃灰
  static const Color secondaryText = Color(0xFF8A8A8E); // 中性灰
  static const Color dividerColor = Color(0xFFE5E5EA); // 浅灰
  static const Color increaseColor = Color(0xFFFF3B30); // 温暖红
  static const Color decreaseColor = Color(0xFF34C759); // 理性绿
  static const Color warningColor = Color(0xFFFF9500); // 橙色

  // 字体规范
  static const String fontFamily = 'Inter'; // 优先使用Inter，回退到系统字体

  // 布局规范
  static const double borderRadius = 12.0; // 12pt圆角
  static const double baseSpacing = 8.0; // 8pt基础单位

  // 阴影规范
  static BoxShadow get cardShadow => BoxShadow(
        color: Colors.black.withOpacity(0.04),
        blurRadius: 16,
        spreadRadius: 0,
        offset: const Offset(0, 4),
      );

  // 主题数据
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,
      
      // 色彩方案
      colorScheme: const ColorScheme.light(
        primary: primaryAction,
        secondary: accentBackground,
        surface: Colors.white,
        onPrimary: Colors.white,
        onSecondary: primaryText,
        onSurface: primaryText,
        outline: dividerColor,
      ),

      // 应用栏主题
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: primaryText,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: primaryText,
        ),
      ),

      // 卡片主题
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        shadowColor: Colors.black.withOpacity(0.04),
      ),

      // 按钮主题
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryAction,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // 文本按钮主题
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryAction,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // 输入框主题
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: primaryAction, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: const TextStyle(
          fontFamily: fontFamily,
          fontSize: 17,
          color: secondaryText,
        ),
      ),

      // 文本主题
      textTheme: const TextTheme(
        // 大标题 (金额)
        displayLarge: TextStyle(
          fontFamily: fontFamily,
          fontSize: 34,
          fontWeight: FontWeight.w600,
          color: primaryText,
        ),
        // 页面标题
        displayMedium: TextStyle(
          fontFamily: fontFamily,
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: primaryText,
        ),
        // 卡片标题
        headlineMedium: TextStyle(
          fontFamily: fontFamily,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: primaryText,
        ),
        // 正文/列表项
        bodyLarge: TextStyle(
          fontFamily: fontFamily,
          fontSize: 17,
          fontWeight: FontWeight.w400,
          color: primaryText,
        ),
        // 辅助说明
        bodyMedium: TextStyle(
          fontFamily: fontFamily,
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: secondaryText,
        ),
        // 标签/按钮文字
        labelLarge: TextStyle(
          fontFamily: fontFamily,
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: primaryText,
        ),
      ),

      // 浮动操作按钮主题
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryAction,
        foregroundColor: Colors.white,
        elevation: 4,
      ),

      // 分割线主题
      dividerTheme: const DividerThemeData(
        color: dividerColor,
        thickness: 0.5,
        space: 1,
      ),
    );
  }
}

// 扩展方法，方便使用设计规范
extension AppThemeExtensions on BuildContext {
  // 获取主题色彩
  Color get primaryBackground => AppTheme.primaryBackground;
  Color get accentBackground => AppTheme.accentBackground;
  Color get primaryAction => AppTheme.primaryAction;
  Color get primaryText => AppTheme.primaryText;
  Color get secondaryText => AppTheme.secondaryText;
  Color get dividerColor => AppTheme.dividerColor;
  Color get increaseColor => AppTheme.increaseColor;
  Color get decreaseColor => AppTheme.decreaseColor;
  Color get warningColor => AppTheme.warningColor;
  
  // 别名，为了兼容性
  Color get successColor => AppTheme.increaseColor; // 温暖红
  Color get errorColor => AppTheme.decreaseColor; // 理性绿

  // 获取间距
  double get spacing4 => AppTheme.baseSpacing * 0.5; // 4pt
  double get spacing8 => AppTheme.baseSpacing; // 8pt
  double get spacing12 => AppTheme.baseSpacing * 1.5; // 12pt
  double get spacing16 => AppTheme.baseSpacing * 2; // 16pt
  double get spacing24 => AppTheme.baseSpacing * 3; // 24pt
  double get spacing32 => AppTheme.baseSpacing * 4; // 32pt

  // 获取圆角
  double get borderRadius => AppTheme.borderRadius;

  // 获取阴影
  BoxShadow get cardShadow => AppTheme.cardShadow;

  // 格式化金额
  String formatAmount(double amount, {String currency = 'CNY'}) {
    if (currency == 'CNY') {
      return '¥${amount.toStringAsFixed(2)}';
    }
    return '\$${amount.toStringAsFixed(2)}';
  }

  // 格式化百分比
  String formatPercentage(double percentage) {
    return '${percentage.toStringAsFixed(1)}%';
  }

  // 获取文本主题
  TextTheme get textTheme => Theme.of(this).textTheme;

  // 格式化日期时间
  String formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  // 格式化日期
  String formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // 格式化时间
  String formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  // 获取边框颜色
  Color get borderColor => dividerColor;
}
