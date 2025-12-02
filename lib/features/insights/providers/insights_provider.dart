import 'package:flutter/foundation.dart';
import 'package:your_finance_flutter/features/insights/models/daily_cap.dart';
import 'package:your_finance_flutter/features/insights/models/micro_insight.dart';
import 'package:your_finance_flutter/features/insights/models/weekly_anomaly.dart';
import 'package:your_finance_flutter/features/insights/models/monthly_health.dart';
import 'package:your_finance_flutter/features/insights/models/flux_loop_job.dart';
import 'package:your_finance_flutter/features/insights/services/insight_service.dart';

/// Main provider for Flux Insights 2.0 - orchestrates all insight types
class InsightsProvider with ChangeNotifier {
  InsightsProvider(this._insightService);

  final InsightService _insightService;

  // Current insight data
  DailyCap? _dailyCap;
  List<WeeklyAnomaly> _weeklyAnomalies = [];
  MonthlyHealthScore? _monthlyHealth;
  List<FluxLoopJob> _activeJobs = [];

  // UI state
  bool _isLoading = false;
  String? _error;

  // Getters
  DailyCap? get dailyCap => _dailyCap;
  List<WeeklyAnomaly> get weeklyAnomalies => _weeklyAnomalies;
  MonthlyHealthScore? get monthlyHealth => _monthlyHealth;
  List<FluxLoopJob> get activeJobs => _activeJobs;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Initialize all insights
  Future<void> initialize() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Initialize daily cap
      await _initializeDailyInsights();

      // Initialize weekly insights
      await _initializeWeeklyInsights();

      // Initialize monthly insights
      await _initializeMonthlyInsights();

    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Initialize daily insights
  Future<void> _initializeDailyInsights() async {
    // Daily cap would be calculated based on user's monthly budget
    // For now, using placeholder values
    const double dailyReference = 200.0;

    _dailyCap = DailyCap(
      id: 'daily_cap_${DateTime.now().toIso8601String().split('T').first}',
      date: DateTime.now(),
      referenceAmount: dailyReference,
      currentSpending: 0.0, // Would be calculated from actual transactions
      percentage: 0.0,
      status: CapStatus.safe,
    );
  }

  /// Initialize weekly insights
  Future<void> _initializeWeeklyInsights() async {
    // Weekly anomalies would be calculated from transaction patterns
    // For now, using placeholder data
    _weeklyAnomalies = [
      // Example anomalies would be populated by the insight service
    ];
  }

  /// Initialize monthly insights
  Future<void> _initializeMonthlyInsights() async {
    // Monthly health would be calculated from comprehensive transaction analysis
    // For now, using placeholder data
    _monthlyHealth = MonthlyHealthScore(
      id: 'monthly_health_${DateTime.now().year}_${DateTime.now().month}',
      month: DateTime(DateTime.now().year, DateTime.now().month, 1),
      grade: LetterGrade.B,
      score: 85.0,
      diagnosis: '财务状况良好，支出控制在合理范围内。',
      factors: [
        HealthFactor(
          name: '预算控制',
          impact: 0.8,
          description: '月支出未超过预算上限',
        ),
        HealthFactor(
          name: '消费结构',
          impact: 0.6,
          description: '生活必需支出占比合理',
        ),
      ],
      recommendations: [
        '考虑增加储蓄比例',
        '优化娱乐支出结构',
      ],
      metrics: {
        'savingsRate': 0.15,
        'expenseRatio': 0.75,
        'debtRatio': 0.05,
      },
    );
  }

  /// Trigger Flux Loop analysis for transaction changes
  Future<void> onTransactionChanged({
    required String transactionId,
    required JobType analysisType,
  }) async {
    try {
      // Create and queue analysis job
      final job = await _insightService.triggerAnalysis(
        type: analysisType,
        transactionId: transactionId,
      );

      _activeJobs.add(job);
      notifyListeners();

      // Listen for job completion
      _insightService.jobStatusStream(job.id).listen((updatedJob) {
        // Update job status
        final index = _activeJobs.indexWhere((j) => j.id == job.id);
        if (index != -1) {
          _activeJobs[index] = updatedJob;

          // Process completed job results
          if (updatedJob.isCompleted && updatedJob.result != null) {
            _processJobResult(updatedJob);
          }
        }
        notifyListeners();
      });

    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Process completed job results
  void _processJobResult(FluxLoopJob job) {
    try {
      // Parse and apply job results based on type
      switch (job.type) {
        case JobType.dailyAnalysis:
          // Update daily cap with new analysis
          break;
        case JobType.weeklyPatterns:
          // Update weekly anomalies
          break;
        case JobType.monthlyHealth:
          // Update monthly health score
          break;
        case JobType.microInsight:
          // Update micro insights
          break;
      }
    } catch (e) {
      _error = 'Failed to process analysis results: $e';
    }
  }

  /// Generate on-demand micro-insight
  Future<void> generateMicroInsight({
    required InsightTrigger trigger,
    String? context,
  }) async {
    if (_dailyCap == null) return;

    try {
      final insight = await _insightService.generateMicroInsight(
        dailyCapId: _dailyCap!.id,
        trigger: trigger,
        context: context,
      );

      // Update daily cap with new insight
      _dailyCap = _dailyCap!.copyWith(latestInsight: insight);
      notifyListeners();

    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Clear error state
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Refresh all insights
  Future<void> refreshInsights() async {
    await initialize();
  }
}

