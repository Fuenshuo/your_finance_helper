/// 文件系统扫描工具 - 用于分析Flutter应用目录结构
///
/// 提供文件扫描、过滤和统计功能，支持：
/// - 递归目录遍历
/// - 文件类型过滤
/// - 大小统计
/// - 修改时间分析
library;

import 'dart:io';

import 'package:path/path.dart' as path;

/// 文件扫描结果
class ScanResult {

  ScanResult({
    required this.filePath,
    required this.relativePath,
    required this.type,
    required this.size,
    required this.modified,
    required this.extension,
  });
  final String filePath;
  final String relativePath;
  final FileSystemEntityType type;
  final int size;
  final DateTime modified;
  final String extension;

  bool get isDartFile => extension == '.dart';
  bool get isAssetFile => _isAssetPath(relativePath);
  bool get isConfigFile => _isConfigPath(relativePath);
  bool get isLegacyFile => _isLegacyPath(relativePath);

  static bool _isAssetPath(String relativePath) => relativePath.startsWith('assets/') ||
           relativePath.startsWith('images/') ||
           relativePath.contains('/assets/');

  static bool _isConfigPath(String relativePath) => relativePath.contains('pubspec.yaml') ||
           relativePath.contains('.yaml') ||
           relativePath.contains('.json') ||
           relativePath.startsWith('.');

  static bool _isLegacyPath(String relativePath) => relativePath.startsWith('legacy/') ||
           relativePath.startsWith('backup_') ||
           relativePath.contains('/legacy/');
}

/// 文件系统扫描工具
class FileScanner {

  FileScanner({
    required this.rootPath,
    this.excludePatterns = const [
      '.git',
      'build',
      '.dart_tool',
      'ios/Pods',
      'android/.gradle',
      'node_modules',
    ],
  });
  final String rootPath;
  final List<String> excludePatterns;

  /// 扫描目录并返回所有文件信息
  Future<List<ScanResult>> scanDirectory([
    String? subPath,
    Set<String>? fileExtensions,
  ]) async {
    final scanPath = subPath != null ? path.join(rootPath, subPath) : rootPath;
    final directory = Directory(scanPath);

    if (!await directory.exists()) {
      return [];
    }

    final results = <ScanResult>[];

    await for (final entity in directory.list(recursive: true, followLinks: false)) {
      // 检查是否应该排除
      if (_shouldExclude(entity.path)) {
        continue;
      }

      // 检查文件扩展名过滤
      if (fileExtensions != null) {
        final extension = path.extension(entity.path).toLowerCase();
        if (!fileExtensions.contains(extension)) {
          continue;
        }
      }

      try {
        final stat = await entity.stat();
        final relativePath = path.relative(entity.path, from: rootPath);

        results.add(ScanResult(
          filePath: entity.path,
          relativePath: relativePath,
          type: entity is File ? FileSystemEntityType.file : FileSystemEntityType.directory,
          size: stat.size,
          modified: stat.modified,
          extension: path.extension(entity.path).toLowerCase(),
        ),);
      } catch (e) {
        // 忽略无法访问的文件
        continue;
      }
    }

    return results;
  }

  /// 获取目录统计信息
  Future<Map<String, dynamic>> getDirectoryStats([String? subPath]) async {
    final files = await scanDirectory(subPath);

    final stats = {
      'totalFiles': files.where((f) => f.type == FileSystemEntityType.file).length,
      'totalDirectories': files.where((f) => f.type == FileSystemEntityType.directory).length,
      'totalSize': files.fold<int>(0, (sum, f) => sum + f.size),
      'dartFiles': files.where((f) => f.isDartFile).length,
      'assetFiles': files.where((f) => f.isAssetFile).length,
      'configFiles': files.where((f) => f.isConfigFile).length,
      'legacyFiles': files.where((f) => f.isLegacyFile).length,
      'extensions': <String, int>{},
    };

    // 统计文件扩展名
    final extensions = stats['extensions']! as Map<String, int>;
    for (final file in files.where((f) => f.type == FileSystemEntityType.file)) {
      final ext = file.extension.isEmpty ? 'no-extension' : file.extension;
      extensions[ext] = (extensions[ext] ?? 0) + 1;
    }

    return stats;
  }

  /// 查找包含特定内容的Dart文件
  Future<List<ScanResult>> findDartFilesWithContent(String searchPattern) async {
    final dartFiles = await scanDirectory(null, {'.dart'});
    final matchingFiles = <ScanResult>[];

    for (final file in dartFiles) {
      try {
        final content = await File(file.filePath).readAsString();
        if (content.contains(searchPattern)) {
          matchingFiles.add(file);
        }
      } catch (e) {
        // 忽略无法读取的文件
        continue;
      }
    }

    return matchingFiles;
  }

  /// 查找演示和测试文件
  Future<List<ScanResult>> findDemoAndTestFiles() async {
    final allFiles = await scanDirectory();
    return allFiles.where((file) =>
      file.relativePath.contains('_demo.dart') ||
      file.relativePath.contains('_test.dart') ||
      file.relativePath.contains('/demo/') ||
      file.relativePath.contains('/test/'),
    ).toList();
  }

  bool _shouldExclude(String filePath) {
    final relativePath = path.relative(filePath, from: rootPath);
    return excludePatterns.any(relativePath.contains);
  }
}

/// 扫描结果分析器
class ScanResultAnalyzer {
  static Map<String, dynamic> analyzeResults(List<ScanResult> results) {
    final analysis = {
      'fileCount': results.where((r) => r.type == FileSystemEntityType.file).length,
      'directoryCount': results.where((r) => r.type == FileSystemEntityType.directory).length,
      'totalSize': results.fold<int>(0, (sum, r) => sum + r.size),
      'dartFiles': results.where((r) => r.isDartFile).toList(),
      'assetFiles': results.where((r) => r.isAssetFile).toList(),
      'configFiles': results.where((r) => r.isConfigFile).toList(),
      'legacyFiles': results.where((r) => r.isLegacyFile).toList(),
      'demoFiles': <ScanResult>[],
      'recentlyModified': <ScanResult>[],
    };

    // 查找演示文件
    analysis['demoFiles'] = results.where((r) =>
      r.relativePath.contains('_demo') ||
      r.relativePath.contains('demo/'),
    ).toList();

    // 查找最近修改的文件（7天内）
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    analysis['recentlyModified'] = results.where((r) =>
      r.modified.isAfter(weekAgo),
    ).toList();

    return analysis;
  }
}
