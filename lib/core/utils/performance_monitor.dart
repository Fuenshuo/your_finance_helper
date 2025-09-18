import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// 性能监控工具类
class PerformanceMonitor {
  static final Map<String, List<int>> _buildTimes = {};
  static final Map<String, List<int>> _paintTimes = {};

  /// 监控 Widget 构建时间
  static T monitorBuild<T>(String widgetName, T Function() buildFunction) {
    if (!kDebugMode) {
      return buildFunction();
    }

    final stopwatch = Stopwatch()..start();
    final result = buildFunction();
    stopwatch.stop();

    final buildTime = stopwatch.elapsedMicroseconds;
    _buildTimes.putIfAbsent(widgetName, () => []).add(buildTime);

    // 只记录超过阈值的构建时间
    if (buildTime > _getBuildThreshold(widgetName)) {
      print('🚀 $widgetName build time: $buildTimeμs');
    }

    // 每50次构建输出统计信息（减少输出频率）
    if (_buildTimes[widgetName]!.length % 50 == 0) {
      _printBuildStats(widgetName);
    }

    return result;
  }

  /// 监控绘制时间
  static void monitorPaint(String painterName, VoidCallback paintFunction) {
    if (!kDebugMode) {
      paintFunction();
      return;
    }

    final stopwatch = Stopwatch()..start();
    paintFunction();
    stopwatch.stop();

    final paintTime = stopwatch.elapsedMicroseconds;
    _paintTimes.putIfAbsent(painterName, () => []).add(paintTime);

    // 只记录超过阈值的绘制时间
    if (paintTime > _getPaintThreshold(painterName)) {
      print('🎨 $painterName paint time: $paintTimeμs');
    }
  }

  /// 获取构建时间阈值
  static int _getBuildThreshold(String widgetName) {
    switch (widgetName) {
      case 'AssetListScreen':
        return 10000; // 10ms
      case 'AssetListItem':
        return 3000; // 3ms
      case 'SimpleTrendChart':
        return 1000; // 1ms
      default:
        return 2000; // 默认2ms
    }
  }

  /// 获取绘制时间阈值
  static int _getPaintThreshold(String painterName) {
    switch (painterName) {
      case '_TrendLinePainter':
        return 500; // 0.5ms
      default:
        return 200; // 默认0.2ms
    }
  }

  /// 打印构建统计信息
  static void _printBuildStats(String widgetName) {
    final times = _buildTimes[widgetName]!;
    final avg = times.reduce((a, b) => a + b) / times.length;
    final max = times.reduce((a, b) => a > b ? a : b);
    final min = times.reduce((a, b) => a < b ? a : b);

    print('📊 $widgetName 构建统计 (最近${times.length}次):');
    print('   平均: ${avg.toStringAsFixed(1)}μs');
    print('   最大: $maxμs');
    print('   最小: $minμs');
  }

  /// 打印所有统计信息
  static void printAllStats() {
    print('📈 性能统计报告:');
    for (final widgetName in _buildTimes.keys) {
      _printBuildStats(widgetName);
    }
    for (final painterName in _paintTimes.keys) {
      final times = _paintTimes[painterName]!;
      final avg = times.reduce((a, b) => a + b) / times.length;
      print('🎨 $painterName 绘制统计: 平均 ${avg.toStringAsFixed(1)}μs');
    }
  }

  /// 清除统计数据
  static void clearStats() {
    _buildTimes.clear();
    _paintTimes.clear();
    print('🧹 性能统计数据已清除');
  }

  /// 开始性能分析
  static void startProfiling() {
    if (kDebugMode) {
      developer.Timeline.startSync('Performance Analysis');
    }
  }

  /// 结束性能分析
  static void endProfiling() {
    if (kDebugMode) {
      developer.Timeline.finishSync();
    }
  }
}
