import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:your_finance_flutter/core/animations/animation_config.dart';

/// iOS风格状态变化动效组件
/// 基于Notion的状态反馈和过渡动画

/// 状态切换容器
class IOSStateContainer extends StatefulWidget {
  const IOSStateContainer({
    required this.child,
    super.key,
    this.state = AnimationState.normal,
    this.duration = IOSAnimationConfig.normal,
    this.enableHaptic = true,
    this.onStateChanged,
  });

  final Widget child;
  final AnimationState state;
  final Duration duration;
  final bool enableHaptic;
  final VoidCallback? onStateChanged;

  @override
  State<IOSStateContainer> createState() => _IOSStateContainerState();
}

class _IOSStateContainerState extends State<IOSStateContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<Color?> _colorAnimation;

  AnimationState _previousState = AnimationState.normal;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _setupAnimations();
  }

  @override
  void didUpdateWidget(IOSStateContainer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.state != oldWidget.state) {
      _previousState = oldWidget.state;
      _updateAnimations();
      _controller.forward(from: 0.0);
      widget.onStateChanged?.call();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: _getScaleForState(widget.state),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: _getCurveForState(widget.state),
      ),
    );

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: _getOpacityForState(widget.state),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: _getCurveForState(widget.state),
      ),
    );

    _colorAnimation = ColorTween(
      begin: _getColorForState(_previousState),
      end: _getColorForState(widget.state),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: IOSAnimationConfig.standard,
      ),
    );
  }

  void _updateAnimations() {
    _scaleAnimation = Tween<double>(
      begin: _getScaleForState(_previousState),
      end: _getScaleForState(widget.state),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: _getCurveForState(widget.state),
      ),
    );

    _opacityAnimation = Tween<double>(
      begin: _getOpacityForState(_previousState),
      end: _getOpacityForState(widget.state),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: _getCurveForState(widget.state),
      ),
    );

    _colorAnimation = ColorTween(
      begin: _getColorForState(_previousState),
      end: _getColorForState(widget.state),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: IOSAnimationConfig.standard,
      ),
    );
  }

  double _getScaleForState(AnimationState state) {
    switch (state) {
      case AnimationState.normal:
        return 1.0;
      case AnimationState.pressed:
        return IOSAnimationConfig.pressScale;
      case AnimationState.selected:
        return 1.05;
      case AnimationState.success:
        return 1.1;
      case AnimationState.error:
        return 0.95;
      case AnimationState.loading:
        return 1.02;
      case AnimationState.disabled:
        return 0.98;
    }
  }

  double _getOpacityForState(AnimationState state) {
    switch (state) {
      case AnimationState.normal:
        return 1.0;
      case AnimationState.pressed:
        return IOSAnimationConfig.hoverOpacity;
      case AnimationState.selected:
        return 1.0;
      case AnimationState.success:
        return 1.0;
      case AnimationState.error:
        return 0.8;
      case AnimationState.loading:
        return 0.9;
      case AnimationState.disabled:
        return IOSAnimationConfig.disabledOpacity;
    }
  }

  Color _getColorForState(AnimationState state) {
    switch (state) {
      case AnimationState.normal:
        return Colors.transparent;
      case AnimationState.pressed:
        return Colors.black.withOpacity(0.05);
      case AnimationState.selected:
        return Colors.blue.withOpacity(0.1);
      case AnimationState.success:
        return Colors.green.withOpacity(0.1);
      case AnimationState.error:
        return Colors.red.withOpacity(0.1);
      case AnimationState.loading:
        return Colors.orange.withOpacity(0.1);
      case AnimationState.disabled:
        return Colors.grey.withOpacity(0.1);
    }
  }

  Curve _getCurveForState(AnimationState state) {
    switch (state) {
      case AnimationState.normal:
        return IOSAnimationConfig.standard;
      case AnimationState.pressed:
        return IOSAnimationConfig.accelerate;
      case AnimationState.selected:
        return IOSAnimationConfig.bounce;
      case AnimationState.success:
        return IOSAnimationConfig.spring;
      case AnimationState.error:
        return IOSAnimationConfig.standard;
      case AnimationState.loading:
        return IOSAnimationConfig.standard;
      case AnimationState.disabled:
        return IOSAnimationConfig.decelerate;
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Container(
          decoration: BoxDecoration(
            color: _colorAnimation.value,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: widget.child,
            ),
          ),
        ),
      );
}

/// 加载状态动画容器
class IOSLoadingContainer extends StatefulWidget {
  const IOSLoadingContainer({
    required this.child,
    super.key,
    this.isLoading = false,
    this.loadingColor = Colors.blue,
    this.duration = const Duration(milliseconds: 600),
  });

  final Widget child;
  final bool isLoading;
  final Color loadingColor;
  final Duration duration;

  @override
  State<IOSLoadingContainer> createState() => _IOSLoadingContainerState();
}

class _IOSLoadingContainerState extends State<IOSLoadingContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ),
    );
  }

  @override
  void didUpdateWidget(IOSLoadingContainer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isLoading && !oldWidget.isLoading) {
      _controller.repeat();
    } else if (!widget.isLoading && oldWidget.isLoading) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Stack(
        alignment: Alignment.center,
        children: [
          // 主要内容（带脉冲效果）
          Transform.scale(
            scale: _pulseAnimation.value,
            child: Opacity(
              opacity: 0.7,
              child: widget.child,
            ),
          ),
          // 加载指示器
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Transform.rotate(
              angle: _rotationAnimation.value,
              child: Icon(
                Icons.refresh,
                color: widget.loadingColor,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 成功反馈动画容器
class IOSSuccessContainer extends StatefulWidget {
  const IOSSuccessContainer({
    required this.child,
    super.key,
    this.successTrigger,
    this.successColor = Colors.green,
    this.particleColor = Colors.green,
    this.particleCount = 8,
    this.duration = IOSAnimationConfig.verySlow,
    this.enableHaptic = true,
  });

  final Widget child;
  final bool? successTrigger;
  final Color successColor;
  final Color particleColor;
  final int particleCount;
  final Duration duration;
  final bool enableHaptic;

  @override
  State<IOSSuccessContainer> createState() => _IOSSuccessContainerState();
}

class _IOSSuccessContainerState extends State<IOSSuccessContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkAnimation;

  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: IOSAnimationConfig.spring,
      ),
    );

    _checkAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: IOSAnimationConfig.bounce,
        // 开始延迟
      ),
    );
  }

  @override
  void didUpdateWidget(IOSSuccessContainer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.successTrigger ?? false && oldWidget.successTrigger != true) {
      _startSuccessAnimation();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startSuccessAnimation() {
    if (_isAnimating) return;

    setState(() => _isAnimating = true);

    // iOS风格的触觉反馈
    if (widget.enableHaptic) {
      // HapticFeedback.success(); // 需要导入 haptic_feedback
    }

    _controller.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() => _isAnimating = false);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Stack(
          alignment: Alignment.center,
          children: [
            // 主要内容
            Transform.scale(
              scale: _scaleAnimation.value,
              child: widget.child,
            ),

            // 成功图标和粒子效果
            if (_isAnimating) ...[
              // 背景光晕
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: widget.successColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
              ),

              // 粒子效果
              ..._buildParticles(),

              // 成功图标
              AnimatedBuilder(
                animation: _checkAnimation,
                builder: (context, child) => CustomPaint(
                  size: const Size(40, 40),
                  painter: _CheckPainter(
                    progress: _checkAnimation.value,
                    color: widget.successColor,
                  ),
                ),
              ),
            ],
          ],
        ),
      );

  List<Widget> _buildParticles() {
    final particles = <Widget>[];

    for (var i = 0; i < widget.particleCount; i++) {
      final angle = (i / widget.particleCount) * 2 * math.pi;
      const distance = 60.0;

      particles.add(
        Transform.translate(
          offset: Offset(
            math.cos(angle) * distance * _controller.value,
            math.sin(angle) * distance * _controller.value,
          ),
          child: Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: widget.particleColor.withOpacity(1 - _controller.value),
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
    }

    return particles;
  }
}

/// 自定义打勾动画绘制器
class _CheckPainter extends CustomPainter {
  _CheckPainter({required this.progress, required this.color});
  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // 打勾路径
    final path = Path();
    path.moveTo(size.width * 0.25, size.height * 0.5);
    path.lineTo(size.width * 0.45, size.height * 0.7);
    path.lineTo(size.width * 0.75, size.height * 0.3);

    // 创建路径度量
    final pathMetric = path.computeMetrics().first;
    final extractPath = pathMetric.extractPath(
      0,
      pathMetric.length * progress,
    );

    canvas.drawPath(extractPath, paint);
  }

  @override
  bool shouldRepaint(_CheckPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}

/// 数字滚动动画容器
class IOSNumberRollContainer extends StatefulWidget {
  const IOSNumberRollContainer({
    required this.value,
    super.key,
    this.style,
    this.duration = const Duration(milliseconds: 800),
    this.curve = Curves.easeOutCubic,
    this.formatter,
  });

  final double value;
  final TextStyle? style;
  final Duration duration;
  final Curve curve;
  final String Function(double)? formatter;

  @override
  State<IOSNumberRollContainer> createState() => _IOSNumberRollContainerState();
}

class _IOSNumberRollContainerState extends State<IOSNumberRollContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _previousValue = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: _previousValue,
      end: widget.value,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
      ),
    );

    _controller.forward();
  }

  @override
  void didUpdateWidget(IOSNumberRollContainer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.value != widget.value) {
      _previousValue = oldWidget.value;
      _animation = Tween<double>(
        begin: _previousValue,
        end: widget.value,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: widget.curve,
        ),
      );

      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatValue(double value) {
    if (widget.formatter != null) {
      return widget.formatter!(value);
    }

    // 默认格式化为整数并添加千分位分隔符
    final intValue = value.toInt();
    return intValue.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
        );
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _animation,
        builder: (context, child) => Text(
          _formatValue(_animation.value),
          style: widget.style ?? Theme.of(context).textTheme.displayLarge,
        ),
      );
}

/// 状态枚举
enum AnimationState {
  normal,
  pressed,
  selected,
  success,
  error,
  loading,
  disabled,
}
