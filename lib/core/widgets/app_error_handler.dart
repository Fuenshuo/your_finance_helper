import 'package:flutter/material.dart';
import '../theme/app_design_tokens.dart';
import 'app_empty_state.dart';

/// 全局错误处理器
/// 统一处理各种错误场景，提供友好的用户提示
class AppErrorHandler {
  AppErrorHandler._();

  /// 处理错误并显示友好的提示
  static void handleError(
    BuildContext context,
    dynamic error, {
    VoidCallback? onRetry,
    String? customMessage,
  }) {
    String message;
    IconData icon;
    String? actionLabel;

    if (error is NetworkException) {
      message = customMessage ?? '网络连接失败，请检查网络设置';
      icon = Icons.wifi_off;
      actionLabel = '重试';
    } else if (error is AIException) {
      message = customMessage ?? 'AI走神了，请重试或手动输入';
      icon = Icons.smart_toy_outlined;
      actionLabel = '重试';
    } else if (error is ValidationException) {
      message = customMessage ?? error.message;
      icon = Icons.error_outline;
    } else if (error is StorageException) {
      message = customMessage ?? '数据保存失败，请重试';
      icon = Icons.storage_outlined;
      actionLabel = '重试';
    } else {
      message = customMessage ?? '操作失败，请稍后重试';
      icon = Icons.error_outline;
      actionLabel = '重试';
    }

    // 显示错误提示
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: AppDesignTokens.iconSizeMedium),
            SizedBox(width: AppDesignTokens.spacing12),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.bodyMedium(context).copyWith(
                  color: Colors.white,
                ),
              ),
            ),
            if (actionLabel != null && onRetry != null)
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  onRetry();
                },
                child: Text(
                  actionLabel,
                  style: AppTextStyles.bodyMedium(context).copyWith(
                    color: Colors.white,
                    fontWeight: AppDesignTokens.fontWeightMedium,
                  ),
                ),
              ),
          ],
        ),
        backgroundColor: AppDesignTokens.errorColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// 显示错误页面（全屏）
  static Widget buildErrorPage({
    required dynamic error,
    VoidCallback? onRetry,
    String? customMessage,
  }) {
    if (error is NetworkException) {
      return AppEmptyStates.networkError(onRetry: onRetry);
    } else if (error is AIException) {
      return AppEmptyStates.aiParseError(onRetry: onRetry);
    } else {
      return AppEmptyState(
        icon: Icons.error_outline,
        title: customMessage ?? '出错了',
        subtitle: error.toString(),
        actionLabel: '重试',
        onAction: onRetry,
      );
    }
  }
}

/// 网络异常
class NetworkException implements Exception {
  NetworkException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// AI异常
class AIException implements Exception {
  AIException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// 验证异常
class ValidationException implements Exception {
  ValidationException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// 存储异常
class StorageException implements Exception {
  StorageException(this.message);
  final String message;
  @override
  String toString() => message;
}

