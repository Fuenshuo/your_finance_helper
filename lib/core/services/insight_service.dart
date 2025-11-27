// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:async';
import 'dart:math';

import 'package:equatable/equatable.dart';

/// Sentiment for the AI CFO commentary.
enum InsightSentiment {
  safe,
  warning,
  overload,
}

/// A minimal daily pacer insight.
class DailyInsight extends Equatable {
  const DailyInsight({
    required this.spent,
    required this.dailyBudget,
    required this.aiComment,
    required this.sentiment,
  });

  final double spent;
  final double dailyBudget;
  final String aiComment;
  final InsightSentiment sentiment;

  double get utilization => dailyBudget == 0 ? 0 : spent / dailyBudget;

  @override
  List<Object?> get props => [spent, dailyBudget, aiComment, sentiment];
}

/// Represents a single point inside the weekly insight sparkline.
class DailyPoint extends Equatable {
  const DailyPoint({
    required this.label,
    required this.amount,
  });

  final String label;
  final double amount;

  @override
  List<Object?> get props => [label, amount];
}

/// Seven day anomaly tracker.
class WeeklyInsight extends Equatable {
  const WeeklyInsight({
    required this.data,
    required this.averageSpend,
    required this.anomalyDate,
    required this.anomalyReason,
  });

  final List<DailyPoint> data;
  final double averageSpend;
  final String anomalyDate;
  final String anomalyReason;

  @override
  List<Object?> get props => [data, averageSpend, anomalyDate, anomalyReason];
}

/// Monthly CFO report snapshot.
class MonthlyInsight extends Equatable {
  const MonthlyInsight({
    required this.fixedCost,
    required this.flexibleCost,
    required this.score,
    required this.cfoReport,
  });

  final double fixedCost;
  final double flexibleCost;
  final double score;
  final String cfoReport;

  double get total => fixedCost + flexibleCost;
  double get fixedRatio => total == 0 ? 0 : fixedCost / total;

  @override
  List<Object?> get props => [fixedCost, flexibleCost, score, cfoReport];
}

/// Snapshot describing the Flux Loop state.
class InsightSnapshot<T> extends Equatable {
  const InsightSnapshot._({
    required this.isLoading,
    required this.generatedAt,
    this.data,
  });

  final bool isLoading;
  final DateTime? generatedAt;
  final T? data;

  bool get hasData => data != null;
  bool get isStale => isLoading && hasData;

  factory InsightSnapshot.loading({
    T? previous,
    DateTime? generatedAt,
  }) =>
      InsightSnapshot._(
        isLoading: true,
        generatedAt: generatedAt,
        data: previous,
      );

  factory InsightSnapshot.ready(
    T data, {
    DateTime? generatedAt,
  }) =>
      InsightSnapshot._(
        isLoading: false,
        generatedAt: generatedAt ?? DateTime.now(),
        data: data,
      );

  @override
  List<Object?> get props => [isLoading, generatedAt, data];
}

/// Contract for the Insight service.
abstract class InsightService {
  Stream<InsightSnapshot<DailyInsight>> dailyInsights();
  Stream<InsightSnapshot<WeeklyInsight>> weeklyInsights();
  Stream<InsightSnapshot<MonthlyInsight>> monthlyInsights();

  Future<void> refreshDay();
  Future<void> refreshWeek();
  Future<void> refreshMonth();
  Future<void> warmup();
  void dispose();
}

/// Mock implementation that simulates a remote AI CFO.
class MockInsightService implements InsightService {
  MockInsightService({
    this.minDelay = const Duration(milliseconds: 900),
    this.maxDelay = const Duration(milliseconds: 1600),
  });

  final Duration minDelay;
  final Duration maxDelay;

  final _random = Random();

  final _dailyController =
      StreamController<InsightSnapshot<DailyInsight>>.broadcast();
  final _weeklyController =
      StreamController<InsightSnapshot<WeeklyInsight>>.broadcast();
  final _monthlyController =
      StreamController<InsightSnapshot<MonthlyInsight>>.broadcast();

  DailyInsight? _cachedDaily;
  DateTime? _cachedDailyAt;
  WeeklyInsight? _cachedWeekly;
  DateTime? _cachedWeeklyAt;
  MonthlyInsight? _cachedMonthly;
  DateTime? _cachedMonthlyAt;

  bool _initialized = false;

  @override
  Stream<InsightSnapshot<DailyInsight>> dailyInsights() {
    _maybeStart();
    if (_cachedDaily != null) {
      _dailyController.add(
        InsightSnapshot.ready(
          _cachedDaily!,
          generatedAt: _cachedDailyAt,
        ),
      );
    } else {
      _dailyController.add(InsightSnapshot.loading());
    }
    return _dailyController.stream;
  }

  @override
  Stream<InsightSnapshot<WeeklyInsight>> weeklyInsights() {
    _maybeStart();
    if (_cachedWeekly != null) {
      _weeklyController.add(
        InsightSnapshot.ready(
          _cachedWeekly!,
          generatedAt: _cachedWeeklyAt,
        ),
      );
    } else {
      _weeklyController.add(InsightSnapshot.loading());
    }
    return _weeklyController.stream;
  }

  @override
  Stream<InsightSnapshot<MonthlyInsight>> monthlyInsights() {
    _maybeStart();
    if (_cachedMonthly != null) {
      _monthlyController.add(
        InsightSnapshot.ready(
          _cachedMonthly!,
          generatedAt: _cachedMonthlyAt,
        ),
      );
    } else {
      _monthlyController.add(InsightSnapshot.loading());
    }
    return _monthlyController.stream;
  }

  @override
  Future<void> refreshDay() async {
    _dailyController.add(
      InsightSnapshot.loading(
        previous: _cachedDaily,
        generatedAt: _cachedDailyAt,
      ),
    );
    await Future<void>.delayed(_randomDelay());
    _cachedDaily = _buildDailyInsight();
    _cachedDailyAt = DateTime.now();
    _dailyController.add(
      InsightSnapshot.ready(
        _cachedDaily!,
        generatedAt: _cachedDailyAt,
      ),
    );
  }

  @override
  Future<void> refreshWeek() async {
    _weeklyController.add(
      InsightSnapshot.loading(
        previous: _cachedWeekly,
        generatedAt: _cachedWeeklyAt,
      ),
    );
    await Future<void>.delayed(_randomDelay());
    _cachedWeekly = _buildWeeklyInsight();
    _cachedWeeklyAt = DateTime.now();
    _weeklyController.add(
      InsightSnapshot.ready(
        _cachedWeekly!,
        generatedAt: _cachedWeeklyAt,
      ),
    );
  }

  @override
  Future<void> refreshMonth() async {
    _monthlyController.add(
      InsightSnapshot.loading(
        previous: _cachedMonthly,
        generatedAt: _cachedMonthlyAt,
      ),
    );
    await Future<void>.delayed(_randomDelay());
    _cachedMonthly = _buildMonthlyInsight();
    _cachedMonthlyAt = DateTime.now();
    _monthlyController.add(
      InsightSnapshot.ready(
        _cachedMonthly!,
        generatedAt: _cachedMonthlyAt,
      ),
    );
  }

  @override
  Future<void> warmup() async {
    if (_initialized) {
      return;
    }
    _initialized = true;
    await Future.wait([
      refreshDay(),
      refreshWeek(),
      refreshMonth(),
    ]);
  }

  @override
  void dispose() {
    _dailyController.close();
    _weeklyController.close();
    _monthlyController.close();
  }

  void _maybeStart() {
    if (!_initialized) {
      warmup();
    }
  }

  Duration _randomDelay() {
    final delta = maxDelay.inMilliseconds - minDelay.inMilliseconds;
    if (delta <= 0) {
      return minDelay;
    }
    final jitter = _random.nextInt(delta);
    return Duration(milliseconds: minDelay.inMilliseconds + jitter);
  }

  DailyInsight _buildDailyInsight() {
    final baseSpent = 95 + _random.nextInt(60); // 95 - 154
    const dailyBudget = 200.0;
    const sentiments = InsightSentiment.values;
    final sentiment = sentiments[_random.nextInt(sentiments.length)];
    final comment = switch (sentiment) {
      InsightSentiment.safe => '今日非常克制，比平时少花 ¥50，攒了一杯咖啡钱。',
      InsightSentiment.warning => '午餐社交有点超标，下午别忘了切回清单模式。',
      InsightSentiment.overload => '外出高消费已触顶，今晚尝试无花费挑战⚡️。',
    };

    return DailyInsight(
      spent: baseSpent.toDouble(),
      dailyBudget: dailyBudget,
      aiComment: comment,
      sentiment: sentiment,
    );
  }

  WeeklyInsight _buildWeeklyInsight() {
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final values = labels
        .map(
          (label) => DailyPoint(
            label: label,
            amount: 80 + _random.nextInt(120) + _random.nextDouble() * 20,
          ),
        )
        .toList();

    final average = values.fold<double>(0, (sum, point) => sum + point.amount) /
        values.length;
    final highest = values.reduce(
      (current, next) => current.amount >= next.amount ? current : next,
    );

    return WeeklyInsight(
      data: values,
      averageSpend: average,
      anomalyDate: highest.label,
      anomalyReason: '${highest.label} spike due to Dining Out',
    );
  }

  MonthlyInsight _buildMonthlyInsight() {
    final fixed = 5200 + _random.nextInt(400);
    final flexible = 2300 + _random.nextInt(900);
    final score = 80 + _random.nextDouble() * 15; // 80 - 95

    return MonthlyInsight(
      fixedCost: fixed.toDouble(),
      flexibleCost: flexible.toDouble(),
      score: double.parse(score.toStringAsFixed(1)),
      cfoReport: '固定支出稳定，弹性预算仍有 12% 的压缩空间。建议把餐饮订阅改为家庭套餐，释放 600 元月度现金流。',
    );
  }
}
