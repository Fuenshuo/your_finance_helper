import 'package:flutter/material.dart';

/// iOS风格动效配置系统
/// 基于Notion iOS版本的动效实现标杆
class IOSAnimationConfig {
  // ===== 全局配置 =====
  /// 触觉反馈强度 (0.0-1.0)
  static const double hapticFeedbackIntensity = 0.6;

  /// 是否启用简化动效
  static const bool enableReducedMotion = false;

  // ===== 时间配置 (iOS标准) =====
  /// 瞬间动画时长 (0ms)
  static const Duration instant = Duration.zero;

  /// 非常快速动画时长 (150ms)
  static const Duration veryFast = Duration(milliseconds: 150);

  /// 快速动画时长 (250ms)
  static const Duration fast = Duration(milliseconds: 250);

  /// 正常动画时长 (350ms)
  static const Duration normal = Duration(milliseconds: 350);

  /// 慢速动画时长 (500ms)
  static const Duration slow = Duration(milliseconds: 500);

  /// 非常慢速动画时长 (700ms)
  static const Duration verySlow = Duration(milliseconds: 700);

  // ===== 缓动曲线 (iOS风格) =====
  /// 标准缓动曲线 (easeInOut)
  static const Curve standard = Curves.easeInOut;

  /// 加速缓动曲线 (easeIn)
  static const Curve accelerate = Curves.easeIn;

  /// 减速缓动曲线 (easeOut)
  static const Curve decelerate = Curves.easeOut;

  /// 弹跳缓动曲线 (elasticOut)
  static const Curve bounce = Curves.elasticOut;

  /// 过冲缓动曲线 (easeOutBack)
  static const Curve overshoot = Curves.easeOutBack;

  /// 弹簧缓动曲线 (bounceOut)
  static const Curve spring = Curves.bounceOut;

  // ===== 缩放参数 =====
  /// 点击时的缩放比例
  static const double tapScale = 0.95;

  /// 悬停时的缩放比例
  static const double hoverScale = 1.02;

  /// 按下时的缩放比例
  static const double pressScale = 0.92;

  /// 拖拽时的缩放比例
  static const double dragScale = 1.05;

  // ===== 阴影参数 =====
  /// 基础阴影高度
  static const double baseElevation = 2.0;

  /// 悬停时的阴影高度
  static const double hoverElevation = 8.0;

  /// 按下时的阴影高度
  static const double pressedElevation = 1.0;

  // ===== 透明度参数 =====
  /// 禁用状态透明度
  static const double disabledOpacity = 0.5;

  /// 悬停状态透明度
  static const double hoverOpacity = 0.8;

  /// 聚焦状态透明度
  static const double focusOpacity = 0.9;

  // ===== 抖动参数 =====
  /// 抖动振幅
  static const double shakeAmplitude = 8.0;

  /// 抖动频率
  static const int shakeFrequency = 6;

  /// 抖动持续时长
  static const Duration shakeDuration = Duration(milliseconds: 400);

  // ===== 拖拽参数 =====
  /// 拖拽阈值
  static const double dragThreshold = 0.1;

  /// 拖拽反馈延迟
  static const Duration dragFeedbackDelay = Duration(milliseconds: 50);

  /// 拖拽时透明度
  static const double dragOpacity = 0.8;

  // ===== 弹性参数 =====
  /// 弹簧阻尼系数
  static const double springDamping = 0.7;

  /// 弹簧刚度系数
  static const double springStiffness = 180.0;

  // ===== 颜色动画参数 =====
  /// 颜色过渡动画时长
  static const Duration colorTransitionDuration = Duration(milliseconds: 200);

  // ===== 粒子效果参数 =====
  /// 粒子数量
  static const int particleCount = 12;

  /// 粒子生命周期
  static const Duration particleLifetime = Duration(milliseconds: 800);

  /// 粒子扩散范围
  static const double particleSpread = 50.0;
}

/// 动效类型枚举
enum AnimationType {
  // 基础交互
  /// 点击动画
  tap,
  /// 按下动画
  press,
  /// 悬停动画
  hover,
  /// 拖拽动画
  drag,

  // 状态变化
  /// 出现动画
  appear,
  /// 消失动画
  disappear,
  /// 变换动画
  transform,
  /// 变形动画
  morph,

  // 反馈动画
  /// 成功反馈动画
  success,
  /// 错误反馈动画
  error,
  /// 警告反馈动画
  warning,
  /// 加载动画
  loading,

  // 导航动画
  /// 滑动导航动画
  slide,
  /// 淡入淡出导航动画
  fade,
  /// 缩放导航动画
  scale,
  /// 旋转导航动画
  rotate,

  // 特殊效果
  /// 抖动效果
  shake,
  /// 弹跳效果
  bounce,
  /// 摇摆效果
  wobble,
  /// 脉冲效果
  pulse,

  // iOS特色
  /// iOS弹簧动画
  iosSpring,
  /// iOS橡皮筋动画
  iosRubberBand,
  /// iOS精灵动画
  iosGenie,
  /// iOS吸入动画
  iosSuck,
}

/// 动效场景枚举
enum AnimationContext {
  // UI组件
  /// 按钮组件
  button,
  /// 卡片组件
  card,
  /// 列表组件
  list,
  /// 输入组件
  input,
  /// 模态框组件
  modal,

  // 页面级别
  /// 导航场景
  navigation,
  /// 页面过渡场景
  transition,
  /// 新手引导场景
  onboarding,

  // 数据展示
  /// 图表展示
  chart,
  /// 图形展示
  graph,
  /// 指标展示
  indicator,

  // 交互反馈
  /// 手势交互
  gesture,
  /// 反馈场景
  feedback,
  /// 确认场景
  confirmation,

  // 特殊场景
  /// 错误场景
  error,
  /// 成功场景
  success,
  /// 加载场景
  loading,
}

/// 动效配置类
/// 定义完整的动效规格，包括类型、时长、曲线等参数
class AnimationSpec {
  /// 创建动效配置
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

  /// 动效类型
  final AnimationType type;

  /// 动效场景上下文
  final AnimationContext context;

  /// 动效持续时长
  final Duration duration;

  /// 缓动曲线
  final Curve curve;

  /// 缩放比例 (可选)
  final double? scale;

  /// 透明度 (可选)
  final double? opacity;

  /// 偏移量 (可选)
  final Offset? offset;

  /// 颜色 (可选)
  final Color? color;

  /// 是否启用触觉反馈
  final bool enableHaptic;

  /// 是否遵循减少动画设置
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
/// 定义应用的动效主题设置，包括启用状态、速度调整等
class AnimationTheme {
  /// 创建动效主题配置
  const AnimationTheme({
    this.enableAnimations = true,
    this.enableHapticFeedback = true,
    this.respectReducedMotion = true,
    this.animationSpeed = 1.0,
    this.defaultButtonSpec = AnimationSpec.buttonTap,
    this.defaultCardSpec = AnimationSpec.cardHover,
    this.defaultListSpec = AnimationSpec.listItemInsert,
  });

  /// 是否启用动画效果
  final bool enableAnimations;

  /// 是否启用触觉反馈
  final bool enableHapticFeedback;

  /// 是否遵循减少动画设置
  final bool respectReducedMotion;

  /// 动画速度倍数 (1.0为正常速度)
  final double animationSpeed;

  /// 默认按钮动效规格
  final AnimationSpec defaultButtonSpec;

  /// 默认卡片动效规格
  final AnimationSpec defaultCardSpec;

  /// 默认列表动效规格
  final AnimationSpec defaultListSpec;

  /// 根据主题设置调整动效时长
  Duration adjustDuration(Duration duration) {
    if (!enableAnimations) return Duration.zero;
    return Duration(
      milliseconds: (duration.inMilliseconds * animationSpeed).round(),
    );
  }

  /// 创建当前主题的副本，并可选地修改某些属性
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

/// 全局动效主题提供者
/// 通过InheritedWidget模式提供动效主题配置
class AnimationThemeProvider extends InheritedWidget {
  /// 创建动效主题提供者
  const AnimationThemeProvider({
    required this.theme,
    required super.child,
    super.key,
  });

  /// 动效主题配置
  final AnimationTheme theme;

  /// 获取当前上下文的动效主题
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
