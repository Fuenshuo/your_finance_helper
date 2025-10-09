import 'package:flutter/material.dart';

/// iOS风格动效配置系统
/// 基于Notion iOS版本的动效实现标杆
class IOSAnimationConfig {
  // ===== 全局配置 =====
  static const double hapticFeedbackIntensity = 0.6;
  static const bool enableReducedMotion = false;

  // ===== 时间配置 (iOS标准) =====
  static const Duration instant = Duration();
  static const Duration veryFast = Duration(milliseconds: 150);
  static const Duration fast = Duration(milliseconds: 250);
  static const Duration normal = Duration(milliseconds: 350);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration verySlow = Duration(milliseconds: 700);

  // ===== 缓动曲线 (iOS风格) =====
  static const Curve standard = Curves.easeInOut;
  static const Curve accelerate = Curves.easeIn;
  static const Curve decelerate = Curves.easeOut;
  static const Curve bounce = Curves.elasticOut;
  static const Curve overshoot = Curves.easeOutBack;
  static const Curve spring = Curves.bounceOut;

  // ===== 缩放参数 =====
  static const double tapScale = 0.95;
  static const double hoverScale = 1.02;
  static const double pressScale = 0.92;
  static const double dragScale = 1.05;

  // ===== 阴影参数 =====
  static const double baseElevation = 2.0;
  static const double hoverElevation = 8.0;
  static const double pressedElevation = 1.0;

  // ===== 透明度参数 =====
  static const double disabledOpacity = 0.5;
  static const double hoverOpacity = 0.8;
  static const double focusOpacity = 0.9;

  // ===== 抖动参数 =====
  static const double shakeAmplitude = 8.0;
  static const int shakeFrequency = 6;
  static const Duration shakeDuration = Duration(milliseconds: 400);

  // ===== 拖拽参数 =====
  static const double dragThreshold = 0.1;
  static const Duration dragFeedbackDelay = Duration(milliseconds: 50);
  static const double dragOpacity = 0.8;

  // ===== 弹性参数 =====
  static const double springDamping = 0.7;
  static const double springStiffness = 180.0;

  // ===== 颜色动画参数 =====
  static const Duration colorTransitionDuration = Duration(milliseconds: 200);

  // ===== 粒子效果参数 =====
  static const int particleCount = 12;
  static const Duration particleLifetime = Duration(milliseconds: 800);
  static const double particleSpread = 50.0;
}

/// 动效类型枚举
enum AnimationType {
  // 基础交互
  tap,
  press,
  hover,
  drag,

  // 状态变化
  appear,
  disappear,
  transform,
  morph,

  // 反馈动画
  success,
  error,
  warning,
  loading,

  // 导航动画
  slide,
  fade,
  scale,
  rotate,

  // 特殊效果
  shake,
  bounce,
  wobble,
  pulse,

  // iOS特色
  iosSpring,
  iosRubberBand,
  iosGenie,
  iosSuck,
}

/// 动效场景枚举
enum AnimationContext {
  // UI组件
  button,
  card,
  list,
  input,
  modal,

  // 页面级别
  navigation,
  transition,
  onboarding,

  // 数据展示
  chart,
  graph,
  indicator,

  // 交互反馈
  gesture,
  feedback,
  confirmation,

  // 特殊场景
  error,
  success,
  loading,
}

/// 动效配置类
class AnimationSpec {
  const AnimationSpec({
    required this.type,
    required this.context,
    required this.duration,
    required this.curve,
    this.scale,
    this.opacity,
    this.offset,
    this.color,
    this.enableHaptic = false,
    this.respectReducedMotion = true,
  });
  final AnimationType type;
  final AnimationContext context;
  final Duration duration;
  final Curve curve;
  final double? scale;
  final double? opacity;
  final Offset? offset;
  final Color? color;
  final bool enableHaptic;
  final bool respectReducedMotion;

  // 预定义动画规格
  static const AnimationSpec buttonTap = AnimationSpec(
    type: AnimationType.tap,
    context: AnimationContext.button,
    duration: IOSAnimationConfig.fast,
    curve: IOSAnimationConfig.standard,
    scale: IOSAnimationConfig.tapScale,
    enableHaptic: true,
  );

  static const AnimationSpec cardHover = AnimationSpec(
    type: AnimationType.hover,
    context: AnimationContext.card,
    duration: IOSAnimationConfig.fast,
    curve: IOSAnimationConfig.standard,
    scale: IOSAnimationConfig.hoverScale,
  );

  static const AnimationSpec listItemInsert = AnimationSpec(
    type: AnimationType.appear,
    context: AnimationContext.list,
    duration: IOSAnimationConfig.normal,
    curve: IOSAnimationConfig.decelerate,
    offset: Offset(0, 20),
  );

  static const AnimationSpec successFeedback = AnimationSpec(
    type: AnimationType.success,
    context: AnimationContext.feedback,
    duration: IOSAnimationConfig.verySlow,
    curve: IOSAnimationConfig.bounce,
    scale: 1.2,
    enableHaptic: true,
  );

  static const AnimationSpec errorShake = AnimationSpec(
    type: AnimationType.shake,
    context: AnimationContext.error,
    duration: IOSAnimationConfig.shakeDuration,
    curve: IOSAnimationConfig.standard,
    enableHaptic: true,
  );
}

/// 动效主题配置
class AnimationTheme {
  const AnimationTheme({
    this.enableAnimations = true,
    this.enableHapticFeedback = true,
    this.respectReducedMotion = true,
    this.animationSpeed = 1.0,
    this.defaultButtonSpec = AnimationSpec.buttonTap,
    this.defaultCardSpec = AnimationSpec.cardHover,
    this.defaultListSpec = AnimationSpec.listItemInsert,
  });
  final bool enableAnimations;
  final bool enableHapticFeedback;
  final bool respectReducedMotion;
  final double animationSpeed;
  final AnimationSpec defaultButtonSpec;
  final AnimationSpec defaultCardSpec;
  final AnimationSpec defaultListSpec;

  Duration adjustDuration(Duration duration) {
    if (!enableAnimations) return Duration.zero;
    return Duration(
      milliseconds: (duration.inMilliseconds * animationSpeed).round(),
    );
  }

  AnimationTheme copyWith({
    bool? enableAnimations,
    bool? enableHapticFeedback,
    bool? respectReducedMotion,
    double? animationSpeed,
    AnimationSpec? defaultButtonSpec,
    AnimationSpec? defaultCardSpec,
    AnimationSpec? defaultListSpec,
  }) =>
      AnimationTheme(
        enableAnimations: enableAnimations ?? this.enableAnimations,
        enableHapticFeedback: enableHapticFeedback ?? this.enableHapticFeedback,
        respectReducedMotion: respectReducedMotion ?? this.respectReducedMotion,
        animationSpeed: animationSpeed ?? this.animationSpeed,
        defaultButtonSpec: defaultButtonSpec ?? this.defaultButtonSpec,
        defaultCardSpec: defaultCardSpec ?? this.defaultCardSpec,
        defaultListSpec: defaultListSpec ?? this.defaultListSpec,
      );
}

/// 全局动效主题
class AnimationThemeProvider extends InheritedWidget {
  const AnimationThemeProvider({
    required this.theme,
    required super.child,
    super.key,
  });
  final AnimationTheme theme;

  static AnimationTheme of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<AnimationThemeProvider>();
    return provider?.theme ?? const AnimationTheme();
  }

  @override
  bool updateShouldNotify(AnimationThemeProvider oldWidget) =>
      theme.enableAnimations != oldWidget.theme.enableAnimations ||
      theme.animationSpeed != oldWidget.theme.animationSpeed ||
      theme.enableHapticFeedback != oldWidget.theme.enableHapticFeedback;
}
