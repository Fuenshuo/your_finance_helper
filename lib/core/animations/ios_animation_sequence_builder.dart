import 'package:flutter/material.dart';
import 'package:your_finance_flutter/core/animations/ios_animation_system.dart';

/// ===== v1.1.0 新功能：高级动画序列构建器 =====

/// 高级动画序列构建器 - 支持复杂的动画编排
class IOSAnimationSequenceBuilder {
  IOSAnimationSequenceBuilder({
    required TickerProvider vsync,
    required IOSAnimationSystem system,
    required String sequenceId,
  })  : _vsync = vsync,
        _system = system,
        _sequenceId = sequenceId;

  final TickerProvider _vsync;
  final IOSAnimationSystem _system;
  final String _sequenceId;

  final List<IOSAnimationStep> _steps = [];
  IOSAnimationSequenceConfig _config = const IOSAnimationSequenceConfig();

  /// 配置序列参数
  IOSAnimationSequenceBuilder configure(IOSAnimationSequenceConfig config) {
    _config = config;
    return this;
  }

  /// 添加动画步骤
  IOSAnimationSequenceBuilder addStep(IOSAnimationStep step) {
    _steps.add(step);
    return this;
  }

  /// 添加延迟步骤
  IOSAnimationSequenceBuilder addDelay(Duration delay) {
    _steps.add(IOSAnimationStep.delay(delay));
    return this;
  }

  /// 添加并行动画步骤
  IOSAnimationSequenceBuilder addParallel(List<IOSAnimationStep> steps) {
    _steps.add(IOSAnimationStep.parallel(steps));
    return this;
  }

  /// 执行序列动画
  Future<void> execute({
    VoidCallback? onComplete,
    VoidCallback? onError,
    void Function(int stepIndex, bool success)? onStepComplete,
  }) async {
    try {
      for (var i = 0; i < _steps.length; i++) {
        final step = _steps[i];
        await step.execute(_system, _vsync, '$_sequenceId-step-$i');
        onStepComplete?.call(i, true);
      }
      onComplete?.call();
    } catch (e) {
      onError?.call();
      rethrow;
    }
  }

  /// 构建可复用的序列
  IOSAnimationSequence build() => IOSAnimationSequence(
        steps: List.from(_steps),
        config: _config,
        sequenceId: _sequenceId,
      );
}

/// 动画序列配置
class IOSAnimationSequenceConfig {
  const IOSAnimationSequenceConfig({
    this.loop = false,
    this.reverseOnComplete = false,
    this.autoDispose = true,
    this.enablePerformanceMonitoring = true,
  });

  final bool loop;
  final bool reverseOnComplete;
  final bool autoDispose;
  final bool enablePerformanceMonitoring;
}

/// 动画步骤
class IOSAnimationStep {
  const IOSAnimationStep({
    required this.spec,
    this.delay = Duration.zero,
    this.condition,
    List<IOSAnimationStep>? parallelSteps,
  }) : _parallelSteps = parallelSteps;

  const IOSAnimationStep.delay(Duration delay)
      : spec = null,
        delay = delay,
        condition = null,
        _parallelSteps = null;

  const IOSAnimationStep.parallel(List<IOSAnimationStep> steps)
      : spec = null,
        delay = Duration.zero,
        condition = null,
        _parallelSteps = steps;

  final IOSAnimationSpec? spec;
  final Duration delay;
  final bool Function()? condition;
  final List<IOSAnimationStep>? _parallelSteps;

  bool get isDelay => spec == null && _parallelSteps == null;
  bool get isParallel => _parallelSteps != null;

  Future<void> execute(
    IOSAnimationSystem system,
    TickerProvider vsync,
    String stepId,
  ) async {
    if (condition != null && !condition!()) return;

    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
      return;
    }

    if (isParallel && _parallelSteps != null) {
      await Future.wait(
        _parallelSteps.map((step) => step.execute(system, vsync, stepId)),
      );
      return;
    }

    if (spec != null) {
      await system.executeAnimation(
        animationId: stepId,
        vsync: vsync,
        spec: spec!,
      );
    }
  }
}

/// 可复用的动画序列
class IOSAnimationSequence {
  const IOSAnimationSequence({
    required this.steps,
    required this.config,
    required this.sequenceId,
  });

  final List<IOSAnimationStep> steps;
  final IOSAnimationSequenceConfig config;
  final String sequenceId;

  Future<void> execute(
    IOSAnimationSystem system,
    TickerProvider vsync, {
    VoidCallback? onComplete,
    VoidCallback? onError,
  }) async {
    final builder = system.createSequenceBuilder(
        vsync: vsync, sequenceId: sequenceId)
      ..configure(config);

    for (final step in steps) {
      if (step.isDelay) {
        builder.addDelay(step.delay);
      } else if (step.isParallel) {
        // Handle parallel steps
      } else {
        builder.addStep(step);
      }
    }

    await builder.execute(
      onComplete: onComplete,
      onError: onError,
    );
  }
}
