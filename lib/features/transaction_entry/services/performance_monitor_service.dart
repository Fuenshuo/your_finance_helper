import 'dart:async';
import '../models/input_validation.dart';

/// 性能监控服务接口
abstract class PerformanceMonitorService {
  /// 开始监控操作
  void startMonitoring(String operationName);

  /// 结束监控操作并记录性能数据
  void endMonitoring(String operationName);

  /// 获取性能统计信息
  Map<String, dynamic> getPerformanceStats();

  /// 重置性能统计
  void resetStats();
}

/// 默认性能监控服务实现
class DefaultPerformanceMonitorService implements PerformanceMonitorService {
  final Map<String, DateTime> _activeOperations = {};
  final Map<String, List<int>> _operationTimes = {};
  final Map<String, int> _operationCounts = {};

  @override
  void startMonitoring(String operationName) {
    _activeOperations[operationName] = DateTime.now();
  }

  @override
  void endMonitoring(String operationName) {
    final startTime = _activeOperations.remove(operationName);
    if (startTime != null) {
      final duration = DateTime.now().difference(startTime).inMilliseconds;

      // 记录操作时间
      _operationTimes.putIfAbsent(operationName, () => []).add(duration);

      // 记录操作次数
      _operationCounts[operationName] = (_operationCounts[operationName] ?? 0) + 1;

      // 检查性能阈值
      _checkPerformanceThreshold(operationName, duration);
    }
  }

  @override
  Map<String, dynamic> getPerformanceStats() {
    final stats = <String, dynamic>{};

    for (final operationName in _operationTimes.keys) {
      final times = _operationTimes[operationName]!;
      if (times.isNotEmpty) {
        final avgTime = times.reduce((a, b) => a + b) / times.length;
        final maxTime = times.reduce((a, b) => a > b ? a : b);
        final minTime = times.reduce((a, b) => a < b ? a : b);

        stats[operationName] = {
          'count': _operationCounts[operationName] ?? 0,
          'averageMs': avgTime.round(),
          'maxMs': maxTime,
          'minMs': minTime,
          'lastMs': times.last,
        };
      }
    }

    return stats;
  }

  @override
  void resetStats() {
    _activeOperations.clear();
    _operationTimes.clear();
    _operationCounts.clear();
  }

  /// 检查性能阈值
  void _checkPerformanceThreshold(String operationName, int durationMs) {
    const performanceThresholds = {
      'parse_transaction': 50, // 解析交易50ms阈值
      'validate_draft': 20,    // 验证草稿20ms阈值
      'save_draft': 100,       // 保存草稿100ms阈值
      'load_drafts': 200,      // 加载草稿200ms阈值
    };

    final threshold = performanceThresholds[operationName];
    if (threshold != null && durationMs > threshold) {
      // 记录性能警告
      _logPerformanceWarning(operationName, durationMs, threshold);
    }
  }

  /// 记录性能警告
  void _logPerformanceWarning(String operationName, int actualMs, int thresholdMs) {
    // debugPrint('性能警告: $operationName 耗时 ${actualMs}ms (阈值: ${thresholdMs}ms)');
  }
}

/// PerformanceMonitorService Provider
final performanceMonitorServiceProvider = Provider<PerformanceMonitorService>((ref) {
  return DefaultPerformanceMonitorService();
});

