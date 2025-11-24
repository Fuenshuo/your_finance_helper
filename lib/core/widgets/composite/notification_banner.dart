import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:your_finance_flutter/core/theme/app_design_tokens.dart';

/// S31: 通知横幅样式
/// 提示关键信息（如 Policy Data Service 更新失败、清账提醒）
///
/// **样式特征：**
/// - 位于页面顶部，带有关闭按钮，图标+文字
/// - 成功：绿色背景，白色文字/图标
/// - 警告：黄色背景，深色文字/图标
/// - 错误：红色背景，白色文字/图标
enum NotificationBannerType {
  success,
  warning,
  error,
}

class NotificationBanner extends StatelessWidget {
  const NotificationBanner({
    required this.type,
    required this.message,
    super.key,
    this.icon,
    this.onDismiss,
    this.backgroundColor,
    this.textColor,
    this.showDismissButton = true,
  });

  /// 横幅类型
  final NotificationBannerType type;

  /// 消息文本
  final String message;

  /// 图标（默认根据类型自动选择）
  final IconData? icon;

  /// 关闭回调
  final VoidCallback? onDismiss;

  /// 自定义背景色
  final Color? backgroundColor;

  /// 自定义文字颜色
  final Color? textColor;

  /// 是否显示关闭按钮
  final bool showDismissButton;

  Color _getBackgroundColor(BuildContext context) {
    if (backgroundColor != null) return backgroundColor!;

    switch (type) {
      case NotificationBannerType.success:
        return AppDesignTokens.successColor(context);
      case NotificationBannerType.warning:
        return AppDesignTokens.warningColor;
      case NotificationBannerType.error:
        return AppDesignTokens.errorColor;
    }
  }

  Color _getTextColor(BuildContext context) {
    if (textColor != null) return textColor!;

    switch (type) {
      case NotificationBannerType.success:
      case NotificationBannerType.error:
        return Colors.white;
      case NotificationBannerType.warning:
        return Colors.black87;
    }
  }

  IconData _getDefaultIcon() {
    if (icon != null) return icon!;

    switch (type) {
      case NotificationBannerType.success:
        return CupertinoIcons.check_mark_circled;
      case NotificationBannerType.warning:
        return CupertinoIcons.exclamationmark_triangle;
      case NotificationBannerType.error:
        return CupertinoIcons.xmark_circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _getBackgroundColor(context);
    final txtColor = _getTextColor(context);
    final defaultIcon = _getDefaultIcon();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDesignTokens.spacing16,
        vertical: AppDesignTokens.spacing12,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppDesignTokens.radiusMedium(context)),
          bottomRight: Radius.circular(AppDesignTokens.radiusMedium(context)),
        ),
      ),
      child: Row(
        children: [
          Icon(defaultIcon, color: txtColor),
          const SizedBox(width: AppDesignTokens.spacing12),
          Expanded(
            child: Text(
              message,
              style: AppDesignTokens.body(context).copyWith(color: txtColor),
            ),
          ),
          if (showDismissButton && onDismiss != null)
            IconButton(
              icon: Icon(CupertinoIcons.xmark, color: txtColor),
              onPressed: onDismiss,
              iconSize: 18,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
}
