import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 性能监控工具类
///
/// 提供组件级和应用级的性能监控功能，
/// 包括构建时间、渲染时间、内存使用等指标
class PerformanceMonitor {
  static final Map<String, _PerformanceData> _performanceData = {};
  static final StreamController<PerformanceEvent> _eventController =
      StreamController<PerformanceEvent>.broadcast();

  /// 监听性能事件
  static Stream<PerformanceEvent> get performanceEvents =>
      _eventController.stream;

  /// 监控Widget构建时间
  static Widget monitorBuild(String componentName, Widget Function() builder) {
    if (!kDebugMode) return builder();

    return _BuildMonitor(
      componentName: componentName,
      builder: builder,
    );
  }

  /// 监控Widget绘制时间
  static Widget monitorPaint(String componentName, Widget child) {
    // Simplified implementation - paint monitoring disabled due to render object compatibility issues
    return child;
  }

  /// 开始监控操作
  static void startOperation(String operationName) {
    if (!kDebugMode) return;

    _performanceData[operationName] = _PerformanceData(
      startTime: DateTime.now(),
      operationName: operationName,
    );
  }

  /// 结束监控操作
  static void endOperation(String operationName) {
    if (!kDebugMode) return;

    final data = _performanceData.remove(operationName);
    if (data != null) {
      final duration = DateTime.now().difference(data.startTime);
      _eventController.add(PerformanceEvent(
        type: PerformanceEventType.operation,
        componentName: operationName,
        duration: duration,
        metadata: {'operation': operationName},
      ));

      // 检查性能阈值
      _checkPerformanceThreshold(operationName, duration);
    }
  }

  /// 记录自定义性能指标
  static void recordMetric(String name, Duration duration,
      {Map<String, dynamic>? metadata}) {
    if (!kDebugMode) return;

    _eventController.add(PerformanceEvent(
      type: PerformanceEventType.metric,
      componentName: name,
      duration: duration,
      metadata: metadata,
    ));
  }

  /// 获取性能统计信息
  static Map<String, dynamic> getPerformanceStats() {
    return {
      'totalEvents': _eventController.hasListener ? 1 : 0,
      'monitoredComponents': _performanceData.length,
      'activeOperations': _performanceData.keys.toList(),
    };
  }

  /// 检查性能阈值
  static void _checkPerformanceThreshold(
      String operationName, Duration duration) {
    const thresholds = {
      'parse_transaction': Duration(milliseconds: 50),
      'validate_draft': Duration(milliseconds: 20),
      'save_draft': Duration(milliseconds: 100),
      'load_drafts': Duration(milliseconds: 200),
      'ui_build': Duration(milliseconds: 16), // 60fps
      'ui_paint': Duration(milliseconds: 8), // 120fps
    };

    final threshold = thresholds[operationName];
    if (threshold != null && duration > threshold) {
      // debugPrint('⚠️ 性能警告: $operationName 耗时 ${duration.inMilliseconds}ms (阈值: ${threshold.inMilliseconds}ms)');

      _eventController.add(PerformanceEvent(
        type: PerformanceEventType.thresholdExceeded,
        componentName: operationName,
        duration: duration,
        metadata: {
          'threshold': threshold.inMilliseconds,
          'actual': duration.inMilliseconds,
          'exceededBy': duration.inMilliseconds - threshold.inMilliseconds,
        },
      ));
    }
  }

  /// 清理资源
  static void dispose() {
    _eventController.close();
    _performanceData.clear();
  }
}

/// 性能事件类型
enum PerformanceEventType {
  /// 操作完成
  operation,

  /// 自定义指标
  metric,

  /// 阈值超限
  thresholdExceeded,

  /// UI构建
  uiBuild,

  /// UI绘制
  uiPaint,
}

/// 性能事件
class PerformanceEvent {
  final PerformanceEventType type;
  final String componentName;
  final Duration duration;
  final Map<String, dynamic>? metadata;
  final DateTime timestamp;

  PerformanceEvent({
    required this.type,
    required this.componentName,
    required this.duration,
    this.metadata,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  String toString() {
    return 'PerformanceEvent(type: $type, component: $componentName, duration: ${duration.inMilliseconds}ms)';
  }
}

/// 内部性能数据类
class _PerformanceData {
  final DateTime startTime;
  final String operationName;

  const _PerformanceData({
    required this.startTime,
    required this.operationName,
  });
}

/// 构建时间监控Widget
class _BuildMonitor extends StatefulWidget {
  final String componentName;
  final Widget Function() builder;

  const _BuildMonitor({
    required this.componentName,
    required this.builder,
  });

  @override
  State<_BuildMonitor> createState() => _BuildMonitorState();
}

class _BuildMonitorState extends State<_BuildMonitor> {
  @override
  Widget build(BuildContext context) {
    final startTime = DateTime.now();

    try {
      final child = widget.builder();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final duration = DateTime.now().difference(startTime);
        PerformanceMonitor.recordMetric(
          '${widget.componentName}_build',
          duration,
          metadata: {'phase': 'build'},
        );
      });

      return child;
    } on Exception catch (e) {
      final duration = DateTime.now().difference(startTime);
      PerformanceMonitor.recordMetric(
        '${widget.componentName}_build_error',
        duration,
        metadata: {'error': e.toString()},
      );
      rethrow;
    }
  }
}

/// 性能监控扩展方法
extension PerformanceMonitorExtensions on WidgetRef {
  /// 监控异步操作性能
  Future<T> monitorAsync<T>(
    String operationName,
    Future<T> Function() operation,
  ) async {
    PerformanceMonitor.startOperation(operationName);
    try {
      final result = await operation();
      PerformanceMonitor.endOperation(operationName);
      return result;
    } catch (e) {
      PerformanceMonitor.endOperation(operationName);
      rethrow;
    }
  }

  /// 监控同步操作性能
  T monitorSync<T>(String operationName, T Function() operation) {
    PerformanceMonitor.startOperation(operationName);
    try {
      final result = operation();
      PerformanceMonitor.endOperation(operationName);
      return result;
    } catch (e) {
      PerformanceMonitor.endOperation(operationName);
      rethrow;
    }
  }
}

/// 性能监控工具类 - 简化API
class PerfMonitor {
  /// 监控构建时间
  static Widget build(String name, Widget Function() builder) {
    return PerformanceMonitor.monitorBuild(name, builder);
  }

  /// 监控绘制时间
  static Widget paint(String name, Widget child) {
    return PerformanceMonitor.monitorPaint(name, child);
  }

  /// 开始操作监控
  static void start(String operation) {
    PerformanceMonitor.startOperation(operation);
  }

  /// 结束操作监控
  static void end(String operation) {
    PerformanceMonitor.endOperation(operation);
  }

  /// 记录指标
  static void metric(String name, Duration duration,
      {Map<String, dynamic>? metadata}) {
    PerformanceMonitor.recordMetric(name, duration, metadata: metadata);
  }

  /// 获取统计信息
  static Map<String, dynamic> stats() {
    return PerformanceMonitor.getPerformanceStats();
  }
}
