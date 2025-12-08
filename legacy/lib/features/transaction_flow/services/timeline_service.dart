import 'dart:math';

import 'package:your_finance_flutter/core/models/transaction.dart';

/// 时间轴服务
/// 管理周期性交易的自动执行时间
class TimelineService {
  factory TimelineService() => _instance;
  TimelineService._internal();
  static final TimelineService _instance = TimelineService._internal();

  /// 获取指定日期范围内的周期性交易计划
  List<TimelineEvent> getTimelineEvents({
    required DateTime startDate,
    required DateTime endDate,
    required List<Transaction> recurringTransactions,
  }) {
    final events = <TimelineEvent>[];

    for (final transaction in recurringTransactions) {
      if (!transaction.isRecurring || transaction.recurringRule == null) {
        continue;
      }

      final recurringDates = _generateRecurringDates(
        startDate: startDate,
        endDate: endDate,
        baseDate: transaction.date,
        rule: transaction.recurringRule!,
      );

      for (final date in recurringDates) {
        events.add(
          TimelineEvent(
            id: '${transaction.id}_${date.millisecondsSinceEpoch}',
            transaction: transaction,
            scheduledDate: date,
            amount: transaction.amount,
            type: transaction.type ?? TransactionType.income,
            description: transaction.description,
            category: transaction.category,
          ),
        );
      }
    }

    // 按日期排序
    events.sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));

    return events;
  }

  /// 生成周期性日期
  List<DateTime> _generateRecurringDates({
    required DateTime startDate,
    required DateTime endDate,
    required DateTime baseDate,
    required String rule,
  }) {
    final dates = <DateTime>[];
    var currentDate = _getNextOccurrence(baseDate, rule, startDate);

    while (currentDate.isBefore(endDate) ||
        currentDate.isAtSameMomentAs(endDate)) {
      if (currentDate.isAfter(startDate) ||
          currentDate.isAtSameMomentAs(startDate)) {
        dates.add(currentDate);
      }
      currentDate = _getNextOccurrence(
        currentDate,
        rule,
        currentDate.add(const Duration(days: 1)),
      );
    }

    return dates;
  }

  /// 获取下一个执行日期
  DateTime _getNextOccurrence(
    DateTime baseDate,
    String rule,
    DateTime fromDate,
  ) {
    switch (rule.toLowerCase()) {
      case 'daily':
        return fromDate;
      case 'weekly':
        final daysUntilNext = (7 - (fromDate.weekday - baseDate.weekday)) % 7;
        return fromDate
            .add(Duration(days: daysUntilNext == 0 ? 7 : daysUntilNext));
      case 'monthly':
        return DateTime(fromDate.year, fromDate.month, baseDate.day);
      case 'yearly':
        return DateTime(fromDate.year, baseDate.month, baseDate.day);
      default:
        return fromDate;
    }
  }

  /// 获取指定日期的资产预测
  AssetPrediction getAssetPrediction({
    required DateTime date,
    required double currentAssets,
    required List<TimelineEvent> events,
  }) {
    final dayEvents = events
        .where(
          (event) =>
              event.scheduledDate.year == date.year &&
              event.scheduledDate.month == date.month &&
              event.scheduledDate.day == date.day,
        )
        .toList();

    var totalIncome = 0.0;
    var totalExpense = 0.0;

    for (final event in dayEvents) {
      if (event.type == TransactionType.income) {
        totalIncome += event.amount;
      } else {
        totalExpense += event.amount;
      }
    }

    final netChange = totalIncome - totalExpense;
    final predictedAssets = currentAssets + netChange;

    return AssetPrediction(
      date: date,
      currentAssets: currentAssets,
      predictedAssets: predictedAssets,
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      netChange: netChange,
      events: dayEvents,
    );
  }

  /// 获取指定月份的所有预测
  List<AssetPrediction> getMonthlyPredictions({
    required DateTime month,
    required double currentAssets,
    required List<TimelineEvent> events,
  }) {
    final predictions = <AssetPrediction>[];
    final endOfMonth = DateTime(month.year, month.month + 1, 0);

    var runningAssets = currentAssets;

    for (var day = 1; day <= endOfMonth.day; day++) {
      final date = DateTime(month.year, month.month, day);
      final prediction = getAssetPrediction(
        date: date,
        currentAssets: runningAssets,
        events: events,
      );

      predictions.add(prediction);
      runningAssets = prediction.predictedAssets;
    }

    return predictions;
  }

  /// 获取资产波动趋势
  AssetTrend getAssetTrend({
    required DateTime startDate,
    required DateTime endDate,
    required double currentAssets,
    required List<TimelineEvent> events,
  }) {
    final predictions = <AssetPrediction>[];
    var runningAssets = currentAssets;

    for (var date = startDate;
        date.isBefore(endDate) || date.isAtSameMomentAs(endDate);
        date = date.add(const Duration(days: 1))) {
      final prediction = getAssetPrediction(
        date: date,
        currentAssets: runningAssets,
        events: events,
      );

      predictions.add(prediction);
      runningAssets = prediction.predictedAssets;
    }

    if (predictions.isEmpty) {
      return AssetTrend(
        startDate: startDate,
        endDate: endDate,
        startAssets: currentAssets,
        endAssets: currentAssets,
        minAssets: currentAssets,
        maxAssets: currentAssets,
        totalIncome: 0,
        totalExpense: 0,
        netChange: 0,
        volatility: 0,
        predictions: [],
      );
    }

    final startAssets = predictions.first.predictedAssets;
    final endAssets = predictions.last.predictedAssets;
    final minAssets = predictions
        .map((p) => p.predictedAssets)
        .reduce((a, b) => a < b ? a : b);
    final maxAssets = predictions
        .map((p) => p.predictedAssets)
        .reduce((a, b) => a > b ? a : b);
    final totalIncome = predictions.fold(0.0, (sum, p) => sum + p.totalIncome);
    final totalExpense =
        predictions.fold(0.0, (sum, p) => sum + p.totalExpense);
    final netChange = totalIncome - totalExpense;

    // 计算波动率（标准差）
    final mean = predictions.fold(0.0, (sum, p) => sum + p.predictedAssets) /
        predictions.length;
    final variance = predictions.fold(
          0.0,
          (sum, p) =>
              sum + (p.predictedAssets - mean) * (p.predictedAssets - mean),
        ) /
        predictions.length.toDouble();
    final volatility = variance > 0 ? sqrt(variance) : 0;

    return AssetTrend(
      startDate: startDate,
      endDate: endDate,
      startAssets: startAssets,
      endAssets: endAssets,
      minAssets: minAssets,
      maxAssets: maxAssets,
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      netChange: netChange,
      volatility: volatility.toDouble(),
      predictions: predictions,
    );
  }
}

/// 时间轴事件
class TimelineEvent {
  TimelineEvent({
    required this.id,
    required this.transaction,
    required this.scheduledDate,
    required this.amount,
    required this.type,
    required this.description,
    required this.category,
  });
  final String id;
  final Transaction transaction;
  final DateTime scheduledDate;
  final double amount;
  final TransactionType type;
  final String description;
  final TransactionCategory category;
}

/// 资产预测
class AssetPrediction {
  AssetPrediction({
    required this.date,
    required this.currentAssets,
    required this.predictedAssets,
    required this.totalIncome,
    required this.totalExpense,
    required this.netChange,
    required this.events,
  });
  final DateTime date;
  final double currentAssets;
  final double predictedAssets;
  final double totalIncome;
  final double totalExpense;
  final double netChange;
  final List<TimelineEvent> events;
}

/// 资产趋势
class AssetTrend {
  AssetTrend({
    required this.startDate,
    required this.endDate,
    required this.startAssets,
    required this.endAssets,
    required this.minAssets,
    required this.maxAssets,
    required this.totalIncome,
    required this.totalExpense,
    required this.netChange,
    required this.volatility,
    required this.predictions,
  });
  final DateTime startDate;
  final DateTime endDate;
  final double startAssets;
  final double endAssets;
  final double minAssets;
  final double maxAssets;
  final double totalIncome;
  final double totalExpense;
  final double netChange;
  final double volatility;
  final List<AssetPrediction> predictions;

  /// 获取趋势方向
  TrendDirection get direction {
    if (endAssets > startAssets * 1.01) return TrendDirection.up;
    if (endAssets < startAssets * 0.99) return TrendDirection.down;
    return TrendDirection.stable;
  }

  /// 获取风险等级
  RiskLevel get riskLevel {
    if (volatility > startAssets * 0.1) return RiskLevel.high;
    if (volatility > startAssets * 0.05) return RiskLevel.medium;
    return RiskLevel.low;
  }
}

/// 趋势方向
enum TrendDirection {
  up, // 上升
  down, // 下降
  stable, // 稳定
}

/// 风险等级
enum RiskLevel {
  low, // 低风险
  medium, // 中风险
  high, // 高风险
}
