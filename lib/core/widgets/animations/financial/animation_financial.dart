part of '../../app_animations.dart';

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

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.2),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 0.95),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.95, end: 1.0),
        weight: 30,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
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

// ===== 金融特定动画 =====

/// 收入飘然动画
class _AnimatedIncomeFloat extends StatefulWidget {
  const _AnimatedIncomeFloat({
    required this.amount,
    required this.shouldFloat,
    required this.textColor,
    required this.duration,
  });

  final String amount;
  final bool shouldFloat;
  final Color? textColor;
  final Duration duration;

  @override
  State<_AnimatedIncomeFloat> createState() => _AnimatedIncomeFloatState();
}

class _AnimatedIncomeFloatState extends State<_AnimatedIncomeFloat>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _positionAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _positionAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -100),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    if (widget.shouldFloat) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(_AnimatedIncomeFloat oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shouldFloat && !oldWidget.shouldFloat) {
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
  Widget build(BuildContext context) => widget.shouldFloat
      ? AnimatedBuilder(
          animation: _controller,
          builder: (context, child) => Opacity(
            opacity: _opacityAnimation.value,
            child: Transform.translate(
              offset: _positionAnimation.value,
              child: Text(
                '+${widget.amount}',
                style: TextStyle(
                  color: widget.textColor ?? Colors.green,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        )
      : const SizedBox.shrink();
}

/// 支出波纹动画
class _AnimatedExpenseRipple extends StatefulWidget {
  const _AnimatedExpenseRipple({
    required this.amount,
    required this.shouldRipple,
    required this.rippleColor,
    required this.duration,
  });

  final String amount;
  final bool shouldRipple;
  final Color? rippleColor;
  final Duration duration;

  @override
  State<_AnimatedExpenseRipple> createState() => _AnimatedExpenseRippleState();
}

class _AnimatedExpenseRippleState extends State<_AnimatedExpenseRipple>
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

    if (widget.shouldRipple) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(_AnimatedExpenseRipple oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shouldRipple && !oldWidget.shouldRipple) {
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
  Widget build(BuildContext context) => widget.shouldRipple
      ? AnimatedBuilder(
          animation: _controller,
          builder: (context, child) => Container(
            width: 80 + (_rippleAnimation.value * 40),
            height: 80 + (_rippleAnimation.value * 40),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (widget.rippleColor ?? Colors.red)
                  .withValues(alpha: (1 - _rippleAnimation.value) * 0.3),
            ),
            child: Center(
              child: Text(
                '-${widget.amount}',
                style: TextStyle(
                  color: widget.rippleColor ?? Colors.red,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        )
      : const SizedBox.shrink();
}

/// 预算警戒动画
class _AnimatedBudgetAlert extends StatefulWidget {
  const _AnimatedBudgetAlert({
    required this.child,
    required this.isAlerting,
    required this.alertThreshold,
    required this.alertColor,
    required this.duration,
  });

  final Widget child;
  final bool isAlerting;
  final double alertThreshold;
  final Color? alertColor;
  final Duration duration;

  @override
  State<_AnimatedBudgetAlert> createState() => _AnimatedBudgetAlertState();
}

class _AnimatedBudgetAlertState extends State<_AnimatedBudgetAlert>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.isAlerting) {
      _startPulsing();
    }
  }

  void _startPulsing() {
    _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(_AnimatedBudgetAlert oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAlerting != oldWidget.isAlerting) {
      if (widget.isAlerting) {
        _startPulsing();
      } else {
        _controller.stop();
        _controller.value = 0;
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
            border: widget.isAlerting
                ? Border.all(
                    color: widget.alertColor ?? Colors.orange,
                    width: 2 * _pulseAnimation.value,
                  )
                : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: widget.child,
        ),
      );
}

/// 投资收益波动动画
class _AnimatedInvestmentWave extends StatefulWidget {
  const _AnimatedInvestmentWave({
    required this.values,
    required this.profitColor,
    required this.lossColor,
    required this.duration,
  });

  final List<double> values;
  final Color? profitColor;
  final Color? lossColor;
  final Duration duration;

  @override
  State<_AnimatedInvestmentWave> createState() =>
      _AnimatedInvestmentWaveState();
}

class _AnimatedInvestmentWaveState extends State<_AnimatedInvestmentWave>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _heightAnimations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _heightAnimations = List.generate(widget.values.length, (index) {
      final value = widget.values[index];
      final isPositive = value >= 0;
      final maxValue = widget.values.map((v) => v.abs()).reduce(math.max);

      return Tween<double>(
        begin: 0.0,
        end: (value.abs() / maxValue) * 100,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            index * 0.1,
            (index + 1) * 0.1,
            curve: Curves.elasticOut,
          ),
        ),
      );
    });

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
        builder: (context, child) => Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(
            widget.values.length,
            (index) => Container(
              width: 20,
              height: _heightAnimations[index].value,
              decoration: BoxDecoration(
                color: widget.values[index] >= 0
                    ? (widget.profitColor ?? Colors.green)
                    : (widget.lossColor ?? Colors.red),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      );
}

/// 信用卡消费动画
class _AnimatedCreditCardSpend extends StatefulWidget {
  const _AnimatedCreditCardSpend({
    required this.child,
    required this.isSpending,
    required this.spendAmount,
    required this.duration,
  });

  final Widget child;
  final bool isSpending;
  final double spendAmount;
  final Duration duration;

  @override
  State<_AnimatedCreditCardSpend> createState() =>
      _AnimatedCreditCardSpendState();
}

class _AnimatedCreditCardSpendState extends State<_AnimatedCreditCardSpend>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

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

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -20),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    if (widget.isSpending) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(_AnimatedCreditCardSpend oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSpending && !oldWidget.isSpending) {
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
        builder: (context, child) => Stack(
          alignment: Alignment.center,
          children: [
            Transform.scale(
              scale: widget.isSpending ? _scaleAnimation.value : 1.0,
              child: widget.child,
            ),
            if (widget.isSpending)
              Positioned(
                top: 20,
                child: Transform.translate(
                  offset: _slideAnimation.value,
                  child: Text(
                    '¥${widget.spendAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
}
