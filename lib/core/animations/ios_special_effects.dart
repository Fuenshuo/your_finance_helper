import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:your_finance_flutter/core/animations/animation_config.dart';

/// iOS风格特殊动效组件
/// 基于Notion的文件夹、抖动、缩放等特效实现

/// 文件夹展开动画组件
class IOSFolderContainer extends StatefulWidget {
  const IOSFolderContainer({
    required this.folderIcon,
    required this.children,
    super.key,
    this.isExpanded = false,
    this.folderColor = Colors.blue,
    this.duration = IOSAnimationConfig.normal,
    this.onExpansionChanged,
  });

  final Widget folderIcon;
  final List<Widget> children;
  final bool isExpanded;
  final Color folderColor;
  final Duration duration;
  final ValueChanged<bool>? onExpansionChanged;

  @override
  State<IOSFolderContainer> createState() => _IOSFolderContainerState();
}

class _IOSFolderContainerState extends State<IOSFolderContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _folderScaleAnimation;
  late Animation<double> _contentOpacityAnimation;
  late Animation<double> _contentHeightAnimation;
  late Animation<Offset> _folderIconAnimation;

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
  void didUpdateWidget(IOSFolderContainer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isExpanded != oldWidget.isExpanded) {
      _updateAnimationState();
      widget.onExpansionChanged?.call(widget.isExpanded);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _folderScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: IOSAnimationConfig.spring,
      ),
    );

    _contentOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: IOSAnimationConfig.decelerate,
      ),
    );

    _contentHeightAnimation = Tween<double>(
      begin: 0.0,
      end: widget.children.length * 60.0, // 假设每个子项高度60
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: IOSAnimationConfig.spring,
      ),
    );

    _folderIconAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.0, -10.0),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: IOSAnimationConfig.bounce,
      ),
    );
  }

  void _updateAnimationState() {
    if (widget.isExpanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 文件夹图标
          GestureDetector(
            onTap: () => widget.onExpansionChanged?.call(!widget.isExpanded),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) => Transform.translate(
                offset: _folderIconAnimation.value,
                child: Transform.scale(
                  scale: _folderScaleAnimation.value,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: widget.folderColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: widget.folderColor.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      widget.isExpanded ? Icons.folder_open : Icons.folder,
                      color: widget.folderColor,
                      size: 32,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 文件夹内容
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) => ClipRect(
              child: SizedBox(
                height: _contentHeightAnimation.value,
                child: Opacity(
                  opacity: _contentOpacityAnimation.value,
                  child: Column(
                    children: widget.children
                        .map(
                          (child) => Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Transform.scale(
                              scale: _contentOpacityAnimation.value,
                              child: child,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
}

/// iOS风格的网格抖动组件（编辑模式）
class IOSWobbleGrid extends StatefulWidget {
  const IOSWobbleGrid({
    required this.children,
    super.key,
    this.isEditing = false,
    this.crossAxisCount = 4,
    this.wobbleIntensity = 0.02,
    this.duration = const Duration(milliseconds: 600),
    this.onItemTap,
    this.onItemLongPress,
  });

  final List<Widget> children;
  final bool isEditing;
  final int crossAxisCount;
  final double wobbleIntensity;
  final Duration duration;
  final void Function(int index)? onItemTap;
  final void Function(int index)? onItemLongPress;

  @override
  State<IOSWobbleGrid> createState() => _IOSWobbleGridState();
}

class _IOSWobbleGridState extends State<IOSWobbleGrid>
    with TickerProviderStateMixin {
  final List<AnimationController> _controllers = [];
  final List<Animation<double>> _rotationAnimations = [];
  final List<Animation<double>> _scaleAnimations = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  @override
  void didUpdateWidget(IOSWobbleGrid oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isEditing != oldWidget.isEditing) {
      if (widget.isEditing) {
        _startWobble();
      } else {
        _stopWobble();
      }
    }

    if (widget.children.length != oldWidget.children.length) {
      _disposeAnimations();
      _initializeAnimations();
    }
  }

  @override
  void dispose() {
    _disposeAnimations();
    super.dispose();
  }

  void _initializeAnimations() {
    for (var i = 0; i < widget.children.length; i++) {
      final controller = AnimationController(
        duration: widget.duration,
        vsync: this,
      );

      final rotationAnimation = TweenSequence<double>([
        TweenSequenceItem(
          tween: Tween(begin: 0.0, end: widget.wobbleIntensity),
          weight: 1,
        ),
        TweenSequenceItem(
          tween: Tween(
              begin: widget.wobbleIntensity, end: -widget.wobbleIntensity),
          weight: 1,
        ),
        TweenSequenceItem(
          tween: Tween(begin: -widget.wobbleIntensity, end: 0.0),
          weight: 1,
        ),
      ]).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeInOut,
        ),
      );

      final scaleAnimation = Tween<double>(
        begin: 1.0,
        end: 1.05,
      ).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeInOut,
        ),
      );

      _controllers.add(controller);
      _rotationAnimations.add(rotationAnimation);
      _scaleAnimations.add(scaleAnimation);
    }
  }

  void _disposeAnimations() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    _controllers.clear();
    _rotationAnimations.clear();
    _scaleAnimations.clear();
  }

  void _startWobble() {
    for (var i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 100), () {
        if (mounted && widget.isEditing) {
          _controllers[i].repeat();
        }
      });
    }
  }

  void _stopWobble() {
    for (final controller in _controllers) {
      controller.stop();
      controller.reset();
    }
  }

  @override
  Widget build(BuildContext context) => GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: widget.crossAxisCount,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: widget.children.length,
        itemBuilder: (context, index) => GestureDetector(
          onTap: () => widget.onItemTap?.call(index),
          onLongPress: () => widget.onItemLongPress?.call(index),
          child: AnimatedBuilder(
            animation: _controllers[index],
            builder: (context, child) => Transform.rotate(
              angle: _rotationAnimations[index].value,
              child: Transform.scale(
                scale: widget.isEditing ? _scaleAnimations[index].value : 1.0,
                child: Stack(
                  children: [
                    widget.children[index],
                    if (widget.isEditing)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}

/// iOS风格的缩放新建动画
class IOSScaleNewItem extends StatefulWidget {
  const IOSScaleNewItem({
    required this.child,
    super.key,
    this.newItemTrigger,
    this.scaleFactor = 0.1,
    this.duration = IOSAnimationConfig.slow,
    this.enableHaptic = true,
  });

  final Widget child;
  final bool? newItemTrigger;
  final double scaleFactor;
  final Duration duration;
  final bool enableHaptic;

  @override
  State<IOSScaleNewItem> createState() => _IOSScaleNewItemState();
}

class _IOSScaleNewItemState extends State<IOSScaleNewItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: widget.scaleFactor,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: IOSAnimationConfig.spring,
      ),
    );

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: IOSAnimationConfig.decelerate,
      ),
    );
  }

  @override
  void didUpdateWidget(IOSScaleNewItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.newItemTrigger ?? false && oldWidget.newItemTrigger != true) {
      _startNewItemAnimation();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startNewItemAnimation() {
    if (_isAnimating) return;

    setState(() => _isAnimating = true);

    // iOS风格的触觉反馈
    if (widget.enableHaptic) {
      // HapticFeedback.mediumImpact(); // 需要导入 haptic_feedback
    }

    _controller.forward().then((_) {
      if (mounted) {
        setState(() => _isAnimating = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isAnimating) {
      return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: widget.child,
          ),
        ),
      );
    }

    return widget.child;
  }
}

/// iOS风格的拖拽排序指示器
class IOSDragIndicator extends StatefulWidget {
  const IOSDragIndicator({
    super.key,
    this.isDragging = false,
    this.indicatorColor = Colors.blue,
    this.duration = IOSAnimationConfig.fast,
  });

  final bool isDragging;
  final Color indicatorColor;
  final Duration duration;

  @override
  State<IOSDragIndicator> createState() => _IOSDragIndicatorState();
}

class _IOSDragIndicatorState extends State<IOSDragIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

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
        curve: IOSAnimationConfig.standard,
      ),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: IOSAnimationConfig.spring,
      ),
    );

    _updateAnimationState();
  }

  @override
  void didUpdateWidget(IOSDragIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isDragging != oldWidget.isDragging) {
      _updateAnimationState();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateAnimationState() {
    if (widget.isDragging) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                color: widget.indicatorColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      );
}

/// iOS风格的浮动操作按钮
class IOSFloatingActionButton extends StatefulWidget {
  const IOSFloatingActionButton({
    required this.icon,
    required this.onPressed,
    super.key,
    this.backgroundColor = Colors.blue,
    this.size = 56.0,
    this.enableSpring = true,
    this.enableShadow = true,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final double size;
  final bool enableSpring;
  final bool enableShadow;

  @override
  State<IOSFloatingActionButton> createState() =>
      _IOSFloatingActionButtonState();
}

class _IOSFloatingActionButtonState extends State<IOSFloatingActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shadowAnimation;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: IOSAnimationConfig.fast,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: IOSAnimationConfig.standard,
      ),
    );

    _shadowAnimation = Tween<double>(
      begin: 8.0,
      end: 4.0,
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
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
    widget.onPressed();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) => Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              shape: BoxShape.circle,
              boxShadow: widget.enableShadow
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: _isPressed ? _shadowAnimation.value : 8.0,
                        offset: Offset(0, _isPressed ? 2.0 : 4.0),
                      ),
                    ]
                  : null,
            ),
            child: Transform.scale(
              scale: widget.enableSpring && _isPressed
                  ? _scaleAnimation.value
                  : 1.0,
              child: Icon(
                widget.icon,
                color: Colors.white,
                size: widget.size * 0.5,
              ),
            ),
          ),
        ),
      );
}

/// iOS风格的删除确认动画
class IOSDeleteConfirmation extends StatefulWidget {
  const IOSDeleteConfirmation({
    required this.child,
    super.key,
    this.onDelete,
    this.deleteColor = Colors.red,
    this.duration = IOSAnimationConfig.normal,
    this.enableHaptic = true,
  });

  final Widget child;
  final VoidCallback? onDelete;
  final Color deleteColor;
  final Duration duration;
  final bool enableHaptic;

  @override
  State<IOSDeleteConfirmation> createState() => _IOSDeleteConfirmationState();
}

class _IOSDeleteConfirmationState extends State<IOSDeleteConfirmation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _opacityAnimation;

  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: -100.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: IOSAnimationConfig.accelerate,
      ),
    );

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: IOSAnimationConfig.accelerate,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startDeleteAnimation() {
    if (_isDeleting) return;

    setState(() => _isDeleting = true);

    // iOS风格的触觉反馈
    if (widget.enableHaptic) {
      // HapticFeedback.heavyImpact(); // 需要导入 haptic_feedback
    }

    _controller.forward().then((_) {
      widget.onDelete?.call();
    });
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onLongPress: _startDeleteAnimation,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) => Stack(
            children: [
              // 主内容
              Transform.translate(
                offset: Offset(_slideAnimation.value, 0),
                child: Opacity(
                  opacity: _opacityAnimation.value,
                  child: widget.child,
                ),
              ),

              // 删除背景
              Positioned.fill(
                child: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: widget.deleteColor,
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

/// iOS风格的波纹反馈
class IOSRippleEffect extends StatefulWidget {
  const IOSRippleEffect({
    required this.child,
    super.key,
    this.rippleColor = Colors.blue,
    this.duration = IOSAnimationConfig.slow,
    this.maxRadius = 100.0,
  });

  final Widget child;
  final Color rippleColor;
  final Duration duration;
  final double maxRadius;

  @override
  State<IOSRippleEffect> createState() => _IOSRippleEffectState();
}

class _IOSRippleEffectState extends State<IOSRippleEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _radiusAnimation;
  late Animation<double> _opacityAnimation;

  Offset? _tapPosition;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _radiusAnimation = Tween<double>(
      begin: 0.0,
      end: widget.maxRadius,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: IOSAnimationConfig.decelerate,
      ),
    );

    _opacityAnimation = Tween<double>(
      begin: 0.6,
      end: 0.0,
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
    setState(() => _tapPosition = details.localPosition);
    _controller.forward(from: 0.0);
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
    setState(() => _tapPosition = null);
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: Stack(
          children: [
            widget.child,

            // 波纹效果
            if (_tapPosition != null)
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) => Positioned(
                  left: _tapPosition!.dx - _radiusAnimation.value,
                  top: _tapPosition!.dy - _radiusAnimation.value,
                  child: Container(
                    width: _radiusAnimation.value * 2,
                    height: _radiusAnimation.value * 2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.rippleColor
                          .withOpacity(_opacityAnimation.value),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
}
