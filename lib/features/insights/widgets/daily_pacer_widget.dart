import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:your_finance_flutter/core/theme/app_design_tokens.dart';
import 'package:your_finance_flutter/features/insights/models/daily_cap.dart';
import 'package:your_finance_flutter/features/insights/models/micro_insight.dart';

/// Daily spending progress widget with AI-powered micro-insights
class DailyPacerWidget extends StatelessWidget {
  const DailyPacerWidget({
    super.key,
    required this.dailyCap,
    this.onTap,
  });

  final DailyCap dailyCap;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(AppDesignTokens.spacing16),
        decoration: BoxDecoration(
          color: AppDesignTokens.surface(context),
          borderRadius: BorderRadius.circular(12.0), // radiusMedium
          boxShadow: [
            AppDesignTokens.primaryShadow(context),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '今日消费进度',
                  style: AppDesignTokens.headline(context),
                ),
                _buildStatusIndicator(context),
              ],
            ),
            SizedBox(height: AppDesignTokens.spacing12),

            // Progress bar
            _buildProgressBar(context),
            const SizedBox(height: 12),

            // Spending details
            _buildSpendingDetails(context),
            const SizedBox(height: 16),

            // AI Micro-insight
            if (dailyCap.latestInsight != null)
              _buildMicroInsight(context, dailyCap.latestInsight!),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(BuildContext context) {
    final color = _getStatusColor(context);
    final icon = _getStatusIcon();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          PhosphorIcon(
            icon,
            size: 16,
            color: color,
          ),
          SizedBox(width: AppDesignTokens.spacing4),
          Text(
            _getStatusText(),
            style: AppDesignTokens.caption(context).copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    final progress = dailyCap.percentage.clamp(0.0, 1.0);
    final color = _getStatusColor(context);

    return Container(
      height: 24,
      decoration: BoxDecoration(
        color: AppDesignTokens.inputFill(context),
        borderRadius: BorderRadius.circular(6.0),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6.0),
        child: LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.transparent,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ),
    );
  }

  Widget _buildSpendingDetails(BuildContext context) {
    final spent = dailyCap.currentSpending;
    final remaining = dailyCap.remainingAmount;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '已消费 ¥${spent.toStringAsFixed(0)}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
          ),
        ),
        Text(
          remaining > 0
              ? '剩余 ¥${remaining.toStringAsFixed(0)}'
              : '超支 ¥${remaining.abs().toStringAsFixed(0)}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: remaining > 0
                ? AppDesignTokens.successColor(context)
                : AppDesignTokens.accentColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMicroInsight(BuildContext context, MicroInsight insight) {
    final color = _getSentimentColor(context, insight.sentiment);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(6.0),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PhosphorIcon(
                _getSentimentIcon(insight.sentiment),
                size: 16,
                color: color,
              ),
              SizedBox(width: AppDesignTokens.spacing8),
              Text(
                'AI 建议',
                style: AppDesignTokens.caption(context).copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: AppDesignTokens.spacing8),
          Text(
            insight.message,
            style: AppDesignTokens.body(context),
          ),
          if (insight.actions.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: insight.actions.map((action) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: Text(
                    action,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(BuildContext context) {
    switch (dailyCap.status) {
      case CapStatus.safe:
        return AppDesignTokens.successColor(context);
      case CapStatus.warning:
        return AppDesignTokens.accentColor; // warning color
      case CapStatus.danger:
        return AppDesignTokens.accentColor; // danger color
    }
  }

  PhosphorIconData _getStatusIcon() {
    switch (dailyCap.status) {
      case CapStatus.safe:
        return PhosphorIconsRegular.smiley;
      case CapStatus.warning:
        return PhosphorIconsRegular.warning;
      case CapStatus.danger:
        return PhosphorIconsRegular.warningCircle;
    }
  }

  String _getStatusText() {
    switch (dailyCap.status) {
      case CapStatus.safe:
        return '安全';
      case CapStatus.warning:
        return '注意';
      case CapStatus.danger:
        return '超支';
    }
  }

  Color _getSentimentColor(BuildContext context, Sentiment sentiment) {
    switch (sentiment) {
      case Sentiment.positive:
        return AppDesignTokens.successColor(context);
      case Sentiment.neutral:
        return Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7) ?? Colors.grey;
      case Sentiment.negative:
        return AppDesignTokens.accentColor;
    }
  }

  PhosphorIconData _getSentimentIcon(Sentiment sentiment) {
    switch (sentiment) {
      case Sentiment.positive:
        return PhosphorIconsRegular.thumbsUp;
      case Sentiment.neutral:
        return PhosphorIconsRegular.info;
      case Sentiment.negative:
        return PhosphorIconsRegular.warning;
    }
  }
}
