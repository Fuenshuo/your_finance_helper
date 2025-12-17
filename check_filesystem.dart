import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('🔍 检查文件系统中的遗留数据文件...');

  try {
    // 获取应用文档目录
    final appDir = await getApplicationDocumentsDirectory();
    print('📁 应用文档目录: ${appDir.path}');

    // 递归查找所有 JSON 文件
    await _scanDirectory(appDir);

    // 检查常见的位置
    final commonPaths = [
      '${appDir.path}/assets.json',
      '${appDir.path}/transactions.json',
      '${appDir.path}/data/transactions.json',
      '${appDir.path}/backup/transactions.json',
    ];

    print('\n🔍 检查常见路径:');
    for (final path in commonPaths) {
      final file = File(path);
      if (await file.exists()) {
        print('✅ 找到文件: $path');
        final content = await file.readAsString();
        print('  文件大小: ${content.length} 字符');
        if (content.length < 500) {
          print('  内容预览: $content');
        } else {
          print('  内容预览: ${content.substring(0, 200)}...');
        }
      } else {
        print('❌ 文件不存在: $path');
      }
    }
  } catch (e, stackTrace) {
    print('❌ 检查失败: $e');
    print('📋 堆栈跟踪: $stackTrace');
  }
}

Future<void> _scanDirectory(Directory dir) async {
  try {
    final entities = dir.listSync(recursive: true);
    final jsonFiles =
        entities.whereType<File>().where((file) => file.path.endsWith('.json'));

    if (jsonFiles.isNotEmpty) {
      print('\n📄 发现的 JSON 文件:');
      for (final file in jsonFiles) {
        print('  - ${file.path} (${await file.length()} 字节)');
      }
    }
  } catch (e) {
    print('⚠️ 扫描目录失败 ${dir.path}: $e');
  }
}
