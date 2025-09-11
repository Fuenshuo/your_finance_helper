import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:your_finance_flutter/models/account.dart';
import 'package:your_finance_flutter/models/asset_item.dart';
import 'package:your_finance_flutter/models/budget.dart';
import 'package:your_finance_flutter/models/transaction.dart';

/// 持久化存储服务 - 使用文件系统存储，在应用重新安装时也能保留数据
class PersistentStorageService {
  PersistentStorageService._();

  static PersistentStorageService? _instance;
  static Directory? _documentsDirectory;

  static Future<PersistentStorageService> getInstance() async {
    _instance ??= PersistentStorageService._();
    _documentsDirectory ??= await getApplicationDocumentsDirectory();
    return _instance!;
  }

  // 获取数据文件路径
  String _getFilePath(String fileName) =>
      '${_documentsDirectory!.path}/$fileName.json';

  // 写入JSON文件
  Future<void> _writeJsonFile(
    String fileName,
    Map<String, dynamic> data,
  ) async {
    final file = File(_getFilePath(fileName));
    final jsonString = const JsonEncoder.withIndent('  ').convert(data);
    await file.writeAsString(jsonString);
  }

  // 读取JSON文件
  Future<Map<String, dynamic>?> _readJsonFile(String fileName) async {
    try {
      final file = File(_getFilePath(fileName));
      if (!await file.exists()) return null;

      final jsonString = await file.readAsString();
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      print('❌ 读取JSON文件失败: $fileName, 错误: $e');
      // 如果文件损坏，删除它
      try {
        final file = File(_getFilePath(fileName));
        if (await file.exists()) {
          await file.delete();
          print('🗑️ 已删除损坏的文件: $fileName');
        }
      } catch (deleteError) {
        print('❌ 删除损坏文件失败: $deleteError');
      }
      return null;
    }
  }

  // 保存资产列表
  Future<void> saveAssets(List<AssetItem> assets) async {
    print('📁 PersistentStorageService.saveAssets() 开始执行');
    print('📁 要保存的资产数量: ${assets.length}');
    print('📁 存储路径: ${_documentsDirectory?.path}');

    for (var i = 0; i < assets.length; i++) {
      final asset = assets[i];
      print('📁 资产${i + 1}: ${asset.name} - ${asset.amount}');
    }

    final data = {
      'assets': assets.map((asset) => asset.toJson()).toList(),
      'lastUpdated': DateTime.now().toIso8601String(),
    };

    await _writeJsonFile('assets', data);
    print('✅ 文件系统资产保存完成');

    // 验证保存是否成功
    final savedAssets = await getAssets();
    print('🔍 验证保存结果: 期望${assets.length}个，实际${savedAssets.length}个');
    if (savedAssets.length != assets.length) {
      print('❌ 保存验证失败！数据可能丢失');
      for (var i = 0; i < savedAssets.length; i++) {
        print(
          '🔍 保存的资产${i + 1}: ${savedAssets[i].name} - ${savedAssets[i].amount}',
        );
      }
    } else {
      print('✅ 保存验证成功');
    }
  }

  // 获取资产列表
  Future<List<AssetItem>> getAssets() async {
    print('📁 PersistentStorageService.getAssets() 开始执行');
    print('📁 存储路径: ${_documentsDirectory?.path}');

    // 检查文件是否存在
    final file = File(_getFilePath('assets'));
    final fileExists = await file.exists();
    print('📁 assets.json 文件存在: $fileExists');

    if (fileExists) {
      final fileSize = await file.length();
      print('📁 assets.json 文件大小: $fileSize 字节');
    }

    final data = await _readJsonFile('assets');
    if (data == null || data['assets'] == null) {
      print('📁 没有找到资产数据文件或数据为空');
      return [];
    }

    final assetsJson = data['assets'] as List<dynamic>;
    final assets = assetsJson
        .map((json) => AssetItem.fromJson(json as Map<String, dynamic>))
        .toList();

    print('📁 从文件系统加载到${assets.length}个资产');
    for (var i = 0; i < assets.length; i++) {
      final asset = assets[i];
      print('📁 文件系统资产${i + 1}: ${asset.name} - ${asset.amount}');
    }

    return assets;
  }

  // 保存交易列表
  Future<void> saveTransactions(List<Transaction> transactions) async {
    final data = {
      'transactions': transactions.map((t) => t.toJson()).toList(),
      'lastUpdated': DateTime.now().toIso8601String(),
    };
    await _writeJsonFile('transactions', data);
  }

  // 获取交易列表
  Future<List<Transaction>> loadTransactions() async {
    final data = await _readJsonFile('transactions');
    if (data == null || data['transactions'] == null) return [];

    final transactionsJson = data['transactions'] as List<dynamic>;
    return transactionsJson
        .map((json) => Transaction.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // 保存账户列表
  Future<void> saveAccounts(List<Account> accounts) async {
    final data = {
      'accounts': accounts.map((a) => a.toJson()).toList(),
      'lastUpdated': DateTime.now().toIso8601String(),
    };
    await _writeJsonFile('accounts', data);
  }

  // 获取账户列表
  Future<List<Account>> loadAccounts() async {
    final data = await _readJsonFile('accounts');
    if (data == null || data['accounts'] == null) return [];

    final accountsJson = data['accounts'] as List<dynamic>;
    return accountsJson
        .map((json) => Account.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // 保存预算列表
  Future<void> saveEnvelopeBudgets(List<EnvelopeBudget> budgets) async {
    final data = {
      'envelopeBudgets': budgets.map((b) => b.toJson()).toList(),
      'lastUpdated': DateTime.now().toIso8601String(),
    };
    await _writeJsonFile('envelope_budgets', data);
  }

  // 获取预算列表
  Future<List<EnvelopeBudget>> loadEnvelopeBudgets() async {
    final data = await _readJsonFile('envelope_budgets');
    if (data == null || data['envelopeBudgets'] == null) return [];

    final budgetsJson = data['envelopeBudgets'] as List<dynamic>;
    return budgetsJson
        .map((json) => EnvelopeBudget.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // 保存零基预算列表
  Future<void> saveZeroBasedBudgets(List<ZeroBasedBudget> budgets) async {
    final data = {
      'zeroBasedBudgets': budgets.map((b) => b.toJson()).toList(),
      'lastUpdated': DateTime.now().toIso8601String(),
    };
    await _writeJsonFile('zero_based_budgets', data);
  }

  // 获取零基预算列表
  Future<List<ZeroBasedBudget>> loadZeroBasedBudgets() async {
    final data = await _readJsonFile('zero_based_budgets');
    if (data == null || data['zeroBasedBudgets'] == null) return [];

    final budgetsJson = data['zeroBasedBudgets'] as List<dynamic>;
    return budgetsJson
        .map((json) => ZeroBasedBudget.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // 导出所有数据到文件
  Future<String> exportAllData() async {
    final assets = await getAssets();
    final transactions = await loadTransactions();
    final accounts = await loadAccounts();
    final envelopeBudgets = await loadEnvelopeBudgets();
    final zeroBasedBudgets = await loadZeroBasedBudgets();

    final exportData = {
      'assets': assets.map((a) => a.toJson()).toList(),
      'transactions': transactions.map((t) => t.toJson()).toList(),
      'accounts': accounts.map((a) => a.toJson()).toList(),
      'envelopeBudgets': envelopeBudgets.map((b) => b.toJson()).toList(),
      'zeroBasedBudgets': zeroBasedBudgets.map((b) => b.toJson()).toList(),
      'exportTime': DateTime.now().toIso8601String(),
      'version': '1.0.0',
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);

    // 保存到文件
    final file = File(
      _getFilePath('backup_${DateTime.now().millisecondsSinceEpoch}.json'),
    );
    await file.writeAsString(jsonString);

    return file.path;
  }

  // 从文件导入数据
  Future<void> importFromFile(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) throw Exception('文件不存在');

    final jsonString = await file.readAsString();
    final importData = jsonDecode(jsonString) as Map<String, dynamic>;

    // 导入资产
    if (importData['assets'] != null) {
      final assets = (importData['assets'] as List)
          .map((json) => AssetItem.fromJson(json as Map<String, dynamic>))
          .toList();
      await saveAssets(assets);
    }

    // 导入交易
    if (importData['transactions'] != null) {
      final transactions = (importData['transactions'] as List)
          .map((json) => Transaction.fromJson(json as Map<String, dynamic>))
          .toList();
      await saveTransactions(transactions);
    }

    // 导入账户
    if (importData['accounts'] != null) {
      final accounts = (importData['accounts'] as List)
          .map((json) => Account.fromJson(json as Map<String, dynamic>))
          .toList();
      await saveAccounts(accounts);
    }

    // 导入预算
    if (importData['envelopeBudgets'] != null) {
      final budgets = (importData['envelopeBudgets'] as List)
          .map((json) => EnvelopeBudget.fromJson(json as Map<String, dynamic>))
          .toList();
      await saveEnvelopeBudgets(budgets);
    }

    if (importData['zeroBasedBudgets'] != null) {
      final budgets = (importData['zeroBasedBudgets'] as List)
          .map((json) => ZeroBasedBudget.fromJson(json as Map<String, dynamic>))
          .toList();
      await saveZeroBasedBudgets(budgets);
    }
  }

  // 清空所有数据
  Future<void> clearAll() async {
    print('🗑️ PersistentStorageService.clearAll() 开始执行');
    print('📁 存储路径: ${_documentsDirectory!.path}');

    final files = [
      'assets',
      'transactions',
      'accounts',
      'envelope_budgets',
      'zero_based_budgets',
    ];

    for (final fileName in files) {
      final file = File(_getFilePath(fileName));
      final exists = await file.exists();
      print('📁 检查文件: $fileName, 存在: $exists');

      if (exists) {
        await file.delete();
        print('🗑️ 已删除文件: $fileName');
      }
    }

    print('🗑️ PersistentStorageService.clearAll() 执行完成');
  }

  // 获取存储信息
  Future<Map<String, dynamic>> getStorageInfo() async {
    final files = [
      'assets.json',
      'transactions.json',
      'accounts.json',
      'envelope_budgets.json',
      'zero_based_budgets.json',
    ];

    final info = <String, dynamic>{};
    var totalSize = 0;

    for (final fileName in files) {
      final file = File(_getFilePath(fileName));
      if (await file.exists()) {
        final stat = await file.stat();
        info[fileName] = {
          'size': stat.size,
          'modified': stat.modified.toIso8601String(),
        };
        totalSize += stat.size;
      }
    }

    info['totalSize'] = totalSize;
    info['storagePath'] = _documentsDirectory!.path;

    return info;
  }
}
