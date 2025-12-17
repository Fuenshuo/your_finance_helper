import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:your_finance_flutter/core/animations/animation_config.dart';
import 'package:your_finance_flutter/core/animations/animation_engine.dart';
import 'package:your_finance_flutter/core/animations/ios_animation_sequence_builder.dart';
import 'package:your_finance_flutter/core/widgets/swipe_action_item.dart';

/// 企业级iOS动效系统
/// 集成flutter_animate和自定义动效，提供企业级稳定性和性能
class IOSAnimationSystem {
  factory IOSAnimationSystem() => _instance;
  IOSAnimationSystem._internal();
  static final IOSAnimationSystem _instance = IOSAnimationSystem._internal();

  final IOSAnimationEngine _engine = IOSAnimationEngine();
  final Map<String, AnimationController> _activeControllers = {};
  final Map<String, Completer<void>> _pendingAnimations = {};

  // ===== 企业级动效配置 =====

  /// 全局动效配置
  static const IOSAnimationTheme defaultTheme = IOSAnimationTheme();

  // ===== v1.1.0 新功能：高级动画序列编排器 =====

  /// 创建高级动画序列构建器
  IOSAnimationSequenceBuilder createSequenceBuilder({
    required TickerProvider vsync,
    String? sequenceId,
  }) =>
      IOSAnimationSequenceBuilder(
        vsync: vsync,
        system: this,
        sequenceId:
            sequenceId ?? 'sequence_${DateTime.now().millisecondsSinceEpoch}',
      );

  // ===== v1.1.0 新功能：自定义缓动曲线 =====

  /// 注册自定义缓动曲线
  static final Map<String, Curve> _customCurves = {};

  static void registerCustomCurve(String name, Curve curve) {
    _customCurves[name] = curve;
  }

  static Curve? getCustomCurve(String name) => _customCurves[name];

  /// 获取所有可用曲线（包括预定义和自定义）
  static Map<String, Curve> getAllCurves() => {
        ..._predefinedCurves,
        ..._customCurves,
      };

  static const Map<String, Curve> _predefinedCurves = {
    'linear': Curves.linear,
    'ease': Curves.ease,
    'easeIn': Curves.easeIn,
    'easeOut': Curves.easeOut,
    'easeInOut': Curves.easeInOut,
    'bounceIn': Curves.bounceIn,
    'bounceOut': Curves.bounceOut,
    'bounceInOut': Curves.bounceInOut,
    'elasticIn': Curves.elasticIn,
    'elasticOut': Curves.elasticOut,
    'elasticInOut': Curves.elasticInOut,
    'fastOutSlowIn': Curves.fastOutSlowIn,
    'slowMiddle': Curves.slowMiddle,
    'decelerate': Curves.decelerate,
    // ===== v1.1.0 新增：列表页面动效曲线 =====
    'list-item-slide': Curves.easeOutCubic,
    'swipe-delete-feedback': Curves.elasticOut,
    'search-highlight': Curves.easeInOutCubic,
    'bulk-select-bounce': Curves.bounceOut,
    'infinite-scroll-fade': Curves.easeInOut,
    'drag-sort-bounce': Curves.elasticIn,
    'filter-expand-collapse': Curves.fastOutSlowIn,
  };

  // ===== v1.1.0 新功能：iOS 18特性 =====

  /// iOS 18 风格的深度动画
  Future<void> executeDepthAnimation({
    required String animationId,
    required TickerProvider vsync,
    required Widget target,
    double depth = 0.1,
    Duration duration = const Duration(milliseconds: 600),
    Curve curve = Curves.easeInOutCubic,
  }) async {
    if (!_currentTheme.enableAnimations) return;

    _recordAnimationStart(animationId);

    try {
      final controller = AnimationController(
        duration: _currentTheme.adjustDuration(duration),
        vsync: vsync,
      );


      await controller.forward();
      await controller.reverse();

      _recordAnimationEnd(animationId, true);
    } catch (e) {
      _recordAnimationEnd(animationId, false);
      rethrow;
    }
  }

  /// iOS 18 风格的材质动画
  Future<void> executeMaterialAnimation({
    required String animationId,
    required TickerProvider vsync,
    required Widget target,
    double intensity = 1.0,
    Duration duration = const Duration(milliseconds: 800),
  }) async {
    if (!_currentTheme.enableAnimations) return;

    _recordAnimationStart(animationId);

    try {
      // iOS 18风格的多层材质动画
      final specs = [
        IOSAnimationSpec(
          type: AnimationType.appear,
          duration: duration ~/ 3,
          begin: 0.0,
          end: intensity * 0.3,
        ),
        IOSAnimationSpec(
          type: AnimationType.transform,
          duration: duration ~/ 3,
          begin: 1.0,
          end: 1.0 + intensity * 0.1,
        ),
        IOSAnimationSpec(
          type: AnimationType.disappear,
          duration: duration ~/ 3,
          begin: intensity * 0.3,
          end: 0.0,
        ),
      ];

      await executeSequence(
        animationId: animationId,
        vsync: vsync,
        specs: specs,
      );

      _recordAnimationEnd(animationId, true);
    } catch (e) {
      _recordAnimationEnd(animationId, false);
      rethrow;
    }
  }

  IOSAnimationTheme _currentTheme = defaultTheme;
  IOSAnimationTheme get currentTheme => _currentTheme;

  void updateTheme(IOSAnimationTheme theme) {
    _currentTheme = theme;
  }

  // ===== 性能监控 =====

  final Map<String, AnimationMetrics> _performanceMetrics = {};

  void _recordAnimationStart(String animationId) {
    if (!_currentTheme.enablePerformanceMonitoring) return;

    _performanceMetrics[animationId] = AnimationMetrics(
      startTime: DateTime.now(),
      animationId: animationId,
    );
  }

  void _recordAnimationEnd(String animationId, bool successful) {
    if (!_currentTheme.enablePerformanceMonitoring) return;

    final metrics = _performanceMetrics[animationId];
    if (metrics != null) {
      metrics.endTime = DateTime.now();
      metrics.successful = successful;
      metrics.duration =
          metrics.endTime!.difference(metrics.startTime).inMilliseconds;

      // 记录性能指标
      _logPerformanceMetrics(metrics);
    }
  }

  void _logPerformanceMetrics(AnimationMetrics metrics) {
    debugPrint('[IOSAnimationSystem] Animation "${metrics.animationId}" '
        'completed in ${metrics.duration}ms (${metrics.successful ?? false ? 'success' : 'failed'})');
  }

  // ===== 高级动效API =====

  /// 执行组合动效序列
  Future<void> executeSequence({
    required String animationId,
    required TickerProvider vsync,
    required List<IOSAnimationSpec> specs,
    VoidCallback? onComplete,
    VoidCallback? onError,
  }) async {
    if (!_currentTheme.enableAnimations) {
      onComplete?.call();
      return;
    }

    _recordAnimationStart(animationId);

    try {
      final completer = Completer<void>();
      _pendingAnimations[animationId] = completer;

      // 按顺序执行动效
      for (final spec in specs) {
        await _executeSingleAnimation(
          animationId: '$animationId-${spec.type}',
          vsync: vsync,
          spec: spec,
        );
      }

      completer.complete();
      _recordAnimationEnd(animationId, true);
      onComplete?.call();
    } catch (e) {
      _recordAnimationEnd(animationId, false);
      onError?.call();
      rethrow;
    } finally {
      _pendingAnimations.remove(animationId);
    }
  }

  /// 执行单个动效
  Future<void> executeAnimation({
    required String animationId,
    required TickerProvider vsync,
    required IOSAnimationSpec spec,
    VoidCallback? onComplete,
    VoidCallback? onError,
  }) async {
    if (!_currentTheme.enableAnimations) {
      onComplete?.call();
      return;
    }

    _recordAnimationStart(animationId);

    try {
      await _executeSingleAnimation(
        animationId: animationId,
        vsync: vsync,
        spec: spec,
      );

      _recordAnimationEnd(animationId, true);
      onComplete?.call();
    } catch (e) {
      _recordAnimationEnd(animationId, false);
      onError?.call();
      rethrow;
    }
  }

  Future<void> _executeSingleAnimation({
    required String animationId,
    required TickerProvider vsync,
    required IOSAnimationSpec spec,
  }) async {
    final completer = Completer<void>();

    try {
      // 创建动画控制器
      final controller = AnimationController(
        duration: _currentTheme.adjustDuration(spec.duration),
        vsync: vsync,
      );

      _activeControllers[animationId] = controller;

      // 执行动画
      controller.forward().then((_) {
        completer.complete();
      }).catchError((Object error) {
        completer.completeError(error);
      });
    } catch (e) {
      completer.completeError(e);
    }

    return completer.future;
  }


  // ===== iOS风格动效组件 =====

  /// iOS风格弹性按钮
  Widget iosButton({
    required Widget child,
    required VoidCallback onPressed,
    IOSButtonStyle style = IOSButtonStyle.filled,
    bool enabled = true,
  }) =>
      _IOSButton(
        onPressed: enabled ? onPressed : null,
        style: style,
        enabled: enabled,
        theme: _currentTheme,
        child: child,
      );

  /// iOS风格卡片
  Widget iosCard({
    required Widget child,
    EdgeInsetsGeometry? padding,
    Color? backgroundColor,
    double? elevation,
    VoidCallback? onTap,
  }) =>
      _IOSCard(
        padding: padding,
        backgroundColor: backgroundColor,
        elevation: elevation,
        onTap: onTap,
        theme: _currentTheme,
        child: child,
      );

  /// iOS风格列表项
  Widget iosListItem({
    required Widget child,
    bool isLast = false,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
  }) =>
      _IOSListItem(
        isLast: isLast,
        onTap: onTap,
        onLongPress: onLongPress,
        theme: _currentTheme,
        child: child,
      );

  /// iOS风格模态弹窗
  Future<T?> showIOSModal<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool barrierDismissible = true,
    Color? barrierColor,
  }) =>
      showGeneralDialog<T>(
        context: context,
        barrierDismissible: barrierDismissible,
        barrierColor: barrierColor ?? Colors.black.withOpacity(0.5),
        barrierLabel: 'Dismiss',
        transitionDuration:
            _currentTheme.adjustDuration(IOSAnimationConfig.normal),
        pageBuilder: (context, animation, secondaryAnimation) => Material(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 400,
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              child: builder(context),
            ),
          ),
        ),
        transitionBuilder: (context, animation, secondaryAnimation, child) =>
            ScaleTransition(
          scale: Tween<double>(
            begin: 0.8,
            end: 1.0,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: IOSAnimationConfig.spring,
            ),
          ),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        ),
      );

  // ===== 资源管理 =====

  /// 清理所有动效资源
  void dispose() {
    for (final controller in _activeControllers.values) {
      controller.dispose();
    }
    _activeControllers.clear();

    for (final completer in _pendingAnimations.values) {
      if (!completer.isCompleted) {
        completer.complete();
      }
    }
    _pendingAnimations.clear();

    _engine.disposeAll();
  }

  /// 取消特定动效
  void cancelAnimation(String animationId) {
    final controller = _activeControllers[animationId];
    if (controller != null) {
      controller.stop();
      controller.dispose();
      _activeControllers.remove(animationId);
    }

    final completer = _pendingAnimations[animationId];
    if (completer != null && !completer.isCompleted) {
      completer.complete();
      _pendingAnimations.remove(animationId);
    }
  }

  // ===== v1.1.0 新增：列表页面专用动效方法 =====

  /// 创建带有滑动删除反馈的列表项
  Widget iosSwipeableListItem({
    required Widget child,
    required SwipeAction action,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    double actionWidth = 120.0,
    Duration animationDuration = const Duration(milliseconds: 300),
  }) =>
      SwipeActionItem(
        action: action,
        actionWidth: actionWidth,
        child: iosListItem(
          child: child,
          onTap: onTap,
          onLongPress: onLongPress,
        ),
      )
          .animate(
            target: onTap != null ? 1.0 : 0.0,
          )
          .scale(
            begin: const Offset(1.0, 1.0),
            end: const Offset(0.98, 0.98),
            curve: IOSAnimationSystem.getCustomCurve('swipe-delete-feedback') ??
                Curves.elasticOut,
            duration: animationDuration,
          );

  /// 搜索高亮动效
  Widget iosSearchHighlight({
    required Widget child,
    required bool isHighlighted,
    Color highlightColor = Colors.yellow,
    Duration duration = const Duration(milliseconds: 400),
  }) =>
      Container(
        child: child,
      )
          .animate(
            target: isHighlighted ? 1.0 : 0.0,
          )
          .tint(
            color: highlightColor.withOpacity(0.3),
            curve: IOSAnimationSystem.getCustomCurve('search-highlight') ??
                Curves.easeInOutCubic,
            duration: duration,
          );

  /// 批量选择弹跳动效
  Widget iosBulkSelectBounce({
    required Widget child,
    required bool isSelected,
    Duration duration = const Duration(milliseconds: 300),
  }) =>
      child
          .animate(
            target: isSelected ? 1.0 : 0.0,
          )
          .scale(
            begin: const Offset(1.0, 1.0),
            end: const Offset(1.05, 1.05),
            curve: IOSAnimationSystem.getCustomCurve('bulk-select-bounce') ??
                Curves.bounceOut,
            duration: duration,
          );

  /// 无限滚动淡入动效
  Widget iosInfiniteScrollFade({
    required Widget child,
    required bool isVisible,
    double beginOpacity = 0.0,
    double endOpacity = 1.0,
    Duration duration = const Duration(milliseconds: 500),
  }) =>
      child
          .animate(
            target: isVisible ? 1.0 : 0.0,
          )
          .fade(
            begin: beginOpacity,
            end: endOpacity,
            curve: IOSAnimationSystem.getCustomCurve('infinite-scroll-fade') ??
                Curves.easeInOut,
            duration: duration,
          );

  /// 拖拽排序弹跳反馈
  Widget iosDragSortBounce({
    required Widget child,
    required bool isDragging,
    double elevation = 8.0,
    Duration duration = const Duration(milliseconds: 200),
  }) =>
      child
          .animate(
            target: isDragging ? 1.0 : 0.0,
          )
          .elevation(
            begin: 2.0,
            end: elevation,
            curve: IOSAnimationSystem.getCustomCurve('drag-sort-bounce') ??
                Curves.elasticIn,
            duration: duration,
          )
          .scale(
            begin: const Offset(1.0, 1.0),
            end: const Offset(1.02, 1.02),
            curve: IOSAnimationSystem.getCustomCurve('drag-sort-bounce') ??
                Curves.elasticIn,
            duration: duration,
          );

  /// 筛选展开/折叠动效
  Widget iosFilterExpandCollapse({
    required Widget child,
    required bool isExpanded,
    Duration duration = const Duration(milliseconds: 350),
  }) =>
      child
          .animate(
            target: isExpanded ? 1.0 : 0.0,
          )
          .slideY(
            begin: -0.2,
            end: 0.0,
            curve:
                IOSAnimationSystem.getCustomCurve('filter-expand-collapse') ??
                    Curves.fastOutSlowIn,
            duration: duration,
          )
          .fade(
            begin: 0.0,
            end: 1.0,
            curve:
                IOSAnimationSystem.getCustomCurve('filter-expand-collapse') ??
                    Curves.fastOutSlowIn,
            duration: duration,
          );
}

/// iOS动效主题配置
class IOSAnimationTheme {
  const IOSAnimationTheme({
    this.enableAnimations = true,
    this.enableHapticFeedback = true,
    this.respectReducedMotion = true,
    this.enablePerformanceMonitoring = false,
    this.animationSpeed = 1.0,
  });
  final bool enableAnimations;
  final bool enableHapticFeedback;
  final bool respectReducedMotion;
  final bool enablePerformanceMonitoring;
  final double animationSpeed;

  Duration adjustDuration(Duration duration) {
    if (!enableAnimations) return Duration.zero;
    return Duration(
      milliseconds: (duration.inMilliseconds * animationSpeed).round(),
    );
  }

  IOSAnimationTheme copyWith({
    bool? enableAnimations,
    bool? enableHapticFeedback,
    bool? respectReducedMotion,
    bool? enablePerformanceMonitoring,
    double? animationSpeed,
  }) =>
      IOSAnimationTheme(
        enableAnimations: enableAnimations ?? this.enableAnimations,
        enableHapticFeedback: enableHapticFeedback ?? this.enableHapticFeedback,
        respectReducedMotion: respectReducedMotion ?? this.respectReducedMotion,
        enablePerformanceMonitoring:
            enablePerformanceMonitoring ?? this.enablePerformanceMonitoring,
        animationSpeed: animationSpeed ?? this.animationSpeed,
      );
}

/// 动效规格定义
class IOSAnimationSpec {
  const IOSAnimationSpec({
    required this.type,
    required this.duration,
    this.curve,
    this.begin,
    this.end,
    this.enableHaptic = false,
  });
  final AnimationType type;
  final Duration duration;
  final Curve? curve;
  final double? begin;
  final double? end;
  final bool enableHaptic;

  // 预定义规格
  static const IOSAnimationSpec buttonTap = IOSAnimationSpec(
    type: AnimationType.tap,
    duration: IOSAnimationConfig.fast,
    curve: IOSAnimationConfig.standard,
    begin: 1.0,
    end: IOSAnimationConfig.tapScale,
    enableHaptic: true,
  );

  static const IOSAnimationSpec successFeedback = IOSAnimationSpec(
    type: AnimationType.success,
    duration: IOSAnimationConfig.verySlow,
    curve: IOSAnimationConfig.spring,
    begin: 1.0,
    end: 1.2,
    enableHaptic: true,
  );
}

/// 性能指标
class AnimationMetrics {
  AnimationMetrics({
    required this.animationId,
    required this.startTime,
  });
  final String animationId;
  final DateTime startTime;
  DateTime? endTime;
  int? duration;
  bool? successful;
}

/// 按钮样式枚举
enum IOSButtonStyle {
  filled,
  outlined,
  text,
}

/// 私有组件实现
class _IOSButton extends StatefulWidget {
  const _IOSButton({
    required this.child,
    required this.onPressed,
    required this.style,
    required this.enabled,
    required this.theme,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final IOSButtonStyle style;
  final bool enabled;
  final IOSAnimationTheme theme;

  @override
  State<_IOSButton> createState() => _IOSButtonState();
}

class _IOSButtonState extends State<_IOSButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.theme.adjustDuration(IOSAnimationConfig.fast),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: IOSAnimationConfig.tapScale,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: IOSAnimationConfig.standard,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.enabled) {
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onPressed?.call();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final buttonStyle = _getButtonStyle();

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Transform.scale(
          scale: widget.enabled ? _scaleAnimation.value : 1.0,
          child: Opacity(
            opacity: widget.enabled ? 1.0 : 0.5,
            child: ElevatedButton(
              onPressed: widget.enabled ? () {} : null,
              style: buttonStyle,
              child: widget.child,
            )
                .animate(
                  target: widget.enabled ? 1.0 : 0.0,
                )
                .scale(
                  begin: const Offset(0.95, 0.95),
                  end: const Offset(1.0, 1.0),
                  curve: IOSAnimationConfig.spring,
                ),
          ),
        ),
      ),
    );
  }

  ButtonStyle _getButtonStyle() {
    switch (widget.style) {
      case IOSButtonStyle.filled:
        return ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        );
      case IOSButtonStyle.outlined:
        return OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.blue),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        );
      case IOSButtonStyle.text:
        return TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        );
    }
  }
}

class _IOSCard extends StatelessWidget {
  const _IOSCard({
    required this.child,
    required this.padding,
    required this.backgroundColor,
    required this.elevation,
    required this.onTap,
    required this.theme,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final double? elevation;
  final VoidCallback? onTap;
  final IOSAnimationTheme theme;

  @override
  Widget build(BuildContext context) => Card(
        color: backgroundColor ?? Colors.white,
        elevation: elevation ?? 2,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      )
          .animate(
            target: onTap != null ? 1.0 : 0.0,
          )
          .scale(
            begin: const Offset(1.0, 1.0),
            end: const Offset(1.02, 1.02),
            curve: IOSAnimationConfig.standard,
            duration: theme.adjustDuration(IOSAnimationConfig.fast),
          );
}

class _IOSListItem extends StatelessWidget {
  const _IOSListItem({
    required this.child,
    required this.isLast,
    required this.onTap,
    required this.onLongPress,
    required this.theme,
  });

  final Widget child;
  final bool isLast;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final IOSAnimationTheme theme;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: isLast
                ? BorderSide.none
                : BorderSide(color: Colors.grey.withOpacity(0.2), width: 0.5),
          ),
        ),
        child: ListTile(
          onTap: onTap,
          onLongPress: onLongPress,
          title: child,
        ),
      )
          .animate(
            target: onTap != null ? 1.0 : 0.0,
          )
          .fadeIn(
            duration: theme.adjustDuration(IOSAnimationConfig.normal),
            curve: IOSAnimationConfig.decelerate,
          )
          .slideX(
            begin: 0.1,
            end: 0.0,
            duration: theme.adjustDuration(IOSAnimationConfig.normal),
            curve: IOSAnimationConfig.standard,
          );
}
