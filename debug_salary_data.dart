import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  final prefs = await SharedPreferences.getInstance();

  // 检查所有可能的工资数据键
  final possibleKeys = [
    'salary_incomes_data',
    'salary_income_data',
    'salary_data',
    'income_data',
    'salary_incomes',
  ];

  print('🔍 检查SharedPreferences中的工资数据...\n');

  for (final key in possibleKeys) {
    final data = prefs.getString(key);
    if (data != null) {
      print('✅ 找到数据 - 键: $key');
      print('📊 数据长度: ${data.length} 字符');

      try {
        final jsonData = jsonDecode(data);
        if (jsonData is List) {
          print('📋 数据类型: 列表，包含 ${jsonData.length} 条记录');
          if (jsonData.isNotEmpty) {
            print('👤 第一条记录: ${jsonData[0]}');
          }
        } else if (jsonData is Map) {
          print('📋 数据类型: 对象');
          print('👤 记录内容: $jsonData');
        }
      } catch (e) {
        print('❌ 数据解析失败: $e');
        print('📄 原始数据: ${data.substring(0, min(200, data.length))}...');
      }
    } else {
      print('❌ 未找到数据 - 键: $key');
    }
    print('');
  }

  // 检查数据迁移版本
  final migrationVersion = prefs.getInt('data_migration_version');
  print('🔄 数据迁移版本: ${migrationVersion ?? '未设置'}');

  // 检查迁移历史
  final migrationHistory = prefs.getString('migration_history');
  if (migrationHistory != null) {
    print('📝 迁移历史: $migrationHistory');
  } else {
    print('📝 迁移历史: 无');
  }
}

int min(int a, int b) => a < b ? a : b;

