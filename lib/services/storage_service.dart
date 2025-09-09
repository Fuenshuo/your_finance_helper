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
    final jsonString = _prefs!.getString(_assetsKey);
    if (jsonString == null) return [];

    final jsonList = jsonDecode(jsonString) as List<dynamic>;
    return jsonList
        .map((json) => AssetItem.fromJson(json as Map<String, dynamic>))
        .toList();
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
    await _prefs!.remove(_assetsKey);
    await _prefs!.remove(_transactionsKey);
    await _prefs!.remove(_draftTransactionsKey);
    await _prefs!.remove(_accountsKey);
    await _prefs!.remove(_currenciesKey);
    await _prefs!.remove(_exchangeRatesKey);
    await _prefs!.remove(_envelopeBudgetsKey);
    await _prefs!.remove(_zeroBasedBudgetsKey);
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
}
