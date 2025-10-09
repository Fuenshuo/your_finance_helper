import 'package:flutter/material.dart';
import 'package:your_finance_flutter/core/animations/animation_config.dart';
import 'package:your_finance_flutter/core/animations/animation_engine.dart';
import 'package:your_finance_flutter/core/animations/ios_gesture_animations.dart';
import 'package:your_finance_flutter/core/animations/ios_navigation_animations.dart';
import 'package:your_finance_flutter/core/animations/ios_special_effects.dart';
import 'package:your_finance_flutter/core/animations/ios_state_animations.dart';

/// iOS动效管理器
/// 统一的动效API入口，提供所有iOS风格动效的便捷访问
class IOSAnimationManager {
  factory IOSAnimationManager() => _instance;
  IOSAnimationManager._internal();
  static final IOSAnimationManager _instance = IOSAnimationManager._internal();

  final AnimationCoordinator _coordinator = AnimationCoordinator();

  // ===== 手势动效 =====

  /// 创建手势反馈容器
  Widget gestureContainer({
    required Widget child,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    VoidCallback? onDragStart,
    void Function(DragUpdateDetails)? onDragUpdate,
    void Function(DragEndDetails)? onDragEnd,
    bool enableHaptic = true,
    bool enableSpring = true,
    double scaleFactor = IOSAnimationConfig.tapScale,
    double dragScaleFactor = IOSAnimationConfig.dragScale,
  }) =>
      IOSGestureContainer(
        onTap: onTap,
        onLongPress: onLongPress,
        onDragStart: onDragStart,
        onDragUpdate: onDragUpdate,
        onDragEnd: onDragEnd,
        enableHaptic: enableHaptic,
        enableSpring: enableSpring,
        scaleFactor: scaleFactor,
        dragScaleFactor: dragScaleFactor,
        child: child,
      );

  /// 创建抖动反馈容器
  Widget shakeContainer({
    required Widget child,
    bool? shakeTrigger,
    Duration duration = IOSAnimationConfig.shakeDuration,
    double amplitude = IOSAnimationConfig.shakeAmplitude,
    int frequency = IOSAnimationConfig.shakeFrequency,
    bool enableHaptic = true,
  }) =>
      IOSShakeContainer(
        shakeTrigger: shakeTrigger,
        duration: duration,
        amplitude: amplitude,
        frequency: frequency,
        enableHaptic: enableHaptic,
        child: child,
      );

  /// 创建弹性反馈容器
  Widget springContainer({
    required Widget child,
    bool? springTrigger,
    double targetScale = 1.1,
    Duration duration = IOSAnimationConfig.slow,
    bool enableHaptic = true,
  }) =>
      IOSSpringContainer(
        springTrigger: springTrigger,
        targetScale: targetScale,
        duration: duration,
        enableHaptic: enableHaptic,
        child: child,
      );

  /// 创建拖拽反馈容器
  Widget dragContainer({
    required Widget child,
    VoidCallback? onDragStart,
    GestureDragUpdateCallback? onDragUpdate,
    GestureDragEndCallback? onDragEnd,
    bool enableShadow = true,
    bool enableRotation = true,
    double maxRotation = 0.05,
  }) =>
      IOSDragContainer(
        onDragStart: onDragStart,
        onDragUpdate: onDragUpdate,
        onDragEnd: onDragEnd,
        enableShadow: enableShadow,
        enableRotation: enableRotation,
        maxRotation: maxRotation,
        child: child,
      );

  // ===== 状态动效 =====

  /// 创建状态变化容器
  Widget stateContainer({
    required Widget child,
    AnimationState state = AnimationState.normal,
    Duration duration = IOSAnimationConfig.normal,
    bool enableHaptic = true,
    VoidCallback? onStateChanged,
  }) =>
      IOSStateContainer(
        state: state,
        duration: duration,
        enableHaptic: enableHaptic,
        onStateChanged: onStateChanged,
        child: child,
      );

  /// 创建加载状态容器
  Widget loadingContainer({
    required Widget child,
    bool isLoading = false,
    Color loadingColor = Colors.blue,
    Duration duration = const Duration(milliseconds: 600),
  }) =>
      IOSLoadingContainer(
        isLoading: isLoading,
        loadingColor: loadingColor,
        duration: duration,
        child: child,
      );

  /// 创建成功反馈容器
  Widget successContainer({
    required Widget child,
    bool? successTrigger,
    Color successColor = Colors.green,
    Color particleColor = Colors.green,
    int particleCount = 8,
    Duration duration = IOSAnimationConfig.verySlow,
    bool enableHaptic = true,
  }) =>
      IOSSuccessContainer(
        successTrigger: successTrigger,
        successColor: successColor,
        particleColor: particleColor,
        particleCount: particleCount,
        duration: duration,
        enableHaptic: enableHaptic,
        child: child,
      );

  /// 创建数字滚动容器
  Widget numberRollContainer({
    required double value,
    TextStyle? style,
    Duration duration = const Duration(milliseconds: 800),
    Curve curve = Curves.easeOutCubic,
    String Function(double)? formatter,
  }) =>
      IOSNumberRollContainer(
        value: value,
        style: style,
        duration: duration,
        curve: curve,
        formatter: formatter,
      );

  // ===== 导航动效 =====

  /// 创建iOS页面路由
  Route<T> createPageRoute<T extends Object?>({
    required Widget page,
    RouteSettings? settings,
    Duration duration = IOSAnimationConfig.normal,
    IOSPageTransition transition = IOSPageTransition.slide,
  }) =>
      IOSPageRoute<T>(
        page: page,
        settings: settings,
        duration: duration,
        transition: transition,
      );

  /// 创建标签页切换容器
  Widget tabSwitchContainer({
    required List<Widget> children,
    required int selectedIndex,
    Duration duration = IOSAnimationConfig.fast,
    ValueChanged<int>? onTabChanged,
  }) =>
      IOSTabSwitchContainer(
        selectedIndex: selectedIndex,
        duration: duration,
        onTabChanged: onTabChanged,
        children: children,
      );

  /// 创建卡片堆叠容器
  Widget cardStackContainer({
    required List<Widget> children,
    required int selectedIndex,
    double stackOffset = 8.0,
    Duration duration = IOSAnimationConfig.normal,
  }) =>
      IOSCardStackContainer(
        selectedIndex: selectedIndex,
        stackOffset: stackOffset,
        duration: duration,
        children: children,
      );

  /// 创建抽屉容器
  Widget drawerContainer({
    required Widget child,
    required Widget drawer,
    bool isOpen = false,
    double drawerWidth = 280.0,
    Duration duration = IOSAnimationConfig.normal,
    ValueChanged<bool>? onDrawerChanged,
  }) =>
      IOSDrawerContainer(
        drawer: drawer,
        isOpen: isOpen,
        drawerWidth: drawerWidth,
        duration: duration,
        onDrawerChanged: onDrawerChanged,
        child: child,
      );

  // ===== 特殊效果 =====

  /// 创建文件夹容器
  Widget folderContainer({
    required Widget folderIcon,
    required List<Widget> children,
    bool isExpanded = false,
    Color folderColor = Colors.blue,
    Duration duration = IOSAnimationConfig.normal,
    ValueChanged<bool>? onExpansionChanged,
  }) =>
      IOSFolderContainer(
        folderIcon: folderIcon,
        isExpanded: isExpanded,
        folderColor: folderColor,
        duration: duration,
        onExpansionChanged: onExpansionChanged,
        children: children,
      );

  /// 创建网格抖动容器
  Widget wobbleGrid({
    required List<Widget> children,
    bool isEditing = false,
    int crossAxisCount = 4,
    double wobbleIntensity = 0.02,
    Duration duration = const Duration(milliseconds: 600),
    void Function(int index)? onItemTap,
    void Function(int index)? onItemLongPress,
  }) =>
      IOSWobbleGrid(
        isEditing: isEditing,
        crossAxisCount: crossAxisCount,
        wobbleIntensity: wobbleIntensity,
        duration: duration,
        onItemTap: onItemTap,
        onItemLongPress: onItemLongPress,
        children: children,
      );

  /// 创建缩放新建动画容器
  Widget scaleNewItem({
    required Widget child,
    bool? newItemTrigger,
    double scaleFactor = 0.1,
    Duration duration = IOSAnimationConfig.slow,
    bool enableHaptic = true,
  }) =>
      IOSScaleNewItem(
        newItemTrigger: newItemTrigger,
        scaleFactor: scaleFactor,
        duration: duration,
        enableHaptic: enableHaptic,
        child: child,
      );

  /// 创建拖拽指示器
  Widget dragIndicator({
    bool isDragging = false,
    Color indicatorColor = Colors.blue,
    Duration duration = IOSAnimationConfig.fast,
  }) =>
      IOSDragIndicator(
        isDragging: isDragging,
        indicatorColor: indicatorColor,
        duration: duration,
      );

  /// 创建浮动操作按钮
  Widget floatingActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color backgroundColor = Colors.blue,
    double size = 56.0,
    bool enableSpring = true,
    bool enableShadow = true,
  }) =>
      IOSFloatingActionButton(
        icon: icon,
        onPressed: onPressed,
        backgroundColor: backgroundColor,
        size: size,
        enableSpring: enableSpring,
        enableShadow: enableShadow,
      );

  /// 创建删除确认动画
  Widget deleteConfirmation({
    required Widget child,
    VoidCallback? onDelete,
    Color deleteColor = Colors.red,
    Duration duration = IOSAnimationConfig.normal,
    bool enableHaptic = true,
  }) =>
      IOSDeleteConfirmation(
        onDelete: onDelete,
        deleteColor: deleteColor,
        duration: duration,
        enableHaptic: enableHaptic,
        child: child,
      );

  /// 创建波纹效果
  Widget rippleEffect({
    required Widget child,
    Color rippleColor = Colors.blue,
    Duration duration = IOSAnimationConfig.slow,
    double maxRadius = 100.0,
  }) =>
      IOSRippleEffect(
        rippleColor: rippleColor,
        duration: duration,
        maxRadius: maxRadius,
        child: child,
      );

  // ===== 便捷方法 =====

  /// 创建标准按钮动效
  Widget animatedButton({
    required Widget child,
    required VoidCallback onPressed,
    Duration duration = IOSAnimationConfig.fast,
    bool enableHaptic = true,
  }) =>
      gestureContainer(
        child: child,
        onTap: onPressed,
        enableHaptic: enableHaptic,
      );

  /// 创建列表项动效
  Widget animatedListItem({
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

  /// 显示底部弹窗
  Future<T?> showBottomSheet<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    Color? backgroundColor,
    double? elevation,
    ShapeBorder? shape,
    bool isScrollControlled = true,
    bool showDragHandle = true,
  }) =>
      showModalBottomSheet<T>(
        context: context,
        builder: builder,
        backgroundColor: backgroundColor ?? Colors.white,
        elevation: elevation ?? 8,
        shape: shape ??
            const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
        isScrollControlled: isScrollControlled,
        showDragHandle: showDragHandle,
      );

  // ===== 动画协调 =====

  /// 执行手势反馈动画
  Future<void> executeGestureFeedback({
    required String animationId,
    required TickerProvider vsync,
    required GestureType gesture,
    required VoidCallback onUpdate,
  }) async {
    await _coordinator.executeGestureFeedback(
      animationId: animationId,
      vsync: vsync,
      gesture: gesture,
      onUpdate: onUpdate,
    );
  }

  /// 执行状态转换动画
  Future<void> executeStateTransition({
    required String animationId,
    required TickerProvider vsync,
    required StateTransition transition,
    required VoidCallback onUpdate,
  }) async {
    await _coordinator.executeStateTransition(
      animationId: animationId,
      vsync: vsync,
      transition: transition,
      onUpdate: onUpdate,
    );
  }

  /// 执行成功反馈动画
  Future<void> executeSuccessFeedback({
    required String animationId,
    required TickerProvider vsync,
    required Offset position,
    required VoidCallback onUpdate,
  }) async {
    await _coordinator.executeSuccessFeedback(
      animationId: animationId,
      vsync: vsync,
      position: position,
      onUpdate: onUpdate,
    );
  }

  /// 清理所有动画资源
  void dispose() {
    _coordinator.dispose();
  }
}

// 私有动画组件实现（复用现有代码）
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
