import 'package:flutter/material.dart';

class DataRefreshAnimation extends StatefulWidget {
  const DataRefreshAnimation({
    required this.child,
    required this.isRefreshing,
    super.key,
    this.duration = const Duration(milliseconds: 800),
  });
  final Widget child;
  final bool isRefreshing;
  final Duration duration;

  @override
  State<DataRefreshAnimation> createState() => _DataRefreshAnimationState();
}

class _DataRefreshAnimationState extends State<DataRefreshAnimation>
    with TickerProviderStateMixin {
  late AnimationController _blinkController;
  late AnimationController _scaleController;
  late Animation<double> _blinkAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _blinkController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _blinkAnimation = Tween<double>(
      begin: 1.0,
      end: 0.3,
    ).animate(
      CurvedAnimation(
        parent: _blinkController,
        curve: Curves.easeInOut,
      ),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void didUpdateWidget(DataRefreshAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isRefreshing && !oldWidget.isRefreshing) {
      _startRefreshAnimation();
    }
  }

  void _startRefreshAnimation() {
    _blinkController.forward().then((_) {
      _blinkController.reverse();
    });

    _scaleController.forward().then((_) {
      _scaleController.reverse();
    });
  }

  @override
  void dispose() {
    _blinkController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: Listenable.merge([_blinkAnimation, _scaleAnimation]),
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _blinkAnimation.value,
            child: widget.child,
          ),
        ),
      );
}

// 数字滚动动画组件
class NumberRollAnimation extends StatefulWidget {
  const NumberRollAnimation({
    required this.value,
    required this.formatter,
    super.key,
    this.duration = const Duration(milliseconds: 800),
    this.style,
  });
  final double value;
  final String Function(double) formatter;
  final Duration duration;
  final TextStyle? style;

  @override
  State<NumberRollAnimation> createState() => _NumberRollAnimationState();
}

class _NumberRollAnimationState extends State<NumberRollAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _previousValue = 0;

  @override
  void initState() {
    super.initState();
    _previousValue = widget.value;

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
        curve: Curves.easeOutCubic,
      ),
    );

    _controller.forward();
  }

  @override
  void didUpdateWidget(NumberRollAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.value != widget.value) {
      _previousValue = _animation.value;
      _animation = Tween<double>(
        begin: _previousValue,
        end: widget.value,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOutCubic,
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

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _animation,
        builder: (context, child) => Text(
          widget.formatter(_animation.value),
          style: widget.style,
        ),
      );
}

// 闪烁提示组件
class BlinkIndicator extends StatefulWidget {
  const BlinkIndicator({
    required this.child,
    super.key,
    this.blinkColor = const Color(0xFF007AFF),
    this.duration = const Duration(milliseconds: 300),
  });
  final Widget child;
  final Color blinkColor;
  final Duration duration;

  @override
  State<BlinkIndicator> createState() => _BlinkIndicatorState();
}

class _BlinkIndicatorState extends State<BlinkIndicator>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _animation,
        builder: (context, child) => Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color:
                    widget.blinkColor.withValues(alpha: _animation.value * 0.3),
                blurRadius: 8 * _animation.value,
                spreadRadius: 2 * _animation.value,
              ),
            ],
          ),
          child: widget.child,
        ),
      );
}
