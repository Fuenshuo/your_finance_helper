import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:your_finance_flutter/core/widgets/glass_notification.dart';

/// 通知管理器 - 管理应用的全局通知显示
/// 支持队列显示，自动回收，确保只有一个通知同时显示
class NotificationManager {
  factory NotificationManager() => _instance;
  NotificationManager._internal();
  static final NotificationManager _instance = NotificationManager._internal();

  final Queue<_NotificationItem> _notificationQueue =
      Queue<_NotificationItem>();
  bool _isShowing = false;

  /// 显示通知 - 会自动加入队列并按顺序显示
  void showNotification(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
    Color? backgroundColor,
    Color? textColor,
    IconData? icon,
  }) {
    _notificationQueue.add(
      _NotificationItem(
        message: message,
        duration: duration,
        backgroundColor: backgroundColor,
        textColor: textColor,
        icon: icon,
      ),
    );

    _processQueue(context);
  }

  /// 显示开发阶段提示信息
  void showDevelopmentHint(
    BuildContext context,
    String featureName, {
    String? additionalInfo,
  }) {
    final message = additionalInfo != null
        ? '$featureName 功能正在开发中\n$additionalInfo'
        : '$featureName 功能正在开发中';

    showNotification(
      context,
      message: message,
      duration: const Duration(seconds: 2),
      icon: Icons.build_circle_outlined,
      // 使用默认透明背景，不设置backgroundColor和textColor
    );
  }

  /// 显示成功提示
  void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    showNotification(
      context,
      message: message,
      duration: duration,
      icon: Icons.check_circle_outline,
      // 使用默认透明背景
    );
  }

  /// 显示警告提示
  void showWarning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    showNotification(
      context,
      message: message,
      duration: duration,
      icon: Icons.warning_amber_outlined,
      // 使用默认透明背景
    );
  }

  /// 显示错误提示
  void showError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) {
    showNotification(
      context,
      message: message,
      duration: duration,
      icon: Icons.error_outline,
      // 使用默认透明背景
    );
  }

  /// 处理通知队列
  void _processQueue(BuildContext context) {
    if (_isShowing || _notificationQueue.isEmpty) return;

    _isShowing = true;
    final notification = _notificationQueue.removeFirst();

    GlassNotification.show(
      context,
      message: notification.message,
      duration: notification.duration,
      backgroundColor: notification.backgroundColor,
      textColor: notification.textColor,
      icon: notification.icon,
      onDismiss: () {
        _isShowing = false;
        // 延迟一下再处理下一个，确保动画完成
        Future.delayed(const Duration(milliseconds: 500), () {
          if (context.mounted) {
            _processQueue(context);
          }
        });
      },
    );
  }

  /// 清空通知队列
  void clearQueue() {
    _notificationQueue.clear();
    _isShowing = false;
  }
}

/// 通知项数据类
class _NotificationItem {
  const _NotificationItem({
    required this.message,
    required this.duration,
    this.backgroundColor,
    this.textColor,
    this.icon,
  });

  final String message;
  final Duration duration;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
}
