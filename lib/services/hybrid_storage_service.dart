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
    _persistentStorage ??= await PersistentStorageService.getInstance();
    _sharedPreferencesStorage ??= await StorageService.getInstance();
    return _instance!;
  }
  
  // 资产相关方法
  Future<void> saveAssets(List<AssetItem> assets) async {
    // 同时保存到两种存储方式
    await _persistentStorage!.saveAssets(assets);
    await _sharedPreferencesStorage!.saveAssets(assets);
  }
  
  Future<List<AssetItem>> getAssets() async {
    // 优先从文件系统读取
    final persistentAssets = await _persistentStorage!.getAssets();
    if (persistentAssets.isNotEmpty) {
      return persistentAssets;
    }
    
    // 如果文件系统没有数据，从SharedPreferences读取
    final sharedPrefsAssets = await _sharedPreferencesStorage!.getAssets();
    if (sharedPrefsAssets.isNotEmpty) {
      // 将SharedPreferences的数据迁移到文件系统
      await _persistentStorage!.saveAssets(sharedPrefsAssets);
    }
    
    return sharedPrefsAssets;
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
    await _persistentStorage!.saveTransactions(transactions);
    await _sharedPreferencesStorage!.saveTransactions(transactions);
  }
  
  Future<List<Transaction>> loadTransactions() async {
    final persistentTransactions = await _persistentStorage!.loadTransactions();
    if (persistentTransactions.isNotEmpty) {
      return persistentTransactions;
    }
    
    final sharedPrefsTransactions = await _sharedPreferencesStorage!.loadTransactions();
    if (sharedPrefsTransactions.isNotEmpty) {
      await _persistentStorage!.saveTransactions(sharedPrefsTransactions);
    }
    
    return sharedPrefsTransactions;
  }
  
  // 账户相关方法
  Future<void> saveAccounts(List<Account> accounts) async {
    await _persistentStorage!.saveAccounts(accounts);
    await _sharedPreferencesStorage!.saveAccounts(accounts);
  }
  
  Future<List<Account>> loadAccounts() async {
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
    await _persistentStorage!.saveEnvelopeBudgets(budgets);
    await _sharedPreferencesStorage!.saveEnvelopeBudgets(budgets);
  }
  
  Future<List<EnvelopeBudget>> loadEnvelopeBudgets() async {
    final persistentBudgets = await _persistentStorage!.loadEnvelopeBudgets();
    if (persistentBudgets.isNotEmpty) {
      return persistentBudgets;
    }
    
    final sharedPrefsBudgets = await _sharedPreferencesStorage!.loadEnvelopeBudgets();
    if (sharedPrefsBudgets.isNotEmpty) {
      await _persistentStorage!.saveEnvelopeBudgets(sharedPrefsBudgets);
    }
    
    return sharedPrefsBudgets;
  }
  
  Future<void> saveZeroBasedBudgets(List<ZeroBasedBudget> budgets) async {
    await _persistentStorage!.saveZeroBasedBudgets(budgets);
    await _sharedPreferencesStorage!.saveZeroBasedBudgets(budgets);
  }
  
  Future<List<ZeroBasedBudget>> loadZeroBasedBudgets() async {
    final persistentBudgets = await _persistentStorage!.loadZeroBasedBudgets();
    if (persistentBudgets.isNotEmpty) {
      return persistentBudgets;
    }
    
    final sharedPrefsBudgets = await _sharedPreferencesStorage!.loadZeroBasedBudgets();
    if (sharedPrefsBudgets.isNotEmpty) {
      await _persistentStorage!.saveZeroBasedBudgets(sharedPrefsBudgets);
    }
    
    return sharedPrefsBudgets;
  }
  
  // 币种相关方法
  Future<void> saveCurrencies(List<Currency> currencies) async {
    await _sharedPreferencesStorage!.saveCurrencies(currencies);
  }
  
  Future<List<Currency>> loadCurrencies() async {
    return await _sharedPreferencesStorage!.loadCurrencies();
  }
  
  Future<void> saveExchangeRates(List<ExchangeRate> exchangeRates) async {
    await _sharedPreferencesStorage!.saveExchangeRates(exchangeRates);
  }
  
  Future<List<ExchangeRate>> loadExchangeRates() async {
    return await _sharedPreferencesStorage!.loadExchangeRates();
  }
  
  // 草稿交易相关方法
  Future<void> saveDraftTransactions(List<Transaction> draftTransactions) async {
    await _sharedPreferencesStorage!.saveDraftTransactions(draftTransactions);
  }
  
  Future<List<Transaction>> loadDraftTransactions() async {
    return await _sharedPreferencesStorage!.loadDraftTransactions();
  }
  
  // 清空所有数据
  Future<void> clearAll() async {
    await _persistentStorage!.clearAll();
    await _sharedPreferencesStorage!.clearAll();
  }
  
  // 导出数据
  Future<String> exportAllData() async {
    return await _persistentStorage!.exportAllData();
  }
  
  // 导入数据
  Future<void> importFromFile(String filePath) async {
    await _persistentStorage!.importFromFile(filePath);
  }
  
  // 获取存储信息
  Future<Map<String, dynamic>> getStorageInfo() async {
    return await _persistentStorage!.getStorageInfo();
  }
}
