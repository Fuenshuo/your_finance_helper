import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_finance_flutter/core/models/account.dart';
import 'package:your_finance_flutter/core/models/transaction.dart';
import 'package:your_finance_flutter/core/providers/shared_providers.dart';
import 'package:your_finance_flutter/core/providers/transaction_provider.dart';
import 'package:your_finance_flutter/core/services/loan_calculation_service.dart';

/// Account state for Riverpod
@immutable
sealed class AccountState {
  const AccountState();

  bool get isInitial => this is AccountStateInitial;
  bool get isLoading => this is AccountStateLoading;
  bool get isLoaded => this is AccountStateLoaded;
  bool get isError => this is AccountStateError;

  List<Account> get accounts => this is AccountStateLoaded ? (this as AccountStateLoaded).accounts : [];
  String get errorMessage => this is AccountStateError ? (this as AccountStateError).message : '';
}

class AccountStateInitial extends AccountState {
  const AccountStateInitial();
}

class AccountStateLoading extends AccountState {
  const AccountStateLoading();
}

class AccountStateLoaded extends AccountState {
  const AccountStateLoaded(this.accounts);

  final List<Account> accounts;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccountStateLoaded &&
          runtimeType == other.runtimeType &&
          listEquals(accounts, other.accounts);

  @override
  int get hashCode => accounts.hashCode;
}

class AccountStateError extends AccountState {
  const AccountStateError(this.message);

  final String message;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccountStateError &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;
}

/// Account notifier for Riverpod state management
class AccountNotifier extends StateNotifier<AccountState> {
  AccountNotifier(this._storageService, this._transactionProvider)
      : super(const AccountStateInitial()) {
    loadAccounts();
  }

  final StorageService _storageService;
  final TransactionProvider _transactionProvider;
  List<Account> _accounts = [];

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

  Future<void> _initialize() async {
    state = const AccountStateInitial();
    await loadAccounts();
  }

  // 加载账户数据
  Future<void> loadAccounts() async {
    state = const AccountStateLoading();
    try {
      _accounts = await _storageService.loadAccounts();
      state = AccountStateLoaded(_accounts);
    } catch (e) {
      state = AccountStateError(e.toString());
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
      state = AccountStateLoaded(_accounts);
    } catch (e) {
      state = AccountStateError(e.toString());
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
        state = AccountStateLoaded(_accounts);
      }
    } catch (e) {
      state = AccountStateError(e.toString());
    }
  }

  // 删除账户
  Future<void> deleteAccount(String accountId) async {
    try {
      _accounts.removeWhere((a) => a.id == accountId);
      await _storageService.saveAccounts(_accounts);
      state = AccountStateLoaded(_accounts);
    } catch (e) {
      state = AccountStateError(e.toString());
    }
  }

  // 计算账户实时余额（基于所有交易）
  double getAccountBalance(String accountId, List<Transaction> transactions) {
    // 过滤出所有与该账户相关的交易
    final accountTransactions = transactions.where(
      (transaction) =>
          transaction.fromAccountId == accountId ||
          transaction.toAccountId == accountId,
    );

    // 计算余额变化 - 从交易历史汇总
    var balance = 0.0;
    for (final transaction in accountTransactions) {
      if (transaction.fromAccountId == accountId) {
        // 从这个账户出去的钱（支出或转出）
        balance -= transaction.amount;
      }
      if (transaction.toAccountId == accountId) {
        // 进入这个账户的钱（收入或转入）
        balance += transaction.amount;
      }
    }

    return balance;
  }

  // 获取账户的初始余额（通过查找初始化交易）
  double getAccountInitialBalance(
    String accountId,
    List<Transaction> transactions,
  ) {
    // 查找该账户的初始化交易
    final initTransaction = transactions.firstWhere(
      (transaction) =>
          transaction.toAccountId == accountId &&
          transaction.isAutoGenerated == true &&
          transaction.description == '账户初始化',
      orElse: () => null as Transaction,
    );

    return initTransaction.amount ?? 0.0;
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

  // 计算总资产（需要传入交易数据）
  double calculateTotalAssets(List<Transaction> transactions) =>
      assetAccounts.fold(
        0.0,
        (sum, account) => sum + getAccountBalance(account.id, transactions),
      );

  // 计算总负债（使用实际负债余额，需要传入交易数据）
  double calculateTotalLiabilities(List<Transaction> transactions) =>
      liabilityAccounts.fold(
        0.0,
        (sum, account) => sum + getAccountBalance(account.id, transactions),
      );

  // 计算净资产（需要传入交易数据）
  double calculateNetWorth(List<Transaction> transactions) =>
      calculateTotalAssets(transactions) -
      calculateTotalLiabilities(transactions);

  // 按类型统计账户
  Map<AccountType, List<Account>> getAccountsByTypeMap() {
    final typeMap = <AccountType, List<Account>>{};

    for (final type in AccountType.values) {
      typeMap[type] = getAccountsByType(type);
    }

    return typeMap;
  }

  // 按类型统计余额
  Map<AccountType, double> getBalanceByType(List<Transaction> transactions) {
    final balanceMap = <AccountType, double>{};

    for (final type in AccountType.values) {
      final accounts = getAccountsByType(type);
      balanceMap[type] = accounts.fold(
        0.0,
        (sum, account) => sum + getAccountBalance(account.id, transactions),
      );
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

  // 验证账户名称是否唯一
  bool isAccountNameUnique(String name, {String? excludeId}) => !_accounts.any(
        (a) =>
            a.name.toLowerCase() == name.toLowerCase() &&
            (excludeId == null || a.id != excludeId),
      );

  // 获取账户统计信息
  Map<String, dynamic> getAccountStatistics(List<Transaction> transactions) {
    final totalAccounts = _accounts.length;
    final activeAccounts =
        _accounts.where((a) => a.status == AccountStatus.active).length;
    final totalAssets = calculateTotalAssets(transactions);
    final totalLiabilities = calculateTotalLiabilities(transactions);
    final netWorth = calculateNetWorth(transactions);

    return {
      'totalAccounts': totalAccounts,
      'activeAccounts': activeAccounts,
      'totalAssets': totalAssets,
      'totalLiabilities': totalLiabilities,
      'netWorth': netWorth,
    };
  }

  // 刷新数据
  Future<void> refresh() async {
    await loadAccounts();
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
      state = AccountStateError(e.toString());
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
      state = AccountStateError(e.toString());
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
        state = AccountStateLoaded(_accounts);
      }
    } catch (e) {
      state = AccountStateError(e.toString());
    }
  }

  /// 验证贷款设置
  LoanValidationResult validateLoanSettings(Account account) {
    final loanCalculationService = LoanCalculationService();
    return loanCalculationService.validateLoanSettings(account);
  }
}

/// Riverpod providers for account management
final transactionProviderProvider = Provider<TransactionProvider>((ref) {
  throw UnimplementedError('TransactionProvider must be provided');
});

final accountProvider = StateNotifierProvider<AccountNotifier, AccountState>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  final transactionProvider = ref.watch(transactionProviderProvider);
  return AccountNotifier(storageService, transactionProvider);
});

/// Computed providers for derived account data
final activeAccountsProvider = Provider<List<Account>>((ref) {
  final state = ref.watch(accountProvider);
  return state.isLoaded ? state.accounts.where((a) => a.status == AccountStatus.active).toList() : [];
});

final assetAccountsProvider = Provider<List<Account>>((ref) {
  final state = ref.watch(accountProvider);
  return state.isLoaded ? state.accounts
      .where((a) => a.type.isAsset && a.status == AccountStatus.active)
      .toList() : [];
});

final liabilityAccountsProvider = Provider<List<Account>>((ref) {
  final state = ref.watch(accountProvider);
  return state.isLoaded ? state.accounts
      .where((a) => a.type.isLiability && a.status == AccountStatus.active)
      .toList() : [];
});

final loanAccountsProvider = Provider<List<Account>>((ref) {
  final state = ref.watch(accountProvider);
  return state.isLoaded ? state.accounts
      .where((a) => a.isLoanAccount && a.status == AccountStatus.active)
      .toList() : [];
});

final defaultAccountProvider = Provider<Account?>((ref) {
  final state = ref.watch(accountProvider);
  if (!state.isLoaded) return null;

  try {
    return state.accounts.firstWhere(
      (a) => a.isDefault && a.status == AccountStatus.active,
    );
  } catch (e) {
    return null;
  }
});

/// Provider for account loading state
final isAccountLoadingProvider = Provider<bool>((ref) {
  return ref.watch(accountProvider).isLoading;
});

/// Provider for account error state
final accountErrorProvider = Provider<String?>((ref) {
  final state = ref.watch(accountProvider);
  return state.isError ? state.errorMessage : null;
});
