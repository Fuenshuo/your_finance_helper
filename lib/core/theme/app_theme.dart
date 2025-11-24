import 'package:flutter/foundation.dart';
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
  static const String fontFamily = 'Alibaba PuHuiTi'; // 阿里巴巴普惠体

  // 布局规范
  static const double borderRadius = 12.0; // 12pt圆角
  static const double baseSpacing = 8.0; // 8pt基础单位

  // 阴影规范
  static BoxShadow get cardShadow => BoxShadow(
        color: Colors.black.withOpacity(0.04),
        blurRadius: 16,
        offset: const Offset(0, 4),
      );

  // 响应式字体大小
  static double getResponsiveFontSize(
    BuildContext context,
    double baseFontSize,
  ) {
    final mediaQuery = MediaQuery.of(context);
    final devicePixelRatio = mediaQuery.devicePixelRatio;
    final screenWidth = mediaQuery.size.width;

    // 移动端字体缩放因子
    if (kIsWeb) {
      return baseFontSize; // Web端保持原大小
    } else {
      // 移动端根据屏幕宽度和像素密度调整
      var scaleFactor = 1.0;

      if (screenWidth < 400) {
        // 小屏手机
        scaleFactor = 0.85;
      } else if (screenWidth < 600) {
        // 普通手机
        scaleFactor = 0.9;
      } else if (screenWidth < 900) {
        // 大屏手机/小平板
        scaleFactor = 0.95;
      }

      // 高像素密度设备进一步缩小字体
      if (devicePixelRatio > 2.5) {
        scaleFactor *= 0.9;
      }

      return (baseFontSize * scaleFactor).clamp(12.0, baseFontSize);
    }
  }

  // 响应式间距
  static double getResponsiveSpacing(BuildContext context, double baseSpacing) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;

    if (kIsWeb) {
      return baseSpacing; // Web端保持原大小
    } else {
      // 移动端间距稍微缩小
      if (screenWidth < 400) {
        return baseSpacing * 0.8;
      } else if (screenWidth < 600) {
        return baseSpacing * 0.9;
      }
      return baseSpacing;
    }
  }

  // 主题数据
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        fontFamily: fontFamily,

        // 色彩方案
        colorScheme: const ColorScheme.light(
          primary: primaryAction,
          secondary: accentBackground,
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
        cardTheme: CardThemeData(
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

  // 深色主题
  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        fontFamily: fontFamily,
        brightness: Brightness.dark,

        // 色彩方案
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF0A84FF), // iOS深色模式蓝
          secondary: Color(0xFF2C2C2E),
          onSecondary: Colors.white,
          onSurface: Colors.white,
          outline: Color(0xFF38383A),
        ),

        // 应用栏主题
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF000000),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontFamily: fontFamily,
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),

        // 卡片主题
        cardTheme: CardThemeData(
          color: const Color(0xFF1C1C1E),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          shadowColor: Colors.black.withOpacity(0.3),
        ),

        // 按钮主题
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0A84FF),
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
            foregroundColor: const Color(0xFF0A84FF),
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
          fillColor: const Color(0xFF2C2C2E),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: const BorderSide(
              color: Color(0xFF0A84FF),
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),

        // 文本主题
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontFamily: fontFamily,
            fontSize: 34,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          displayMedium: TextStyle(
            fontFamily: fontFamily,
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
          headlineMedium: TextStyle(
            fontFamily: fontFamily,
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          bodyLarge: TextStyle(
            fontFamily: fontFamily,
            fontSize: 17,
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
          bodyMedium: TextStyle(
            fontFamily: fontFamily,
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: Color(0xFF8E8E93),
          ),
          labelLarge: TextStyle(
            fontFamily: fontFamily,
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),

        // 浮动操作按钮主题
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF0A84FF),
          foregroundColor: Colors.white,
          elevation: 4,
        ),

        // 分割线主题
        dividerTheme: const DividerThemeData(
          color: Color(0xFF38383A),
          thickness: 0.5,
          space: 1,
        ),

        // 脚手架背景色
        scaffoldBackgroundColor: const Color(0xFF000000),
      );
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
  Color get primaryColor => AppTheme.primaryAction; // 兼容性别名
  Color get surfaceColor => Colors.white; // 表面颜色

  // ColorScheme 兼容性扩展
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  // 获取间距
  double get spacing2 => AppTheme.baseSpacing * 0.25; // 2pt
  double get spacing4 => AppTheme.baseSpacing * 0.5; // 4pt
  double get spacing8 => AppTheme.baseSpacing; // 8pt
  double get spacing12 => AppTheme.baseSpacing * 1.5; // 12pt
  double get spacing16 => AppTheme.baseSpacing * 2; // 16pt
  double get spacing24 => AppTheme.baseSpacing * 3; // 24pt
  double get spacing32 => AppTheme.baseSpacing * 4; // 32pt

  // 响应式间距
  double responsiveSpacing(double baseSpacing) =>
      AppTheme.getResponsiveSpacing(this, baseSpacing);
  double get responsiveSpacing2 => responsiveSpacing(2);
  double get responsiveSpacing4 => responsiveSpacing(4);
  double get responsiveSpacing6 => responsiveSpacing(6);
  double get responsiveSpacing8 => responsiveSpacing(8);
  double get responsiveSpacing12 => responsiveSpacing(12);
  double get responsiveSpacing16 => responsiveSpacing(16);
  double get responsiveSpacing24 => responsiveSpacing(24);
  double get responsiveSpacing32 => responsiveSpacing(32);

  // 响应式字体大小
  double responsiveFontSize(double baseFontSize) =>
      AppTheme.getResponsiveFontSize(this, baseFontSize);

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
  String formatPercentage(double percentage) =>
      '${percentage.toStringAsFixed(1)}%';

  // 获取文本主题
  TextTheme get textTheme => Theme.of(this).textTheme;

  // 格式化日期时间
  String formatDateTime(DateTime dateTime) =>
      '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

  // 格式化日期
  String formatDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  // 格式化时间
  String formatTime(DateTime dateTime) =>
      '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

  // 获取边框颜色
  Color get borderColor => dividerColor;
}
