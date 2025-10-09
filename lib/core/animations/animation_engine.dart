import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:your_finance_flutter/core/animations/animation_config.dart';

/// iOS风格动效引擎
/// 核心动效执行和协调系统
class IOSAnimationEngine {
  factory IOSAnimationEngine() => _instance;
  IOSAnimationEngine._internal();
  static final IOSAnimationEngine _instance = IOSAnimationEngine._internal();

  // ===== 动画控制器池 =====
  final Map<String, AnimationController> _controllers = {};

  // ===== 动效执行器 =====

  /// 执行标准动画
  Future<void> executeAnimation({
    required String animationId,
    required TickerProvider vsync,
    required AnimationSpec spec,
    required VoidCallback onUpdate,
    VoidCallback? onComplete,
  }) async {
    final controller = _getOrCreateController(animationId, vsync);

    // 配置动画
    _configureController(controller, spec);

    // 执行动画
    controller.forward(from: 0.0).then((_) {
      onComplete?.call();
    });

    // 监听更新
    controller.addListener(onUpdate);
  }

  /// 执行组合动画
  Future<void> executeSequence({
    required String animationId,
    required TickerProvider vsync,
    required List<AnimationSpec> specs,
    required VoidCallback onUpdate,
    VoidCallback? onComplete,
  }) async {
    for (final spec in specs) {
      await executeAnimation(
        animationId: '$animationId-${spec.type}',
        vsync: vsync,
        spec: spec,
        onUpdate: onUpdate,
      );
    }
    onComplete?.call();
  }

  /// 执行弹性动画 (iOS风格)
  Future<void> executeSpringAnimation({
    required String animationId,
    required TickerProvider vsync,
    required double targetValue,
    required double currentValue,
    required Duration duration,
    required VoidCallback onUpdate,
    VoidCallback? onComplete,
  }) async {
    final controller = _getOrCreateController(animationId, vsync);

    final animation = Tween<double>(
      begin: currentValue,
      end: targetValue,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: IOSAnimationConfig.spring,
      ),
    );

    controller.duration = duration;
    controller.forward(from: 0.0).then((_) {
      onComplete?.call();
    });

    controller.addListener(onUpdate);
  }

  /// 执行抖动动画 (iOS风格)
  Future<void> executeShakeAnimation({
    required String animationId,
    required TickerProvider vsync,
    required VoidCallback onUpdate,
    VoidCallback? onComplete,
  }) async {
    final controller = _getOrCreateController(animationId, vsync);

    final shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: IOSAnimationConfig.shakeAmplitude),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(
            begin: IOSAnimationConfig.shakeAmplitude,
            end: -IOSAnimationConfig.shakeAmplitude),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(
            begin: -IOSAnimationConfig.shakeAmplitude,
            end: IOSAnimationConfig.shakeAmplitude),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(
            begin: IOSAnimationConfig.shakeAmplitude,
            end: -IOSAnimationConfig.shakeAmplitude),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: -IOSAnimationConfig.shakeAmplitude, end: 0.0),
        weight: 1,
      ),
    ]).animate(
      CurvedAnimation(
        parent: controller,
        curve: IOSAnimationConfig.standard,
      ),
    );

    controller.duration = IOSAnimationConfig.shakeDuration;
    controller.forward(from: 0.0).then((_) {
      onComplete?.call();
    });

    controller.addListener(onUpdate);
  }

  /// 执行粒子效果动画
  Future<void> executeParticleAnimation({
    required String animationId,
    required TickerProvider vsync,
    required Offset origin,
    required VoidCallback onUpdate,
    VoidCallback? onComplete,
  }) async {
    final controller = _getOrCreateController(animationId, vsync);

    // 创建粒子动画
    final particleAnimations = List.generate(
      IOSAnimationConfig.particleCount,
      (index) => _createParticleAnimation(index, origin),
    );

    controller.duration = IOSAnimationConfig.particleLifetime;
    controller.forward(from: 0.0).then((_) {
      onComplete?.call();
    });

    controller.addListener(onUpdate);
  }

  // ===== 控制器管理 =====

  AnimationController _getOrCreateController(String id, TickerProvider vsync) {
    if (_controllers.containsKey(id)) {
      return _controllers[id]!;
    }

    final controller = AnimationController(vsync: vsync);
    _controllers[id] = controller;
    return controller;
  }

  void _configureController(
      AnimationController controller, AnimationSpec spec) {
    controller.duration = spec.duration;
    controller.reset();
  }

  void disposeController(String id) {
    _controllers[id]?.dispose();
    _controllers.remove(id);
  }

  void disposeAll() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
  }

  // ===== 辅助方法 =====

  Animation<Offset> _createParticleAnimation(int index, Offset origin) {
    final angle = (index / IOSAnimationConfig.particleCount) * 2 * math.pi;
    const distance = IOSAnimationConfig.particleSpread;

    final endOffset = Offset(
      origin.dx + math.cos(angle) * distance,
      origin.dy + math.sin(angle) * distance,
    );

    return Tween<Offset>(
      begin: origin,
      end: endOffset,
    ).animate(
      CurvedAnimation(
        parent: _controllers['particle']!,
        curve: IOSAnimationConfig.bounce,
      ),
    );
  }
}

/// 动效协调器
/// 管理复杂动画序列和状态
class AnimationCoordinator {
  final IOSAnimationEngine _engine = IOSAnimationEngine();

  /// 执行手势反馈动画
  Future<void> executeGestureFeedback({
    required String animationId,
    required TickerProvider vsync,
    required GestureType gesture,
    required VoidCallback onUpdate,
  }) async {
    final spec = _getGestureSpec(gesture);

    await _engine.executeAnimation(
      animationId: animationId,
      vsync: vsync,
      spec: spec,
      onUpdate: onUpdate,
    );
  }

  /// 执行状态变化动画
  Future<void> executeStateTransition({
    required String animationId,
    required TickerProvider vsync,
    required StateTransition transition,
    required VoidCallback onUpdate,
  }) async {
    final specs = _getTransitionSpecs(transition);

    await _engine.executeSequence(
      animationId: animationId,
      vsync: vsync,
      specs: specs,
      onUpdate: onUpdate,
    );
  }

  /// 执行iOS风格的成功反馈
  Future<void> executeSuccessFeedback({
    required String animationId,
    required TickerProvider vsync,
    required Offset position,
    required VoidCallback onUpdate,
  }) async {
    // 缩放动画 + 粒子效果
    await Future.wait([
      _engine.executeSpringAnimation(
        animationId: '$animationId-scale',
        vsync: vsync,
        targetValue: 1.2,
        currentValue: 1.0,
        duration: IOSAnimationConfig.verySlow,
        onUpdate: onUpdate,
      ),
      _engine.executeParticleAnimation(
        animationId: '$animationId-particles',
        vsync: vsync,
        origin: position,
        onUpdate: onUpdate,
      ),
    ]);
  }

  AnimationSpec _getGestureSpec(GestureType gesture) {
    switch (gesture) {
      case GestureType.tap:
        return AnimationSpec.buttonTap;
      case GestureType.longPress:
        return const AnimationSpec(
          type: AnimationType.press,
          context: AnimationContext.gesture,
          duration: IOSAnimationConfig.normal,
          curve: IOSAnimationConfig.accelerate,
          scale: IOSAnimationConfig.pressScale,
          enableHaptic: true,
        );
      case GestureType.drag:
        return const AnimationSpec(
          type: AnimationType.drag,
          context: AnimationContext.gesture,
          duration: IOSAnimationConfig.fast,
          curve: IOSAnimationConfig.standard,
          scale: IOSAnimationConfig.dragScale,
          opacity: IOSAnimationConfig.dragOpacity,
        );
    }
  }

  List<AnimationSpec> _getTransitionSpecs(StateTransition transition) {
    switch (transition) {
      case StateTransition.appear:
        return [
          AnimationSpec.listItemInsert,
          const AnimationSpec(
            type: AnimationType.fade,
            context: AnimationContext.transition,
            duration: IOSAnimationConfig.normal,
            curve: IOSAnimationConfig.decelerate,
            opacity: 1.0,
          ),
        ];
      case StateTransition.disappear:
        return [
          const AnimationSpec(
            type: AnimationType.fade,
            context: AnimationContext.transition,
            duration: IOSAnimationConfig.fast,
            curve: IOSAnimationConfig.accelerate,
            opacity: 0.0,
          ),
          const AnimationSpec(
            type: AnimationType.slide,
            context: AnimationContext.transition,
            duration: IOSAnimationConfig.fast,
            curve: IOSAnimationConfig.accelerate,
            offset: Offset(0, -20),
          ),
        ];
      case StateTransition.transform:
        return [
          const AnimationSpec(
            type: AnimationType.scale,
            context: AnimationContext.transition,
            duration: IOSAnimationConfig.normal,
            curve: IOSAnimationConfig.bounce,
            scale: 1.1,
          ),
          const AnimationSpec(
            type: AnimationType.rotate,
            context: AnimationContext.transition,
            duration: IOSAnimationConfig.slow,
            curve: IOSAnimationConfig.spring,
          ),
        ];
    }
  }

  void dispose() {
    _engine.disposeAll();
  }
}

/// 手势类型枚举
enum GestureType {
  tap,
  longPress,
  drag,
}

/// 状态转换类型枚举
enum StateTransition {
  appear,
  disappear,
  transform,
}
