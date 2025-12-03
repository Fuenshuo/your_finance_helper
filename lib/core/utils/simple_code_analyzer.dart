/// 简化版代码分析器 - 用于基本代码结构分析
///
/// 提供基本的代码统计和依赖分析功能
library;

import 'dart:io';

/// 代码分析结果
class CodeAnalysisResult {

  CodeAnalysisResult({
    required this.filePath,
    required this.linesOfCode,
    required this.classes,
    required this.functions,
    required this.imports,
    required this.dependencies,
  });
  final String filePath;
  final int linesOfCode;
  final int classes;
  final int functions;
  final List<String> imports;
  final List<String> dependencies;
}

/// 简化代码分析器
class SimpleCodeAnalyzer {
  /// 分析单个Dart文件
  Future<CodeAnalysisResult> analyzeFile(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      return CodeAnalysisResult(
        filePath: filePath,
        linesOfCode: 0,
        classes: 0,
        functions: 0,
        imports: [],
        dependencies: [],
      );
    }

    final content = await file.readAsString();
    final lines = content.split('\n');

    // 基本统计
    final linesOfCode = lines.where((line) => line.trim().isNotEmpty).length;

    // 查找类定义
    final classes = lines.where((line) =>
      line.contains('class ') && !line.trim().startsWith('//'),
    ).length;

    // 查找函数定义
    final functions = lines.where((line) =>
      (line.contains('Function(') ||
       line.contains(' void ') ||
       line.contains(' String ') ||
       line.contains(' int ') ||
       line.contains(' bool ')) &&
      line.contains('(') && line.contains(')') &&
      !line.trim().startsWith('//'),
    ).length;

    // 查找导入语句
    final imports = <String>[];
    for (final line in lines) {
      final trimmed = line.trim();
      if ((trimmed.startsWith('import ') || trimmed.startsWith('export ')) &&
          (trimmed.contains(" '") || trimmed.contains(' "'))) {
        // 提取导入路径
        final startQuote = trimmed.indexOf("'");
        final endQuote = trimmed.lastIndexOf("'");
        if (startQuote != -1 && endQuote != -1 && endQuote > startQuote) {
          final importPath = trimmed.substring(startQuote + 1, endQuote);
          imports.add(importPath);
        }
      }
    }

    return CodeAnalysisResult(
      filePath: filePath,
      linesOfCode: linesOfCode,
      classes: classes,
      functions: functions,
      imports: imports,
      dependencies: _extractDependencies(imports),
    );
  }

  /// 批量分析目录
  Future<Map<String, CodeAnalysisResult>> analyzeDirectory(String directoryPath) async {
    final results = <String, CodeAnalysisResult>{};
    final directory = Directory(directoryPath);

    if (!await directory.exists()) {
      return results;
    }

    await for (final entity in directory.list(recursive: true, followLinks: false)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        final result = await analyzeFile(entity.path);
        results[entity.path] = result;
      }
    }

    return results;
  }

  /// 生成摘要报告
  Map<String, dynamic> generateSummaryReport(Map<String, CodeAnalysisResult> results) {
    var totalFiles = 0;
    var totalLines = 0;
    var totalClasses = 0;
    var totalFunctions = 0;
    final allImports = <String>{};
    final allDependencies = <String>{};

    for (final result in results.values) {
      totalFiles++;
      totalLines += result.linesOfCode;
      totalClasses += result.classes;
      totalFunctions += result.functions;
      allImports.addAll(result.imports);
      allDependencies.addAll(result.dependencies);
    }

    return {
      'totalFiles': totalFiles,
      'totalLinesOfCode': totalLines,
      'totalClasses': totalClasses,
      'totalFunctions': totalFunctions,
      'uniqueImports': allImports.length,
      'uniqueDependencies': allDependencies.length,
      'averageLinesPerFile': totalFiles > 0 ? (totalLines / totalFiles).round() : 0,
      'averageClassesPerFile': totalFiles > 0 ? (totalClasses / totalFiles).round() : 0,
      'averageFunctionsPerFile': totalFiles > 0 ? (totalFunctions / totalFiles).round() : 0,
    };
  }

  List<String> _extractDependencies(List<String> imports) {
    final dependencies = <String>[];

    for (final import in imports) {
      if (import.startsWith('package:your_finance_flutter/')) {
        // 内部依赖
        final parts = import.replaceFirst('package:your_finance_flutter/', '').split('/');
        if (parts.isNotEmpty) {
          dependencies.add(parts[0]);
        }
      } else if (import.startsWith('package:')) {
        // 外部包依赖
        final packageName = import.split('/').first.replaceFirst('package:', '');
        dependencies.add(packageName);
      } else if (import.startsWith('dart:')) {
        // Dart SDK
        dependencies.add('dart-sdk');
      }
    }

    return dependencies.toSet().toList();
  }
}
