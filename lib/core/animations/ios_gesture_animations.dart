import 'package:flutter/material.dart';
import 'package:your_finance_flutter/core/animations/animation_config.dart';
import 'package:your_finance_flutter/core/animations/animation_engine.dart';

/// iOS风格手势动效组件
/// 基于Notion iOS版本的手势反馈实现

/// 手势反馈容器
class IOSGestureContainer extends StatefulWidget {
  const IOSGestureContainer({
    required this.child,
    super.key,
    this.onTap,
    this.onLongPress,
    this.onDragStart,
    this.onDragUpdate,
    this.onDragEnd,
    this.enableHaptic = true,
    this.enableSpring = true,
    this.scaleFactor = IOSAnimationConfig.tapScale,
    this.dragScaleFactor = IOSAnimationConfig.dragScale,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onDragStart;
  final void Function(DragUpdateDetails)? onDragUpdate;
  final void Function(DragEndDetails)? onDragEnd;
  final bool enableHaptic;
  final bool enableSpring;
  final double scaleFactor;
  final double dragScaleFactor;

  @override
  State<IOSGestureContainer> createState() => _IOSGestureContainerState();
}

class _IOSGestureContainerState extends State<IOSGestureContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  bool _isPressed = false;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: IOSAnimationConfig.fast,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleFactor,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: IOSAnimationConfig.standard,
      ),
    );

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: IOSAnimationConfig.hoverOpacity,
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
    if (!mounted) return;

    setState(() => _isPressed = true);
    _controller.forward();

    // iOS风格的触觉反馈
    if (widget.enableHaptic) {
      // HapticFeedback.lightImpact(); // 需要导入 haptic_feedback
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (!mounted) return;

    setState(() => _isPressed = false);
    _controller.reverse();
    widget.onTap?.call();
  }

  void _handleTapCancel() {
    if (!mounted) return;

    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _handleLongPress() {
    if (!mounted) return;

    // 长按时的额外反馈
    if (widget.enableSpring) {
      final springController = AnimationController(
        duration: IOSAnimationConfig.slow,
        vsync: this,
      );

      final springAnimation = Tween<double>(
        begin: widget.scaleFactor,
        end: widget.scaleFactor * 0.9,
      ).animate(
        CurvedAnimation(
          parent: springController,
          curve: IOSAnimationConfig.spring,
        ),
      );

      springController.forward().then((_) {
        springController.reverse();
        widget.onLongPress?.call();
      });

      springController.addListener(() {
        if (mounted) setState(() {});
      });
    } else {
      widget.onLongPress?.call();
    }
  }

  void _handleDragStart(DragStartDetails details) {
    if (!mounted) return;

    setState(() => _isDragging = true);

    // 拖拽开始时的缩放反馈
    _controller.animateTo(
      widget.dragScaleFactor,
      duration: IOSAnimationConfig.veryFast,
      curve: IOSAnimationConfig.accelerate,
    );

    widget.onDragStart?.call();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    widget.onDragUpdate?.call(details);
  }

  void _handleDragEnd(DragEndDetails details) {
    if (!mounted) return;

    setState(() => _isDragging = false);
    _controller.reverse();

    widget.onDragEnd?.call(details);
  }

  double get _currentScale {
    if (_isDragging) return widget.dragScaleFactor;
    if (_isPressed) return _scaleAnimation.value;
    return 1.0;
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onLongPress: _handleLongPress,
        onHorizontalDragStart: _handleDragStart,
        onHorizontalDragUpdate: _handleDragUpdate,
        onHorizontalDragEnd: _handleDragEnd,
        onVerticalDragStart: _handleDragStart,
        onVerticalDragUpdate: _handleDragUpdate,
        onVerticalDragEnd: _handleDragEnd,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) => Transform.scale(
            scale: _currentScale,
            child: Opacity(
              opacity: _isPressed ? _opacityAnimation.value : 1.0,
              child: widget.child,
            ),
          ),
        ),
      );
}

/// iOS风格抖动反馈组件
class IOSShakeContainer extends StatefulWidget {
  const IOSShakeContainer({
    required this.child,
    super.key,
    this.shakeTrigger,
    this.duration = IOSAnimationConfig.shakeDuration,
    this.amplitude = IOSAnimationConfig.shakeAmplitude,
    this.frequency = IOSAnimationConfig.shakeFrequency,
    this.enableHaptic = true,
  });

  final Widget child;
  final bool? shakeTrigger;
  final Duration duration;
  final double amplitude;
  final int frequency;
  final bool enableHaptic;

  @override
  State<IOSShakeContainer> createState() => _IOSShakeContainerState();
}

class _IOSShakeContainerState extends State<IOSShakeContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shakeAnimation;

  bool _isShaking = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _shakeAnimation = TweenSequence<double>(
      List.generate(widget.frequency, (index) {
        final isEven = index.isEven;
        return TweenSequenceItem(
          tween: Tween(
            begin: isEven ? 0.0 : widget.amplitude,
            end: isEven ? -widget.amplitude : 0.0,
          ),
          weight: 1,
        );
      }),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: IOSAnimationConfig.standard,
      ),
    );
  }

  @override
  void didUpdateWidget(IOSShakeContainer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.shakeTrigger ?? false && oldWidget.shakeTrigger != true) {
      _startShake();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startShake() {
    if (_isShaking) return;

    setState(() => _isShaking = true);

    // iOS风格的触觉反馈
    if (widget.enableHaptic) {
      // HapticFeedback.heavyImpact(); // 需要导入 haptic_feedback
    }

    _controller.forward().then((_) {
      setState(() => _isShaking = false);
    });
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: widget.child,
        ),
      );
}

/// iOS风格弹性反馈组件
class IOSSpringContainer extends StatefulWidget {
  const IOSSpringContainer({
    required this.child,
    super.key,
    this.springTrigger,
    this.targetScale = 1.1,
    this.duration = IOSAnimationConfig.slow,
    this.enableHaptic = true,
  });

  final Widget child;
  final bool? springTrigger;
  final double targetScale;
  final Duration duration;
  final bool enableHaptic;

  @override
  State<IOSSpringContainer> createState() => _IOSSpringContainerState();
}

class _IOSSpringContainerState extends State<IOSSpringContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.targetScale,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: IOSAnimationConfig.spring,
      ),
    );
  }

  @override
  void didUpdateWidget(IOSSpringContainer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.springTrigger ?? false && oldWidget.springTrigger != true) {
      _startSpring();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startSpring() {
    // iOS风格的触觉反馈
    if (widget.enableHaptic) {
      // HapticFeedback.mediumImpact(); // 需要导入 haptic_feedback
    }

    _controller.forward().then((_) {
      _controller.reverse();
    });
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: widget.child,
        ),
      );
}

/// iOS风格拖拽反馈组件
class IOSDragContainer extends StatefulWidget {
  const IOSDragContainer({
    required this.child,
    super.key,
    this.onDragStart,
    this.onDragUpdate,
    this.onDragEnd,
    this.enableShadow = true,
    this.enableRotation = true,
    this.maxRotation = 0.05,
  });

  final Widget child;
  final VoidCallback? onDragStart;
  final void Function(DragUpdateDetails)? onDragUpdate;
  final void Function(DragEndDetails)? onDragEnd;
  final bool enableShadow;
  final bool enableRotation;
  final double maxRotation;

  @override
  State<IOSDragContainer> createState() => _IOSDragContainerState();
}

class _IOSDragContainerState extends State<IOSDragContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  bool _isDragging = false;
  double _dragOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: IOSAnimationConfig.fast,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: IOSAnimationConfig.dragScale,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: IOSAnimationConfig.standard,
      ),
    );

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: IOSAnimationConfig.dragOpacity,
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

  void _handleDragStart(DragStartDetails details) {
    setState(() => _isDragging = true);
    _controller.forward();
    widget.onDragStart?.call();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() => _dragOffset = details.delta.dx);
    widget.onDragUpdate?.call(details);
  }

  void _handleDragEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
      _dragOffset = 0.0;
    });
    _controller.reverse();
    widget.onDragEnd?.call(details);
  }

  double get _currentRotation {
    if (!widget.enableRotation || !_isDragging) return 0.0;
    return (_dragOffset / 200).clamp(-widget.maxRotation, widget.maxRotation);
  }

  double get _currentElevation {
    if (!widget.enableShadow || !_isDragging)
      return IOSAnimationConfig.baseElevation;
    return IOSAnimationConfig.hoverElevation;
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onHorizontalDragStart: _handleDragStart,
        onHorizontalDragUpdate: _handleDragUpdate,
        onHorizontalDragEnd: _handleDragEnd,
        onVerticalDragStart: _handleDragStart,
        onVerticalDragUpdate: _handleDragUpdate,
        onVerticalDragEnd: _handleDragEnd,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) => Transform(
            transform: Matrix4.identity()
              ..rotateZ(_currentRotation)
              ..scale(_isDragging ? _scaleAnimation.value : 1.0),
            child: Opacity(
              opacity: _isDragging ? _opacityAnimation.value : 1.0,
              child: Material(
                elevation: _currentElevation,
                shadowColor: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                child: widget.child,
              ),
            ),
          ),
        ),
      );
}
