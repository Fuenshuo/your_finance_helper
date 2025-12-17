import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:your_finance_flutter/core/models/account.dart';
import 'package:your_finance_flutter/core/models/asset_item.dart';
import 'package:your_finance_flutter/core/models/budget.dart';
import 'package:your_finance_flutter/core/models/transaction.dart';
import 'package:your_finance_flutter/core/services/base_service.dart';

/// 持久化存储服务 - 使用文件系统存储，在应用重新安装时也能保留数据
class PersistentStorageService extends BaseService {
  PersistentStorageService._();

  static PersistentStorageService? _instance;
  static Directory? _documentsDirectory;

  bool _isInitialized = false;
  bool _isLoading = false;
  String? _lastError;

  @override
  bool get isInitialized => _isInitialized;

  @override
  bool get isLoading => _isLoading;

  @override
  String? get lastError => _lastError;

  @override
  String get serviceName => 'PersistentStorageService';

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
      // 如果文件损坏，删除它
      try {
        final file = File(_getFilePath(fileName));
        if (await file.exists()) {
          await file.delete();
        }
      } catch (deleteError) {
        // Ignore delete errors
      }
      return null;
    }
  }

  // 保存资产列表
  Future<void> saveAssets(List<AssetItem> assets) async {
    final data = {
      'assets': assets.map((asset) => asset.toJson()).toList(),
      'lastUpdated': DateTime.now().toIso8601String(),
    };

    await _writeJsonFile('assets', data);
  }

  // 获取资产列表
  Future<List<AssetItem>> getAssets() async {
    final data = await _readJsonFile('assets');
    if (data == null || data['assets'] == null) {
      return [];
    }

    final assetsJson = data['assets'] as List<dynamic>;
    final assets = assetsJson
        .map((json) => AssetItem.fromJson(json as Map<String, dynamic>))
        .toList();

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

  // ============================================================================
  // 薪资收入相关方法
  // ============================================================================

  Future<void> saveSalaryIncomes(List<SalaryIncome> incomes) async {
    final data = {'incomes': incomes.map((income) => income.toJson()).toList()};
    await _writeJsonFile('salary_incomes', data);
  }

  Future<List<SalaryIncome>> loadSalaryIncomes() async {
    final data = await _readJsonFile('salary_incomes');
    if (data == null || data['incomes'] == null) return [];

    return (data['incomes'] as List)
        .map((json) => SalaryIncome.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // ============================================================================
  // 月度钱包相关方法
  // ============================================================================

  Future<void> saveMonthlyWallets(List<MonthlyWallet> wallets) async {
    final data = {'wallets': wallets.map((wallet) => wallet.toJson()).toList()};
    await _writeJsonFile('monthly_wallets', data);
  }

  Future<List<MonthlyWallet>> loadMonthlyWallets() async {
    final data = await _readJsonFile('monthly_wallets');
    if (data == null || data['wallets'] == null) return [];

    return (data['wallets'] as List)
        .map((json) => MonthlyWallet.fromJson(json as Map<String, dynamic>))
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
      if (exists) {
        await file.delete();
      }
    }
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

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    _isLoading = true;
    try {
      // Directory initialization is already done in getInstance()
      _isInitialized = true;
      _lastError = null;
    } catch (e) {
      _lastError = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
    }
  }

  @override
  Future<void> reset() async {
    _isLoading = true;
    try {
      // Clear all stored files
      final files = [
        'assets',
        'transactions',
        'accounts',
        'envelope_budgets',
        'zero_based_budgets',
        'currencies',
        'exchange_rates',
        'salary_incomes',
        'monthly_wallets',
      ];

      for (final fileName in files) {
        final file = File(_getFilePath(fileName));
        if (await file.exists()) {
          await file.delete();
        }
      }
      _lastError = null;
    } catch (e) {
      _lastError = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
    }
  }

  @override
  Future<void> dispose() async {
    // Clear references
    _documentsDirectory = null;
    _isInitialized = false;
  }

  @override
  Future<bool> healthCheck() async {
    try {
      // Try to access the directory
      if (_documentsDirectory == null) return false;
      return await _documentsDirectory!.exists();
    } catch (e) {
      _lastError = e.toString();
      return false;
    }
  }

  @override
  Map<String, dynamic> getStats() => {
        'serviceName': serviceName,
        'isInitialized': isInitialized,
        'isLoading': isLoading,
        'documentsDirectory': _documentsDirectory?.path,
        'lastError': lastError,
      };
}
