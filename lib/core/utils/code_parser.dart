/// Dart代码解析工具 - 用于分析代码结构和依赖关系
///
/// 提供以下分析功能：
/// - 类和函数定义提取
/// - 导入语句分析
/// - 依赖关系图构建
/// - 代码复杂度评估
library;

import 'dart:io';

import 'package:path/path.dart' as path;

/// 代码元素类型
enum CodeElementType {
  class_,
  function,
  variable,
  import,
  export,
  widget,
}

/// 代码元素
class CodeElement {
  CodeElement({
    required this.type,
    required this.name,
    required this.lineNumber,
    required this.sourceFile,
    this.returnType,
    this.parameters = const [],
    this.superClass,
    this.interfaces = const [],
  });
  final CodeElementType type;
  final String name;
  final String? returnType;
  final List<String> parameters;
  final int lineNumber;
  final String sourceFile;
  final String? superClass;
  final List<String> interfaces;
}

/// 代码依赖关系
class CodeDependency {
  CodeDependency({
    required this.fromFile,
    required this.toFile,
    required this.type,
    this.importedElement,
  });
  final String fromFile;
  final String toFile;
  final DependencyType type;
  final String? importedElement;
}

/// 依赖类型
enum DependencyType {
  import,
  export,
  part,
  partOf,
}

/// Dart代码解析器
class CodeParser {
  final RegExp _classRegex = RegExp(
    r'^(?:abstract\s+)?(?:class|enum)\s+(\w+)(?:\s+extends\s+(\w+))?(?:\s+implements\s+(.+?))?\s*\{',
    multiLine: true,
  );

  final RegExp _functionRegex = RegExp(
    r'^(?:static\s+)?(?:(\w+)\s+)?(\w+)\s*\([^)]*\)\s*\{',
    multiLine: true,
  );

  final RegExp _importRegex = RegExp(r'import\s+.*?', multiLine: true);
  final RegExp _exportRegex = RegExp(r'export\s+.*?', multiLine: true);
  final RegExp _partRegex = RegExp(r'part\s+.*?', multiLine: true);
  final RegExp _partOfRegex = RegExp(r'part\s+of\s+.*?', multiLine: true);

  /// 解析Dart文件
  Future<List<CodeElement>> parseFile(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      return [];
    }

    final content = await file.readAsString();
    final lines = content.split('\n');
    final elements = <CodeElement>[];

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].trim();

      // 解析类定义
      final classMatch = _classRegex.firstMatch(line);
      if (classMatch != null) {
        final className = classMatch.group(1)!;
        final superClass = classMatch.group(2);
        final implements =
            classMatch.group(3)?.split(',').map((s) => s.trim()).toList() ?? [];

        elements.add(
          CodeElement(
            type: line.contains('enum')
                ? CodeElementType.class_
                : CodeElementType.class_,
            name: className,
            lineNumber: i + 1,
            sourceFile: filePath,
            superClass: superClass,
            interfaces: implements,
          ),
        );
        continue;
      }

      // 解析函数定义
      final functionMatch = _functionRegex.firstMatch(line);
      if (functionMatch != null && !line.contains('class')) {
        final returnType = functionMatch.group(1);
        final functionName = functionMatch.group(2)!;

        // 跳过构造函数和getter/setter
        if (functionName.startsWith('get ') ||
            functionName.startsWith('set ')) {
          continue;
        }

        elements.add(
          CodeElement(
            type: CodeElementType.function,
            name: functionName,
            returnType: returnType,
            lineNumber: i + 1,
            sourceFile: filePath,
          ),
        );
        continue;
      }

      // 解析导入语句
      final importMatch = _importRegex.firstMatch(line);
      if (importMatch != null) {
        final importPath = importMatch.group(1)!;
        elements.add(
          CodeElement(
            type: CodeElementType.import,
            name: importPath,
            lineNumber: i + 1,
            sourceFile: filePath,
          ),
        );
        continue;
      }

      // 解析导出语句
      final exportMatch = _exportRegex.firstMatch(line);
      if (exportMatch != null) {
        final exportPath = exportMatch.group(1);
        if (exportPath != null) {
          elements.add(
            CodeElement(
              type: CodeElementType.export,
              name: exportPath,
              lineNumber: i + 1,
              sourceFile: filePath,
            ),
          );
        }
        continue;
      }
    }

    return elements;
  }

  /// 分析文件依赖关系
  Future<List<CodeDependency>> analyzeDependencies(
    String filePath,
    String rootPath,
  ) async {
    final file = File(filePath);
    if (!await file.exists()) {
      return [];
    }

    final content = await file.readAsString();
    final lines = content.split('\n');
    final dependencies = <CodeDependency>[];

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].trim();

      // 解析导入
      final importMatch = _importRegex.firstMatch(line);
      if (importMatch != null) {
        final importPath = importMatch.group(1)!;
        final resolvedPath = _resolveImportPath(importPath, filePath, rootPath);
        if (resolvedPath != null) {
          dependencies.add(
            CodeDependency(
              fromFile: path.relative(filePath, from: rootPath),
              toFile: path.relative(resolvedPath, from: rootPath),
              type: DependencyType.import,
            ),
          );
        }
        continue;
      }

      // 解析导出
      final exportMatch = _exportRegex.firstMatch(line);
      if (exportMatch != null) {
        final exportPath = exportMatch.group(1);
        if (exportPath != null) {
          final resolvedPath =
              _resolveImportPath(exportPath, filePath, rootPath);
          if (resolvedPath != null) {
            dependencies.add(
              CodeDependency(
                fromFile: path.relative(filePath, from: rootPath),
                toFile: path.relative(resolvedPath, from: rootPath),
                type: DependencyType.export,
              ),
            );
          }
        }
        continue;
      }

      // 解析part/part of
      final partMatch = _partRegex.firstMatch(line);
      if (partMatch != null) {
        final partPath = partMatch.group(1)!;
        final resolvedPath = _resolveImportPath(partPath, filePath, rootPath);
        if (resolvedPath != null) {
          dependencies.add(
            CodeDependency(
              fromFile: path.relative(filePath, from: rootPath),
              toFile: path.relative(resolvedPath, from: rootPath),
              type: DependencyType.part,
            ),
          );
        }
        continue;
      }

      final partOfMatch = _partOfRegex.firstMatch(line);
      if (partOfMatch != null) {
        final partOfPath = partOfMatch.group(1)!;
        final resolvedPath = _resolveImportPath(partOfPath, filePath, rootPath);
        if (resolvedPath != null) {
          dependencies.add(
            CodeDependency(
              fromFile: path.relative(filePath, from: rootPath),
              toFile: path.relative(resolvedPath, from: rootPath),
              type: DependencyType.partOf,
            ),
          );
        }
        continue;
      }
    }

    return dependencies;
  }

  /// 解析导入路径为绝对路径
  String? _resolveImportPath(
    String importPath,
    String fromFile,
    String rootPath,
  ) {
    if (importPath.startsWith('dart:') || importPath.startsWith('package:')) {
      // 系统库和包导入，不解析为文件路径
      return null;
    }

    final fromDir = path.dirname(fromFile);

    if (importPath.startsWith('./') || importPath.startsWith('../')) {
      // 相对路径
      final resolvedPath = path.normalize(path.join(fromDir, importPath));
      return resolvedPath;
    } else {
      // 绝对路径（相对于lib或项目根目录）
      final libPath = path.join(rootPath, 'lib', importPath);
      if (File(libPath).existsSync()) {
        return libPath;
      }

      final rootFilePath = path.join(rootPath, importPath);
      if (File(rootFilePath).existsSync()) {
        return rootFilePath;
      }
    }

    return null;
  }
}

/// 代码分析结果
class CodeAnalysisResult {
  CodeAnalysisResult({
    required this.elements,
    required this.dependencies,
    required this.complexityMetrics,
  });
  final List<CodeElement> elements;
  final List<CodeDependency> dependencies;
  final Map<String, int> complexityMetrics;

  int get classCount =>
      elements.where((e) => e.type == CodeElementType.class_).length;
  int get functionCount =>
      elements.where((e) => e.type == CodeElementType.function).length;
  int get importCount =>
      elements.where((e) => e.type == CodeElementType.import).length;

  List<String> getClasses() => elements
      .where((e) => e.type == CodeElementType.class_)
      .map((e) => e.name)
      .toList();

  List<String> getFunctions() => elements
      .where((e) => e.type == CodeElementType.function)
      .map((e) => e.name)
      .toList();
}

/// 批量代码分析器
class BatchCodeAnalyzer {
  BatchCodeAnalyzer() : parser = CodeParser();
  final CodeParser parser;

  /// 分析整个目录的代码
  Future<Map<String, CodeAnalysisResult>> analyzeDirectory(
    String directoryPath,
  ) async {
    final results = <String, CodeAnalysisResult>{};
    final directory = Directory(directoryPath);

    if (!await directory.exists()) {
      return results;
    }

    await for (final entity
        in directory.list(recursive: true, followLinks: false)) {
      if (entity is File && path.extension(entity.path) == '.dart') {
        try {
          final elements = await parser.parseFile(entity.path);
          final dependencies =
              await parser.analyzeDependencies(entity.path, directoryPath);

          final complexityMetrics = _calculateComplexityMetrics(elements);

          results[path.relative(entity.path, from: directoryPath)] =
              CodeAnalysisResult(
            elements: elements,
            dependencies: dependencies,
            complexityMetrics: complexityMetrics,
          );
        } catch (e) {
          // 记录解析错误但继续处理其他文件
          print('Error parsing ${entity.path}: $e');
        }
      }
    }

    return results;
  }

  Map<String, int> _calculateComplexityMetrics(List<CodeElement> elements) => {
        'totalElements': elements.length,
        'classes':
            elements.where((e) => e.type == CodeElementType.class_).length,
        'functions':
            elements.where((e) => e.type == CodeElementType.function).length,
        'imports':
            elements.where((e) => e.type == CodeElementType.import).length,
        'exports':
            elements.where((e) => e.type == CodeElementType.export).length,
      };
}
