import 'package:flutter/material.dart';
import 'package:your_finance_flutter/core/theme/app_design_tokens.dart';
import 'package:your_finance_flutter/core/widgets/app_primary_button.dart';

/// 空状态组件 - 统一的空状态展示
/// 用于列表为空、数据加载失败等场景
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    required this.icon,
    required this.title,
    super.key,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppDesignTokens.spacing32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppDesignTokens.primaryBackground(context),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: AppDesignTokens.iconSizeLarge,
                    color: AppDesignTokens.secondaryText(context),
                  ),
                ),
                const SizedBox(height: AppDesignTokens.spacing24),
                Text(
                  title,
                  style: AppTextStyles.headlineMedium(context),
                  textAlign: TextAlign.center,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: AppDesignTokens.spacing8),
                  Text(
                    subtitle!,
                    style: AppTextStyles.bodyMedium(context),
                    textAlign: TextAlign.center,
                  ),
                ],
                if (actionLabel != null && onAction != null) ...[
                  const SizedBox(height: AppDesignTokens.spacing24),
                  AppPrimaryButton(
                    onPressed: onAction,
                    label: actionLabel!,
                  ),
                ],
              ],
            ),
          ),
        ),
      );
}

/// 预定义的空状态组件
class AppEmptyStates {
  AppEmptyStates._();

  /// 空列表状态
  static Widget emptyList({
    String? actionLabel,
    VoidCallback? onAction,
  }) =>
      AppEmptyState(
        icon: Icons.inbox_outlined,
        title: '暂无数据',
        subtitle: '点击下方按钮添加第一条记录',
        actionLabel: actionLabel ?? '添加',
        onAction: onAction,
      );

  /// 加载失败状态
  static Widget loadError({
    VoidCallback? onRetry,
  }) =>
      AppEmptyState(
        icon: Icons.error_outline,
        title: '加载失败',
        subtitle: '请检查网络连接后重试',
        actionLabel: '重试',
        onAction: onRetry,
      );

  /// 搜索无结果状态
  static Widget noSearchResults({
    String? keyword,
  }) =>
      AppEmptyState(
        icon: Icons.search_off,
        title: '未找到相关结果',
        subtitle: keyword != null ? '没有找到与"$keyword"相关的内容' : null,
      );

  /// 网络错误状态
  static Widget networkError({
    VoidCallback? onRetry,
  }) =>
      AppEmptyState(
        icon: Icons.wifi_off,
        title: '网络连接失败',
        subtitle: '请检查网络设置后重试',
        actionLabel: '重试',
        onAction: onRetry,
      );

  /// AI解析失败状态
  static Widget aiParseError({
    VoidCallback? onRetry,
  }) =>
      AppEmptyState(
        icon: Icons.smart_toy_outlined,
        title: 'AI走神了',
        subtitle: '请重试或手动输入',
        actionLabel: '重试',
        onAction: onRetry,
      );
}
