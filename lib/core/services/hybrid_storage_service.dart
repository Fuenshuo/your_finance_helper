import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:your_finance_flutter/core/models/account.dart';
import 'package:your_finance_flutter/core/models/asset_item.dart';
import 'package:your_finance_flutter/core/models/budget.dart';
import 'package:your_finance_flutter/core/models/currency.dart';
import 'package:your_finance_flutter/core/models/transaction.dart';
import 'package:your_finance_flutter/core/services/base_service.dart';
import 'package:your_finance_flutter/core/services/persistent_storage_service.dart';
import 'package:your_finance_flutter/core/services/storage_service.dart';

/// 混合存储服务 - 优先使用文件系统，回退到SharedPreferences
/// 这样在开发过程中数据更持久，重新安装应用时也能保留数据
class HybridStorageService extends BaseService {
  HybridStorageService._();

  static HybridStorageService? _instance;
  static PersistentStorageService? _persistentStorage;
  static StorageService? _sharedPreferencesStorage;

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
  String get serviceName => 'HybridStorageService';

  static Future<HybridStorageService> getInstance() async {
    _instance ??= HybridStorageService._();

    // 在Web平台上只使用SharedPreferences，不使用文件系统
    if (kIsWeb) {
      _sharedPreferencesStorage ??= await StorageService.getInstance();
    } else {
      _persistentStorage ??= await PersistentStorageService.getInstance();
      _sharedPreferencesStorage ??= await StorageService.getInstance();
    }

    return _instance!;
  }

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    _isLoading = true;
    try {
      // The initialization is already done in getInstance()
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
      // Reset storage services
      if (_persistentStorage != null) {
        await _persistentStorage!.reset();
      }
      if (_sharedPreferencesStorage != null) {
        await _sharedPreferencesStorage!.reset();
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
    // Dispose of storage services
    if (_persistentStorage != null) {
      await _persistentStorage!.dispose();
    }
    if (_sharedPreferencesStorage != null) {
      await _sharedPreferencesStorage!.dispose();
    }
    _isInitialized = false;
  }

  @override
  Future<bool> healthCheck() async {
    try {
      // Check if both storage services are healthy
      var persistentHealthy = true;
      var sharedHealthy = true;

      if (_persistentStorage != null) {
        persistentHealthy = await _persistentStorage!.healthCheck();
      }
      if (_sharedPreferencesStorage != null) {
        sharedHealthy = await _sharedPreferencesStorage!.healthCheck();
      }

      return persistentHealthy && sharedHealthy;
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
        'hasPersistentStorage': _persistentStorage != null,
        'hasSharedPreferencesStorage': _sharedPreferencesStorage != null,
        'lastError': lastError,
      };

  // 资产相关方法
  Future<void> saveAssets(List<AssetItem> assets) async {
    // 在Web平台上只使用SharedPreferences
    if (kIsWeb) {
      await _sharedPreferencesStorage!.saveAssets(assets);
    } else {
      // 同时保存到两种存储方式
      await _persistentStorage!.saveAssets(assets);
      await _sharedPreferencesStorage!.saveAssets(assets);
    }
  }

  Future<List<AssetItem>> getAssets() async {
    // 在Web平台上只使用SharedPreferences
    if (kIsWeb) {
      final assets = await _sharedPreferencesStorage!.getAssets();
      return assets;
    }

    // 优先从文件系统读取
    final persistentAssets = await _persistentStorage!.getAssets();

    if (persistentAssets.isNotEmpty) {
      return persistentAssets;
    }

    // 即使文件系统有数据，也检查SharedPreferences是否有更多数据
    final sharedPrefsAssets = await _sharedPreferencesStorage!.getAssets();

    // 如果SharedPreferences有更多数据，使用SharedPreferences的数据
    if (sharedPrefsAssets.length > persistentAssets.length) {
      await _persistentStorage!.saveAssets(sharedPrefsAssets);
      return sharedPrefsAssets;
    }

    return persistentAssets;
  }

  Future<void> addAsset(AssetItem asset) async {
    final assets = await getAssets();
    assets.add(asset);
    await saveAssets(assets);
  }

  Future<void> updateAsset(AssetItem asset) async {
    final assets = await getAssets();
    final index = assets.indexWhere((a) => a.id == asset.id);
    if (index != -1) {
      assets[index] = asset;
      await saveAssets(assets);
    }
  }

  Future<void> deleteAsset(String assetId) async {
    final assets = await getAssets();
    assets.removeWhere((asset) => asset.id == assetId);
    await saveAssets(assets);
  }

  // 交易相关方法
  Future<void> saveTransactions(List<Transaction> transactions) async {
    if (kIsWeb) {
      await _sharedPreferencesStorage!.saveTransactions(transactions);
    } else {
      await _persistentStorage!.saveTransactions(transactions);
      await _sharedPreferencesStorage!.saveTransactions(transactions);
    }
  }

  Future<List<Transaction>> loadTransactions() async {
    if (kIsWeb) {
      return _sharedPreferencesStorage!.loadTransactions();
    }

    final persistentTransactions = await _persistentStorage!.loadTransactions();
    if (persistentTransactions.isNotEmpty) {
      return persistentTransactions;
    }

    final sharedPrefsTransactions =
        await _sharedPreferencesStorage!.loadTransactions();
    if (sharedPrefsTransactions.isNotEmpty) {
      await _persistentStorage!.saveTransactions(sharedPrefsTransactions);
    }

    return sharedPrefsTransactions;
  }

  // 账户相关方法
  Future<void> saveAccounts(List<Account> accounts) async {
    if (kIsWeb) {
      await _sharedPreferencesStorage!.saveAccounts(accounts);
    } else {
      await _persistentStorage!.saveAccounts(accounts);
      await _sharedPreferencesStorage!.saveAccounts(accounts);
    }
  }

  Future<List<Account>> loadAccounts() async {
    if (kIsWeb) {
      return _sharedPreferencesStorage!.loadAccounts();
    }

    final persistentAccounts = await _persistentStorage!.loadAccounts();
    if (persistentAccounts.isNotEmpty) {
      return persistentAccounts;
    }

    final sharedPrefsAccounts = await _sharedPreferencesStorage!.loadAccounts();
    if (sharedPrefsAccounts.isNotEmpty) {
      await _persistentStorage!.saveAccounts(sharedPrefsAccounts);
    }

    return sharedPrefsAccounts;
  }

  // 预算相关方法
  Future<void> saveEnvelopeBudgets(List<EnvelopeBudget> budgets) async {
    if (kIsWeb) {
      await _sharedPreferencesStorage!.saveEnvelopeBudgets(budgets);
    } else {
      await _persistentStorage!.saveEnvelopeBudgets(budgets);
      await _sharedPreferencesStorage!.saveEnvelopeBudgets(budgets);
    }
  }

  Future<List<EnvelopeBudget>> loadEnvelopeBudgets() async {
    if (kIsWeb) {
      return _sharedPreferencesStorage!.loadEnvelopeBudgets();
    }

    final persistentBudgets = await _persistentStorage!.loadEnvelopeBudgets();
    if (persistentBudgets.isNotEmpty) {
      return persistentBudgets;
    }

    final sharedPrefsBudgets =
        await _sharedPreferencesStorage!.loadEnvelopeBudgets();
    if (sharedPrefsBudgets.isNotEmpty) {
      await _persistentStorage!.saveEnvelopeBudgets(sharedPrefsBudgets);
    }

    return sharedPrefsBudgets;
  }

  Future<void> saveZeroBasedBudgets(List<ZeroBasedBudget> budgets) async {
    if (kIsWeb) {
      await _sharedPreferencesStorage!.saveZeroBasedBudgets(budgets);
    } else {
      await _persistentStorage!.saveZeroBasedBudgets(budgets);
      await _sharedPreferencesStorage!.saveZeroBasedBudgets(budgets);
    }
  }

  Future<List<ZeroBasedBudget>> loadZeroBasedBudgets() async {
    if (kIsWeb) {
      return _sharedPreferencesStorage!.loadZeroBasedBudgets();
    }

    final persistentBudgets = await _persistentStorage!.loadZeroBasedBudgets();
    if (persistentBudgets.isNotEmpty) {
      return persistentBudgets;
    }

    final sharedPrefsBudgets =
        await _sharedPreferencesStorage!.loadZeroBasedBudgets();
    if (sharedPrefsBudgets.isNotEmpty) {
      await _persistentStorage!.saveZeroBasedBudgets(sharedPrefsBudgets);
    }

    return sharedPrefsBudgets;
  }

  // 薪资收入相关方法
  Future<void> saveSalaryIncomes(List<SalaryIncome> incomes) async {
    if (kIsWeb) {
      await _sharedPreferencesStorage!.saveSalaryIncomes(incomes);
    } else {
      await _persistentStorage!.saveSalaryIncomes(incomes);
      await _sharedPreferencesStorage!.saveSalaryIncomes(incomes);
    }
  }

  Future<List<SalaryIncome>> loadSalaryIncomes() async {
    if (kIsWeb) {
      return _sharedPreferencesStorage!.loadSalaryIncomes();
    }

    final persistentIncomes = await _persistentStorage!.loadSalaryIncomes();
    if (persistentIncomes.isNotEmpty) {
      return persistentIncomes;
    }

    final sharedPrefsIncomes =
        await _sharedPreferencesStorage!.loadSalaryIncomes();
    if (sharedPrefsIncomes.isNotEmpty) {
      await _persistentStorage!.saveSalaryIncomes(sharedPrefsIncomes);
    }

    return sharedPrefsIncomes;
  }

  // 月度钱包相关方法
  Future<void> saveMonthlyWallets(List<MonthlyWallet> wallets) async {
    if (kIsWeb) {
      await _sharedPreferencesStorage!.saveMonthlyWallets(wallets);
    } else {
      await _persistentStorage!.saveMonthlyWallets(wallets);
      await _sharedPreferencesStorage!.saveMonthlyWallets(wallets);
    }
  }

  Future<List<MonthlyWallet>> loadMonthlyWallets() async {
    if (kIsWeb) {
      return _sharedPreferencesStorage!.loadMonthlyWallets();
    }

    final persistentWallets = await _persistentStorage!.loadMonthlyWallets();
    if (persistentWallets.isNotEmpty) {
      return persistentWallets;
    }

    final sharedPrefsWallets =
        await _sharedPreferencesStorage!.loadMonthlyWallets();
    if (sharedPrefsWallets.isNotEmpty) {
      await _persistentStorage!.saveMonthlyWallets(sharedPrefsWallets);
    }

    return sharedPrefsWallets;
  }

  // 币种相关方法
  Future<void> saveCurrencies(List<Currency> currencies) async {
    await _sharedPreferencesStorage!.saveCurrencies(currencies);
  }

  Future<List<Currency>> loadCurrencies() async =>
      _sharedPreferencesStorage!.loadCurrencies();

  Future<void> saveExchangeRates(List<ExchangeRate> exchangeRates) async {
    await _sharedPreferencesStorage!.saveExchangeRates(exchangeRates);
  }

  Future<List<ExchangeRate>> loadExchangeRates() async =>
      _sharedPreferencesStorage!.loadExchangeRates();

  // 草稿交易相关方法
  Future<void> saveDraftTransactions(
    List<Transaction> draftTransactions,
  ) async {
    await _sharedPreferencesStorage!.saveDraftTransactions(draftTransactions);
  }

  Future<List<Transaction>> loadDraftTransactions() async =>
      _sharedPreferencesStorage!.loadDraftTransactions();

  // 清空所有数据
  Future<void> clearAll() async {
    if (kIsWeb) {
      await _sharedPreferencesStorage!.clearAll();
    } else {
      await _persistentStorage!.clearAll();
      await _sharedPreferencesStorage!.clearAll();
    }
  }

  // 导出数据
  Future<String> exportAllData() async {
    if (kIsWeb) {
      // Web平台不能导出到文件，返回JSON字符串
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

      return const JsonEncoder.withIndent('  ').convert(exportData);
    } else {
      return _persistentStorage!.exportAllData();
    }
  }

  // 导入数据
  Future<void> importFromFile(String filePath) async {
    await _persistentStorage!.importFromFile(filePath);
  }

  // 获取存储信息
  Future<Map<String, dynamic>> getStorageInfo() async =>
      _persistentStorage!.getStorageInfo();
}
