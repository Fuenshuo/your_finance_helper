/// Verification Performance Monitor - Monitors and optimizes verification performance
///
/// Tracks execution times, memory usage, and provides performance insights
/// to help optimize verification processes and identify bottlenecks.

import 'dart:async';
import '../models/verification_result.dart';

class VerificationPerformanceMonitor {
  final Map<String, ComponentPerformanceMetrics> _componentMetrics = {};
  final List<PerformanceSnapshot> _snapshots = [];
  Timer? _monitoringTimer;

  /// Start monitoring a verification session
  void startSessionMonitoring() {
    _snapshots.clear();
    _componentMetrics.clear();

    // Take snapshots every 100ms during verification
    _monitoringTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _takePerformanceSnapshot();
    });
  }

  /// Stop monitoring and return performance report
  PerformanceReport stopSessionMonitoring() {
    _monitoringTimer?.cancel();
    _monitoringTimer = null;

    return PerformanceReport(
      componentMetrics: Map.from(_componentMetrics),
      snapshots: List.from(_snapshots),
      summary: _generatePerformanceSummary(),
    );
  }

  /// Start monitoring a specific component
  ComponentPerformanceTracker startComponentMonitoring(String componentName) {
    return ComponentPerformanceTracker(componentName, this);
  }

  /// Record component performance metrics
  void recordComponentMetrics(ComponentPerformanceMetrics metrics) {
    _componentMetrics[metrics.componentName] = metrics;
  }

  /// Take a performance snapshot
  void _takePerformanceSnapshot() {
    // In a real implementation, this would use platform-specific APIs
    // For now, we'll simulate basic metrics
    _snapshots.add(PerformanceSnapshot(
      timestamp: DateTime.now(),
      memoryUsage: _getSimulatedMemoryUsage(),
      cpuUsage: _getSimulatedCpuUsage(),
      activeTasks: _getSimulatedActiveTasks(),
    ));
  }

  /// Generate performance summary
  PerformanceSummary _generatePerformanceSummary() {
    if (_snapshots.isEmpty) {
      return PerformanceSummary(
        totalDuration: Duration.zero,
        peakMemoryUsage: 0,
        averageCpuUsage: 0.0,
        totalSnapshots: 0,
        performanceScore: 100, // Default good score
        recommendations: [],
      );
    }

    final totalDuration = _snapshots.last.timestamp.difference(_snapshots.first.timestamp);
    final peakMemoryUsage = _snapshots.map((s) => s.memoryUsage).reduce((a, b) => a > b ? a : b);
    final averageCpuUsage = _snapshots.map((s) => s.cpuUsage).reduce((a, b) => a + b) / _snapshots.length;

    // Calculate performance score (0-100, higher is better)
    final memoryScore = peakMemoryUsage < 100 ? 100 : (100000000 / peakMemoryUsage).clamp(0, 100);
    final cpuScore = (100 - averageCpuUsage).clamp(0, 100);
    final durationScore = totalDuration.inSeconds < 60 ? 100 : (3600 / totalDuration.inSeconds * 100).clamp(0, 100);
    final performanceScore = ((memoryScore + cpuScore + durationScore) / 3).round();

    final recommendations = <String>[];

    if (peakMemoryUsage > 150) {
      recommendations.add('High memory usage detected (${peakMemoryUsage}MB). Consider optimizing memory-intensive components.');
    }

    if (averageCpuUsage > 70) {
      recommendations.add('High CPU usage (${averageCpuUsage.toStringAsFixed(1)}%). Consider reducing computational load.');
    }

    if (totalDuration.inSeconds > 120) {
      recommendations.add('Long verification duration (${totalDuration.inSeconds}s). Consider parallelizing or optimizing slow components.');
    }

    // Component-specific recommendations
    final slowComponents = _componentMetrics.values
        .where((m) => m.duration.inSeconds > 10)
        .map((m) => m.componentName)
        .toList();

    if (slowComponents.isNotEmpty) {
      recommendations.add('Slow components detected: ${slowComponents.join(", ")}. Consider optimization.');
    }

    return PerformanceSummary(
      totalDuration: totalDuration,
      peakMemoryUsage: peakMemoryUsage,
      averageCpuUsage: averageCpuUsage,
      totalSnapshots: _snapshots.length,
      performanceScore: performanceScore,
      recommendations: recommendations,
    );
  }

  /// Get optimization suggestions for a specific component
  List<String> getOptimizationSuggestions(String componentName) {
    final metrics = _componentMetrics[componentName];
    if (metrics == null) return [];

    final suggestions = <String>[];

    if (metrics.duration.inSeconds > 30) {
      suggestions.add('Consider caching results or reducing API calls');
      suggestions.add('Implement lazy loading for heavy operations');
    }

    if (metrics.memoryUsage > 50) {
      suggestions.add('Reduce object allocations or implement object pooling');
      suggestions.add('Use streaming for large data processing');
    }

    if (metrics.errorCount > 0) {
      suggestions.add('Review error handling - ${metrics.errorCount} errors occurred');
      suggestions.add('Add retry logic for transient failures');
    }

    return suggestions;
  }

  /// Get performance comparison between components
  PerformanceComparison compareComponents(String componentA, String componentB) {
    final metricsA = _componentMetrics[componentA];
    final metricsB = _componentMetrics[componentB];

    if (metricsA == null || metricsB == null) {
      return PerformanceComparison(
        componentA: componentA,
        componentB: componentB,
        durationDifference: Duration.zero,
        memoryDifference: 0,
        errorDifference: 0,
        winner: 'insufficient_data',
      );
    }

    final durationDiff = metricsA.duration - metricsB.duration;
    final memoryDiff = metricsA.memoryUsage - metricsB.memoryUsage;
    final errorDiff = metricsA.errorCount - metricsB.errorCount;

    String winner;
    if (metricsA.duration < metricsB.duration && metricsA.memoryUsage < metricsB.memoryUsage) {
      winner = componentA;
    } else if (metricsB.duration < metricsA.duration && metricsB.memoryUsage < metricsA.memoryUsage) {
      winner = componentB;
    } else {
      winner = 'tie';
    }

    return PerformanceComparison(
      componentA: componentA,
      componentB: componentB,
      durationDifference: durationDiff,
      memoryDifference: memoryDiff,
      errorDifference: errorDiff,
      winner: winner,
    );
  }

  /// Simulated methods (would use platform APIs in real implementation)
  int _getSimulatedMemoryUsage() {
    // Simulate memory usage between 50-200 MB
    return 50 + (DateTime.now().millisecondsSinceEpoch % 150);
  }

  double _getSimulatedCpuUsage() {
    // Simulate CPU usage between 10-90%
    return 10 + (DateTime.now().millisecondsSinceEpoch % 80);
  }

  int _getSimulatedActiveTasks() {
    // Simulate 1-10 active tasks
    return 1 + (DateTime.now().millisecondsSinceEpoch % 9);
  }
}

/// Component Performance Tracker - Tracks individual component performance
class ComponentPerformanceTracker {
  final String componentName;
  final VerificationPerformanceMonitor _monitor;
  final DateTime _startTime;
  int _initialMemoryUsage;
  int _errorCount = 0;

  ComponentPerformanceTracker(this.componentName, this._monitor)
      : _startTime = DateTime.now(),
        _initialMemoryUsage = 0 {
    // In real implementation, get actual memory usage
    _initialMemoryUsage = _monitor._getSimulatedMemoryUsage();
  }

  /// Record an error occurrence
  void recordError() {
    _errorCount++;
  }

  /// Complete tracking and record metrics
  void complete() {
    final duration = DateTime.now().difference(_startTime);
    final finalMemoryUsage = _monitor._getSimulatedMemoryUsage();
    final memoryUsage = finalMemoryUsage - _initialMemoryUsage;

    final metrics = ComponentPerformanceMetrics(
      componentName: componentName,
      duration: duration,
      memoryUsage: memoryUsage.clamp(0, memoryUsage), // Ensure non-negative
      errorCount: _errorCount,
      timestamp: DateTime.now(),
    );

    _monitor.recordComponentMetrics(metrics);
  }
}

/// Data classes for performance metrics

class PerformanceReport {
  final Map<String, ComponentPerformanceMetrics> componentMetrics;
  final List<PerformanceSnapshot> snapshots;
  final PerformanceSummary summary;

  PerformanceReport({
    required this.componentMetrics,
    required this.snapshots,
    required this.summary,
  });
}

class ComponentPerformanceMetrics {
  final String componentName;
  final Duration duration;
  final int memoryUsage; // MB
  final int errorCount;
  final DateTime timestamp;

  ComponentPerformanceMetrics({
    required this.componentName,
    required this.duration,
    required this.memoryUsage,
    required this.errorCount,
    required this.timestamp,
  });
}

class PerformanceSnapshot {
  final DateTime timestamp;
  final int memoryUsage; // MB
  final double cpuUsage; // %
  final int activeTasks;

  PerformanceSnapshot({
    required this.timestamp,
    required this.memoryUsage,
    required this.cpuUsage,
    required this.activeTasks,
  });
}

class PerformanceSummary {
  final Duration totalDuration;
  final int peakMemoryUsage; // MB
  final double averageCpuUsage; // %
  final int totalSnapshots;
  final int performanceScore; // 0-100, higher is better
  final List<String> recommendations;

  PerformanceSummary({
    required this.totalDuration,
    required this.peakMemoryUsage,
    required this.averageCpuUsage,
    required this.totalSnapshots,
    required this.performanceScore,
    required this.recommendations,
  });
}

class PerformanceComparison {
  final String componentA;
  final String componentB;
  final Duration durationDifference; // Positive means A is slower
  final int memoryDifference; // Positive means A uses more memory
  final int errorDifference; // Positive means A has more errors
  final String winner; // 'componentA', 'componentB', 'tie', 'insufficient_data'

  PerformanceComparison({
    required this.componentA,
    required this.componentB,
    required this.durationDifference,
    required this.memoryDifference,
    required this.errorDifference,
    required this.winner,
  });
}
