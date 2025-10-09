import 'package:flutter/material.dart';
import 'animations/input_animations.dart';
import 'animations/state_animations.dart';
import 'animations/list_animations.dart';
import 'animations/selection_animations.dart';
import 'animations/success_animations.dart';
import 'animations/component_animations.dart';

// 动画相关枚举定义
enum StatusType { loading, success, error, warning, info }

enum PriorityLevel { low, medium, high, urgent }

enum DrawerPosition { left, right, top, bottom }

/// 金融记账应用动画库
/// 提供专门为金融、记账、金额变动、列表操作等场景设计的特效动画
///
/// 使用示例：
/// ```dart
/// // 金额变动脉冲效果
/// AppAnimations.animatedAmountPulse(
///   child: Text('¥1,234.56'),
///   isPositive: true,
/// );
///
/// // 列表项插入动画
/// AppAnimations.animatedListInsert(
///   child: transactionItem,
///   index: 0,
/// );
///
/// // 预算达成庆祝
/// AppAnimations.animatedBudgetCelebration(
///   child: budgetCard,
///   isCelebrating: budgetAchieved,
/// );
/// ```
class AppAnimations {
  // 按钮点击动画
  static Widget animatedButton({
    required Widget child,
    required VoidCallback onPressed,
    Duration duration = const Duration(milliseconds: 150),
  }) =>
      _AnimatedButton(
        onPressed: onPressed,
        duration: duration,
        child: child,
      );

  // 数字滚动动画
  static Widget animatedNumber({
    required double value,
    required String Function(double) formatter,
    Duration duration = const Duration(milliseconds: 800),
    Curve curve = Curves.easeOutCubic,
  }) =>
      _AnimatedNumber(
        value: value,
        formatter: formatter,
        duration: duration,
        curve: curve,
      );

  // 列表项动画
  static Widget animatedListItem({
    required Widget child,
    required int index,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeOutCubic,
  }) =>
      _AnimatedListItem(
        index: index,
        duration: duration,
        curve: curve,
        child: child,
      );

  // 页面转场动画
  static Route<T> createRoute<T extends Object?>(
    Widget page, {
    RouteSettings? settings,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOutCubic,
  }) =>
      PageRouteBuilder<T>(
        settings: settings,
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;

          final tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: duration,
      );

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
  }) =>
      showModalBottomSheet<T>(
        context: context,
        isScrollControlled: isScrollControlled,
        showDragHandle: showDragHandle,
        backgroundColor: backgroundColor ?? Colors.white,
        elevation: elevation ?? 8,
        shape: shape ??
            const RoundedRectangleBorder(
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

  // ===== 金融记账特效 =====

  // 金额变动脉冲动画
  static Widget animatedAmountPulse({
    required Widget child,
    required bool isPositive,
    Duration duration = const Duration(milliseconds: 600),
    double scaleFactor = 1.1,
  }) =>
      _AnimatedAmountPulse(
        isPositive: isPositive,
        duration: duration,
        scaleFactor: scaleFactor,
        child: child,
      );

  // 金额变化颜色过渡动画
  static Widget animatedAmountColor({
    required double amount,
    required String Function(double) formatter,
    Duration duration = const Duration(milliseconds: 800),
  }) =>
      _AnimatedAmountColor(
        amount: amount,
        formatter: formatter,
        duration: duration,
      );

  // 资产余额变动波纹效果
  static Widget animatedBalanceRipple({
    required Widget child,
    required bool isChanged,
    Color rippleColor = Colors.blue,
    Duration duration = const Duration(milliseconds: 1000),
  }) =>
      _AnimatedBalanceRipple(
        isChanged: isChanged,
        rippleColor: rippleColor,
        duration: duration,
        child: child,
      );

  // 列表项插入动画（从右滑入）
  static Widget animatedListInsert({
    required Widget child,
    required int index,
    Duration duration = const Duration(milliseconds: 400),
    Curve curve = Curves.easeOutCubic,
  }) =>
      _AnimatedListInsert(
        index: index,
        duration: duration,
        curve: curve,
        child: child,
      );

  // 列表项删除动画（向左滑出）
  static Widget animatedListDelete({
    required Widget child,
    required VoidCallback onAnimationComplete,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInCubic,
  }) =>
      _AnimatedListDelete(
        onAnimationComplete: onAnimationComplete,
        duration: duration,
        curve: curve,
        child: child,
      );

  // 交易记录确认动画（打勾效果）
  static Widget animatedTransactionConfirm({
    required Widget child,
    required bool showConfirm,
    Duration duration = const Duration(milliseconds: 800),
  }) =>
      _AnimatedTransactionConfirm(
        showConfirm: showConfirm,
        duration: duration,
        child: child,
      );

  // 预算达成庆祝动画
  static Widget animatedBudgetCelebration({
    required Widget child,
    required bool isCelebrating,
    Duration duration = const Duration(milliseconds: 1200),
  }) =>
      _AnimatedBudgetCelebration(
        isCelebrating: isCelebrating,
        duration: duration,
        child: child,
      );

  // 数字键盘按键动画
  static Widget animatedKeypadButton({
    required Widget child,
    required VoidCallback onPressed,
    Duration duration = const Duration(milliseconds: 100),
  }) =>
      _AnimatedKeypadButton(
        onPressed: onPressed,
        duration: duration,
        child: child,
      );

  // 金额输入时的跳动反馈
  static Widget animatedAmountBounce({
    required Widget child,
    required bool isBouncing,
    Duration duration = const Duration(milliseconds: 400),
  }) =>
      _AnimatedAmountBounce(
        isBouncing: isBouncing,
        duration: duration,
        child: child,
      );

  // 分类选择缩放动画
  static Widget animatedCategorySelect({
    required Widget child,
    required bool isSelected,
    Duration duration = const Duration(milliseconds: 200),
    double scaleFactor = 1.05,
  }) =>
      _AnimatedCategorySelect(
        isSelected: isSelected,
        duration: duration,
        scaleFactor: scaleFactor,
        child: child,
      );

  // 保存成功时的确认动画
  static Widget animatedSaveConfirm({
    required Widget child,
    required bool showConfirm,
    Duration duration = const Duration(milliseconds: 1000),
  }) =>
      _AnimatedSaveConfirm(
        showConfirm: showConfirm,
        duration: duration,
        child: child,
      );
}

// ===== 动画实现类 =====
// 这些类在对应的子模块文件中定义，这里只保留接口定义
  const _AnimatedButton({
    required this.child,
    required this.onPressed,
    required this.duration,
  });
  final Widget child;
  final VoidCallback onPressed;
  final Duration duration;

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
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
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

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          widget.onPressed();
        },
        onTapCancel: () => _controller.reverse(),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) => Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: widget.child,
            ),
          ),
        ),
      );
}

// 数字滚动动画实现
class _AnimatedNumber extends StatefulWidget {
  const _AnimatedNumber({
    required this.value,
    required this.formatter,
    required this.duration,
    required this.curve,
  });
  final double value;
  final String Function(double) formatter;
  final Duration duration;
  final Curve curve;

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
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
      ),
    );
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

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _animation,
        builder: (context, child) => Text(
          widget.formatter(_animation.value),
          style: Theme.of(context).textTheme.displayLarge,
        ),
      );
}

// 列表项动画实现
class _AnimatedListItem extends StatefulWidget {
  const _AnimatedListItem({
    required this.child,
    required this.index,
    required this.duration,
    required this.curve,
  });
  final Widget child;
  final int index;
  final Duration duration;
  final Curve curve;

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
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
      ),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
      ),
    );

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
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: widget.child,
          ),
        ),
      );
}

// ===== 金融记账特效实现 =====

// 金额变动脉冲动画实现
class _AnimatedAmountPulse extends StatefulWidget {
  const _AnimatedAmountPulse({
    required this.child,
    required this.isPositive,
    required this.duration,
    required this.scaleFactor,
  });

  final Widget child;
  final bool isPositive;
  final Duration duration;
  final double scaleFactor;

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

    // 使用简单的Tween动画，避免TweenSequence的问题
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleFactor,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _colorAnimation = ColorTween(
      begin: Colors.transparent,
      end: widget.isPositive
          ? Colors.green.withOpacity(0.2)
          : Colors.red.withOpacity(0.2),
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

// 金额变化颜色过渡动画实现
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
  double _previousAmount = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _updateAnimation();
    _controller.forward();
  }

  @override
  void didUpdateWidget(_AnimatedAmountColor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.amount != widget.amount) {
      _previousAmount = oldWidget.amount;
      _controller.reset();
      _updateAnimation();
      _controller.forward();
    }
  }

  void _updateAnimation() {
    final isPositive = widget.amount > _previousAmount;
    _colorAnimation = ColorTween(
      begin: isPositive
          ? Colors.green.withOpacity(0.8)
          : Colors.red.withOpacity(0.8),
      end: Colors.transparent,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );
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
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _colorAnimation.value,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            widget.formatter(widget.amount),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: widget.amount > _previousAmount
                      ? Colors.green
                      : Colors.red,
                ),
          ),
        ),
      );
}

// 资产余额变动波纹效果实现
class _AnimatedBalanceRipple extends StatefulWidget {
  const _AnimatedBalanceRipple({
    required this.child,
    required this.isChanged,
    required this.rippleColor,
    required this.duration,
  });

  final Widget child;
  final bool isChanged;
  final Color rippleColor;
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
      end: 2.0,
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
  Widget build(BuildContext context) => Stack(
        alignment: Alignment.center,
        children: [
          widget.child,
          if (widget.isChanged)
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) => Container(
                width: 200 * _rippleAnimation.value,
                height: 200 * _rippleAnimation.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.rippleColor.withOpacity(
                      (1.0 - _rippleAnimation.value / 2.0).clamp(0.0, 1.0),
                    ),
                    width: 2,
                  ),
                ),
              ),
            ),
        ],
      );
}

// 列表项插入动画实现
class _AnimatedListInsert extends StatefulWidget {
  const _AnimatedListInsert({
    required this.child,
    required this.index,
    required this.duration,
    required this.curve,
  });

  final Widget child;
  final int index;
  final Duration duration;
  final Curve curve;

  @override
  State<_AnimatedListInsert> createState() => _AnimatedListInsertState();
}

class _AnimatedListInsertState extends State<_AnimatedListInsert>
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
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
      ),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
      ),
    );

    // 延迟启动，创建错落效果
    Future.delayed(Duration(milliseconds: widget.index * 50), () {
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
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: widget.child,
          ),
        ),
      );
}

// 列表项删除动画实现
class _AnimatedListDelete extends StatefulWidget {
  const _AnimatedListDelete({
    required this.child,
    required this.onAnimationComplete,
    required this.duration,
    required this.curve,
  });

  final Widget child;
  final VoidCallback onAnimationComplete;
  final Duration duration;
  final Curve curve;

  @override
  State<_AnimatedListDelete> createState() => _AnimatedListDeleteState();
}

class _AnimatedListDeleteState extends State<_AnimatedListDelete>
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
      begin: Offset.zero,
      end: const Offset(-1.0, 0.0),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
      ),
    );

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
      ),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onAnimationComplete();
      }
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
        builder: (context, child) => FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: widget.child,
          ),
        ),
      );
}

// 交易记录确认动画实现
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
  late Animation<double> _checkAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _checkAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.elasticOut),
      ),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.2,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    if (widget.showConfirm) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(_AnimatedTransactionConfirm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showConfirm && !oldWidget.showConfirm) {
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
  Widget build(BuildContext context) => Stack(
        alignment: Alignment.center,
        children: [
          widget.child,
          if (widget.showConfirm)
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) => Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 30 * _checkAnimation.value,
                  ),
                ),
              ),
            ),
        ],
      );
}

// 预算达成庆祝动画实现
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

    _colorAnimation = ColorTween(
      begin: Colors.transparent,
      end: Colors.yellow.withOpacity(0.3),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.isCelebrating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(_AnimatedBudgetCelebration oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCelebrating != oldWidget.isCelebrating) {
      if (widget.isCelebrating) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.reset();
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
            color: _colorAnimation.value,
            borderRadius: BorderRadius.circular(12),
            boxShadow: widget.isCelebrating
                ? [
                    BoxShadow(
                      color: Colors.yellow.withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ]
                : null,
          ),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value,
              child: widget.child,
            ),
          ),
        ),
      );
}

// 数字键盘按键动画实现
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
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: widget.child,
            ),
          ),
        ),
      );
}

// 金额输入时的跳动反馈实现
class _AnimatedAmountBounce extends StatefulWidget {
  const _AnimatedAmountBounce({
    required this.child,
    required this.isBouncing,
    required this.duration,
  });

  final Widget child;
  final bool isBouncing;
  final Duration duration;

  @override
  State<_AnimatedAmountBounce> createState() => _AnimatedAmountBounceState();
}

class _AnimatedAmountBounceState extends State<_AnimatedAmountBounce>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: -3.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    if (widget.isBouncing) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(_AnimatedAmountBounce oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isBouncing && !oldWidget.isBouncing) {
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
        builder: (context, child) => Transform.translate(
          offset: Offset(0, _bounceAnimation.value),
          child: widget.child,
        ),
      );
}

// 分类选择缩放动画实现
class _AnimatedCategorySelect extends StatefulWidget {
  const _AnimatedCategorySelect({
    required this.child,
    required this.isSelected,
    required this.duration,
    required this.scaleFactor,
  });

  final Widget child;
  final bool isSelected;
  final Duration duration;
  final double scaleFactor;

  @override
  State<_AnimatedCategorySelect> createState() =>
      _AnimatedCategorySelectState();
}

class _AnimatedCategorySelectState extends State<_AnimatedCategorySelect>
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
      end: widget.scaleFactor,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _colorAnimation = ColorTween(
      begin: Colors.transparent,
      end: Colors.blue.withOpacity(0.2),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.isSelected) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void didUpdateWidget(_AnimatedCategorySelect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
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
            color: _colorAnimation.value,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: widget.child,
          ),
        ),
      );
}

// 保存成功时的确认动画实现
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
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
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

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
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
    if (widget.showConfirm && !oldWidget.showConfirm) {
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
  Widget build(BuildContext context) => Stack(
        alignment: Alignment.topCenter,
        children: [
          widget.child,
          if (widget.showConfirm)
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) => FadeTransition(
                opacity: _opacityAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '保存成功',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
}
