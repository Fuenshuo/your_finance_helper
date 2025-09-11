import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:your_finance_flutter/models/account.dart';
import 'package:your_finance_flutter/models/asset_item.dart';
import 'package:your_finance_flutter/models/budget.dart';
import 'package:your_finance_flutter/models/currency.dart';
import 'package:your_finance_flutter/models/transaction.dart';
import 'package:your_finance_flutter/services/persistent_storage_service.dart';
import 'package:your_finance_flutter/services/storage_service.dart';

/// 混合存储服务 - 优先使用文件系统，回退到SharedPreferences
/// 这样在开发过程中数据更持久，重新安装应用时也能保留数据
class HybridStorageService {
  HybridStorageService._();

  static HybridStorageService? _instance;
  static PersistentStorageService? _persistentStorage;
  static StorageService? _sharedPreferencesStorage;

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

  // 资产相关方法
  Future<void> saveAssets(List<AssetItem> assets) async {
    print('💾 HybridStorageService.saveAssets() 开始执行');
    print('💾 要保存的资产数量: ${assets.length}');

    // 在Web平台上只使用SharedPreferences
    if (kIsWeb) {
      print('🌐 Web平台：保存到SharedPreferences');
      await _sharedPreferencesStorage!.saveAssets(assets);
      print('✅ Web平台保存完成');
    } else {
      print('📱 移动平台：保存到文件系统和SharedPreferences');
      // 同时保存到两种存储方式
      await _persistentStorage!.saveAssets(assets);
      print('✅ 文件系统保存完成');
      await _sharedPreferencesStorage!.saveAssets(assets);
      print('✅ SharedPreferences保存完成');
    }
    print('💾 所有存储保存完成');

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

  Future<List<AssetItem>> getAssets() async {
    print('🔍 HybridStorageService.getAssets() 开始执行');

    // 在Web平台上只使用SharedPreferences
    if (kIsWeb) {
      print('🌐 Web平台：使用SharedPreferences存储');
      final assets = await _sharedPreferencesStorage!.getAssets();
      print('📊 Web平台加载到${assets.length}个资产');
      return assets;
    }

    print('📱 移动平台：使用混合存储');

    // 优先从文件系统读取
    print('📁 尝试从文件系统读取...');
    final persistentAssets = await _persistentStorage!.getAssets();
    print('📁 文件系统读取到${persistentAssets.length}个资产');

    if (persistentAssets.isNotEmpty) {
      print('✅ 使用文件系统数据');
      // 打印文件系统数据的详细信息
      for (var i = 0; i < persistentAssets.length; i++) {
        final asset = persistentAssets[i];
        print('📁 文件系统资产${i + 1}: ${asset.name} - ${asset.amount}');
      }
      return persistentAssets;
    }

    // 即使文件系统有数据，也检查SharedPreferences是否有更多数据
    print('💾 检查SharedPreferences是否有更多数据...');
    final sharedPrefsAssets = await _sharedPreferencesStorage!.getAssets();
    print('💾 SharedPreferences读取到${sharedPrefsAssets.length}个资产');

    // 如果SharedPreferences有更多数据，使用SharedPreferences的数据
    if (sharedPrefsAssets.length > persistentAssets.length) {
      print('🔄 SharedPreferences有更多数据，使用SharedPreferences数据并迁移到文件系统...');
      await _persistentStorage!.saveAssets(sharedPrefsAssets);
      print('✅ 数据迁移完成');
      return sharedPrefsAssets;
    }

    return persistentAssets;
  }

  Future<void> addAsset(AssetItem asset) async {
    print('💾 HybridStorageService.addAsset() 开始执行');
    print('💾 要添加的资产: ${asset.name} - ${asset.amount}');

    final assets = await getAssets();
    print('💾 当前资产列表长度: ${assets.length}');

    assets.add(asset);
    print('💾 添加后资产列表长度: ${assets.length}');

    await saveAssets(assets);
    print('💾 资产列表已保存到存储');
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
    print('🗑️ HybridStorageService.clearAll() 开始执行');

    if (kIsWeb) {
      print('🌐 Web平台：清空SharedPreferences数据');
      await _sharedPreferencesStorage!.clearAll();
      print('✅ Web平台清空完成');
    } else {
      print('📱 移动平台：清空文件系统和SharedPreferences数据');
      await _persistentStorage!.clearAll();
      print('✅ 文件系统清空完成');
      await _sharedPreferencesStorage!.clearAll();
      print('✅ SharedPreferences清空完成');
    }

    print('🗑️ HybridStorageService.clearAll() 执行完成');
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
