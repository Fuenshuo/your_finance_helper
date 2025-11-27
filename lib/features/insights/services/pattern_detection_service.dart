import 'dart:math';

import 'package:your_finance_flutter/features/insights/models/weekly_anomaly.dart';

/// Service for detecting spending patterns and anomalies in weekly data
class PatternDetectionService {
  PatternDetectionService._();

  static final PatternDetectionService _instance = PatternDetectionService._();

  static PatternDetectionService get instance => _instance;

  /// Analyze weekly spending data and detect anomalies
  Future<List<WeeklyAnomaly>> detectWeeklyAnomalies(
    List<double> dailySpending,
    DateTime weekStart,
    List<String> categoryBreakdown,
  ) async {
    if (dailySpending.length != 7) {
      throw ArgumentError('Weekly analysis requires exactly 7 days of data');
    }

    final anomalies = <WeeklyAnomaly>[];

    // Calculate baseline (average of non-peak days)
    final sortedSpending = List<double>.from(dailySpending)..sort();
    final baseline = (sortedSpending[0] + sortedSpending[1] + sortedSpending[2] +
                     sortedSpending[3] + sortedSpending[4]) / 5;

    // Detect anomalies (both high and low spending)
    for (var i = 0; i < dailySpending.length; i++) {
      final spending = dailySpending[i];
      final rawDeviation = (spending - baseline) / baseline;
      final absDeviation = rawDeviation.abs();

      if (absDeviation >= 0.5) { // 50% deviation threshold (either direction)
        final severity = _calculateSeverity(absDeviation);
        final isHighSpending = spending > baseline;
        final reason = _generateAnomalyReason(
          spending,
          baseline,
          rawDeviation,
          categoryBreakdown.isNotEmpty ? categoryBreakdown[i] : '未知分类',
          isHighSpending,
        );

        anomalies.add(WeeklyAnomaly(
          id: 'weekly_anomaly_${weekStart.toIso8601String()}_$i',
          weekStart: weekStart,
          anomalyDate: weekStart.add(Duration(days: i)),
          expectedAmount: baseline,
          actualAmount: spending,
          deviation: rawDeviation, // Keep the sign for proper deviation tracking
          reason: reason,
          severity: severity,
          categories: _extractCategories(categoryBreakdown, i),
        ));
      }
    }

    return anomalies;
  }

  /// Calculate anomaly severity based on deviation percentage
  AnomalySeverity _calculateSeverity(double deviation) {
    if (deviation >= 1.0) return AnomalySeverity.high; // 100%+ deviation
    if (deviation >= 0.5) return AnomalySeverity.medium; // 50-99% deviation
    return AnomalySeverity.low; // 15-49% deviation
  }

  /// Generate human-readable explanation for the anomaly
  String _generateAnomalyReason(
    double actual,
    double expected,
    double deviation,
    String category,
    bool isHigh,
  ) {
    final percent = (deviation.abs() * 100).round();
    final difference = (actual - expected).abs();

    if (isHigh) {
      if (percent >= 100) {
        return '$category 开支激增 $percent%，超出预期 ¥${difference.toStringAsFixed(0)}。可能是特殊事件或消费习惯变化。';
      } else {
        return '$category 支出偏高 $percent%，比平时多 ¥${difference.toStringAsFixed(0)}。建议检查是否有遗漏的预算项目。';
      }
    } else {
      return '$category 支出偏低 $percent%，比平时少 ¥${difference.toStringAsFixed(0)}。良好的节约表现！';
    }
  }

  /// Extract categories for the specific day
  List<String> _extractCategories(List<String> categoryBreakdown, int dayIndex) {
    if (categoryBreakdown.isEmpty || dayIndex >= categoryBreakdown.length) {
      return ['未知分类'];
    }

    // Parse category string (assuming format like "餐饮:300,购物:150")
    final categories = categoryBreakdown[dayIndex]
        .split(',')
        .map((cat) => cat.split(':')[0])
        .where((cat) => cat.isNotEmpty)
        .toList();

    return categories.isNotEmpty ? categories : ['未知分类'];
  }

  /// Calculate weekly spending statistics
  Map<String, double> calculateWeeklyStats(List<double> dailySpending) {
    if (dailySpending.isEmpty) return {};

    final total = dailySpending.reduce((a, b) => a + b);
    final average = total / dailySpending.length;
    final maxValue = dailySpending.reduce((a, b) => a > b ? a : b);
    final minValue = dailySpending.reduce((a, b) => a < b ? a : b);

    // Calculate variance
    final variance = dailySpending.map((x) => pow(x - average, 2)).reduce((a, b) => a + b) / dailySpending.length;

    return {
      'total': total,
      'average': average,
      'max': maxValue,
      'min': minValue,
      'variance': variance,
      'standardDeviation': sqrt(variance),
    };
  }

  /// Identify spending patterns (weekend spikes, mid-week lows, etc.)
  Map<String, dynamic> identifyPatterns(List<double> dailySpending) {
    final patterns = <String, dynamic>{};

    if (dailySpending.length < 7) return patterns;

    // Weekend vs weekday comparison
    final weekdayAvg = (dailySpending[0] + dailySpending[1] + dailySpending[2] +
                       dailySpending[3] + dailySpending[4]) / 5;
    final weekendAvg = (dailySpending[5] + dailySpending[6]) / 2;

    patterns['weekendMultiplier'] = weekendAvg / weekdayAvg;

    // Peak day identification
    final maxIndex = dailySpending.indexOf(dailySpending.reduce(max));
    patterns['peakDay'] = maxIndex; // 0=Monday, 6=Sunday

    // Trend analysis (simple linear trend)
    final trend = _calculateTrend(dailySpending);
    patterns['spendingTrend'] = trend; // positive = increasing, negative = decreasing

    return patterns;
  }

  /// Calculate simple linear trend
  double _calculateTrend(List<double> data) {
    if (data.length < 2) return 0.0;

    final n = data.length;
    final sumX = (n * (n - 1)) / 2.0;
    final sumY = data.reduce((a, b) => a + b);
    final sumXY = data.asMap().entries.map((e) => e.key * e.value).reduce((a, b) => a + b);
    final sumXX = data.asMap().entries.map((e) => e.key * e.key).reduce((a, b) => a + b);

    final slope = (n * sumXY - sumX * sumY) / (n * sumXX - sumX * sumX);
    return slope;
  }
}
