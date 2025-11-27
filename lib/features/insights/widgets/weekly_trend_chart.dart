import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:your_finance_flutter/core/services/insight_service.dart';
import 'package:your_finance_flutter/core/theme/app_design_tokens.dart';

/// Apple Health-style weekly spending trend chart using fl_chart
class WeeklyTrendChart extends StatelessWidget {
  const WeeklyTrendChart({
    required this.weeklyInsight,
    super.key,
    this.height = 280,
    this.showThinking = false,
  });

  final WeeklyInsight weeklyInsight;
  final double height;
  final bool showThinking;

  @override
  Widget build(BuildContext context) {
    final dailySpending = [
      weeklyInsight.monday,
      weeklyInsight.tuesday,
      weeklyInsight.wednesday,
      weeklyInsight.thursday,
      weeklyInsight.friday,
      weeklyInsight.saturday,
      weeklyInsight.sunday,
    ];

    final maxValue = dailySpending.reduce((a, b) => a > b ? a : b);

    return Container(
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppDesignTokens.surface(context),
        borderRadius:
            BorderRadius.circular(AppDesignTokens.radiusMedium(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Weekly Spending',
            style: AppDesignTokens.headline(context),
          ),
          const SizedBox(height: 8),
          Text(
            'Daily spending trends',
            style: AppDesignTokens.caption(context),
          ),
          const SizedBox(height: 16),

          // Chart - use Expanded to fill remaining space
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: BarChart(
                _buildBarChartData(dailySpending, maxValue, context),
                swapAnimationDuration: const Duration(milliseconds: 800),
                swapAnimationCurve: Curves.easeInOutCubic,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Legend - align with chart bars
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLegendItem(context, 'Mon', 0),
                _buildLegendItem(context, 'Tue', 1),
                _buildLegendItem(context, 'Wed', 2),
                _buildLegendItem(context, 'Thu', 3),
                _buildLegendItem(context, 'Fri', 4),
                _buildLegendItem(context, 'Sat', 5),
                _buildLegendItem(context, 'Sun', 6),
              ],
            ),
          ),

          // Anomalies summary - compact version
          if (weeklyInsight.anomalies.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppDesignTokens.amountNegativeColor(context)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Anomalies: ${weeklyInsight.anomalies.length}',
                style: AppDesignTokens.microCaption(context).copyWith(
                  color: AppDesignTokens.amountNegativeColor(context),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }

  BarChartData _buildBarChartData(
    List<double> dailySpending,
    double maxValue,
    BuildContext context,
  ) =>
      BarChartData(
        // No borders - Apple Health style
        borderData: FlBorderData(show: false),

        // No grid lines
        gridData: const FlGridData(show: false),

        // Remove titles
        titlesData: const FlTitlesData(show: false),

        // Bar groups
        barGroups: List.generate(dailySpending.length, (index) {
          final spending = dailySpending[index];
          final isAnomaly = weeklyInsight.anomalies.any(
            (a) => a.anomalyDate.weekday - 1 == index,
          );

          final normalizedHeight =
              maxValue > 0 ? (spending / maxValue) * 8.0 : 0.0;

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: normalizedHeight,
                color: isAnomaly
                    ? AppDesignTokens.amountNegativeColor(context)
                    : AppDesignTokens.amountPositiveColor(context),
                width: 20,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(6)),
                gradient: LinearGradient(
                  colors: [
                    if (isAnomaly)
                      AppDesignTokens.amountNegativeColor(context)
                    else
                      AppDesignTokens.amountPositiveColor(context),
                    (isAnomaly
                            ? AppDesignTokens.amountNegativeColor(context)
                            : AppDesignTokens.amountPositiveColor(context))
                        .withValues(alpha: 0.5),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ],
          );
        }),

        // Custom tooltip
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor:
                AppDesignTokens.surface(context).withValues(alpha: 0.95),
            tooltipPadding: const EdgeInsets.all(12),
            tooltipMargin: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final amount = dailySpending[group.x];
              final isAnomaly = weeklyInsight.anomalies.any(
                (a) => a.anomalyDate.weekday - 1 == group.x,
              );

              return BarTooltipItem(
                '¥${amount.toStringAsFixed(0)}',
                AppDesignTokens.body(context).copyWith(
                  color: isAnomaly
                      ? AppDesignTokens.amountNegativeColor(context)
                      : AppDesignTokens.amountPositiveColor(context),
                  fontWeight: FontWeight.w600,
                ),
              );
            },
          ),
        ),

        // Spacing - align bars with legend below
        groupsSpace: 4,
        alignment: BarChartAlignment.center,
      );

  Widget _buildLegendItem(BuildContext context, String label, int index) =>
      Column(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppDesignTokens.amountPositiveColor(context),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppDesignTokens.microCaption(context),
          ),
        ],
      );
}
