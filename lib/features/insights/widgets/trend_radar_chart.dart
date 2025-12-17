import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:your_finance_flutter/core/theme/app_design_tokens.dart';
import 'package:your_finance_flutter/features/insights/models/trend_data.dart';

/// Trend Radar Chart Widget
///
/// Displays spending trends with clean bar chart visualization:
/// - No grid, no borders
/// - 12px bars with rounded caps
/// - Gradient colors
/// - Touch feedback (red selection state)
/// - Empty state handling
/// - Zero values show as tiny 2px grey bars
///
/// Usage:
/// ```dart
/// TrendRadarChart(
///   trendData: [
///     TrendData(date: DateTime.now(), amount: 1200.0, dayLabel: 'Mon'),
///     TrendData(date: DateTime.now().add(Duration(days: 1)), amount: 800.0, dayLabel: 'Tue'),
///   ],
/// )
/// ```
class TrendRadarChart extends StatefulWidget {
  final List<TrendData>? trendData;

  const TrendRadarChart({
    super.key,
    this.trendData,
  });

  @override
  State<TrendRadarChart> createState() => _TrendRadarChartState();
}

class _TrendRadarChartState extends State<TrendRadarChart> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    final data = widget.trendData ?? [];

    // Handle empty data case
    if (data.isEmpty) {
      return _buildEmptyState(context);
    }

    // Ensure we have at least 7 days of data (pad with zeros if needed)
    final chartData = _prepareChartData(data);

    return AspectRatio(
      aspectRatio: 2.0, // Wider aspect ratio for trend chart
      child: BarChart(
        BarChartData(
          barGroups: chartData.asMap().entries.map((entry) {
            final index = entry.key;
            final value = entry.value.amount;
            final isTouched = index == _touchedIndex;

            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: value,
                  width: 12, // 12px bar width
                  color: _getBarColor(value, isTouched, context),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(2),
                    topRight: Radius.circular(2),
                  ),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: _getMaxValue(chartData),
                    color: AppDesignTokens.inputFill(context)
                        .withValues(alpha: 0.3),
                  ),
                ),
              ],
            );
          }).toList(),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() < chartData.length) {
                    return Text(
                      chartData[value.toInt()].dayLabel,
                      style: AppDesignTokens.caption(context),
                    );
                  }
                  return const Text('');
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: false, // Hide Y axis labels for clean look
              ),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false), // No borders
          gridData: FlGridData(show: false), // No grid
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: AppDesignTokens.surface(context),
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final data = chartData[groupIndex];
                return BarTooltipItem(
                  '${data.dayLabel}: ${_formatAmount(data.amount)}',
                  AppDesignTokens.body(context),
                );
              },
            ),
            touchCallback: (event, response) {
              if (response?.spot != null) {
                setState(() {
                  _touchedIndex = response!.spot!.touchedBarGroupIndex;
                });
              } else {
                setState(() {
                  _touchedIndex = null;
                });
              }
            },
          ),
        ),
      ),
    );
  }

  String _formatAmount(double amount) {
    // Use the same formatting as the app theme
    return '¥${amount.toStringAsFixed(0)}';
  }

  List<TrendData> _prepareChartData(List<TrendData> data) {
    if (data.length >= 7) {
      // Take the most recent 7 days
      return data.take(7).toList();
    } else {
      // Pad with zero values to show all 7 days
      final result = List<TrendData>.from(data);
      final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

      for (int i = data.length; i < 7; i++) {
        result.add(TrendData(
          date: DateTime.now().add(Duration(days: i - data.length)),
          amount: 0.0,
          dayLabel: days[i],
        ));
      }

      return result;
    }
  }

  double _getMaxValue(List<TrendData> data) {
    final maxValue = data.map((d) => d.amount).reduce((a, b) => a > b ? a : b);
    return maxValue > 0
        ? maxValue * 1.2
        : 100.0; // Add 20% padding, or 100 if all zeros
  }

  Color _getBarColor(double value, bool isTouched, BuildContext context) {
    if (isTouched) {
      return AppDesignTokens.amountNegativeColor(
          context); // Red for touched state
    }

    if (value == 0) {
      return Colors.grey.withValues(alpha: 0.5); // Grey for zero values
    }

    // Gradient-like color based on value
    final baseColor = AppDesignTokens.amountPositiveColor(context);
    final intensity =
        (value / _getMaxValue(widget.trendData ?? [])).clamp(0.3, 1.0);
    return baseColor.withValues(alpha: intensity.toDouble());
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      height: 200,
      alignment: Alignment.center,
      child: Text(
        'No trend data available',
        style: AppDesignTokens.caption(context).copyWith(
          color: AppDesignTokens.secondaryText(context),
        ),
      ),
    );
  }
}
