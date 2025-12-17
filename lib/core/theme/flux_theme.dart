import 'package:flutter/material.dart';

/// 🌊 Flux Ledger 主题系统
/// 基于流式思维重新设计的视觉语言

class FluxTheme {
  // ==================== 色彩系统 ====================

  /// 流蓝色 - 主要资金流的颜色
  static const Color flowBlue = Color(0xFF007AFF);

  /// 收入绿色 - 收入和盈利的颜色
  static const Color incomeGreen = Color(0xFF34C759);

  /// 支出红色 - 支出和亏损的颜色
  static const Color expenseRed = Color(0xFFFF3B30);

  /// 中性灰 - 中性状态和背景
  static const Color neutralGray = Color(0xFF8E8E93);

  /// 流背景色 - 柔和的流体感背景
  static const Color flowBackground = Color(0xFFF2F8FF);

  /// 流卡片色 - 轻微透明的卡片背景
  static const Color flowCardBackground = Color(0xFFFFFFFF);

  /// 流分割线 - 微妙的分割线
  static const Color flowDivider = Color(0xFFE5E5EA);

  // ==================== 流状态色彩 ====================

  /// 流健康色 - 健康的资金流
  static const Color flowHealthy = incomeGreen;

  /// 流警告色 - 需要关注的资金流
  static const Color flowWarning = Color(0xFFFF9500);

  /// 流危险色 - 异常的资金流
  static const Color flowDanger = expenseRed;

  /// 流静止色 - 暂停或停止的资金流
  static const Color flowStatic = neutralGray;

  // ==================== 流动画配置 ====================

  /// 流过渡时长
  static const Duration flowTransitionDuration = Duration(milliseconds: 300);

  /// 流脉动时长
  static const Duration flowPulseDuration = Duration(milliseconds: 600);

  /// 流粒子动画时长
  static const Duration flowParticleDuration = Duration(milliseconds: 2000);

  // ==================== 流形状配置 ====================

  /// 流卡片圆角
  static const double flowCardRadius = 16.0;

  /// 流按钮圆角
  static const double flowButtonRadius = 12.0;

  /// 流输入框圆角
  static const double flowInputRadius = 12.0;

  // ==================== 流间距系统 ====================

  /// 流元素基础间距
  static const double flowSpacingXS = 4.0;
  static const double flowSpacingSM = 8.0;
  static const double flowSpacingMD = 16.0;
  static const double flowSpacingLG = 24.0;
  static const double flowSpacingXL = 32.0;
  static const double flowSpacingXXL = 48.0;

  // ==================== 流阴影系统 ====================

  /// 流卡片阴影
  static List<BoxShadow> flowCardShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  /// 流悬浮阴影
  static List<BoxShadow> flowElevatedShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  /// 流底部导航阴影
  static List<BoxShadow> flowBottomNavShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 12,
      offset: const Offset(0, -2),
    ),
  ];

  // ==================== 流文字样式 ====================

  /// 流标题样式
  static TextStyle flowHeadline(BuildContext context) {
    return Theme.of(context).textTheme.headlineSmall!.copyWith(
          color: const Color(0xFF1C1C1E),
          fontWeight: FontWeight.w600,
          height: 1.2,
        );
  }

  /// 流正文样式
  static TextStyle flowBody(BuildContext context) {
    return Theme.of(context).textTheme.bodyLarge!.copyWith(
          color: const Color(0xFF3C3C43),
          height: 1.4,
        );
  }

  /// 流说明样式
  static TextStyle flowCaption(BuildContext context) {
    return Theme.of(context).textTheme.bodySmall!.copyWith(
          color: neutralGray,
          height: 1.3,
        );
  }

  /// 流金额样式 - 正数（收入）
  static TextStyle flowAmountPositive(BuildContext context) {
    return Theme.of(context).textTheme.headlineMedium!.copyWith(
      color: incomeGreen,
      fontWeight: FontWeight.w700,
      fontFeatures: [const FontFeature.tabularFigures()],
    );
  }

  /// 流金额样式 - 负数（支出）
  static TextStyle flowAmountNegative(BuildContext context) {
    return Theme.of(context).textTheme.headlineMedium!.copyWith(
      color: expenseRed,
      fontWeight: FontWeight.w700,
      fontFeatures: [const FontFeature.tabularFigures()],
    );
  }

  /// 流金额样式 - 中性
  static TextStyle flowAmountNeutral(BuildContext context) {
    return Theme.of(context).textTheme.headlineMedium!.copyWith(
      color: const Color(0xFF1C1C1E),
      fontWeight: FontWeight.w600,
      fontFeatures: [const FontFeature.tabularFigures()],
    );
  }

  // ==================== 流装饰 ====================

  /// 流渐变背景
  static LinearGradient flowBackgroundGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFF2F8FF),
      Color(0xFFF8FBFF),
      Color(0xFFFFFFFF),
    ],
  );

  /// 流健康渐变
  static LinearGradient flowHealthyGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF34C759),
      Color(0xFF30D158),
    ],
  );

  /// 流警告渐变
  static LinearGradient flowWarningGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFF9500),
      Color(0xFFFF9F0A),
    ],
  );

  /// 流危险渐变
  static LinearGradient flowDangerGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFF3B30),
      Color(0xFFFF453A),
    ],
  );

  // ==================== 流图标系统 ====================

  /// 流图标主题数据
  static IconThemeData flowIconTheme = const IconThemeData(
    color: flowBlue,
    size: 24,
  );

  /// 流图标主题数据 - 小尺寸
  static IconThemeData flowIconThemeSmall = const IconThemeData(
    color: flowBlue,
    size: 20,
  );

  // ==================== 流输入装饰 ====================

  /// 流输入框装饰
  static InputDecoration flowInputDecoration({
    required BuildContext context,
    required String labelText,
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFF7F7F7),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(flowInputRadius),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(flowInputRadius),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(flowInputRadius),
        borderSide: const BorderSide(
          color: flowBlue,
          width: 2,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
    );
  }

  // ==================== 流按钮样式 ====================

  /// 流主要按钮样式
  static ButtonStyle flowPrimaryButton = ElevatedButton.styleFrom(
    backgroundColor: flowBlue,
    foregroundColor: Colors.white,
    elevation: 0,
    shadowColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(flowButtonRadius),
    ),
    padding: const EdgeInsets.symmetric(
      horizontal: 24,
      vertical: 16,
    ),
    textStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
  );

  /// 流次要按钮样式
  static ButtonStyle flowSecondaryButton = OutlinedButton.styleFrom(
    foregroundColor: flowBlue,
    side: const BorderSide(color: flowBlue, width: 1.5),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(flowButtonRadius),
    ),
    padding: const EdgeInsets.symmetric(
      horizontal: 24,
      vertical: 16,
    ),
    textStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
  );

  // ==================== 流卡片装饰 ====================

  /// 流卡片装饰
  static BoxDecoration flowCardDecoration = BoxDecoration(
    color: flowCardBackground,
    borderRadius: BorderRadius.circular(flowCardRadius),
    boxShadow: flowCardShadow,
  );

  /// 流卡片装饰 - 悬浮效果
  static BoxDecoration flowCardDecorationElevated = BoxDecoration(
    color: flowCardBackground,
    borderRadius: BorderRadius.circular(flowCardRadius),
    boxShadow: flowElevatedShadow,
  );

  // ==================== 流动画曲线 ====================

  /// 流标准动画曲线
  static const Curve flowStandardCurve = Curves.easeInOutCubic;

  /// 流弹性动画曲线
  static const Curve flowBounceCurve = Curves.elasticOut;

  /// 流快速动画曲线
  static const Curve flowFastCurve = Curves.fastOutSlowIn;
}

/// 🌊 Flux Ledger 扩展方法
extension FluxThemeExtension on BuildContext {
  /// 获取流主题颜色
  FluxThemeColors get fluxColors => const FluxThemeColors();

  /// 获取流间距
  FluxSpacing get fluxSpacing => const FluxSpacing();

  /// 获取流文本样式
  FluxTextStyles get fluxText => FluxTextStyles(this);
}

/// 流主题颜色类
class FluxThemeColors {
  const FluxThemeColors();

  Color get flowBlue => FluxTheme.flowBlue;
  Color get incomeGreen => FluxTheme.incomeGreen;
  Color get expenseRed => FluxTheme.expenseRed;
  Color get neutralGray => FluxTheme.neutralGray;
  Color get flowBackground => FluxTheme.flowBackground;
  Color get flowHealthy => FluxTheme.flowHealthy;
  Color get flowWarning => FluxTheme.flowWarning;
  Color get flowDanger => FluxTheme.flowDanger;
  Color get flowStatic => FluxTheme.flowStatic;
}

/// 流间距类
class FluxSpacing {
  const FluxSpacing();

  double get xs => FluxTheme.flowSpacingXS;
  double get sm => FluxTheme.flowSpacingSM;
  double get md => FluxTheme.flowSpacingMD;
  double get lg => FluxTheme.flowSpacingLG;
  double get xl => FluxTheme.flowSpacingXL;
  double get xxl => FluxTheme.flowSpacingXXL;
}

/// 流文本样式类
class FluxTextStyles {
  final BuildContext context;

  const FluxTextStyles(this.context);

  TextStyle get headline => FluxTheme.flowHeadline(context);
  TextStyle get body => FluxTheme.flowBody(context);
  TextStyle get caption => FluxTheme.flowCaption(context);
  TextStyle get amountPositive => FluxTheme.flowAmountPositive(context);
  TextStyle get amountNegative => FluxTheme.flowAmountNegative(context);
  TextStyle get amountNeutral => FluxTheme.flowAmountNeutral(context);
}
