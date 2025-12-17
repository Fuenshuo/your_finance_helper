import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:your_finance_flutter/core/theme/app_design_tokens.dart';
import 'package:your_finance_flutter/features/insights/models/weekly_anomaly.dart';

/// Floating insight bubble that points to anomalies on charts
class InsightBubble extends StatelessWidget {
  const InsightBubble({
    super.key,
    required this.anomaly,
    required this.targetPosition,
    required this.bubblePosition,
    this.onTap,
    this.maxWidth = 280,
  });

  final WeeklyAnomaly anomaly;
  final Offset targetPosition; // Position to point to
  final Offset bubblePosition; // Position of the bubble
  final VoidCallback? onTap;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = AppDesignTokens.surface(context);
    final shadowColor = Colors.black.withValues(alpha: 0.1);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Pointer line from bubble to target
        Positioned(
          left: bubblePosition.dx + maxWidth / 2,
          top: bubblePosition.dy + 60, // Below bubble
          child: Container(
            width: 2,
            height: (targetPosition.dy - (bubblePosition.dy + 60)).abs(),
            color: _getSeverityColor(context).withValues(alpha: 0.6),
          ),
        ),

        // Bubble
        Positioned(
          left: bubblePosition.dx,
          top: bubblePosition.dy,
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              constraints: BoxConstraints(maxWidth: maxWidth),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getSeverityColor(context).withValues(alpha: 0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header with icon and title
                  Row(
                    children: [
                      PhosphorIcon(
                        _getSeverityIcon(),
                        size: 20,
                        color: _getSeverityColor(context),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _getBubbleTitle(),
                        style: AppDesignTokens.headline(context).copyWith(
                          fontSize: 16,
                          color: _getSeverityColor(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Anomaly explanation
                  Text(
                    anomaly.reason,
                    style: AppDesignTokens.body(context).copyWith(
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),

                  if (anomaly.categories.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    // Category tags
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: anomaly.categories.map((category) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getSeverityColor(context)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            category,
                            style: AppDesignTokens.caption(context).copyWith(
                              color: _getSeverityColor(context),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],

                  // Action hint
                  if (onTap != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        PhosphorIcon(
                          PhosphorIconsRegular.arrowUpRight,
                          size: 14,
                          color: AppDesignTokens.secondaryText(context),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '点击查看详情',
                          style: AppDesignTokens.caption(context).copyWith(
                            color: AppDesignTokens.secondaryText(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),

        // Animated pulse effect for high severity
        if (anomaly.severity == AnomalySeverity.high)
          Positioned(
            left: bubblePosition.dx - 4,
            top: bubblePosition.dy - 4,
            child: Container(
              width: maxWidth + 8,
              height: 80, // Approximate bubble height
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _getSeverityColor(context).withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(seconds: 2),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: (1 - value) * 0.5,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _getSeverityColor(context)
                              .withValues(alpha: (1 - value) * 0.5),
                          width: 2 * (1 - value),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }

  Color _getSeverityColor(BuildContext context) {
    switch (anomaly.severity) {
      case AnomalySeverity.low:
        return AppDesignTokens.successColor(context);
      case AnomalySeverity.medium:
        return AppDesignTokens.warningColor;
      case AnomalySeverity.high:
        return AppDesignTokens.accentColor;
    }
  }

  PhosphorIconData _getSeverityIcon() {
    switch (anomaly.severity) {
      case AnomalySeverity.low:
        return PhosphorIconsRegular.trendDown;
      case AnomalySeverity.medium:
        return PhosphorIconsRegular.warning;
      case AnomalySeverity.high:
        return PhosphorIconsRegular.warningCircle;
    }
  }

  String _getBubbleTitle() {
    switch (anomaly.severity) {
      case AnomalySeverity.low:
        return '消费偏低';
      case AnomalySeverity.medium:
        return '异常支出';
      case AnomalySeverity.high:
        return '重大异常';
    }
  }
}

/// Convenience widget for positioning insight bubbles relative to chart elements
class InsightBubbleOverlay extends StatelessWidget {
  const InsightBubbleOverlay({
    super.key,
    required this.anomalies,
    required this.chartSize,
    required this.dayToPosition,
    this.onAnomalyTap,
  });

  final List<WeeklyAnomaly> anomalies;
  final Size chartSize;
  final Offset Function(int dayIndex) dayToPosition;
  final void Function(WeeklyAnomaly anomaly)? onAnomalyTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: anomalies.map((anomaly) {
        final dayIndex =
            anomaly.anomalyDate.difference(anomaly.weekStart).inDays;
        final targetPosition = dayToPosition(dayIndex);

        // Position bubble above the target point
        final bubblePosition = Offset(
          (targetPosition.dx - 140).clamp(
              10, chartSize.width - 290), // Center horizontally with margins
          targetPosition.dy - 120, // Above the point
        );

        return InsightBubble(
          anomaly: anomaly,
          targetPosition: targetPosition,
          bubblePosition: bubblePosition,
          onTap: onAnomalyTap != null ? () => onAnomalyTap!(anomaly) : null,
        );
      }).toList(),
    );
  }
}
