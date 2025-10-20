import 'package:flutter/material.dart';

/// ===== 左滑操作组件 =====
/// 左滑显示操作按钮，用户点击按钮执行操作，更安全直观
class SwipeActionItem extends StatefulWidget {
  const SwipeActionItem({
    required this.child,
    required this.action,
    super.key,
    this.actionWidth = 120.0,
    this.dragThreshold = 60.0,
  });

  final Widget child;
  final SwipeAction action;
  final double actionWidth; // 操作按钮宽度
  final double dragThreshold; // 展开操作按钮的拖拽阈值

  @override
  State<SwipeActionItem> createState() => _SwipeActionItemState();
}

class _SwipeActionItemState extends State<SwipeActionItem>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<double> _slideAnimation;

  double _dragExtent = 0.0;
  bool _isActionExecuting = false;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: -widget.actionWidth,
    ).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (_isActionExecuting) return;

    setState(() {
      _dragExtent += details.delta.dx;

      // 限制拖拽范围
      if (_dragExtent < -widget.actionWidth) {
        _dragExtent = -widget.actionWidth;
      } else if (_dragExtent > 0) {
        _dragExtent = 0;
      }

      // 更新动画控制器
      final progress = (_dragExtent.abs() / widget.actionWidth).clamp(0.0, 1.0);
      _slideController.value = progress;
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_isActionExecuting) return;

    final velocity = details.velocity.pixelsPerSecond.dx;

    if (_dragExtent.abs() >= widget.dragThreshold || velocity < -300) {
      // 展开操作按钮
      _slideController.animateTo(1.0, curve: Curves.easeOutCubic);
      setState(() {
        _dragExtent = -widget.actionWidth;
      });
    } else {
      // 收起操作按钮
      _slideController.animateTo(0.0, curve: Curves.easeOutCubic);
      setState(() {
        _dragExtent = 0.0;
      });
    }
  }

  void _executeAction() {
    if (_isActionExecuting) return;

    setState(() {
      _isActionExecuting = true;
    });

    // 执行操作
    widget.action.onTap();

    // 收起操作按钮
    _slideController.animateTo(0.0, curve: Curves.easeOutCubic).then((_) {
      setState(() {
        _dragExtent = 0.0;
        _isActionExecuting = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          // 操作按钮背景
          Positioned.fill(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: _executeAction,
                  child: Container(
                    width: widget.actionWidth,
                    color: widget.action.backgroundColor,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          widget.action.icon,
                          color: widget.action.iconColor,
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.action.label,
                          style: TextStyle(
                            color: widget.action.iconColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 主内容
          AnimatedBuilder(
            animation: _slideAnimation,
            builder: (context, child) => Transform.translate(
              offset: Offset(_slideAnimation.value, 0),
              child: child,
            ),
            child: GestureDetector(
              onHorizontalDragUpdate: _handleDragUpdate,
              onHorizontalDragEnd: _handleDragEnd,
              child: widget.child,
            ),
          ),
        ],
      );
}

/// ===== 滑动操作配置 =====
class SwipeAction {
  const SwipeAction({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.iconColor,
    required this.onTap,
  });

  /// 删除操作的预设配置
  factory SwipeAction.delete(VoidCallback onTap) => SwipeAction(
        icon: Icons.delete_forever,
        label: '删除',
        backgroundColor: Colors.red,
        iconColor: Colors.white,
        onTap: onTap,
      );

  /// 编辑操作的预设配置
  factory SwipeAction.edit(VoidCallback onTap) => SwipeAction(
        icon: Icons.edit,
        label: '编辑',
        backgroundColor: Colors.blue,
        iconColor: Colors.white,
        onTap: onTap,
      );

  /// 归档操作的预设配置
  factory SwipeAction.archive(VoidCallback onTap) => SwipeAction(
        icon: Icons.archive,
        label: '归档',
        backgroundColor: Colors.orange,
        iconColor: Colors.white,
        onTap: onTap,
      );

  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color iconColor;
  final VoidCallback onTap;
}
