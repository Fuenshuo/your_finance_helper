import 'package:your_finance_flutter/features/insights/models/daily_cap.dart';
import 'package:your_finance_flutter/features/insights/models/monthly_health.dart';
import 'package:your_finance_flutter/features/insights/models/weekly_anomaly.dart';

/// Optional extension interfaces for AI analysis.
///
/// These are intentionally separate from `AiService` so production AI providers
/// do not need to implement them, while tests can provide deterministic mocks.

abstract class DailyCapAnalyzer {
  /// Note: Parameter is nullable to support Mockito argument matchers (which are
  /// represented as `null` at call sites under sound null-safety).
  Future<DailyCap> analyzeDailyCap(List<Map<String, dynamic>>? transactions);
}

abstract class WeeklyPatternAnalyzer {
  Future<List<WeeklyAnomaly>> analyzeWeeklyPatterns(
    /// Nullable for Mockito matcher compatibility.
    List<Map<String, dynamic>>? weeklyData,
  );
}

abstract class MonthlyHealthAnalyzer {
  Future<MonthlyHealthScore> analyzeMonthlyHealth(
    /// Nullable for Mockito matcher compatibility.
    Map<String, dynamic>? monthlyData,
  );
}
