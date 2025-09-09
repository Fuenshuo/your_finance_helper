import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../models/account.dart';
import '../services/storage_service.dart';

class AccountProvider with ChangeNotifier {
  List<Account> _accounts = [];
  bool _isLoading = false;
  String? _error;
  late final StorageService _storageService;

  // Getters
  List<Account> get accounts => _accounts;
  List<Account> get activeAccounts => _accounts.where((a) => a.status == AccountStatus.active).toList();
  List<Account> get assetAccounts => _accounts.where((a) => a.type.isAsset && a.status == AccountStatus.active).toList();
  List<Account> get liabilityAccounts => _accounts.where((a) => a.type.isLiability && a.status == AccountStatus.active).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;

  // 初始化
  Future<void> initialize() async {
    _storageService = await StorageService.getInstance();
    await _loadAccounts();
  }

  // 加载账户数据
  Future<void> _loadAccounts() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _accounts = await _storageService.loadAccounts();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 添加账户
  Future<void> addAccount(Account account) async {
    try {
      // 如果设置为默认账户，先取消其他默认账户
      if (account.isDefault) {
        _accounts = _accounts.map((a) => a.copyWith(isDefault: false)).toList();
      }
      
      _accounts.add(account);
      await _storageService.saveAccounts(_accounts);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // 更新账户
  Future<void> updateAccount(Account updatedAccount) async {
    try {
      final index = _accounts.indexWhere((a) => a.id == updatedAccount.id);
      if (index != -1) {
        // 如果设置为默认账户，先取消其他默认账户
        if (updatedAccount.isDefault) {
          _accounts = _accounts.map((a) => a.copyWith(isDefault: false)).toList();
        }
        
        _accounts[index] = updatedAccount.copyWith(updateDate: DateTime.now());
        await _storageService.saveAccounts(_accounts);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // 删除账户
  Future<void> deleteAccount(String accountId) async {
    try {
      _accounts.removeWhere((a) => a.id == accountId);
      await _storageService.saveAccounts(_accounts);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // 更新账户余额
  Future<void> updateAccountBalance(String accountId, double newBalance) async {
    try {
      final index = _accounts.indexWhere((a) => a.id == accountId);
      if (index != -1) {
        _accounts[index] = _accounts[index].copyWith(
          balance: newBalance,
          updateDate: DateTime.now(),
        );
        await _storageService.saveAccounts(_accounts);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // 根据ID获取账户
  Account? getAccountById(String accountId) {
    try {
      return _accounts.firstWhere((a) => a.id == accountId);
    } catch (e) {
      return null;
    }
  }

  // 获取默认账户
  Account? getDefaultAccount() {
    try {
      return _accounts.firstWhere((a) => a.isDefault && a.status == AccountStatus.active);
    } catch (e) {
      return null;
    }
  }

  // 根据类型获取账户
  List<Account> getAccountsByType(AccountType type) {
    return _accounts.where((a) => a.type == type && a.status == AccountStatus.active).toList();
  }

  // 计算总资产
  double calculateTotalAssets() {
    return assetAccounts.fold(0.0, (sum, account) => sum + account.balance);
  }

  // 计算总负债
  double calculateTotalLiabilities() {
    return liabilityAccounts.fold(0.0, (sum, account) => sum + account.balance);
  }

  // 计算净资产
  double calculateNetWorth() {
    return calculateTotalAssets() - calculateTotalLiabilities();
  }

  // 按类型统计账户
  Map<AccountType, List<Account>> getAccountsByTypeMap() {
    final Map<AccountType, List<Account>> typeMap = {};
    
    for (final type in AccountType.values) {
      typeMap[type] = getAccountsByType(type);
    }
    
    return typeMap;
  }

  // 按类型统计余额
  Map<AccountType, double> getBalanceByType() {
    final Map<AccountType, double> balanceMap = {};
    
    for (final type in AccountType.values) {
      final accounts = getAccountsByType(type);
      balanceMap[type] = accounts.fold(0.0, (sum, account) => sum + account.balance);
    }
    
    return balanceMap;
  }

  // 搜索账户
  List<Account> searchAccounts(String query) {
    if (query.isEmpty) return _accounts;
    
    final lowercaseQuery = query.toLowerCase();
    return _accounts.where((a) =>
      a.name.toLowerCase().contains(lowercaseQuery) ||
      a.type.displayName.toLowerCase().contains(lowercaseQuery) ||
      (a.bankName?.toLowerCase().contains(lowercaseQuery) ?? false) ||
      a.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery))
    ).toList();
  }

  // 格式化余额
  String formatBalance(double balance, {String currency = 'CNY'}) {
    final formatter = NumberFormat.currency(locale: 'zh_CN', symbol: '¥');
    return formatter.format(balance);
  }

  // 获取账户图标
  String getAccountIcon(AccountType type) {
    switch (type) {
      case AccountType.cash:
        return 'money';
      case AccountType.bank:
        return 'account_balance';
      case AccountType.creditCard:
        return 'credit_card';
      case AccountType.investment:
        return 'trending_up';
      case AccountType.loan:
        return 'account_balance_wallet';
      case AccountType.asset:
        return 'home';
      case AccountType.liability:
        return 'warning';
    }
  }

  // 获取账户颜色
  String getAccountColor(AccountType type) {
    switch (type) {
      case AccountType.cash:
        return '#4CAF50'; // 绿色
      case AccountType.bank:
        return '#2196F3'; // 蓝色
      case AccountType.creditCard:
        return '#FF9800'; // 橙色
      case AccountType.investment:
        return '#9C27B0'; // 紫色
      case AccountType.loan:
        return '#F44336'; // 红色
      case AccountType.asset:
        return '#607D8B'; // 蓝灰色
      case AccountType.liability:
        return '#795548'; // 棕色
    }
  }

  // 验证账户名称是否唯一
  bool isAccountNameUnique(String name, {String? excludeId}) {
    return !_accounts.any((a) => 
      a.name.toLowerCase() == name.toLowerCase() && 
      (excludeId == null || a.id != excludeId)
    );
  }

  // 获取账户统计信息
  Map<String, dynamic> getAccountStatistics() {
    final totalAccounts = _accounts.length;
    final activeAccounts = _accounts.where((a) => a.status == AccountStatus.active).length;
    final totalAssets = calculateTotalAssets();
    final totalLiabilities = calculateTotalLiabilities();
    final netWorth = calculateNetWorth();
    
    return {
      'totalAccounts': totalAccounts,
      'activeAccounts': activeAccounts,
      'totalAssets': totalAssets,
      'totalLiabilities': totalLiabilities,
      'netWorth': netWorth,
    };
  }

  // 清除错误
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // 刷新数据
  Future<void> refresh() async {
    await _loadAccounts();
  }
}
