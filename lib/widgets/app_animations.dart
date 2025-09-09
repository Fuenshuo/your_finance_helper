import 'package:flutter/material.dart';

class AppAnimations {
  // 按钮点击动画
  static Widget animatedButton({
    required Widget child,
    required VoidCallback onPressed,
    Duration duration = const Duration(milliseconds: 150),
  }) {
    return _AnimatedButton(
      onPressed: onPressed,
      duration: duration,
      child: child,
    );
  }

  // 数字滚动动画
  static Widget animatedNumber({
    required double value,
    required String Function(double) formatter,
    Duration duration = const Duration(milliseconds: 800),
    Curve curve = Curves.easeOutCubic,
  }) {
    return _AnimatedNumber(
      value: value,
      formatter: formatter,
      duration: duration,
      curve: curve,
    );
  }

  // 列表项动画
  static Widget animatedListItem({
    required Widget child,
    required int index,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeOutCubic,
  }) {
    return _AnimatedListItem(
      index: index,
      duration: duration,
      curve: curve,
      child: child,
    );
  }

  // 页面转场动画
  static Route<T> createRoute<T extends Object?>(
    Widget page, {
    RouteSettings? settings,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOutCubic,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: duration,
    );
  }

  // 模态弹窗动画
  static Future<T?> showAppModalBottomSheet<T>({
    required BuildContext context,
    required Widget child,
    bool isScrollControlled = true,
    bool showDragHandle = true,
    Color? backgroundColor,
    double? elevation,
    ShapeBorder? shape,
    Clip? clipBehavior,
    BoxConstraints? constraints,
    Color? barrierColor,
    bool isDismissible = true,
    bool enableDrag = true,
    bool useSafeArea = false,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      showDragHandle: showDragHandle,
      backgroundColor: backgroundColor ?? Colors.white,
      elevation: elevation ?? 8,
      shape: shape ?? const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      clipBehavior: clipBehavior ?? Clip.antiAlias,
      constraints: constraints,
      barrierColor: barrierColor ?? Colors.black54,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      useSafeArea: useSafeArea,
      builder: (context) => child,
    );
  }
}

// 动画按钮实现
class _AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final Duration duration;

  const _AnimatedButton({
    required this.child,
    required this.onPressed,
    required this.duration,
  });

  @override
  State<_AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}

// 数字滚动动画实现
class _AnimatedNumber extends StatefulWidget {
  final double value;
  final String Function(double) formatter;
  final Duration duration;
  final Curve curve;

  const _AnimatedNumber({
    required this.value,
    required this.formatter,
    required this.duration,
    required this.curve,
  });

  @override
  State<_AnimatedNumber> createState() => _AnimatedNumberState();
}

class _AnimatedNumberState extends State<_AnimatedNumber>
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
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
    _controller.forward();
  }

  @override
  void didUpdateWidget(_AnimatedNumber oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _previousValue = oldWidget.value;
      _animation = Tween<double>(
        begin: _previousValue,
        end: widget.value,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
      ));
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
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Text(
          widget.formatter(_animation.value),
          style: Theme.of(context).textTheme.displayLarge,
        );
      },
    );
  }
}

// 列表项动画实现
class _AnimatedListItem extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration duration;
  final Curve curve;

  const _AnimatedListItem({
    required this.child,
    required this.index,
    required this.duration,
    required this.curve,
  });

  @override
  State<_AnimatedListItem> createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<_AnimatedListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    // 延迟启动动画，创建错落效果
    Future.delayed(Duration(milliseconds: widget.index * 100), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: widget.child,
          ),
        );
      },
    );
  }
}
