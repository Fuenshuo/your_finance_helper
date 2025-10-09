import 'package:flutter/material.dart';
import 'package:your_finance_flutter/core/animations/animation_config.dart';

/// iOS风格导航动效组件
/// 基于Notion的页面切换和导航体验

/// 页面切换路由动画
class IOSPageRoute<T> extends PageRouteBuilder<T> {
  IOSPageRoute({
    required Widget page,
    super.settings,
    Duration duration = IOSAnimationConfig.normal,
    IOSPageTransition transition = IOSPageTransition.slide,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            switch (transition) {
              case IOSPageTransition.slide:
                return _buildSlideTransition(animation, child);
              case IOSPageTransition.fade:
                return _buildFadeTransition(animation, child);
              case IOSPageTransition.scale:
                return _buildScaleTransition(animation, child);
              case IOSPageTransition.slideUp:
                return _buildSlideUpTransition(animation, child);
              case IOSPageTransition.iosModal:
                return _buildIOSModalTransition(
                    animation, secondaryAnimation, child);
            }
          },
        );

  static Widget _buildSlideTransition(
      Animation<double> animation, Widget child) {
    const begin = Offset(1.0, 0.0);
    const end = Offset.zero;
    const curve = IOSAnimationConfig.standard;

    final tween = Tween(begin: begin, end: end).chain(
      CurveTween(curve: curve),
    );

    return SlideTransition(
      position: animation.drive(tween),
      child: child,
    );
  }

  static Widget _buildFadeTransition(
          Animation<double> animation, Widget child) =>
      FadeTransition(
        opacity: animation,
        child: child,
      );

  static Widget _buildScaleTransition(
      Animation<double> animation, Widget child) {
    final scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: animation,
        curve: IOSAnimationConfig.bounce,
      ),
    );

    return ScaleTransition(
      scale: scaleAnimation,
      child: child,
    );
  }

  static Widget _buildSlideUpTransition(
      Animation<double> animation, Widget child) {
    const begin = Offset(0.0, 1.0);
    const end = Offset.zero;
    const curve = IOSAnimationConfig.spring;

    final tween = Tween(begin: begin, end: end).chain(
      CurveTween(curve: curve),
    );

    return SlideTransition(
      position: animation.drive(tween),
      child: child,
    );
  }

  static Widget _buildIOSModalTransition(
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // iOS风格的模态框动画
    final slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: animation,
        curve: IOSAnimationConfig.spring,
      ),
    );

    final fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: animation,
        curve: IOSAnimationConfig.decelerate,
      ),
    );

    // 背景模糊效果
    final backdropAnimation = Tween<double>(
      begin: 0.0,
      end: 0.5,
    ).animate(
      CurvedAnimation(
        parent: animation,
        curve: IOSAnimationConfig.standard,
      ),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) => Stack(
        children: [
          // 背景遮罩
          FadeTransition(
            opacity: backdropAnimation,
            child: Container(
              color: Colors.black,
            ),
          ),

          // 页面内容
          SlideTransition(
            position: slideAnimation,
            child: FadeTransition(
              opacity: fadeAnimation,
              child: child,
            ),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// 底部弹窗导航动画
class IOSBottomSheetRoute<T> extends PageRoute<T> {
  IOSBottomSheetRoute({
    required this.builder,
    this.barrierColor = Colors.black54,
    this.barrierDismissible = true,
    Duration duration = IOSAnimationConfig.normal,
  }) : _transitionDuration = duration;

  final WidgetBuilder builder;
  final Duration _transitionDuration;

  @override
  final Color? barrierColor;

  @override
  final bool barrierDismissible;

  @override
  Duration get transitionDuration => _transitionDuration;

  @override
  String? get barrierLabel => 'Dismiss';

  @override
  bool get opaque => false;

  @override
  bool get maintainState => true;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) =>
      builder(context);

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: animation,
        curve: IOSAnimationConfig.spring,
      ),
    );

    final fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: animation,
        curve: IOSAnimationConfig.decelerate,
      ),
    );

    return SlideTransition(
      position: slideAnimation,
      child: FadeTransition(
        opacity: fadeAnimation,
        child: child,
      ),
    );
  }
}

/// 标签页切换动画容器
class IOSTabSwitchContainer extends StatefulWidget {
  const IOSTabSwitchContainer({
    required this.children,
    required this.selectedIndex,
    super.key,
    this.duration = IOSAnimationConfig.fast,
    this.onTabChanged,
  });

  final List<Widget> children;
  final int selectedIndex;
  final Duration duration;
  final ValueChanged<int>? onTabChanged;

  @override
  State<IOSTabSwitchContainer> createState() => _IOSTabSwitchContainerState();
}

class _IOSTabSwitchContainerState extends State<IOSTabSwitchContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _fadeOutAnimation;
  late Animation<Offset> _slideInAnimation;
  late Animation<Offset> _slideOutAnimation;

  int _previousIndex = 0;

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
  void didUpdateWidget(IOSTabSwitchContainer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.selectedIndex != oldWidget.selectedIndex) {
      _previousIndex = oldWidget.selectedIndex;
      _updateAnimations();
      _controller.forward(from: 0.0);
      widget.onTabChanged?.call(widget.selectedIndex);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _fadeInAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: IOSAnimationConfig.decelerate,
      ),
    );

    _fadeOutAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: IOSAnimationConfig.accelerate,
      ),
    );

    _slideInAnimation = Tween<Offset>(
      begin: const Offset(0.1, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: IOSAnimationConfig.standard,
      ),
    );

    _slideOutAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-0.1, 0.0),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: IOSAnimationConfig.standard,
      ),
    );
  }

  void _updateAnimations() {
    final isForward = widget.selectedIndex > _previousIndex;

    _slideInAnimation = Tween<Offset>(
      begin: Offset(isForward ? 0.1 : -0.1, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: IOSAnimationConfig.standard,
      ),
    );

    _slideOutAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(isForward ? -0.1 : 0.1, 0.0),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: IOSAnimationConfig.standard,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Stack(
          children: [
            // 淡出的旧内容
            if (_controller.value < 1.0)
              FadeTransition(
                opacity: _fadeOutAnimation,
                child: SlideTransition(
                  position: _slideOutAnimation,
                  child: widget.children[_previousIndex],
                ),
              ),

            // 淡入的新内容
            FadeTransition(
              opacity: _fadeInAnimation,
              child: SlideTransition(
                position: _slideInAnimation,
                child: widget.children[widget.selectedIndex],
              ),
            ),
          ],
        ),
      );
}

/// 卡片堆叠导航动画
class IOSCardStackContainer extends StatefulWidget {
  const IOSCardStackContainer({
    required this.children,
    required this.selectedIndex,
    super.key,
    this.stackOffset = 8.0,
    this.duration = IOSAnimationConfig.normal,
  });

  final List<Widget> children;
  final int selectedIndex;
  final double stackOffset;
  final Duration duration;

  @override
  State<IOSCardStackContainer> createState() => _IOSCardStackContainerState();
}

class _IOSCardStackContainerState extends State<IOSCardStackContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _positionAnimation;

  int _previousIndex = 0;

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
  void didUpdateWidget(IOSCardStackContainer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.selectedIndex != oldWidget.selectedIndex) {
      _previousIndex = oldWidget.selectedIndex;
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: IOSAnimationConfig.spring,
      ),
    );

    _opacityAnimation = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: IOSAnimationConfig.standard,
      ),
    );

    _positionAnimation = Tween<Offset>(
      begin: Offset(0.0, widget.stackOffset),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: IOSAnimationConfig.spring,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Stack(
        children: List.generate(widget.children.length, (index) {
          final isSelected = index == widget.selectedIndex;
          final isPrevious = index == _previousIndex;

          if (!isSelected && !isPrevious) {
            // 未激活的卡片
            return Positioned.fill(
              child: Transform.scale(
                scale: 0.85,
                child: Opacity(
                  opacity: 0.5,
                  child: Transform.translate(
                    offset: Offset(0.0,
                        widget.stackOffset * (widget.children.length - index)),
                    child: widget.children[index],
                  ),
                ),
              ),
            );
          }

          if (isSelected) {
            // 当前选中的卡片
            return AnimatedBuilder(
              animation: _controller,
              builder: (context, child) => Positioned.fill(
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Opacity(
                    opacity: _opacityAnimation.value,
                    child: Transform.translate(
                      offset: _positionAnimation.value,
                      child: widget.children[index],
                    ),
                  ),
                ),
              ),
            );
          }

          if (isPrevious) {
            // 正在淡出的卡片
            return AnimatedBuilder(
              animation: _controller,
              builder: (context, child) => Positioned.fill(
                child: Transform.scale(
                  scale: 1.0 - (_scaleAnimation.value - 1.0),
                  child: Opacity(
                    opacity: 1.0 - _opacityAnimation.value,
                    child: Transform.translate(
                      offset: Offset(0.0, _positionAnimation.value.dy),
                      child: widget.children[index],
                    ),
                  ),
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        }),
      );
}

/// 抽屉导航动画
class IOSDrawerContainer extends StatefulWidget {
  const IOSDrawerContainer({
    required this.child,
    required this.drawer,
    super.key,
    this.isOpen = false,
    this.drawerWidth = 280.0,
    this.duration = IOSAnimationConfig.normal,
    this.onDrawerChanged,
  });

  final Widget child;
  final Widget drawer;
  final bool isOpen;
  final double drawerWidth;
  final Duration duration;
  final ValueChanged<bool>? onDrawerChanged;

  @override
  State<IOSDrawerContainer> createState() => _IOSDrawerContainerState();
}

class _IOSDrawerContainerState extends State<IOSDrawerContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _drawerAnimation;
  late Animation<Offset> _contentAnimation;
  late Animation<double> _backdropAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _setupAnimations();
    _updateAnimationState();
  }

  @override
  void didUpdateWidget(IOSDrawerContainer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isOpen != oldWidget.isOpen) {
      _updateAnimationState();
      widget.onDrawerChanged?.call(widget.isOpen);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _drawerAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: IOSAnimationConfig.spring,
      ),
    );

    _contentAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(widget.drawerWidth / MediaQuery.of(context).size.width, 0.0),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: IOSAnimationConfig.standard,
      ),
    );

    _backdropAnimation = Tween<double>(
      begin: 0.0,
      end: 0.5,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: IOSAnimationConfig.standard,
      ),
    );
  }

  void _updateAnimationState() {
    if (widget.isOpen) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Stack(
          children: [
            // 背景遮罩
            GestureDetector(
              onTap: () => widget.onDrawerChanged?.call(false),
              child: FadeTransition(
                opacity: _backdropAnimation,
                child: Container(
                  color: Colors.black,
                ),
              ),
            ),

            // 主内容区
            SlideTransition(
              position: _contentAnimation,
              child: widget.child,
            ),

            // 抽屉
            SlideTransition(
              position: _drawerAnimation,
              child: SizedBox(
                width: widget.drawerWidth,
                child: widget.drawer,
              ),
            ),
          ],
        ),
      );
}

/// 页面过渡类型枚举
enum IOSPageTransition {
  slide,
  fade,
  scale,
  slideUp,
  iosModal,
}
