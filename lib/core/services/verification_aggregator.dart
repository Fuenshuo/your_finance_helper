/// Verification Aggregator - Aggregates and analyzes verification results across sessions
///
/// Provides statistical analysis, trend tracking, and cross-session insights
/// for verification results to identify patterns and improvement opportunities.

import '../models/verification_result.dart';
import '../models/verification_session.dart';

class VerificationAggregator {
  /// Aggregate results from multiple sessions
  VerificationAggregation aggregateSessions(
      List<VerificationSession> sessions) {
    final allResults = sessions.expand((s) => s.results).toList();

    return VerificationAggregation(
      totalSessions: sessions.length,
      totalComponents: allResults.length,
      componentResults: _aggregateComponentResults(allResults),
      priorityStats: _calculatePriorityStats(allResults),
      timeStats: _calculateTimeStats(sessions),
      trendAnalysis: _analyzeTrends(sessions),
      failurePatterns: _identifyFailurePatterns(allResults),
      recommendations: _generateRecommendations(allResults),
    );
  }

  /// Aggregate results by component name across sessions
  Map<String, ComponentAggregation> _aggregateComponentResults(
      List<VerificationResult> results) {
    final componentMap = <String, List<VerificationResult>>{};

    // Group results by component
    for (final result in results) {
      componentMap.putIfAbsent(result.componentName, () => []).add(result);
    }

    // Calculate aggregation for each component
    final aggregations = <String, ComponentAggregation>{};
    componentMap.forEach((componentName, componentResults) {
      final passed = componentResults
          .where((r) => r.status == VerificationStatus.pass)
          .length;
      final failed = componentResults
          .where((r) => r.status == VerificationStatus.fail)
          .length;
      final pending = componentResults
          .where((r) => r.status == VerificationStatus.pending)
          .length;

      final avgPriority =
          componentResults.map((r) => r.priority).reduce((a, b) => a + b) /
              componentResults.length;
      final avgDuration = componentResults
              .where((r) => r.duration != null)
              .map((r) => r.duration!.inSeconds)
              .fold<double>(0, (sum, duration) => sum + duration) /
          componentResults.where((r) => r.duration != null).length;

      final successRate = componentResults.isNotEmpty
          ? (passed / componentResults.length * 100).round()
          : 0;

      aggregations[componentName] = ComponentAggregation(
        componentName: componentName,
        totalRuns: componentResults.length,
        passed: passed,
        failed: failed,
        pending: pending,
        successRate: successRate,
        averagePriority: avgPriority.round(),
        averageDurationSeconds: avgDuration.isNaN ? 0 : avgDuration.round(),
        recentFailures: componentResults
            .where((r) => r.status == VerificationStatus.fail)
            .take(3)
            .map((r) => r.details)
            .toList(),
      );
    });

    return aggregations;
  }

  /// Calculate statistics by priority level
  PriorityStats _calculatePriorityStats(List<VerificationResult> results) {
    final priorityGroups = <int, List<VerificationResult>>{};

    for (final result in results) {
      priorityGroups.putIfAbsent(result.priority, () => []).add(result);
    }

    final priorityStats = <int, PriorityAggregation>{};
    priorityGroups.forEach((priority, priorityResults) {
      final passed = priorityResults
          .where((r) => r.status == VerificationStatus.pass)
          .length;
      final failed = priorityResults
          .where((r) => r.status == VerificationStatus.fail)
          .length;
      final successRate = priorityResults.isNotEmpty
          ? (passed / priorityResults.length * 100).round()
          : 0;

      priorityStats[priority] = PriorityAggregation(
        priority: priority,
        totalComponents: priorityResults.length,
        passed: passed,
        failed: failed,
        successRate: successRate,
      );
    });

    return PriorityStats(stats: priorityStats);
  }

  /// Calculate time-based statistics
  TimeStats _calculateTimeStats(List<VerificationSession> sessions) {
    if (sessions.isEmpty) {
      return TimeStats(
        totalVerificationTime: Duration.zero,
        averageSessionTime: Duration.zero,
        fastestSession: Duration.zero,
        slowestSession: Duration.zero,
        totalComponentTime: Duration.zero,
        averageComponentTime: Duration.zero,
      );
    }

    final sessionDurations = sessions
        .where((s) => s.endTime != null)
        .map((s) => s.endTime!.difference(s.startTime))
        .toList();

    final componentDurations = sessions
        .expand((s) => s.results)
        .where((r) => r.duration != null)
        .map((r) => r.duration!)
        .toList();

    return TimeStats(
      totalVerificationTime: sessionDurations.fold(
          Duration.zero, (sum, duration) => sum + duration),
      averageSessionTime: sessionDurations.isNotEmpty
          ? sessionDurations.reduce((a, b) => a + b) ~/ sessionDurations.length
          : Duration.zero,
      fastestSession: sessionDurations.isNotEmpty
          ? sessionDurations.reduce((a, b) => a < b ? a : b)
          : Duration.zero,
      slowestSession: sessionDurations.isNotEmpty
          ? sessionDurations.reduce((a, b) => a > b ? a : b)
          : Duration.zero,
      totalComponentTime: componentDurations.fold(
          Duration.zero, (sum, duration) => sum + duration),
      averageComponentTime: componentDurations.isNotEmpty
          ? componentDurations.reduce((a, b) => a + b) ~/
              componentDurations.length
          : Duration.zero,
    );
  }

  /// Analyze trends across sessions
  TrendAnalysis _analyzeTrends(List<VerificationSession> sessions) {
    if (sessions.length < 2) {
      return TrendAnalysis(
        improvingComponents: [],
        decliningComponents: [],
        consistentlyPassing: [],
        consistentlyFailing: [],
        overallTrend: 'insufficient_data',
      );
    }

    // Sort sessions by start time
    final sortedSessions = sessions.where((s) => s.endTime != null).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    final componentTrends = <String, List<bool>>{};

    // Track pass/fail for each component across sessions
    for (final session in sortedSessions) {
      for (final result in session.results) {
        componentTrends
            .putIfAbsent(result.componentName, () => [])
            .add(result.status == VerificationStatus.pass);
      }
    }

    final improvingComponents = <String>[];
    final decliningComponents = <String>[];
    final consistentlyPassing = <String>[];
    final consistentlyFailing = <String>[];

    componentTrends.forEach((componentName, results) {
      if (results.length < 2) return;

      final recentResults = results.sublist(results.length - 3); // Last 3 runs

      if (recentResults.every((passed) => passed)) {
        consistentlyPassing.add(componentName);
      } else if (recentResults.every((passed) => !passed)) {
        consistentlyFailing.add(componentName);
      } else {
        // Check for improvement/decline trends
        final firstHalf = results.sublist(0, results.length ~/ 2);
        final secondHalf = results.sublist(results.length ~/ 2);

        final firstHalfSuccess =
            firstHalf.where((p) => p).length / firstHalf.length;
        final secondHalfSuccess =
            secondHalf.where((p) => p).length / secondHalf.length;

        if (secondHalfSuccess > firstHalfSuccess + 0.2) {
          // 20% improvement
          improvingComponents.add(componentName);
        } else if (firstHalfSuccess > secondHalfSuccess + 0.2) {
          // 20% decline
          decliningComponents.add(componentName);
        }
      }
    });

    // Determine overall trend
    final recentSessions = sortedSessions.sublist(sortedSessions.length - 3);
    final recentSuccessRates = recentSessions.map((s) {
      final passed =
          s.results.where((r) => r.status == VerificationStatus.pass).length;
      return s.results.isNotEmpty ? passed / s.results.length : 0.0;
    }).toList();

    String overallTrend = 'stable';
    if (recentSuccessRates.length >= 2) {
      final trend = recentSuccessRates.last - recentSuccessRates.first;
      if (trend > 0.1)
        overallTrend = 'improving';
      else if (trend < -0.1) overallTrend = 'declining';
    }

    return TrendAnalysis(
      improvingComponents: improvingComponents,
      decliningComponents: decliningComponents,
      consistentlyPassing: consistentlyPassing,
      consistentlyFailing: consistentlyFailing,
      overallTrend: overallTrend,
    );
  }

  /// Identify common failure patterns
  List<FailurePattern> _identifyFailurePatterns(
      List<VerificationResult> results) {
    final failedResults =
        results.where((r) => r.status == VerificationStatus.fail).toList();

    if (failedResults.isEmpty) {
      return [];
    }

    // Group failures by error patterns in details
    final patternMap = <String, List<VerificationResult>>{};

    for (final result in failedResults) {
      final patterns = _extractErrorPatterns(result.details);
      for (final pattern in patterns) {
        patternMap.putIfAbsent(pattern, () => []).add(result);
      }
    }

    return patternMap.entries.map((entry) {
      final affectedComponents =
          entry.value.map((r) => r.componentName).toSet().toList();
      final frequency = entry.value.length;

      return FailurePattern(
        pattern: entry.key,
        frequency: frequency,
        affectedComponents: affectedComponents,
        severity: _calculatePatternSeverity(
            entry.key, frequency, affectedComponents.length),
      );
    }).toList()
      ..sort((a, b) => b.frequency.compareTo(a.frequency)); // Sort by frequency
  }

  /// Generate recommendations based on analysis
  List<String> _generateRecommendations(List<VerificationResult> results) {
    final recommendations = <String>[];

    final failedResults =
        results.where((r) => r.status == VerificationStatus.fail).toList();
    final highPriorityFailures =
        failedResults.where((r) => r.priority >= 4).toList();

    if (highPriorityFailures.isNotEmpty) {
      recommendations.add(
          'Address ${highPriorityFailures.length} high-priority verification failures immediately');
      recommendations.add(
          'High-priority components failing: ${highPriorityFailures.map((r) => r.componentName).join(", ")}');
    }

    // Check for common failure patterns
    final failurePatterns = _identifyFailurePatterns(results);
    if (failurePatterns.isNotEmpty) {
      recommendations.add(
          'Investigate recurring failure patterns: ${failurePatterns.take(3).map((p) => p.pattern).join(", ")}');
    }

    // Check for slow components
    final slowComponents = results
        .where((r) => r.duration != null && r.duration!.inSeconds > 30)
        .map((r) => r.componentName)
        .toList();

    if (slowComponents.isNotEmpty) {
      recommendations.add(
          'Optimize performance for slow components: ${slowComponents.join(", ")}');
    }

    // General recommendations
    final successRate = results.isNotEmpty
        ? (results.where((r) => r.status == VerificationStatus.pass).length /
                results.length *
                100)
            .round()
        : 0;

    if (successRate < 80) {
      recommendations.add(
          'Overall success rate (${successRate}%) needs improvement - focus on failing components');
    } else if (successRate >= 95) {
      recommendations.add(
          'Excellent verification success rate (${successRate}%) - consider adding more comprehensive tests');
    }

    return recommendations;
  }

  /// Extract error patterns from failure details
  List<String> _extractErrorPatterns(String details) {
    final patterns = <String>[];

    // Common error patterns
    if (details.contains('provider') || details.contains('Provider')) {
      patterns.add('Provider dependency issues');
    }
    if (details.contains('import') || details.contains('Import')) {
      patterns.add('Import/path resolution issues');
    }
    if (details.contains('render') || details.contains('widget')) {
      patterns.add('UI rendering issues');
    }
    if (details.contains('animation') || details.contains('Animation')) {
      patterns.add('Animation controller issues');
    }
    if (details.contains('theme') || details.contains('Theme')) {
      patterns.add('Theme adaptation issues');
    }
    if (details.contains('build') || details.contains('compilation')) {
      patterns.add('Build/compilation issues');
    }
    if (details.contains('navigation') || details.contains('route')) {
      patterns.add('Navigation/routing issues');
    }

    // If no specific patterns found, categorize as general
    if (patterns.isEmpty) {
      patterns.add('General verification failures');
    }

    return patterns;
  }

  /// Calculate severity for failure patterns
  String _calculatePatternSeverity(
      String pattern, int frequency, int componentCount) {
    final score = frequency * componentCount;

    if (score >= 10) return 'critical';
    if (score >= 5) return 'high';
    if (score >= 2) return 'medium';
    return 'low';
  }
}

/// Data classes for aggregation results

class VerificationAggregation {
  final int totalSessions;
  final int totalComponents;
  final Map<String, ComponentAggregation> componentResults;
  final PriorityStats priorityStats;
  final TimeStats timeStats;
  final TrendAnalysis trendAnalysis;
  final List<FailurePattern> failurePatterns;
  final List<String> recommendations;

  VerificationAggregation({
    required this.totalSessions,
    required this.totalComponents,
    required this.componentResults,
    required this.priorityStats,
    required this.timeStats,
    required this.trendAnalysis,
    required this.failurePatterns,
    required this.recommendations,
  });
}

class ComponentAggregation {
  final String componentName;
  final int totalRuns;
  final int passed;
  final int failed;
  final int pending;
  final int successRate;
  final int averagePriority;
  final int averageDurationSeconds;
  final List<String> recentFailures;

  ComponentAggregation({
    required this.componentName,
    required this.totalRuns,
    required this.passed,
    required this.failed,
    required this.pending,
    required this.successRate,
    required this.averagePriority,
    required this.averageDurationSeconds,
    required this.recentFailures,
  });
}

class PriorityStats {
  final Map<int, PriorityAggregation> stats;

  PriorityStats({required this.stats});
}

class PriorityAggregation {
  final int priority;
  final int totalComponents;
  final int passed;
  final int failed;
  final int successRate;

  PriorityAggregation({
    required this.priority,
    required this.totalComponents,
    required this.passed,
    required this.failed,
    required this.successRate,
  });
}

class TimeStats {
  final Duration totalVerificationTime;
  final Duration averageSessionTime;
  final Duration fastestSession;
  final Duration slowestSession;
  final Duration totalComponentTime;
  final Duration averageComponentTime;

  TimeStats({
    required this.totalVerificationTime,
    required this.averageSessionTime,
    required this.fastestSession,
    required this.slowestSession,
    required this.totalComponentTime,
    required this.averageComponentTime,
  });
}

class TrendAnalysis {
  final List<String> improvingComponents;
  final List<String> decliningComponents;
  final List<String> consistentlyPassing;
  final List<String> consistentlyFailing;
  final String
      overallTrend; // 'improving', 'declining', 'stable', 'insufficient_data'

  TrendAnalysis({
    required this.improvingComponents,
    required this.decliningComponents,
    required this.consistentlyPassing,
    required this.consistentlyFailing,
    required this.overallTrend,
  });
}

class FailurePattern {
  final String pattern;
  final int frequency;
  final List<String> affectedComponents;
  final String severity; // 'critical', 'high', 'medium', 'low'

  FailurePattern({
    required this.pattern,
    required this.frequency,
    required this.affectedComponents,
    required this.severity,
  });
}

