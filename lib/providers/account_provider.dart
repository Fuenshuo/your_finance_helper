import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:your_finance_flutter/core/models/account.dart';
import 'package:your_finance_flutter/core/services/loan_calculation_service.dart';
import 'package:your_finance_flutter/core/services/storage_service.dart';

class AccountProvider with ChangeNotifier {
  List<Account> _accounts = [];
  bool _isLoading = false;
  String? _error;
  late final StorageService _storageService;

  // Getters
  List<Account> get accounts => _accounts;
  List<Account> get activeAccounts =>
      _accounts.where((a) => a.status == AccountStatus.active).toList();
  List<Account> get assetAccounts => _accounts
      .where((a) => a.type.isAsset && a.status == AccountStatus.active)
      .toList();
  List<Account> get liabilityAccounts => _accounts
      .where((a) => a.type.isLiability && a.status == AccountStatus.active)
      .toList();
  List<Account> get loanAccounts => _accounts
      .where((a) => a.isLoanAccount && a.status == AccountStatus.active)
      .toList();
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
          _accounts =
              _accounts.map((a) => a.copyWith(isDefault: false)).toList();
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
      return _accounts
          .firstWhere((a) => a.isDefault && a.status == AccountStatus.active);
    } catch (e) {
      return null;
    }
  }

  // 根据类型获取账户
  List<Account> getAccountsByType(AccountType type) => _accounts
      .where((a) => a.type == type && a.status == AccountStatus.active)
      .toList();

  // 计算总资产
  double calculateTotalAssets() =>
      assetAccounts.fold(0.0, (sum, account) => sum + account.balance);

  // 计算总负债（使用实际负债余额）
  double calculateTotalLiabilities() => liabilityAccounts.fold(
        0.0,
        (sum, account) => sum + account.effectiveLiabilityBalance,
      );

  // 计算净资产
  double calculateNetWorth() =>
      calculateTotalAssets() - calculateTotalLiabilities();

  // 按类型统计账户
  Map<AccountType, List<Account>> getAccountsByTypeMap() {
    final typeMap = <AccountType, List<Account>>{};

    for (final type in AccountType.values) {
      typeMap[type] = getAccountsByType(type);
    }

    return typeMap;
  }

  // 按类型统计余额
  Map<AccountType, double> getBalanceByType() {
    final balanceMap = <AccountType, double>{};

    for (final type in AccountType.values) {
      final accounts = getAccountsByType(type);
      balanceMap[type] =
          accounts.fold(0.0, (sum, account) => sum + account.balance);
    }

    return balanceMap;
  }

  // 搜索账户
  List<Account> searchAccounts(String query) {
    if (query.isEmpty) return _accounts;

    final lowercaseQuery = query.toLowerCase();
    return _accounts
        .where(
          (a) =>
              a.name.toLowerCase().contains(lowercaseQuery) ||
              a.type.displayName.toLowerCase().contains(lowercaseQuery) ||
              (a.bankName?.toLowerCase().contains(lowercaseQuery) ?? false) ||
              a.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery)),
        )
        .toList();
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
  bool isAccountNameUnique(String name, {String? excludeId}) => !_accounts.any(
        (a) =>
            a.name.toLowerCase() == name.toLowerCase() &&
            (excludeId == null || a.id != excludeId),
      );

  // 获取账户统计信息
  Map<String, dynamic> getAccountStatistics() {
    final totalAccounts = _accounts.length;
    final activeAccounts =
        _accounts.where((a) => a.status == AccountStatus.active).length;
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

  // 贷款管理相关方法

  /// 更新贷款的还款计划
  Future<void> updateLoanPaymentSchedule(String accountId) async {
    try {
      final account = getAccountById(accountId);
      if (account == null || !account.isLoanAccount) return;

      final loanCalculationService = LoanCalculationService();
      final result = loanCalculationService.calculateLoanSchedule(account);

      final updatedAccount = account.copyWith(
        monthlyPayment: result.monthlyPayment,
        updateDate: DateTime.now(),
      );

      await updateAccount(updatedAccount);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// 记录贷款还款
  Future<void> recordLoanPayment(String accountId, double paymentAmount) async {
    try {
      final account = getAccountById(accountId);
      if (account == null || !account.isLoanAccount) return;

      // 计算还款后的剩余本金
      final newRemainingPrincipal =
          (account.remainingPrincipal ?? 0) - paymentAmount;

      final updatedAccount = account.copyWith(
        remainingPrincipal: newRemainingPrincipal.clamp(0, double.infinity),
        updateDate: DateTime.now(),
      );

      await updateAccount(updatedAccount);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// 获取贷款统计信息
  Map<String, dynamic> getLoanStatistics() {
    final loanAccounts = this.loanAccounts;
    final totalLoanAmount = loanAccounts.fold(
      0.0,
      (sum, account) => sum + (account.loanAmount ?? 0),
    );
    final totalRemainingPrincipal = loanAccounts.fold(
      0.0,
      (sum, account) => sum + (account.remainingPrincipal ?? 0),
    );
    final totalPaidPrincipal = totalLoanAmount - totalRemainingPrincipal;
    final totalMonthlyPayment = loanAccounts.fold(
      0.0,
      (sum, account) => sum + (account.monthlyPayment ?? 0),
    );

    return {
      'totalLoans': loanAccounts.length,
      'totalLoanAmount': totalLoanAmount,
      'totalRemainingPrincipal': totalRemainingPrincipal,
      'totalPaidPrincipal': totalPaidPrincipal,
      'totalMonthlyPayment': totalMonthlyPayment,
      'averageLoanAmount':
          loanAccounts.isNotEmpty ? totalLoanAmount / loanAccounts.length : 0,
      'averageMonthlyPayment': loanAccounts.isNotEmpty
          ? totalMonthlyPayment / loanAccounts.length
          : 0,
    };
  }

  /// 获取即将到期的贷款
  List<Account> getUpcomingLoanPayments({int daysAhead = 7}) {
    final now = DateTime.now();
    final upcomingDate = now.add(Duration(days: daysAhead));

    return loanAccounts.where((account) {
      final nextPaymentDate = account.nextPaymentDate;
      return nextPaymentDate != null &&
          nextPaymentDate.isAfter(now) &&
          nextPaymentDate.isBefore(upcomingDate);
    }).toList();
  }

  /// 批量更新贷款的剩余本金
  Future<void> updateAllLoanRemainingPrincipal() async {
    try {
      var hasChanges = false;

      for (var i = 0; i < _accounts.length; i++) {
        final account = _accounts[i];
        if (account.isLoanAccount && account.remainingPrincipal == null) {
          // 如果剩余本金为空，使用贷款总额作为初始值
          _accounts[i] = account.copyWith(
            remainingPrincipal: account.loanAmount,
            updateDate: DateTime.now(),
          );
          hasChanges = true;
        }
      }

      if (hasChanges) {
        await _storageService.saveAccounts(_accounts);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// 验证贷款设置
  LoanValidationResult validateLoanSettings(Account account) {
    final loanCalculationService = LoanCalculationService();
    return loanCalculationService.validateLoanSettings(account);
  }
}
