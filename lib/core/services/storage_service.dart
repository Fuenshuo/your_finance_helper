import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:your_finance_flutter/core/models/account.dart';
import 'package:your_finance_flutter/core/models/asset_item.dart';
import 'package:your_finance_flutter/core/models/budget.dart';
import 'package:your_finance_flutter/core/models/clearance_entry.dart';
import 'package:your_finance_flutter/core/models/currency.dart';
import 'package:your_finance_flutter/core/models/expense_plan.dart';
import 'package:your_finance_flutter/core/models/income_plan.dart';
import 'package:your_finance_flutter/core/models/transaction.dart';
import 'package:your_finance_flutter/core/services/base_service.dart';
import 'package:your_finance_flutter/core/services/shared_preferences_service.dart';

class StorageService extends StatefulService {
  StorageService._(this._prefsService, this._prefs);
  static const String _assetsKey = 'assets_data';
  static const String _transactionsKey = 'transactions_data';
  static const String _draftTransactionsKey = 'draft_transactions_data';
  static const String _accountsKey = 'accounts_data';
  static const String _currenciesKey = 'currencies_data';
  static const String _exchangeRatesKey = 'exchange_rates_data';
  static const String _envelopeBudgetsKey = 'envelope_budgets_data';
  static const String _zeroBasedBudgetsKey = 'zero_based_budgets_data';
  static const String _salaryIncomesKey = 'salary_incomes_data';
  static const String _expensePlansKey = 'expense_plans_data';
  static const String _incomePlansKey = 'income_plans_data';
  static const String _periodClearanceSessionsKey =
      'period_clearance_sessions_data';

  static StorageService? _instance;
  final SharedPreferencesService _prefsService;
  final SharedPreferences _prefs;

  // 统计信息
  int _readOperations = 0;
  int _writeOperations = 0;
  final DateTime _createdAt = DateTime.now();

  static Future<StorageService> getInstance() async {
    if (_instance != null) return _instance!;

    final prefsService = await SharedPreferencesService.getInstance();
    final sharedPrefs = await SharedPreferencesService.getSharedPreferences();
    _instance = StorageService._(prefsService, sharedPrefs);
    return _instance!;
  }

  @override
  String get serviceName => 'StorageService';

  @override
  Future<void> initialize() async {
    if (isInitialized) return;

    await executeOperation('initialize', () async {
      // SharedPreferencesService已在getInstance中初始化
      setState(ServiceState.initialized);
    });
  }

  @override
  Map<String, dynamic> getStats() => {
        'serviceName': serviceName,
        'state': state.name,
        'readOperations': _readOperations,
        'writeOperations': _writeOperations,
        'createdAt': _createdAt.toIso8601String(),
        'prefsStats': _prefsService.getStats(),
        'lastError': lastError,
      };

  // 私有方法来跟踪操作
  void _incrementRead() => _readOperations++;
  void _incrementWrite() => _writeOperations++;

  // 保存资产列表
  Future<void> saveAssets(List<AssetItem> assets) async {
    await executeOperation('saveAssets', () async {
      final jsonList = assets.map((asset) => asset.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      await _prefsService.setString(_assetsKey, jsonString);
      _incrementWrite();
    });
  }

  // 获取资产列表
  Future<List<AssetItem>> getAssets() async {
    return executeOperation('getAssets', () async {
      final jsonString = _prefsService.getString(_assetsKey);
      if (jsonString == null) {
        _incrementRead();
        return [];
      }

      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      final assets = jsonList
          .map((json) => AssetItem.fromJson(json as Map<String, dynamic>))
          .toList();
      _incrementRead();
      return assets;
    }, defaultValue: []);
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
      final exists = _prefs.containsKey(key);
      if (exists) {
        await _prefs.remove(key);
      }
    }
  }

  // ========== 交易相关方法 ==========

  // 保存交易列表
  Future<void> saveTransactions(List<Transaction> transactions) async {
    final jsonList =
        transactions.map((transaction) => transaction.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await _prefs.setString(_transactionsKey, jsonString);
  }

  // 获取交易列表
  Future<List<Transaction>> loadTransactions() async {
    final jsonString = _prefs.getString(_transactionsKey);
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
    await _prefs.setString(_draftTransactionsKey, jsonString);
  }

  // 获取草稿交易列表
  Future<List<Transaction>> loadDraftTransactions() async {
    final jsonString = _prefs.getString(_draftTransactionsKey);
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
    await _prefs.setString(_accountsKey, jsonString);
  }

  // 获取账户列表
  Future<List<Account>> loadAccounts() async {
    final jsonString = _prefs.getString(_accountsKey);
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
    await _prefs.setString(_currenciesKey, jsonString);
  }

  // 获取币种列表
  Future<List<Currency>> loadCurrencies() async {
    final jsonString = _prefs.getString(_currenciesKey);
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
    await _prefs.setString(_exchangeRatesKey, jsonString);
  }

  // 获取汇率列表
  Future<List<ExchangeRate>> loadExchangeRates() async {
    final jsonString = _prefs.getString(_exchangeRatesKey);
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
    await _prefs.setString(_envelopeBudgetsKey, jsonString);
  }

  // 获取信封预算列表
  Future<List<EnvelopeBudget>> loadEnvelopeBudgets() async {
    final jsonString = _prefs.getString(_envelopeBudgetsKey);
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
    await _prefs.setString(_zeroBasedBudgetsKey, jsonString);
  }

  // 获取零基预算列表
  Future<List<ZeroBasedBudget>> loadZeroBasedBudgets() async {
    final jsonString = _prefs.getString(_zeroBasedBudgetsKey);
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
    await _prefs.setString(_salaryIncomesKey, jsonString);
  }

  // 获取工资收入列表
  Future<List<SalaryIncome>> loadSalaryIncomes() async {
    final jsonString = _prefs.getString(_salaryIncomesKey);

    if (jsonString == null) {
      return [];
    }

    try {
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      final result = <SalaryIncome>[];

      for (var i = 0; i < jsonList.length; i++) {
        final json = jsonList[i];

        try {
          final salaryIncome =
              SalaryIncome.fromJson(json as Map<String, dynamic>);
          result.add(salaryIncome);
        } catch (e) {
          // 跳过有问题的记录，继续加载其他记录
        }
      }

      return result;
    } catch (e) {
      return [];
    }
  }

  // 每月工资钱包存储键
  static const String _monthlyWalletsKey = 'monthly_wallets';

  // 保存每月工资钱包列表
  Future<void> saveMonthlyWallets(List<MonthlyWallet> wallets) async {
    final jsonList = wallets.map((wallet) => wallet.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await _prefs.setString(_monthlyWalletsKey, jsonString);
  }

  // 获取每月工资钱包列表
  Future<List<MonthlyWallet>> loadMonthlyWallets() async {
    final jsonString = _prefs.getString(_monthlyWalletsKey);
    if (jsonString == null) return [];

    try {
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      final result = <MonthlyWallet>[];

      for (final json in jsonList) {
        try {
          final wallet = MonthlyWallet.fromJson(json as Map<String, dynamic>);
          result.add(wallet);
        } catch (e) {
          // 跳过有问题的记录，继续加载其他记录
        }
      }

      return result;
    } catch (e) {
      return [];
    }
  }

  // ========== 支出计划数据存储 ==========

  // 保存支出计划列表
  Future<void> saveExpensePlans(List<dynamic> expensePlans) async {
    try {
      final jsonList = expensePlans.map((plan) => plan.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      await _prefs.setString(_expensePlansKey, jsonString);
    } catch (e) {
      rethrow;
    }
  }

  // 加载支出计划列表
  Future<List<dynamic>> loadExpensePlans() async {
    try {
      final jsonString = _prefs.getString(_expensePlansKey);
      if (jsonString == null) {
        return [];
      }

      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      final result = <dynamic>[];

      for (final json in jsonList) {
        try {
          final expensePlan =
              ExpensePlan.fromJson(json as Map<String, dynamic>);
          result.add(expensePlan);
        } catch (e) {
          // 跳过有问题的记录，继续加载其他记录
        }
      }

      return result;
    } catch (e) {
      return [];
    }
  }

  // 保存收入计划列表
  Future<void> saveIncomePlans(List<dynamic> incomePlans) async {
    try {
      final jsonList = incomePlans.map((plan) => plan.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      await _prefs.setString(_incomePlansKey, jsonString);
    } catch (e) {
      rethrow;
    }
  }

  // 加载收入计划列表
  Future<List<dynamic>> loadIncomePlans() async {
    try {
      final jsonString = _prefs.getString(_incomePlansKey);
      if (jsonString == null) {
        return [];
      }

      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      final result = <dynamic>[];

      for (final json in jsonList) {
        try {
          final incomePlan = IncomePlan.fromJson(json as Map<String, dynamic>);
          result.add(incomePlan);
        } catch (e) {
          // 跳过有问题的记录，继续加载其他记录
        }
      }

      return result;
    } catch (e) {
      return [];
    }
  }

  // 旧的清账会话方法已废弃，使用新的周期清账系统
  // Future<void> saveClearanceSessions(List<ClearanceSession> sessions) async { ... }
  // Future<List<ClearanceSession>> loadClearanceSessions() async { ... }

  // 保存周期清账会话列表
  Future<void> savePeriodClearanceSessions(
      List<PeriodClearanceSession> sessions) async {
    try {
      final jsonList = sessions.map((session) => session.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      await _prefs.setString(_periodClearanceSessionsKey, jsonString);
    } catch (e) {
      rethrow;
    }
  }

  // 加载周期清账会话列表
  Future<List<PeriodClearanceSession>> loadPeriodClearanceSessions() async {
    try {
      final jsonString = _prefs.getString(_periodClearanceSessionsKey);
      if (jsonString == null) {
        return [];
      }

      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      final result = <PeriodClearanceSession>[];

      for (final json in jsonList) {
        try {
          final session =
              PeriodClearanceSession.fromJson(json as Map<String, dynamic>);
          result.add(session);
        } catch (e) {
          // 跳过有问题的记录，继续加载其他记录
        }
      }

      return result;
    } catch (e) {
      return [];
    }
  }
}
