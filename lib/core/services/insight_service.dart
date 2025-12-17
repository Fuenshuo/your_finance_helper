// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:async';
import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:your_finance_flutter/features/insights/models/flux_loop_job.dart';
import 'package:your_finance_flutter/features/insights/services/pattern_detection_service.dart';
import 'package:your_finance_flutter/features/insights/models/weekly_anomaly.dart';

/// Sentiment for the AI CFO commentary.
enum InsightSentiment {
  safe,
  warning,
  overload,
}

/// Flux Loop job manager for background AI analysis
class FluxLoopManager {
  static final Map<String, FluxLoopJob> _activeJobs = {};
  static final Map<String, StreamController<FluxLoopJob>> _jobControllers = {};

  /// Trigger a new analysis job
  static Future<FluxLoopJob> triggerAnalysis({
    required JobType type,
    required String transactionId,
  }) async {
    final jobId = 'flux_${type.name}_${DateTime.now().millisecondsSinceEpoch}';

    final job = FluxLoopJob(
      id: jobId,
      type: type,
      status: JobStatus.queued,
      createdAt: DateTime.now(),
      metadata: {'transactionId': transactionId},
    );

    _activeJobs[jobId] = job;
    _jobControllers[jobId] = StreamController<FluxLoopJob>.broadcast();

    // Start background processing
    _processJob(jobId);

    return job;
  }

  /// Get job status stream
  static Stream<FluxLoopJob> jobStatusStream(String jobId) {
    return _jobControllers[jobId]?.stream ?? Stream.empty();
  }

  /// Process job in background
  static Future<void> _processJob(String jobId) async {
    final job = _activeJobs[jobId];
    if (job == null) return;

    try {
      // Update status to processing
      final processingJob = job.copyWith(status: JobStatus.processing);
      _activeJobs[jobId] = processingJob;
      _jobControllers[jobId]?.add(processingJob);

      // Simulate AI processing time (in real app, this would call AI service)
      await Future<void>.delayed(const Duration(seconds: 2));

      // Generate mock result based on job type
      final result = await _generateJobResult(processingJob);

      // Complete job
      final completedJob = processingJob.copyWith(
        status: JobStatus.completed,
        completedAt: DateTime.now(),
        result: result,
      );

      _activeJobs[jobId] = completedJob;
      _jobControllers[jobId]?.add(completedJob);
    } catch (e) {
      // Fail job
      final failedJob = job.copyWith(
        status: JobStatus.failed,
        completedAt: DateTime.now(),
        error: e.toString(),
      );

      _activeJobs[jobId] = failedJob;
      _jobControllers[jobId]?.add(failedJob);
    }
  }

  /// Generate mock result for job type
  static Future<String> _generateJobResult(FluxLoopJob job) async {
    switch (job.type) {
      case JobType.dailyAnalysis:
        return '{"type": "daily_cap", "insights": ["消费控制良好"], "recommendations": ["继续保持"]}';
      case JobType.weeklyPatterns:
        return '{"type": "weekly_anomalies", "anomalies": [], "patterns": ["周末消费较高"]}';
      case JobType.monthlyHealth:
        return '{"type": "monthly_health", "score": 85, "grade": "B", "factors": ["预算控制良好"]}';
      case JobType.microInsight:
        return '{"sentiment": "positive", "message": "今日消费适中", "actions": ["保持习惯"]}';
    }
  }

  /// Clean up completed jobs
  static void cleanup() {
    final now = DateTime.now();
    final expiredJobs = _activeJobs.entries
        .where((entry) {
          final job = entry.value;
          return job.status == JobStatus.completed &&
              job.completedAt != null &&
              now.difference(job.completedAt!).inMinutes > 30;
        })
        .map((e) => e.key)
        .toList();

    for (final jobId in expiredJobs) {
      _activeJobs.remove(jobId);
      _jobControllers[jobId]?.close();
      _jobControllers.remove(jobId);
    }
  }
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
    required this.totalSpent,
    required this.averageSpent,
    required this.anomalies,
    required this.monday,
    required this.tuesday,
    required this.wednesday,
    required this.thursday,
    required this.friday,
    required this.saturday,
    required this.sunday,
  });

  final double totalSpent;
  final double averageSpent;
  final List<WeeklyAnomaly> anomalies;

  // Daily spending amounts
  final double monday;
  final double tuesday;
  final double wednesday;
  final double thursday;
  final double friday;
  final double saturday;
  final double sunday;

  @override
  List<Object?> get props => [
        totalSpent,
        averageSpent,
        anomalies,
        monday,
        tuesday,
        wednesday,
        thursday,
        friday,
        saturday,
        sunday,
      ];
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
  final _patternDetectionService = PatternDetectionService.instance;

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
    _cachedWeekly = await _buildWeeklyInsight();
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
      InsightSentiment.overload => '外出高消费已触顶，今晚尝试无花费挑战[挑战]。',
    };

    return DailyInsight(
      spent: baseSpent.toDouble(),
      dailyBudget: dailyBudget,
      aiComment: comment,
      sentiment: sentiment,
    );
  }

  Future<WeeklyInsight> _buildWeeklyInsight() async {
    final dailySpending =
        List.generate(7, (index) => 100.0 + _random.nextInt(200));
    final weekStart =
        DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
    final categoryBreakdown = [
      '餐饮',
      '交通',
      '购物',
      '娱乐',
      '购物',
      '娱乐',
      '餐饮'
    ]; // 7 categories for 7 days

    final anomalies = await _patternDetectionService.detectWeeklyAnomalies(
      dailySpending,
      weekStart,
      categoryBreakdown,
    );

    final totalSpent = dailySpending.reduce((a, b) => a + b);
    final averageSpent = totalSpent / 7;

    return WeeklyInsight(
      totalSpent: totalSpent,
      averageSpent: averageSpent,
      anomalies: anomalies,
      monday: dailySpending[0],
      tuesday: dailySpending[1],
      wednesday: dailySpending[2],
      thursday: dailySpending[3],
      friday: dailySpending[4],
      saturday: dailySpending[5],
      sunday: dailySpending[6],
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

  // --- Flux Loop Integration ---

  /// Trigger Flux Loop analysis for transaction changes
  Future<FluxLoopJob> triggerAnalysis({
    required JobType type,
    required String transactionId,
  }) async {
    return FluxLoopManager.triggerAnalysis(
      type: type,
      transactionId: transactionId,
    );
  }

  /// Trigger weekly pattern analysis
  Future<FluxLoopJob> triggerWeeklyAnalysis({
    required DateTime weekStart,
    required List<double> dailySpending,
    required List<String> categoryBreakdown,
  }) async {
    final jobId = 'weekly_${weekStart.toIso8601String().split('T').first}';

    // Check if weekly analysis already exists and is recent
    final existingJob = FluxLoopManager._activeJobs[jobId];
    if (existingJob != null &&
        existingJob.status == JobStatus.completed &&
        existingJob.completedAt != null &&
        DateTime.now().difference(existingJob.completedAt!).inHours < 1) {
      return existingJob; // Return cached result
    }

    return FluxLoopManager.triggerAnalysis(
      type: JobType.weeklyPatterns,
      transactionId: 'weekly_${weekStart.toIso8601String()}',
    );
  }

  /// Get status stream for a specific job
  Stream<FluxLoopJob> jobStatusStream(String jobId) {
    return FluxLoopManager.jobStatusStream(jobId);
  }
}
