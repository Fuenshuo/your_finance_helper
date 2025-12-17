import 'package:flutter/material.dart';
import 'package:your_finance_flutter/core/widgets/glass_notification.dart';

/// 统一的提示系统
/// 整合所有提示方式，提供统一的API接口

/// 提示优先级
enum NotificationPriority {
  /// 低优先级，可被覆盖
  low,

  /// 普通优先级
  normal,

  /// 高优先级，不会被覆盖
  high,

  /// 紧急优先级，必须显示
  urgent,
}

/// 显示模式枚举
enum NotificationDisplayMode {
  /// 毛玻璃通知（推荐）
  glassNotification,

  /// Alert对话框
  alertDialog,

  /// SnackBar（仅兼容性保留）
  snackBar,

  /// 动画内联提示
  animatedInline,
}

/// 提示类型枚举
enum NotificationType {
  /// 普通信息提示
  info,

  /// 成功操作提示
  success,

  /// 警告提示
  warning,

  /// 错误提示
  error,

  /// 严重错误，需要用户确认
  critical,

  /// 开发中功能提示
  development,
}

/// 提示配置
class NotificationConfig {
  const NotificationConfig({
    required this.type,
    required this.message,
    this.duration = const Duration(seconds: 3),
    this.priority = NotificationPriority.normal,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.actionLabel,
    this.actionCallback,
    this.showCloseButton = true,
  });

  /// 从类型创建默认配置
  factory NotificationConfig.fromType(
    NotificationType type,
    String message, {
    Duration? duration,
    String? actionLabel,
    VoidCallback? actionCallback,
  }) {
    switch (type) {
      case NotificationType.info:
        return NotificationConfig(
          type: type,
          message: message,
          duration: duration ?? const Duration(seconds: 2),
          priority: NotificationPriority.low,
          icon: Icons.info_outline,
          actionLabel: actionLabel,
          actionCallback: actionCallback,
        );

      case NotificationType.success:
        return NotificationConfig(
          type: type,
          message: message,
          duration: duration ?? const Duration(seconds: 2),
          icon: Icons.check_circle_outline,
          actionLabel: actionLabel,
          actionCallback: actionCallback,
        );

      case NotificationType.warning:
        return NotificationConfig(
          type: type,
          message: message,
          duration: duration ?? const Duration(seconds: 3),
          icon: Icons.warning_amber_outlined,
          actionLabel: actionLabel,
          actionCallback: actionCallback,
        );

      case NotificationType.error:
        return NotificationConfig(
          type: type,
          message: message,
          duration: duration ?? const Duration(seconds: 4),
          priority: NotificationPriority.high,
          icon: Icons.error_outline,
          actionLabel: actionLabel,
          actionCallback: actionCallback,
        );

      case NotificationType.critical:
        return NotificationConfig(
          type: type,
          message: message,
          duration: duration ?? const Duration(), // 不自动关闭
          priority: NotificationPriority.urgent,
          icon: Icons.error,
          actionLabel: actionLabel ?? '确定',
          actionCallback: actionCallback,
          showCloseButton: false,
        );

      case NotificationType.development:
        return NotificationConfig(
          type: type,
          message: message,
          duration: duration ?? const Duration(seconds: 2),
          priority: NotificationPriority.low,
          icon: Icons.build_circle_outlined,
          actionLabel: actionLabel,
          actionCallback: actionCallback,
        );
    }
  }
  final NotificationType type;
  final String message;
  final Duration duration;
  final NotificationPriority priority;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final String? actionLabel;
  final VoidCallback? actionCallback;
  final bool showCloseButton;
}

/// 提示上下文信息
class NotificationContext {
  const NotificationContext({
    required this.isInModal,
    required this.isInBottomSheet,
    required this.isKeyboardVisible,
    required this.screenSize,
    required this.isLandscape,
    required this.textScaleFactor,
  });

  factory NotificationContext.fromBuildContext(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return NotificationContext(
      isInModal: _isInModal(context),
      isInBottomSheet: _isInBottomSheet(context),
      isKeyboardVisible: mediaQuery.viewInsets.bottom > 0,
      screenSize: mediaQuery.size,
      isLandscape: mediaQuery.orientation == Orientation.landscape,
      textScaleFactor: MediaQuery.textScalerOf(context).scale(1.0),
    );
  }
  final bool isInModal;
  final bool isInBottomSheet;
  final bool isKeyboardVisible;
  final Size screenSize;
  final bool isLandscape;
  final double textScaleFactor;

  static bool _isInModal(BuildContext context) =>
      ModalRoute.of(context)?.isCurrent ?? false;

  static bool _isInBottomSheet(BuildContext context) {
    // 检查是否在BottomSheet中
    return context.findAncestorWidgetOfExactType<BottomSheet>() != null;
  }
}

/// 智能提示路由器
class SmartNotificationRouter {
  /// 根据上下文和提示类型选择最佳显示方式
  NotificationDisplayMode selectDisplayMode(
    NotificationType type,
    NotificationContext context,
  ) {
    // 严重错误总是使用AlertDialog
    if (type == NotificationType.critical) {
      return NotificationDisplayMode.alertDialog;
    }

    // 在模态框或BottomSheet中，使用AlertDialog避免层级问题
    if (context.isInModal || context.isInBottomSheet) {
      return NotificationDisplayMode.alertDialog;
    }

    // 键盘可见时，使用AlertDialog避免被键盘遮挡
    if (context.isKeyboardVisible) {
      return NotificationDisplayMode.alertDialog;
    }

    // 横屏模式下优先使用AlertDialog，提供更好的可读性
    if (context.isLandscape) {
      return NotificationDisplayMode.alertDialog;
    }

    // 默认使用GlassNotification
    return NotificationDisplayMode.glassNotification;
  }
}

/// 统一提示管理器
class UnifiedNotifications {
  factory UnifiedNotifications() => _instance;
  UnifiedNotifications._internal();
  static final UnifiedNotifications _instance =
      UnifiedNotifications._internal();

  final SmartNotificationRouter _router = SmartNotificationRouter();

  /// 显示智能提示 - 根据类型和上下文自动选择最佳显示方式
  void show(
    BuildContext context,
    NotificationType type,
    String message, {
    Duration? duration,
    String? actionLabel,
    VoidCallback? actionCallback,
  }) {
    final config = NotificationConfig.fromType(
      type,
      message,
      duration: duration,
      actionLabel: actionLabel,
      actionCallback: actionCallback,
    );

    _showWithConfig(context, config);
  }

  /// 显示自定义配置的提示
  void showWithConfig(BuildContext context, NotificationConfig config) {
    _showWithConfig(context, config);
  }

  /// 显示信息提示
  void showInfo(
    BuildContext context,
    String message, {
    Duration? duration,
    String? actionLabel,
    VoidCallback? actionCallback,
  }) {
    show(
      context,
      NotificationType.info,
      message,
      duration: duration,
      actionLabel: actionLabel,
      actionCallback: actionCallback,
    );
  }

  /// 显示成功提示
  void showSuccess(
    BuildContext context,
    String message, {
    Duration? duration,
    String? actionLabel,
    VoidCallback? actionCallback,
  }) {
    show(
      context,
      NotificationType.success,
      message,
      duration: duration,
      actionLabel: actionLabel,
      actionCallback: actionCallback,
    );
  }

  /// 显示警告提示
  void showWarning(
    BuildContext context,
    String message, {
    Duration? duration,
    String? actionLabel,
    VoidCallback? actionCallback,
  }) {
    show(
      context,
      NotificationType.warning,
      message,
      duration: duration,
      actionLabel: actionLabel,
      actionCallback: actionCallback,
    );
  }

  /// 显示错误提示
  void showError(
    BuildContext context,
    String message, {
    Duration? duration,
    String? actionLabel,
    VoidCallback? actionCallback,
  }) {
    show(
      context,
      NotificationType.error,
      message,
      duration: duration,
      actionLabel: actionLabel,
      actionCallback: actionCallback,
    );
  }

  /// 显示严重错误提示（需要确认）
  void showCritical(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? actionCallback,
  }) {
    show(
      context,
      NotificationType.critical,
      message,
      actionLabel: actionLabel,
      actionCallback: actionCallback,
    );
  }

  /// 显示开发中功能提示
  void showDevelopment(
    BuildContext context,
    String featureName, {
    String? additionalInfo,
  }) {
    final message = additionalInfo != null
        ? '$featureName 功能正在开发中\n$additionalInfo'
        : '$featureName 功能正在开发中';

    show(context, NotificationType.development, message);
  }

  /// 显示确认对话框
  Future<bool?> showConfirmation(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = '确定',
    String cancelLabel = '取消',
    Color? confirmColor,
  }) =>
      showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(cancelLabel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: confirmColor != null
                  ? TextButton.styleFrom(foregroundColor: confirmColor)
                  : null,
              child: Text(confirmLabel),
            ),
          ],
        ),
      );

  /// 显示删除确认对话框
  Future<bool?> showDeleteConfirmation(
    BuildContext context,
    String itemName,
  ) =>
      showConfirmation(
        context,
        title: '确认删除',
        message: '确定要删除 $itemName 吗？此操作无法撤销。',
        confirmLabel: '删除',
        confirmColor: Colors.red,
      );

  /// 内部方法：根据配置显示提示
  void _showWithConfig(BuildContext context, NotificationConfig config) {
    final notificationContext = NotificationContext.fromBuildContext(context);
    final displayMode =
        _router.selectDisplayMode(config.type, notificationContext);

    switch (displayMode) {
      case NotificationDisplayMode.alertDialog:
        _showAlertDialog(context, config);

      case NotificationDisplayMode.glassNotification:
        _showGlassNotification(context, config);

      case NotificationDisplayMode.snackBar:
        _showSnackBar(context, config);

      case NotificationDisplayMode.animatedInline:
        // 暂时使用GlassNotification，后续可扩展
        _showGlassNotification(context, config);
    }
  }

  /// 显示AlertDialog
  void _showAlertDialog(BuildContext context, NotificationConfig config) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(config.icon, size: 48),
        title: Text(_getTypeTitle(config.type)),
        content: Text(config.message),
        actions: [
          if (config.showCloseButton)
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
          if (config.actionLabel != null && config.actionCallback != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                config.actionCallback?.call();
              },
              child: Text(config.actionLabel!),
            ),
        ],
      ),
    );
  }

  /// 显示GlassNotification
  void _showGlassNotification(BuildContext context, NotificationConfig config) {
    GlassNotification.show(
      context,
      message: config.message,
      duration: config.duration,
      backgroundColor: config.backgroundColor,
      textColor: config.textColor,
      icon: config.icon,
      onDismiss: config.actionCallback,
    );
  }

  /// 显示SnackBar（兼容性保留）
  void _showSnackBar(BuildContext context, NotificationConfig config) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          if (config.icon != null) ...[
            Icon(config.icon, size: 18, color: config.textColor),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              config.message,
              style: config.textColor != null
                  ? TextStyle(color: config.textColor)
                  : null,
            ),
          ),
        ],
      ),
      duration: config.duration,
      backgroundColor: config.backgroundColor,
      action: config.actionLabel != null && config.actionCallback != null
          ? SnackBarAction(
              label: config.actionLabel!,
              onPressed: config.actionCallback!,
              textColor: config.textColor,
            )
          : null,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /// 获取类型对应的标题
  String _getTypeTitle(NotificationType type) {
    switch (type) {
      case NotificationType.info:
        return '提示';
      case NotificationType.success:
        return '成功';
      case NotificationType.warning:
        return '警告';
      case NotificationType.error:
        return '错误';
      case NotificationType.critical:
        return '严重错误';
      case NotificationType.development:
        return '开发中';
    }
  }
}

/// 便捷的全局访问方法
final unifiedNotifications = UnifiedNotifications();
