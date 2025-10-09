part of 'app_animations.dart';

/// 金融动画组件私有实现
/// 企业级动画系统 - 金融领域专用动画

class _AnimatedAmountBounce extends StatefulWidget {
  const _AnimatedAmountBounce({
    required this.child,
    required this.isPositive,
    required this.duration,
  });

  final Widget child;
  final bool isPositive;
  final Duration duration;

  @override
  State<_AnimatedAmountBounce> createState() => _AnimatedAmountBounceState();
}

class _AnimatedAmountBounceState extends State<_AnimatedAmountBounce>
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

    // Use a safer animation approach that doesn't exceed bounds
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _controller.forward();
  }

  @override
  void didUpdateWidget(_AnimatedAmountBounce oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Trigger animation when isPositive changes from false to true
    if (widget.isPositive && !oldWidget.isPositive) {
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
        animation: _controller,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: widget.child,
        ),
      );
}

class _AnimatedKeypadButton extends StatefulWidget {
  const _AnimatedKeypadButton({
    required this.child,
    required this.onPressed,
    required this.duration,
  });

  final Widget child;
  final VoidCallback onPressed;
  final Duration duration;

  @override
  State<_AnimatedKeypadButton> createState() => _AnimatedKeypadButtonState();
}

class _AnimatedKeypadButtonState extends State<_AnimatedKeypadButton>
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
      end: 0.9,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onPressed();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) => Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(child: widget.child),
            ),
          ),
        ),
      );
}

class _AnimatedAmountPulse extends StatefulWidget {
  const _AnimatedAmountPulse({
    required this.child,
    required this.isPositive,
    required this.duration,
  });

  final Widget child;
  final bool isPositive;
  final Duration duration;

  @override
  State<_AnimatedAmountPulse> createState() => _AnimatedAmountPulseState();
}

class _AnimatedAmountPulseState extends State<_AnimatedAmountPulse>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _colorAnimation = ColorTween(
      begin: Colors.transparent,
      end: widget.isPositive
          ? Colors.green.withValues(alpha: 0.2)
          : Colors.red.withValues(alpha: 0.2),
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
        animation: _controller,
        builder: (context, child) => Container(
          decoration: BoxDecoration(
            color: _colorAnimation.value,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: widget.child,
          ),
        ),
      );
}

class _AnimatedAmountColor extends StatefulWidget {
  const _AnimatedAmountColor({
    required this.amount,
    required this.formatter,
    required this.duration,
  });

  final double amount;
  final String Function(double) formatter;
  final Duration duration;

  @override
  State<_AnimatedAmountColor> createState() => _AnimatedAmountColorState();
}

class _AnimatedAmountColorState extends State<_AnimatedAmountColor>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _colorAnimation = ColorTween(
      begin: Colors.black,
      end: widget.amount >= 0 ? Colors.green : Colors.red,
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
        animation: _controller,
        builder: (context, child) => Text(
          widget.formatter(widget.amount),
          style: TextStyle(color: _colorAnimation.value),
        ),
      );
}

class _AnimatedBalanceRipple extends StatefulWidget {
  const _AnimatedBalanceRipple({
    required this.child,
    required this.isChanged,
    required this.duration,
  });

  final Widget child;
  final bool isChanged;
  final Duration duration;

  @override
  State<_AnimatedBalanceRipple> createState() => _AnimatedBalanceRippleState();
}

class _AnimatedBalanceRippleState extends State<_AnimatedBalanceRipple>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rippleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _rippleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    if (widget.isChanged) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(_AnimatedBalanceRipple oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isChanged && !oldWidget.isChanged) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue.withValues(alpha: _rippleAnimation.value * 0.3),
          ),
          width: 60 + (_rippleAnimation.value * 40),
          height: 60 + (_rippleAnimation.value * 40),
          child: Center(child: widget.child),
        ),
      );
}

class _AnimatedTransactionConfirm extends StatefulWidget {
  const _AnimatedTransactionConfirm({
    required this.child,
    required this.showConfirm,
    required this.duration,
  });

  final Widget child;
  final bool showConfirm;
  final Duration duration;

  @override
  State<_AnimatedTransactionConfirm> createState() =>
      _AnimatedTransactionConfirmState();
}

class _AnimatedTransactionConfirmState
    extends State<_AnimatedTransactionConfirm>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _backgroundAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _backgroundAnimation = ColorTween(
      begin: Colors.transparent,
      end: Colors.green.withValues(alpha: 0.2),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.showConfirm) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(_AnimatedTransactionConfirm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showConfirm != oldWidget.showConfirm) {
      if (widget.showConfirm) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Container(
          decoration: BoxDecoration(
            color: _backgroundAnimation.value,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: widget.child,
          ),
        ),
      );
}

class _AnimatedBudgetCelebration extends StatefulWidget {
  const _AnimatedBudgetCelebration({
    required this.child,
    required this.isCelebrating,
    required this.duration,
  });

  final Widget child;
  final bool isCelebrating;
  final Duration duration;

  @override
  State<_AnimatedBudgetCelebration> createState() =>
      _AnimatedBudgetCelebrationState();
}

class _AnimatedBudgetCelebrationState extends State<_AnimatedBudgetCelebration>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

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
        curve: Curves.elasticOut,
      ),
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    if (widget.isCelebrating) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(_AnimatedBudgetCelebration oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCelebrating != oldWidget.isCelebrating) {
      if (widget.isCelebrating) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Transform.rotate(
          angle: _rotationAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: widget.child,
          ),
        ),
      );
}

class _AnimatedSaveConfirm extends StatefulWidget {
  const _AnimatedSaveConfirm({
    required this.child,
    required this.showConfirm,
    required this.duration,
  });

  final Widget child;
  final bool showConfirm;
  final Duration duration;

  @override
  State<_AnimatedSaveConfirm> createState() => _AnimatedSaveConfirmState();
}

class _AnimatedSaveConfirmState extends State<_AnimatedSaveConfirm>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _backgroundAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _backgroundAnimation = ColorTween(
      begin: Colors.transparent,
      end: Colors.green.withValues(alpha: 0.2),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.showConfirm) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(_AnimatedSaveConfirm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showConfirm != oldWidget.showConfirm) {
      if (widget.showConfirm) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Stack(
          alignment: Alignment.center,
          children: [
            widget.child,
            if (_controller.value > 0)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: _backgroundAnimation.value,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Opacity(
                    opacity: _opacityAnimation.value,
                    child: const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 48,
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
}
