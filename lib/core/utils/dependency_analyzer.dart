/// 依赖关系分析器 - 用于分析代码间的依赖关系和循环依赖
///
/// 提供以下分析功能：
/// - 依赖关系图构建
/// - 循环依赖检测
/// - 依赖链分析
/// - 模块耦合度评估
library;

import 'package:your_finance_flutter/core/utils/code_parser.dart';

/// 依赖关系图
class DependencyGraph {
  final Map<String, Set<String>> _graph = {};
  final Map<String, Set<String>> _reverseGraph = {};

  /// 添加依赖关系
  void addDependency(String from, String to) {
    _graph.putIfAbsent(from, () => {}).add(to);
    _reverseGraph.putIfAbsent(to, () => {}).add(from);
  }

  /// 获取直接依赖
  Set<String> getDependencies(String node) => _graph[node] ?? {};

  /// 获取被依赖项
  Set<String> getDependents(String node) => _reverseGraph[node] ?? {};

  /// 获取所有节点
  Set<String> getAllNodes() {
    final nodes = <String>{};
    nodes.addAll(_graph.keys);
    nodes.addAll(_reverseGraph.keys);
    return nodes;
  }

  /// 深度优先搜索检测循环依赖
  List<List<String>> findCycles() {
    final cycles = <List<String>>[];
    final visited = <String>{};
    final recursionStack = <String>{};

    void dfs(String node, List<String> path) {
      if (recursionStack.contains(node)) {
        // 找到循环
        final cycleStart = path.indexOf(node);
        if (cycleStart != -1) {
          cycles.add(path.sublist(cycleStart) + [node]);
        }
        return;
      }

      if (visited.contains(node)) {
        return;
      }

      visited.add(node);
      recursionStack.add(node);
      path.add(node);

      for (final neighbor in getDependencies(node)) {
        dfs(neighbor, path);
      }

      path.removeLast();
      recursionStack.remove(node);
    }

    for (final node in getAllNodes()) {
      if (!visited.contains(node)) {
        dfs(node, []);
      }
    }

    return cycles;
  }

  /// 计算依赖深度
  int getDependencyDepth(String node) {
    final visited = <String>{};
    const maxDepth = 0;

    int dfs(String current, int depth) {
      if (visited.contains(current)) {
        return depth;
      }

      visited.add(current);
      var currentMax = depth;

      for (final neighbor in getDependencies(current)) {
        final neighborDepth = dfs(neighbor, depth + 1);
        if (neighborDepth > currentMax) {
          currentMax = neighborDepth;
        }
      }

      return currentMax;
    }

    return dfs(node, 0);
  }

  /// 获取依赖统计
  Map<String, dynamic> getStatistics() {
    final nodes = getAllNodes();
    final mostDependent = <String, int>{};
    final mostDepended = <String, int>{};

    final stats = {
      'totalNodes': nodes.length,
      'totalEdges':
          _graph.values.fold<int>(0, (sum, deps) => sum + deps.length),
      'averageDependencies': 0.0,
      'mostDependent': mostDependent,
      'mostDepended': mostDepended,
      'cycles': findCycles(),
    };

    if (nodes.isNotEmpty) {
      final totalEdges = stats['totalEdges']! as int;
      stats['averageDependencies'] = totalEdges / nodes.length;
    }

    // 找出最多依赖其他模块的模块
    for (final node in nodes) {
      final depCount = getDependencies(node).length;
      mostDependent[node] = depCount;
    }

    // 找出被最多模块依赖的模块
    for (final node in nodes) {
      final depCount = getDependents(node).length;
      mostDepended[node] = depCount;
    }

    return stats;
  }
}

/// 模块依赖分析器
class DependencyAnalyzer {
  final DependencyGraph graph = DependencyGraph();

  /// 从代码分析结果构建依赖图
  void buildFromAnalysisResults(
    Map<String, CodeAnalysisResult> analysisResults,
  ) {
    for (final entry in analysisResults.entries) {
      final filePath = entry.key;
      final result = entry.value;

      for (final dependency in result.dependencies) {
        graph.addDependency(dependency.fromFile, dependency.toFile);
      }
    }
  }

  /// 分析循环依赖
  List<DependencyCycle> analyzeCycles() {
    final cycles = graph.findCycles();
    return cycles
        .map(
          (cycle) => DependencyCycle(
            files: cycle,
            severity: _calculateCycleSeverity(cycle.length),
            description: _generateCycleDescription(cycle),
          ),
        )
        .toList();
  }

  /// 分析依赖健康度
  DependencyHealthReport analyzeHealth() {
    final stats = graph.getStatistics();
    final cycles = analyzeCycles();

    final issues = <DependencyIssue>[];

    // 检查循环依赖
    for (final cycle in cycles) {
      issues.add(
        DependencyIssue(
          type: DependencyIssueType.cycle,
          severity: cycle.severity,
          description: cycle.description,
          affectedFiles: cycle.files,
        ),
      );
    }

    // 检查高耦合模块
    final mostDependent = stats['mostDependent'] as Map<String, int>;
    for (final entry in mostDependent.entries) {
      if (entry.value > 10) {
        // 超过10个依赖
        issues.add(
          DependencyIssue(
            type: DependencyIssueType.highCoupling,
            severity: DependencySeverity.high,
            description: '模块 ${entry.key} 依赖了 ${entry.value} 个其他模块，耦合度过高',
            affectedFiles: [entry.key],
          ),
        );
      }
    }

    // 检查孤立模块
    final isolatedModules = <String>[];
    for (final node in graph.getAllNodes()) {
      if (graph.getDependencies(node).isEmpty &&
          graph.getDependents(node).isEmpty) {
        isolatedModules.add(node);
      }
    }

    return DependencyHealthReport(
      totalModules: (stats['totalNodes'] as num?)?.toInt() ?? 0,
      totalDependencies: (stats['totalEdges'] as num?)?.toInt() ?? 0,
      cyclesCount: cycles.length,
      isolatedModulesCount: isolatedModules.length,
      averageDependencies:
          (stats['averageDependencies'] as num?)?.toDouble() ?? 0.0,
      issues: issues,
      recommendations: _generateRecommendations(issues),
    );
  }

  /// 生成依赖关系报告
  DependencyReport generateReport() {
    final health = analyzeHealth();
    final cycles = analyzeCycles();

    return DependencyReport(
      generatedAt: DateTime.now(),
      healthReport: health,
      cycles: cycles,
      recommendations: health.recommendations,
    );
  }

  DependencySeverity _calculateCycleSeverity(int cycleLength) {
    if (cycleLength >= 5) return DependencySeverity.critical;
    if (cycleLength >= 3) return DependencySeverity.high;
    return DependencySeverity.medium;
  }

  String _generateCycleDescription(List<String> cycle) =>
      '检测到循环依赖: ${cycle.join(' → ')} → ${cycle.first}';

  List<String> _generateRecommendations(List<DependencyIssue> issues) {
    final recommendations = <String>[];

    for (final issue in issues) {
      switch (issue.type) {
        case DependencyIssueType.cycle:
          recommendations.add(
            '重构循环依赖: 考虑提取共同接口或使用依赖注入来打破循环',
          );
        case DependencyIssueType.highCoupling:
          recommendations.add(
            '降低耦合度: 将 ${issue.affectedFiles.first} 的功能拆分为更小的模块',
          );
        case DependencyIssueType.isolatedModule:
          // 孤立模块通常不是问题，除非是预期应该被使用的模块
          break;
      }
    }

    if (recommendations.isEmpty) {
      recommendations.add('依赖结构健康，无需立即优化');
    }

    return recommendations;
  }
}

/// 依赖循环
class DependencyCycle {
  DependencyCycle({
    required this.files,
    required this.severity,
    required this.description,
  });
  final List<String> files;
  final DependencySeverity severity;
  final String description;
}

/// 依赖健康报告
class DependencyHealthReport {
  DependencyHealthReport({
    required this.totalModules,
    required this.totalDependencies,
    required this.cyclesCount,
    required this.isolatedModulesCount,
    required this.averageDependencies,
    required this.issues,
    required this.recommendations,
  });
  final int totalModules;
  final int totalDependencies;
  final int cyclesCount;
  final int isolatedModulesCount;
  final double averageDependencies;
  final List<DependencyIssue> issues;
  final List<String> recommendations;

  bool get isHealthy => issues.isEmpty;
  int get criticalIssues =>
      issues.where((i) => i.severity == DependencySeverity.critical).length;
  int get highSeverityIssues =>
      issues.where((i) => i.severity == DependencySeverity.high).length;
}

/// 依赖问题
class DependencyIssue {
  DependencyIssue({
    required this.type,
    required this.severity,
    required this.description,
    required this.affectedFiles,
  });
  final DependencyIssueType type;
  final DependencySeverity severity;
  final String description;
  final List<String> affectedFiles;
}

/// 依赖问题类型
enum DependencyIssueType {
  cycle,
  highCoupling,
  isolatedModule,
}

/// 依赖严重程度
enum DependencySeverity {
  low,
  medium,
  high,
  critical,
}

/// 依赖报告
class DependencyReport {
  DependencyReport({
    required this.generatedAt,
    required this.healthReport,
    required this.cycles,
    required this.recommendations,
  });
  final DateTime generatedAt;
  final DependencyHealthReport healthReport;
  final List<DependencyCycle> cycles;
  final List<String> recommendations;

  Map<String, dynamic> toJson() => {
        'generatedAt': generatedAt.toIso8601String(),
        'health': {
          'totalModules': healthReport.totalModules,
          'totalDependencies': healthReport.totalDependencies,
          'cyclesCount': healthReport.cyclesCount,
          'isolatedModulesCount': healthReport.isolatedModulesCount,
          'averageDependencies': healthReport.averageDependencies,
          'issuesCount': healthReport.issues.length,
          'isHealthy': healthReport.isHealthy,
        },
        'cycles': cycles
            .map(
              (c) => {
                'files': c.files,
                'severity': c.severity.toString(),
                'description': c.description,
              },
            )
            .toList(),
        'recommendations': recommendations,
      };
}

/// 依赖可视化器
class DependencyVisualizer {
  static String generateDotGraph(DependencyGraph graph) {
    final buffer = StringBuffer();
    buffer.writeln('digraph DependencyGraph {');
    buffer.writeln('  rankdir=LR;');
    buffer.writeln('  node [shape=box];');

    // 添加节点
    for (final node in graph.getAllNodes()) {
      buffer.writeln('  "$node" [label="${_getShortName(node)}"];');
    }

    // 添加边
    for (final entry in graph._graph.entries) {
      final from = entry.key;
      for (final to in entry.value) {
        buffer.writeln('  "$from" -> "$to";');
      }
    }

    buffer.writeln('}');
    return buffer.toString();
  }

  static String _getShortName(String fullPath) {
    final parts = fullPath.split('/');
    if (parts.length <= 2) return fullPath;
    return '${parts[parts.length - 2]}/${parts.last}';
  }
}
