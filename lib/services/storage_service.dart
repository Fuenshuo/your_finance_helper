import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:your_finance_flutter/models/account.dart';
import 'package:your_finance_flutter/models/asset_item.dart';
import 'package:your_finance_flutter/models/budget.dart';
import 'package:your_finance_flutter/models/currency.dart';
import 'package:your_finance_flutter/models/transaction.dart';

class StorageService {
  StorageService._();
  static const String _assetsKey = 'assets_data';
  static const String _transactionsKey = 'transactions_data';
  static const String _draftTransactionsKey = 'draft_transactions_data';
  static const String _accountsKey = 'accounts_data';
  static const String _currenciesKey = 'currencies_data';
  static const String _exchangeRatesKey = 'exchange_rates_data';
  static const String _envelopeBudgetsKey = 'envelope_budgets_data';
  static const String _zeroBasedBudgetsKey = 'zero_based_budgets_data';
  static const String _salaryIncomesKey = 'salary_incomes_data';

  static StorageService? _instance;
  static SharedPreferences? _prefs;

  static Future<StorageService> getInstance() async {
    _instance ??= StorageService._();
    _prefs ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  // 保存资产列表
  Future<void> saveAssets(List<AssetItem> assets) async {
    final jsonList = assets.map((asset) => asset.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await _prefs!.setString(_assetsKey, jsonString);
  }

  // 获取资产列表
  Future<List<AssetItem>> getAssets() async {
    print('💾 StorageService.getAssets() 开始执行');
    try {
      final jsonString = _prefs!.getString(_assetsKey);
      if (jsonString == null) {
        print('💾 SharedPreferences中没有资产数据');
        return [];
      }

      print('💾 从SharedPreferences读取到JSON数据，长度: ${jsonString.length}');
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      final assets = jsonList
          .map((json) => AssetItem.fromJson(json as Map<String, dynamic>))
          .toList();

      print('💾 从SharedPreferences加载到${assets.length}个资产');
      for (var i = 0; i < assets.length; i++) {
        final asset = assets[i];
        print(
          '💾 SharedPreferences资产${i + 1}: ${asset.name} - ${asset.amount}',
        );
      }

      return assets;
    } catch (e) {
      print('❌ 读取资产数据失败: $e');
      // 清除损坏的数据
      await _prefs!.remove(_assetsKey);
      print('🗑️ 已清除损坏的资产数据');
      return [];
    }
  }

  // 添加资产
  Future<void> addAsset(AssetItem asset) async {
    final assets = await getAssets();
    assets.add(asset);
    await saveAssets(assets);
  }

  // 更新资产
  Future<void> updateAsset(AssetItem asset) async {
    final assets = await getAssets();
    final index = assets.indexWhere((a) => a.id == asset.id);
    if (index != -1) {
      assets[index] = asset;
      await saveAssets(assets);
    }
  }

  // 删除资产
  Future<void> deleteAsset(String assetId) async {
    final assets = await getAssets();
    assets.removeWhere((asset) => asset.id == assetId);
    await saveAssets(assets);
  }

  // 清空所有数据
  Future<void> clearAll() async {
    print('🗑️ StorageService.clearAll() 开始执行');

    final keys = [
      _assetsKey,
      _transactionsKey,
      _draftTransactionsKey,
      _accountsKey,
      _currenciesKey,
      _exchangeRatesKey,
      _envelopeBudgetsKey,
      _zeroBasedBudgetsKey,
      _salaryIncomesKey,
    ];

    for (final key in keys) {
      final exists = _prefs!.containsKey(key);
      print('🗑️ 检查SharedPreferences键: $key, 存在: $exists');

      if (exists) {
        await _prefs!.remove(key);
        print('🗑️ 已删除SharedPreferences键: $key');
      }
    }

    print('🗑️ StorageService.clearAll() 执行完成');
  }

  // ========== 交易相关方法 ==========

  // 保存交易列表
  Future<void> saveTransactions(List<Transaction> transactions) async {
    final jsonList =
        transactions.map((transaction) => transaction.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await _prefs!.setString(_transactionsKey, jsonString);
  }

  // 获取交易列表
  Future<List<Transaction>> loadTransactions() async {
    final jsonString = _prefs!.getString(_transactionsKey);
    if (jsonString == null) return [];

    final jsonList = jsonDecode(jsonString) as List<dynamic>;
    return jsonList
        .map((json) => Transaction.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // 保存草稿交易列表
  Future<void> saveDraftTransactions(
    List<Transaction> draftTransactions,
  ) async {
    final jsonList =
        draftTransactions.map((transaction) => transaction.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await _prefs!.setString(_draftTransactionsKey, jsonString);
  }

  // 获取草稿交易列表
  Future<List<Transaction>> loadDraftTransactions() async {
    final jsonString = _prefs!.getString(_draftTransactionsKey);
    if (jsonString == null) return [];

    final jsonList = jsonDecode(jsonString) as List<dynamic>;
    return jsonList
        .map((json) => Transaction.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // ========== 账户相关方法 ==========

  // 保存账户列表
  Future<void> saveAccounts(List<Account> accounts) async {
    final jsonList = accounts.map((account) => account.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await _prefs!.setString(_accountsKey, jsonString);
  }

  // 获取账户列表
  Future<List<Account>> loadAccounts() async {
    final jsonString = _prefs!.getString(_accountsKey);
    if (jsonString == null) return [];

    final jsonList = jsonDecode(jsonString) as List<dynamic>;
    return jsonList
        .map((json) => Account.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // ========== 币种相关方法 ==========

  // 保存币种列表
  Future<void> saveCurrencies(List<Currency> currencies) async {
    final jsonList = currencies.map((currency) => currency.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await _prefs!.setString(_currenciesKey, jsonString);
  }

  // 获取币种列表
  Future<List<Currency>> loadCurrencies() async {
    final jsonString = _prefs!.getString(_currenciesKey);
    if (jsonString == null) return Currency.commonCurrencies;

    final jsonList = jsonDecode(jsonString) as List<dynamic>;
    return jsonList
        .map((json) => Currency.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // 保存汇率列表
  Future<void> saveExchangeRates(List<ExchangeRate> exchangeRates) async {
    final jsonList = exchangeRates.map((rate) => rate.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await _prefs!.setString(_exchangeRatesKey, jsonString);
  }

  // 获取汇率列表
  Future<List<ExchangeRate>> loadExchangeRates() async {
    final jsonString = _prefs!.getString(_exchangeRatesKey);
    if (jsonString == null) return [];

    final jsonList = jsonDecode(jsonString) as List<dynamic>;
    return jsonList
        .map((json) => ExchangeRate.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // ========== 预算相关方法 ==========

  // 保存信封预算列表
  Future<void> saveEnvelopeBudgets(List<EnvelopeBudget> budgets) async {
    final jsonList = budgets.map((budget) => budget.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await _prefs!.setString(_envelopeBudgetsKey, jsonString);
  }

  // 获取信封预算列表
  Future<List<EnvelopeBudget>> loadEnvelopeBudgets() async {
    final jsonString = _prefs!.getString(_envelopeBudgetsKey);
    if (jsonString == null) return [];

    final jsonList = jsonDecode(jsonString) as List<dynamic>;
    return jsonList
        .map((json) => EnvelopeBudget.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // 保存零基预算列表
  Future<void> saveZeroBasedBudgets(List<ZeroBasedBudget> budgets) async {
    final jsonList = budgets.map((budget) => budget.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await _prefs!.setString(_zeroBasedBudgetsKey, jsonString);
  }

  // 获取零基预算列表
  Future<List<ZeroBasedBudget>> loadZeroBasedBudgets() async {
    final jsonString = _prefs!.getString(_zeroBasedBudgetsKey);
    if (jsonString == null) return [];

    final jsonList = jsonDecode(jsonString) as List<dynamic>;
    return jsonList
        .map((json) => ZeroBasedBudget.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // ========== 工资收入相关方法 ==========

  // 保存工资收入列表
  Future<void> saveSalaryIncomes(List<SalaryIncome> incomes) async {
    final jsonList = incomes.map((income) => income.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await _prefs!.setString(_salaryIncomesKey, jsonString);
  }

  // 获取工资收入列表
  Future<List<SalaryIncome>> loadSalaryIncomes() async {
    final jsonString = _prefs!.getString(_salaryIncomesKey);
    if (jsonString == null) return [];

    final jsonList = jsonDecode(jsonString) as List<dynamic>;
    return jsonList
        .map((json) => SalaryIncome.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
