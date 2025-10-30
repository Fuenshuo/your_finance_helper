import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

/// 毛玻璃特效通知弹窗
/// 用于替代底部SnackBar，提供更优雅的用户体验
class GlassNotification extends StatefulWidget {
  const GlassNotification({
    required this.message,
    super.key,
    this.duration = const Duration(seconds: 3),
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.onDismiss,
  });

  final String message;
  final Duration duration;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final VoidCallback? onDismiss;

  /// 显示毛玻璃通知
  static void show(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
    Color? backgroundColor,
    Color? textColor,
    IconData? icon,
    VoidCallback? onDismiss,
  }) {
    // 使用OverlayEntry而不是Dialog，避免阻塞交互
    final overlay = Overlay.of(context);

    // 创建一个包装函数来处理overlayEntry引用
    late final OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: () {
          // 点击背景时关闭通知
          overlayEntry.remove();
          onDismiss?.call();
        },
        child: ColoredBox(
          color: Colors.transparent, // 透明背景，可以点击穿透到底层
          child: _GlassNotificationDialog(
            message: message,
            duration: duration,
            backgroundColor: backgroundColor,
            textColor: textColor,
            icon: icon,
            onDismiss: onDismiss,
            overlayEntry: overlayEntry,
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
  }

  @override
  State<GlassNotification> createState() => _GlassNotificationState();
}

class _GlassNotificationState extends State<GlassNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                left: 16,
                right: 16,
              ),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width - 32,
                    minWidth: 200,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          // 提高背景不透明度，确保在复杂背景下也有足够对比度
                          color: widget.backgroundColor ??
                              Colors.black.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                          ),
                          // 添加阴影增强层次感
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.icon != null) ...[
                              Container(
                                margin: const EdgeInsets.only(top: 2),
                                child: Icon(
                                  widget.icon,
                                  size: 18,
                                  // 确保图标在深色背景下清晰可见
                                  color: Colors.white.withOpacity(0.95),
                                ),
                              ),
                              const SizedBox(width: 12),
                            ],
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    widget.message,
                                    style: TextStyle(
                                      // 使用纯白色文字，确保在深色背景下高度清晰
                                      color: Colors.white.withOpacity(0.95),
                                      fontSize: 14, // 稍微增大字体
                                      fontWeight: FontWeight.w600, // 增强字体粗细
                                      height: 1.4,
                                      // 添加文字阴影，提升可读性
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withOpacity(0.3),
                                          offset: const Offset(0, 1),
                                          blurRadius: 2,
                                        ),
                                      ],
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                if (mounted) {
                                  _animationController.reverse().then((_) {
                                    widget.onDismiss?.call();
                                    _GlassNotificationManager.hideCurrent();
                                  });
                                }
                              },
                              child: Icon(
                                Icons.close,
                                size: 16,
                                // 关闭按钮也要清晰可见
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}

/// 毛玻璃通知管理器
class _GlassNotificationManager {
  static BuildContext? _currentContext;
  static Timer? _hideTimer;

  static void setCurrentContext(BuildContext context) {
    _currentContext = context;
  }

  static void hideCurrent() {
    _hideTimer?.cancel();
    if (_currentContext != null && Navigator.canPop(_currentContext!)) {
      Navigator.of(_currentContext!).pop();
      _currentContext = null;
    }
  }
}

/// 毛玻璃通知对话框
class _GlassNotificationDialog extends StatefulWidget {
  const _GlassNotificationDialog({
    required this.message,
    required this.duration,
    required this.overlayEntry,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.onDismiss,
  });

  final String message;
  final Duration duration;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final VoidCallback? onDismiss;
  final OverlayEntry overlayEntry;

  @override
  State<_GlassNotificationDialog> createState() =>
      _GlassNotificationDialogState();
}

class _GlassNotificationDialogState extends State<_GlassNotificationDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _GlassNotificationManager.setCurrentContext(context);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _slideAnimation = Tween<double>(
      begin: -100.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();

    // 设置自动隐藏定时器
    _hideTimer = Timer(widget.duration, _hide);
  }

  void _hide() {
    if (mounted) {
      _animationController.reverse().then((_) {
        widget.onDismiss?.call();
        widget.overlayEntry.remove();
      });
    }
  }

  void _closeManually() {
    _hideTimer?.cancel();
    _hide();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) => Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 16,
                    left: 16,
                    right: 16,
                  ),
                  child: GestureDetector(
                    onTap: () {}, // 阻止点击穿透到底层
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width - 32,
                          minWidth: 200,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                // 提高背景不透明度，确保在复杂背景下也有足够对比度
                                color: widget.backgroundColor ??
                                    Colors.black.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                ),
                                // 添加阴影增强层次感
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (widget.icon != null) ...[
                                    Container(
                                      margin: const EdgeInsets.only(top: 2),
                                      child: Icon(
                                        widget.icon,
                                        size: 18,
                                        // 确保图标在深色背景下清晰可见
                                        color: Colors.white.withOpacity(0.95),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                  ],
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          widget.message,
                                          style: TextStyle(
                                            // 使用纯白色文字，确保在深色背景下高度清晰
                                            color:
                                                Colors.white.withOpacity(0.95),
                                            fontSize: 14, // 稍微增大字体
                                            fontWeight:
                                                FontWeight.w600, // 增强字体粗细
                                            height: 1.4,
                                            // 添加文字阴影，提升可读性
                                            shadows: [
                                              Shadow(
                                                color: Colors.black
                                                    .withOpacity(0.3),
                                                offset: const Offset(0, 1),
                                                blurRadius: 2,
                                              ),
                                            ],
                                          ),
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: _closeManually,
                                    child: Icon(
                                      Icons.close,
                                      size: 16,
                                      // 关闭按钮也要清晰可见
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
