import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('📄 读取迁移报告...');

  try {
    final appDir = await getApplicationDocumentsDirectory();
    final reportFile = File('${appDir.path}/migration_report.json');

    if (await reportFile.exists()) {
      final content = await reportFile.readAsString();
      print('✅ 迁移报告内容:');
      print(content);

      // 尝试解析 JSON
      try {
        final jsonData = jsonDecode(content);
        print('\n📊 解析后的数据:');
        print('  - 版本: ${jsonData['version']}');
        print('  - 时间戳: ${jsonData['timestamp']}');

        if (jsonData.containsKey('modules')) {
          print('  - 模块:');
          final modules = jsonData['modules'] as Map<String, dynamic>;
          for (final entry in modules.entries) {
            final moduleData = entry.value as Map<String, dynamic>;
            print('    ${entry.key}: 总数=${moduleData['total']}, 成功=${moduleData['imported']}, 失败=${moduleData['failed']}');
          }
        }

        if (jsonData.containsKey('errors') && jsonData['errors'].isNotEmpty) {
          print('  - 错误:');
          for (final error in jsonData['errors']) {
            print('    $error');
          }
        }
      } catch (e) {
        print('❌ JSON 解析失败: $e');
      }
    } else {
      print('❌ 迁移报告文件不存在');
    }

  } catch (e, stackTrace) {
    print('❌ 读取失败: $e');
    print('📋 堆栈跟踪: $stackTrace');
  }
}
