import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

/// 应用主题枚举
enum AppTheme {
  modernForestGreen, // 主色森绿 / 明快黄绿（默认）
  eleganceDeepBlue, // 主色藏青 / 墨绿
  premiumGraphite, // 主色石墨灰 / 经典常春藤绿
  classicBurgundy, // 主色深紫红 / 柔和对比绿
}

/// 金额主题（金额字体+颜色）
enum MoneyTheme {
  fluxBlue, // 经典Flux蓝色能量
  forestEmerald, // 森林祖母绿
  graphiteMono, // 石墨中性
}

/// 应用风格枚举
enum AppStyle {
  iOSFintech, // iOS Fintech 风格（默认）：12pt/16pt圆角，弥散阴影
  SharpProfessional, // SharpProfessional 风格：8pt圆角，清晰阴影
}

/// 现代 iOS 风格设计系统
/// 核心理念：通透、层级感、微交互
/// 支持多主题和多风格切换
class AppDesignTokens {
  AppDesignTokens._();

  // --- 0. 主题和风格状态管理 ---

  static AppTheme _currentTheme = AppTheme.modernForestGreen;
  static AppStyle _currentStyle = AppStyle.iOSFintech;
  static MoneyTheme _currentMoneyTheme = MoneyTheme.fluxBlue;

  static MoneyTheme getCurrentMoneyTheme() => _currentMoneyTheme;

  static void setMoneyTheme(MoneyTheme theme) {
    _currentMoneyTheme = theme;
  }

  /// 获取当前主题
  static AppTheme getCurrentTheme() => _currentTheme;

  /// 设置当前主题
  static void setTheme(AppTheme theme) {
    _currentTheme = theme;
  }









  /// 获取当前风格
  static AppStyle getCurrentStyle() => _currentStyle;

  /// 设置当前风格
  static void setStyle(AppStyle style) {
    _currentStyle = style;
  }

  /// 获取主题颜色配置（用于UI展示）
  static Map<String, Color> getThemeColors(AppTheme theme) {
    return _themeColors[theme]!;
  }

  // --- 1. 色彩系统 (Color System) ---

  // iOS 核心蓝 (Standard iOS Blue) - 保留作为 iOS Fintech 默认主题
  static const Color _primaryBlue = Color(0xFF007AFF);
  static const Color _primaryBlueDark = Color(0xFF0A84FF);

  // 4套主题的颜色配置（暴露给外部访问）
  static const Map<AppTheme, Map<String, Color>> _themeColors = {
    AppTheme.modernForestGreen: {
      'primary': Color(0xFF004D40), // 深森绿
      'primaryDark': Color(0xFF003D32), // 深森绿（深色模式）
      'success': Color(0xFF8BC34A), // 鲜草绿
    },
    AppTheme.eleganceDeepBlue: {
      'primary': Color(0xFF1A237E), // 藏青
      'primaryDark': Color(0xFF0D1B5A), // 藏青（深色模式）
      'success': Color(0xFF2E7D32), // 墨绿
    },
    AppTheme.premiumGraphite: {
      'primary': Color(0xFF424242), // 石墨灰
      'primaryDark': Color(0xFF212121), // 石墨灰（深色模式）
      'success': Color(0xFF4CAF50), // 常春藤绿
    },
    AppTheme.classicBurgundy: {
      'primary': Color(0xFF4A148C), // 深紫红
      'primaryDark': Color(0xFF38006B), // 深紫红（深色模式）
      'success': Color(0xFF66BB6A), // 柔和对比绿
    },
  };

  static const Map<MoneyTheme, _MoneyThemePalette> _moneyThemePalettes = {
    MoneyTheme.fluxBlue: _MoneyThemePalette(
      positiveLight: Color(0xFF0A84FF),
      positiveDark: Color(0xFF64D2FF),
      negativeLight: Color(0xFFFF3B30),
      negativeDark: Color(0xFFFF453A),
      neutralLight: Color(0xFF1C1C1E),
      neutralDark: Color(0xFFE5E5EA),
    ),
    MoneyTheme.forestEmerald: _MoneyThemePalette(
      positiveLight: Color(0xFF2E7D32),
      positiveDark: Color(0xFF66BB6A),
      negativeLight: Color(0xFFC62828),
      negativeDark: Color(0xFFFF5E57),
      neutralLight: Color(0xFF2C3E34),
      neutralDark: Color(0xFFC8E6C9),
    ),
    MoneyTheme.graphiteMono: _MoneyThemePalette(
      positiveLight: Color(0xFF4CAF50),
      positiveDark: Color(0xFF81C784),
      negativeLight: Color(0xFFF4511E),
      negativeDark: Color(0xFFFF7043),
      neutralLight: Color(0xFF263238),
      neutralDark: Color(0xFFCFD8DC),
    ),
  };

  // 所有主题共用的标准色
  static const Color _accentColor = Color(0xFFE53935); // Vibrant Red - 警示色/亏损色

  // 高级灰背景 (System Grouped Background)
  // SharpProfessional: 使用 #F5F7FA 极浅灰，与卡片形成清晰对比
  static const Color _bgLight = Color(0xFFF5F7FA); // 极浅灰，拉开与卡片的对比
  static const Color _bgDark = Color(0xFF000000);

  // 卡片表面 (Surface)
  // SharpProfessional: 纯白 #FFFFFF，与背景形成清晰分界
  static const Color _surfaceLight = Color(0xFFFFFFFF); // 纯白，确保与背景对比
  static const Color _surfaceDark = Color(0xFF1C1C1E);

  // 错误红 (Soft Error)
  static const Color _errorTextLight = Color(0xFFD32F2F);

  // 成功绿（兼容性方法，使用当前主题的成功色）
  @Deprecated('Use successColor(context) instead')
  static const Color successColorLegacy = Color(0xFF34C759);

  // 警告橙（所有主题共用）
  static const Color warningColor = Color(0xFFFF9500);

  /// 获取主题色（支持主题切换）
  /// [theme] 可选，指定主题；如果不提供，使用当前主题
  static Color primaryAction(BuildContext context, {AppTheme? theme}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final t = theme ?? _currentTheme;

    // 如果使用 iOS Fintech 默认主题（蓝色），保持原有逻辑
    // 否则使用配置的主题颜色
    if (t == AppTheme.modernForestGreen &&
        _currentStyle == AppStyle.iOSFintech) {
      // 保持 iOS Fintech 蓝色主题的兼容性
      return isDark ? _primaryBlueDark : _primaryBlue;
    }

    final colors = _themeColors[t]!;
    return isDark ? colors['primaryDark']! : colors['primary']!;
  }

  /// 获取成功色（支持主题切换）
  static Color successColor(BuildContext context, {AppTheme? theme}) {
    final t = theme ?? _currentTheme;
    final colors = _themeColors[t]!;
    return colors['success']!;
  }

  /// 获取警示色（所有主题共用）
  static Color get accentColor => _accentColor;

  static Color amountPositiveColor(BuildContext context, {MoneyTheme? theme}) =>
      moneyPositive(context, theme: theme);

  static Color amountNegativeColor(BuildContext context, {MoneyTheme? theme}) =>
      moneyNegative(context, theme: theme);

  static Color amountNeutralColor(BuildContext context, {MoneyTheme? theme}) =>
      moneyNeutral(context, theme: theme);

  static Color pageBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? _bgDark : _bgLight;
  }

  static Color surface(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? _surfaceDark
        : _surfaceLight;
  }

  // 输入框填充色 (iOS Search Bar style)
  static Color inputFill(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF2C2C2E)
        : const Color(0xFFE5E5EA); // iOS 系统灰
  }

  /// 获取主阴影（支持风格切换）
  /// iOS Fintech: 弥散阴影（有色阴影，blurRadius: 32, opacity: 0.08）
  /// SharpProfessional: 清晰阴影（elevation: 2.0，通过 Card 的 elevation 实现）
  static BoxShadow primaryShadow(BuildContext context, {AppStyle? style}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final s = style ?? _currentStyle;

    if (s == AppStyle.SharpProfessional) {
      // SharpProfessional: 清晰阴影
      return BoxShadow(
        color: Colors.black.withOpacity(isDark ? 0.4 : 0.15),
        blurRadius: 8,
        offset: const Offset(0, 2),
        spreadRadius: 0,
      );
    } else {
      // iOS Fintech: 弥散阴影（有色阴影）
      final primaryColor = primaryAction(context);
      return BoxShadow(
        color: isDark
            ? Colors.black.withOpacity(0.3)
            : primaryColor.withOpacity(0.08), // 浅色模式透明度降低
        blurRadius: isDark ? 24 : 32, // 浅色模式模糊半径增大
        offset: const Offset(0, 8),
        spreadRadius: -4,
      );
    }
  }

  /// 获取卡片阴影（支持风格切换）
  static BoxShadow cardShadow(BuildContext context, {AppStyle? style}) {
    return primaryShadow(context, style: style);
  }

  /// 获取按钮阴影（支持风格切换）
  static BoxShadow buttonShadow(BuildContext context, {AppStyle? style}) {
    final s = style ?? _currentStyle;
    if (s == AppStyle.SharpProfessional) {
      // SharpProfessional: elevation 4.0 的清晰阴影
      return BoxShadow(
        color: Colors.black.withOpacity(0.2),
        blurRadius: 12,
        offset: const Offset(0, 4),
        spreadRadius: 0,
      );
    } else {
      // iOS Fintech: 使用主阴影
      return primaryShadow(context);
    }
  }

  // --- 2. 排版系统 (Typography - iOS Human Interface Guidelines) ---

  // 统一字体：SF Pro (Flutter默认在iOS上使用)
  // 关键调整：行高 (Height) 设为 1.3-1.5，增加呼吸感

  static TextStyle largeTitle(BuildContext context) => TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.5,
        color: _textColor(context),
      );

  static TextStyle title1(BuildContext context) => TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        height: 1.25,
        letterSpacing: -0.4,
        color: _textColor(context),
      );

  static TextStyle headline(BuildContext context) => TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: -0.4,
        color: _textColor(context),
      );

  static TextStyle body(BuildContext context) => TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w400,
        height: 1.4,
        letterSpacing: -0.4,
        color: _textColor(context),
      );

  static TextStyle caption(BuildContext context) => TextStyle(
        fontSize: 13, fontWeight: FontWeight.w400, height: 1.4,
        color: _textColor(context).withOpacity(0.6), // 次级文字
      );

  static TextStyle microCaption(BuildContext context) => TextStyle(
        fontSize: 10, fontWeight: FontWeight.w400, height: 1.4,
        color: _textColor(context).withOpacity(0.6), // 极致紧凑信息，用于计算透明度详情
      );

  // --- 排版层级系统 (Typography Hierarchy) ---
  // 用于财务应用的专业排版层级，确保数据权重清晰

  /// 主要数值样式（24-28pt Bold）
  /// 用途：金额、余额、盈亏等核心数据
  /// 示例：￥54,655.80
  static TextStyle primaryValue(BuildContext context) => TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.5,
        color: _textColor(context),
      );

  /// 卡片主标题样式（18pt SemiBold）
  /// 用途：卡片标题、模块标题（如"资产总览"、"AI 洞察"）
  /// 示例：总览、AI 洞察
  static TextStyle cardTitle(BuildContext context) => TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: -0.3,
        color: _textColor(context),
      );

  /// 副标题/描述样式（14pt Regular）
  /// 用途：副标题、描述性文字（如"S27 月度净收入"）
  /// 示例：月度净收入、年度净收入
  static TextStyle subtitle(BuildContext context) => TextStyle(
        fontSize: 14, fontWeight: FontWeight.w400, height: 1.4,
        letterSpacing: -0.2,
        color: _textColor(context).withOpacity(0.7), // 降低权重，作为主要数值的解释
      );

  /// 标签/正文样式（12pt Regular）
  /// 用途：标签文本、正文、交易时间、分类等标准信息
  /// 示例：交易时间、分类、账户名称
  static TextStyle label(BuildContext context) => TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: _textColor(context).withOpacity(0.6),
      );

  static Color _textColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
  }

  // --- 3. 间距与圆角 (Metrics) - 支持风格切换 ---

  /// 获取小圆角（支持风格切换）
  static double radiusSmall(BuildContext context, {AppStyle? style}) {
    final s = style ?? _currentStyle;
    return s == AppStyle.iOSFintech ? 8.0 : 8.0; // 两种风格相同
  }

  /// 获取中等圆角（支持风格切换）
  static double radiusMedium(BuildContext context, {AppStyle? style}) {
    final s = style ?? _currentStyle;
    return s == AppStyle.iOSFintech
        ? 16.0
        : 8.0; // iOS Fintech: 16pt, SharpProfessional: 8pt
  }

  /// 获取大圆角（支持风格切换）
  static double radiusLarge(BuildContext context, {AppStyle? style}) {
    final s = style ?? _currentStyle;
    return s == AppStyle.iOSFintech
        ? 24.0
        : 12.0; // iOS Fintech: 24pt, SharpProfessional: 12pt
  }

  static const double radiusFull = 999.0;

  // 兼容性常量（保持向后兼容）
  // 注意：这些常量保持向后兼容，但新代码应该使用 context 方法
  @Deprecated('Use radiusSmall(context) instead')
  static const double radiusSmallLegacy = 8.0;

  @Deprecated('Use radiusMedium(context) instead')
  static const double radiusMediumLegacy = 16.0;

  @Deprecated('Use radiusLarge(context) instead')
  static const double radiusLargeLegacy = 24.0;

  // --- 间距系统 (Spacing System) ---
  // 基础间距单位
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;

  // 全局水平边距（统一所有屏幕和卡片的内容对齐）
  /// 全局水平边距：所有屏幕主体内容、卡片内容的左右边距
  /// 确保表单、列表、卡片内容都从同一位置开始
  /// SharpProfessional: 使用 20pt 确保足够的呼吸空间和清晰的对齐
  static const double globalHorizontalPadding = 20.0;

  // 间距层级（用于信息分组）
  /// Major Spacing: 两个独立模块/卡片之间（24-32pt）
  /// 用于：资产总览卡片和预算信封卡片之间、不同功能模块之间
  static const double spacingMajor = 32.0;

  /// Medium Spacing: 卡片内部分组（16-20pt）
  /// 用于：资产总览卡片内的"净资产"和"负债"之间、表单字段组之间
  static const double spacingMedium = 16.0;

  /// Minor Spacing: 文本行、图标和文字之间（8-12pt）
  /// 用于：标签和输入框之间、图标和文字之间、紧密相关的信息
  static const double spacingMinor = 8.0;

  // --- 4. 兼容性方法（保持向后兼容） ---

  // 为了兼容现有代码，保留旧的方法名
  static Color primaryBackground(BuildContext context) =>
      pageBackground(context);
  static Color accentBackground(BuildContext context) => surface(context);
  static Color primaryText(BuildContext context) => _textColor(context);
  static Color secondaryText(BuildContext context) =>
      _textColor(context).withOpacity(0.6);
  static Color tertiaryText(BuildContext context) =>
      _textColor(context).withOpacity(0.4);
  static Color dividerColor(BuildContext context) =>
      _textColor(context).withOpacity(0.1);
  static Color borderColor(BuildContext context) =>
      _textColor(context).withOpacity(0.1);
  static Color get errorColor => _errorTextLight;
  static Color get infoColor => _primaryBlue;

  // 金额颜色
  static Color moneyPositive(BuildContext context, {MoneyTheme? theme}) {
    final palette = _moneyPalette(theme);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? palette.positiveDark : palette.positiveLight;
  }

  static Color moneyNegative(BuildContext context, {MoneyTheme? theme}) {
    final palette = _moneyPalette(theme);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? palette.negativeDark : palette.negativeLight;
  }

  static Color moneyNeutral(BuildContext context, {MoneyTheme? theme}) {
    final palette = _moneyPalette(theme);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? palette.neutralDark : palette.neutralLight;
  }

  static _MoneyThemePalette _moneyPalette(MoneyTheme? theme) =>
      _moneyThemePalettes[theme ?? _currentMoneyTheme]!;

  // 阴影系统（兼容）
  static BoxShadow shadowSmall(BuildContext context) => primaryShadow(context);
  static BoxShadow shadowMedium(BuildContext context) => primaryShadow(context);
  static BoxShadow shadowLarge(BuildContext context) => primaryShadow(context);

  // 字体大小（兼容）
  static const double fontSize10 = 10.0;
  static const double fontSize12 = 12.0;
  static const double fontSize14 = 14.0;
  static const double fontSize15 = 15.0;
  static const double fontSize17 = 17.0;
  static const double fontSize20 = 20.0;
  static const double fontSize24 = 24.0;
  static const double fontSize28 = 28.0;
  static const double fontSize34 = 34.0;

  // 字重（兼容）
  static const FontWeight fontWeightRegular = FontWeight.w400;
  static const FontWeight fontWeightMedium = FontWeight.w500;
  static const FontWeight fontWeightSemiBold = FontWeight.w600;
  static const FontWeight fontWeightBold = FontWeight.w700;

  // 动画时长（兼容）
  static const Duration durationFast = Duration(milliseconds: 100);
  static const Duration durationMedium = Duration(milliseconds: 300);
  static const Duration durationSlow = Duration(milliseconds: 500);

  // 组件尺寸（兼容）
  static const double buttonHeight = 56.0; // iOS标准按钮高度
  static const double inputHeight = 48.0;
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  static const double fabSize = 56.0;
  static const double fabSizeMini = 40.0;

  // 圆角（兼容）
  static const double borderRadius4 = 4.0;
  static const double borderRadius8 = 8.0;
  static const double borderRadius12 = 12.0;
  static const double borderRadius16 = 16.0;
  static const double borderRadius24 = 24.0;
}

class _MoneyThemePalette {
  const _MoneyThemePalette({
    required this.positiveLight,
    required this.positiveDark,
    required this.negativeLight,
    required this.negativeDark,
    required this.neutralLight,
    required this.neutralDark,
  });

  final Color positiveLight;
  final Color positiveDark;
  final Color negativeLight;
  final Color negativeDark;
  final Color neutralLight;
  final Color neutralDark;
}

/// 文本样式Token - iOS风格（兼容旧代码）
class AppTextStyles {
  AppTextStyles._();

  static TextStyle displayLarge(BuildContext context) =>
      AppDesignTokens.largeTitle(context);
  static TextStyle displayMedium(BuildContext context) =>
      AppDesignTokens.title1(context);
  static TextStyle headlineMedium(BuildContext context) =>
      AppDesignTokens.headline(context);
  static TextStyle bodyLarge(BuildContext context) =>
      AppDesignTokens.body(context);
  static TextStyle bodyMedium(BuildContext context) =>
      AppDesignTokens.body(context).copyWith(fontSize: 15);
  static TextStyle bodySmall(BuildContext context) =>
      AppDesignTokens.caption(context);
  static TextStyle button(BuildContext context) =>
      AppDesignTokens.headline(context).copyWith(color: Colors.white);
  static TextStyle label(BuildContext context) =>
      AppDesignTokens.caption(context);
}

/// 间距Token扩展方法
extension AppSpacingExtension on BuildContext {
  double get spacing2 => AppDesignTokens.spacing4 / 2;
  double get spacing4 => AppDesignTokens.spacing4;
  double get spacing8 => AppDesignTokens.spacing8;
  double get spacing12 => AppDesignTokens.spacing16 - AppDesignTokens.spacing4;
  double get spacing16 => AppDesignTokens.spacing16;
  double get spacing24 => AppDesignTokens.spacing24;
  double get spacing32 => AppDesignTokens.spacing32;
}

/// 颜色Token扩展方法（支持深色模式）
extension AppColorExtension on BuildContext {
  Color get appPrimaryBackground => AppDesignTokens.pageBackground(this);
  Color get appAccentBackground => AppDesignTokens.surface(this);
  Color get appPrimaryAction => AppDesignTokens.primaryAction(this);
  Color get appPrimaryText => AppDesignTokens.primaryText(this);
  Color get appSecondaryText => AppDesignTokens.secondaryText(this);
  Color get appSuccessColor => AppDesignTokens.successColorLegacy;
  Color get appErrorColor => AppDesignTokens.errorColor;
  Color get appWarningColor => AppDesignTokens.warningColor;
  Color get appInfoColor => AppDesignTokens.infoColor;
  Color get appDividerColor => AppDesignTokens.dividerColor(this);
  Color get appSurfaceColor => AppDesignTokens.surface(this);
  Color get appBorderColor => AppDesignTokens.borderColor(this);
}
