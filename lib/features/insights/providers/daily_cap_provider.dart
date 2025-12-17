import 'package:flutter/foundation.dart';
import 'package:your_finance_flutter/core/utils/performance_monitor.dart';
import 'package:your_finance_flutter/features/insights/models/daily_cap.dart';
import 'package:your_finance_flutter/features/insights/models/micro_insight.dart';

/// Provider for daily spending cap and micro-insights management
class DailyCapProvider with ChangeNotifier {

  DailyCap? _dailyCap;
  MicroInsight? _latestInsight;
  bool _isLoading = false;
  String? _error;

  // Getters
  DailyCap? get dailyCap => _dailyCap;
  MicroInsight? get latestInsight => _latestInsight;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Initialize daily cap for current date
  Future<void> initializeDailyCap() async {
    return PerformanceMonitor.monitorBuild(
      'DailyCapProvider.initializeDailyCap',
      () async {
        try {
          _isLoading = true;
          _error = null;
          notifyListeners();

          // Calculate daily budget reference (monthly budget - fixed expenses) / 30
          // This would be implemented based on user's monthly budget
          const double dailyReference =
              200.0; // Placeholder - implement real calculation

          _dailyCap = DailyCap(
            id: 'daily_cap_${DateTime.now().toIso8601String().split('T').first}',
            date: DateTime.now(),
            referenceAmount: dailyReference,
            currentSpending: 0.0, // Calculate from transactions
            percentage: 0.0,
            status: CapStatus.safe,
          );

          await _generateInitialInsight();
        } catch (e) {
          _error = e.toString();
        } finally {
          _isLoading = false;
          notifyListeners();
        }
      },
    );
  }

  /// Update daily cap when transactions change
  Future<void> updateDailySpending(double newSpending) async {
    return PerformanceMonitor.monitorBuild(
      'DailyCapProvider.updateDailySpending',
      () async {
        if (_dailyCap == null) return;

        try {
          final updatedCap = _dailyCap!.copyWith(
            currentSpending: newSpending,
            percentage: newSpending / _dailyCap!.referenceAmount,
            status: _calculateStatus(newSpending / _dailyCap!.referenceAmount),
          );

          _dailyCap = updatedCap;
          await _generateMicroInsight();
          notifyListeners();
        } catch (e) {
          _error = e.toString();
          notifyListeners();
        }
      },
    );
  }

  /// Generate initial insight for the day
  Future<void> _generateInitialInsight() async {
    if (_dailyCap == null) return;

    try {
      // Generate AI-powered initial insight
      _latestInsight = MicroInsight(
        id: 'initial_${_dailyCap!.id}',
        dailyCapId: _dailyCap!.id,
        generatedAt: DateTime.now(),
        sentiment: Sentiment.neutral,
        message: '新的一天开始了，保持良好的消费习惯！',
        actions: ['设置今日消费目标', '查看昨日消费总结'],
        trigger: InsightTrigger.timeCheck,
      );
    } catch (e) {
      // Fallback to basic insight if AI fails
      _latestInsight = MicroInsight(
        id: 'fallback_${_dailyCap!.id}',
        dailyCapId: _dailyCap!.id,
        generatedAt: DateTime.now(),
        sentiment: Sentiment.neutral,
        message: '今日消费目标：¥${_dailyCap!.referenceAmount.toStringAsFixed(0)}',
        actions: [],
        trigger: InsightTrigger.timeCheck,
      );
    }
  }

  /// Generate micro-insight based on current spending
  Future<void> _generateMicroInsight() async {
    if (_dailyCap == null) return;

    try {
      final spending = _dailyCap!.currentSpending;
      final reference = _dailyCap!.referenceAmount;
      final percentage = spending / reference;

      String message;
      Sentiment sentiment;
      List<String> actions;

      if (percentage < 0.5) {
        sentiment = Sentiment.positive;
        message =
            '今日非常克制，比平时少花 ¥${((reference - spending) * 0.3).toStringAsFixed(0)}，攒了一杯咖啡钱。';
        actions = ['保持良好的消费习惯'];
      } else if (percentage < 0.8) {
        sentiment = Sentiment.neutral;
        message =
            '今日消费适中，还有 ¥${(reference - spending).toStringAsFixed(0)} 的预算空间。';
        actions = ['合理安排剩余预算'];
      } else if (percentage < 1.0) {
        sentiment = Sentiment.negative;
        message = '今日消费偏高，已使用 ${percentage.toStringAsFixed(1)} 的预算。';
        actions = ['注意控制后续消费', '查看大额消费明细'];
      } else {
        sentiment = Sentiment.negative;
        message =
            '今日预算超支 ¥${(spending - reference).toStringAsFixed(0)}，建议未来 3 天吃土平衡一下。';
        actions = ['分析超支原因', '调整明日消费计划', '查看节省建议'];
      }

      _latestInsight = MicroInsight(
        id: 'micro_${_dailyCap!.id}_${DateTime.now().millisecondsSinceEpoch}',
        dailyCapId: _dailyCap!.id,
        generatedAt: DateTime.now(),
        sentiment: sentiment,
        message: message,
        actions: actions,
        trigger: InsightTrigger.transactionAdded,
      );
    } catch (e) {
      _error = e.toString();
    }
  }

  /// Calculate cap status based on spending percentage
  CapStatus _calculateStatus(double percentage) {
    if (percentage < 0.5) return CapStatus.safe;
    if (percentage < 0.8) return CapStatus.warning;
    return CapStatus.danger;
  }

  /// Clear error state
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
