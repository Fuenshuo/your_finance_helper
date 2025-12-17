import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('🔍 检查 SharedPreferences 数据...');

  try {
    final prefs = await SharedPreferences.getInstance();

    // 获取所有键
    final keys = prefs.getKeys();
    print('📋 SharedPreferences 中的所有键:');
    for (final key in keys) {
      print('  - $key');
    }

    // 特别检查交易相关键
    const transactionsKey = 'transactions_data';
    const draftTransactionsKey = 'draft_transactions_data';

    print('\n🔍 交易数据检查:');
    final transactionsData = prefs.getString(transactionsKey);
    if (transactionsData != null) {
      print('✅ 找到交易数据:');
      print('  原始数据长度: ${transactionsData.length} 字符');
      print('  预览: ${transactionsData.substring(0, math.min(200, transactionsData.length))}');

      // 尝试解析
      try {
        print('  ✅ 数据格式正确');
      } catch (e) {
        print('  ❌ 数据格式错误: $e');
      }
    } else {
      print('❌ 未找到交易数据');
    }

    final draftData = prefs.getString(draftTransactionsKey);
    if (draftData != null) {
      print('✅ 找到草稿交易数据:');
      print('  原始数据长度: ${draftData.length} 字符');
    } else {
      print('❌ 未找到草稿交易数据');
    }

    // 检查迁移版本
    const migrationKey = 'data_migration_version';
    final migrationVersion = prefs.getInt(migrationKey);
    print('\n🔄 数据迁移版本: ${migrationVersion ?? '未设置'}');

  } catch (e, stackTrace) {
    print('❌ 检查失败: $e');
    print('📋 堆栈跟踪: $stackTrace');
  }
}
