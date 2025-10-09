import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:your_finance_flutter/core/animations/animation_config.dart';
import 'package:your_finance_flutter/core/animations/animation_engine.dart';

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

      // 配置动画
      final animation = _createAnimation(controller, spec);

      // 执行动画
      controller.forward().then((_) {
        completer.complete();
      }).catchError(completer.completeError);
    } catch (e) {
      completer.completeError(e);
    }

    return completer.future;
  }

  Animation<double> _createAnimation(
      AnimationController controller, IOSAnimationSpec spec) {
    final curve = spec.curve ?? IOSAnimationConfig.standard;

    return Tween<double>(
      begin: spec.begin ?? 0.0,
      end: spec.end ?? 1.0,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: curve,
      ),
    );
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
        pageBuilder: (context, animation, secondaryAnimation) =>
            builder(context),
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
        milliseconds: (duration.inMilliseconds * animationSpeed).round());
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
