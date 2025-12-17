import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:your_finance_flutter/core/models/transaction.dart';
import 'package:your_finance_flutter/core/providers/shared_providers.dart';
import 'package:your_finance_flutter/core/services/storage_service.dart';
import 'package:your_finance_flutter/features/insights/models/flux_loop_job.dart';
import 'package:your_finance_flutter/features/insights/providers/insights_provider.dart';

/// Transaction state for Riverpod
@immutable
sealed class TransactionState {
  const TransactionState();

  bool get isInitial => this is TransactionStateInitial;
  bool get isLoading => this is TransactionStateLoading;
  bool get isLoaded => this is TransactionStateLoaded;
  bool get isError => this is TransactionStateError;

  List<Transaction> get transactions => this is TransactionStateLoaded
      ? (this as TransactionStateLoaded).transactions
      : [];
  List<Transaction> get draftTransactions => this is TransactionStateLoaded
      ? (this as TransactionStateLoaded).draftTransactions
      : [];
  String get errorMessage => this is TransactionStateError
      ? (this as TransactionStateError).message
      : '';
}

class TransactionStateInitial extends TransactionState {
  const TransactionStateInitial();
}

class TransactionStateLoading extends TransactionState {
  const TransactionStateLoading();
}

class TransactionStateLoaded extends TransactionState {
  const TransactionStateLoaded(
    this.transactions,
    this.draftTransactions,
  );

  @override
  final List<Transaction> transactions;
  @override
  final List<Transaction> draftTransactions;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionStateLoaded &&
          runtimeType == other.runtimeType &&
          listEquals(transactions, other.transactions) &&
          listEquals(draftTransactions, other.draftTransactions);

  @override
  int get hashCode => Object.hash(
        transactions,
        draftTransactions,
      );
}

class TransactionStateError extends TransactionState {
  const TransactionStateError(this.message);

  final String message;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionStateError &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;
}

/// Transaction notifier for Riverpod state management
class TransactionNotifier extends StateNotifier<TransactionState> {
  TransactionNotifier(
    this._storageService,
    this._insightsProvider,
  ) : super(const TransactionStateInitial()) {
    initialize();
  }

  final StorageService _storageService;
  final InsightsProvider? _insightsProvider;
  bool _isInitialized = false;

  Future<void> initialize() async {
    debugPrint('[TransactionNotifier.initialize] 🚀 开始初始化 TransactionNotifier');
    if (!_isInitialized) {
      _isInitialized = true;
      debugPrint('[TransactionNotifier.initialize] [SUCCESS] 初始化完成');
    } else {
      debugPrint('[TransactionNotifier.initialize] [INFO] 已经初始化过');
    }
    await loadTransactions();
    debugPrint(
      '[TransactionNotifier.initialize] [TARGET] TransactionNotifier 初始化完成',
    );
  }

  // 加载交易数据
  Future<void> loadTransactions() async {
    debugPrint('[TransactionNotifier.loadTransactions] [FOLDER] 开始加载交易数据');
    state = const TransactionStateLoading();

    try {
      debugPrint(
        '[TransactionNotifier.loadTransactions] [STORAGE] 从 StorageService 加载正式交易',
      );
      final transactions = await _storageService.loadTransactions();
      debugPrint(
        '[TransactionNotifier.loadTransactions] [SUCCESS] 正式交易加载完成，数量: ${transactions.length}',
      );

      debugPrint(
        '[TransactionNotifier.loadTransactions] [DRAFT] 从 StorageService 加载草稿交易',
      );
      final draftTransactions = await _storageService.loadDraftTransactions();
      debugPrint(
        '[TransactionNotifier.loadTransactions] [SUCCESS] 草稿交易加载完成，数量: ${draftTransactions.length}',
      );

      debugPrint('[TransactionNotifier.loadTransactions] [STATS] 数据加载完成统计:');
      debugPrint(
        '[TransactionNotifier.loadTransactions] [CHART] 正式交易: ${transactions.length} 笔',
      );
      debugPrint(
        '[TransactionNotifier.loadTransactions] [DRAFT] 草稿交易: ${draftTransactions.length} 笔',
      );
      debugPrint(
        '[TransactionNotifier.loadTransactions] [TREND] 总计: ${transactions.length + draftTransactions.length} 笔',
      );

      state = TransactionStateLoaded(transactions, draftTransactions);
    } catch (e) {
      debugPrint('[TransactionNotifier.loadTransactions] [ERROR] 数据加载失败: $e');
      state = TransactionStateError(e.toString());
    }
  }

  // 添加交易
  Future<void> addTransaction(Transaction transaction) async {
    try {
      final currentState = state;
      if (currentState is! TransactionStateLoaded) return;

      final newTransactions = [...currentState.transactions, transaction];
      await _storageService.saveTransactions(newTransactions);

      // Trigger Flux Loop analysis for new transaction
      await _triggerInsightAnalysis(transaction.id, JobType.dailyAnalysis);

      state = TransactionStateLoaded(
        newTransactions,
        currentState.draftTransactions,
      );
    } catch (e) {
      state = TransactionStateError(e.toString());
    }
  }

  // 更新交易
  Future<void> updateTransaction(Transaction updatedTransaction) async {
    try {
      final currentState = state;
      if (currentState is! TransactionStateLoaded) return;

      final newTransactions = currentState.transactions
          .map(
            (t) => t.id == updatedTransaction.id
                ? updatedTransaction.copyWith(updateDate: DateTime.now())
                : t,
          )
          .toList();

      await _storageService.saveTransactions(newTransactions);

      // Trigger Flux Loop analysis for updated transaction
      await _triggerInsightAnalysis(
        updatedTransaction.id,
        JobType.dailyAnalysis,
      );

      state = TransactionStateLoaded(
        newTransactions,
        currentState.draftTransactions,
      );
    } catch (e) {
      state = TransactionStateError(e.toString());
    }
  }

  // 删除交易
  Future<void> deleteTransaction(String transactionId) async {
    try {
      final currentState = state;
      if (currentState is! TransactionStateLoaded) return;

      final newTransactions = currentState.transactions
          .where((t) => t.id != transactionId)
          .toList();
      await _storageService.saveTransactions(newTransactions);

      // Trigger Flux Loop analysis for deleted transaction
      await _triggerInsightAnalysis(transactionId, JobType.dailyAnalysis);

      state = TransactionStateLoaded(
        newTransactions,
        currentState.draftTransactions,
      );
    } catch (e) {
      state = TransactionStateError(e.toString());
    }
  }

  // Helper method to trigger insight analysis
  Future<void> _triggerInsightAnalysis(
    String transactionId,
    JobType jobType,
  ) async {
    try {
      // Only trigger if insights provider is available
      if (_insightsProvider != null) {
        await _insightsProvider.onTransactionChanged(
          transactionId: transactionId,
          analysisType: jobType,
        );
      }
    } catch (e) {
      // Don't let insight analysis failures break transaction operations
      // Log error but don't set it as the main error
      debugPrint('Failed to trigger insight analysis: $e');
    }
  }

  // 添加草稿交易
  Future<void> addDraftTransaction(Transaction transaction) async {
    try {
      final currentState = state;
      if (currentState is! TransactionStateLoaded) return;

      final newDraftTransactions = [
        ...currentState.draftTransactions,
        transaction,
      ];
      await _storageService.saveDraftTransactions(newDraftTransactions);

      state = TransactionStateLoaded(
        currentState.transactions,
        newDraftTransactions,
      );
    } catch (e) {
      state = TransactionStateError(e.toString());
    }
  }

  // 确认草稿交易
  Future<void> confirmDraftTransaction(String draftId) async {
    try {
      final currentState = state;
      if (currentState is! TransactionStateLoaded) return;

      final draftIndex =
          currentState.draftTransactions.indexWhere((t) => t.id == draftId);
      if (draftIndex != -1) {
        final draft = currentState.draftTransactions[draftIndex];
        final confirmedTransaction = draft.copyWith(
          status: TransactionStatus.confirmed,
          updateDate: DateTime.now(),
        );

        final newTransactions = [
          ...currentState.transactions,
          confirmedTransaction,
        ];
        final newDraftTransactions =
            List<Transaction>.from(currentState.draftTransactions)
              ..removeAt(draftIndex);

        await _storageService.saveTransactions(newTransactions);
        await _storageService.saveDraftTransactions(newDraftTransactions);

        state = TransactionStateLoaded(newTransactions, newDraftTransactions);
      }
    } catch (e) {
      state = TransactionStateError(e.toString());
    }
  }

  // 删除草稿交易
  Future<void> deleteDraftTransaction(String draftId) async {
    try {
      final currentState = state;
      if (currentState is! TransactionStateLoaded) return;

      final newDraftTransactions =
          currentState.draftTransactions.where((t) => t.id != draftId).toList();
      await _storageService.saveDraftTransactions(newDraftTransactions);

      state = TransactionStateLoaded(
        currentState.transactions,
        newDraftTransactions,
      );
    } catch (e) {
      state = TransactionStateError(e.toString());
    }
  }

  // 获取指定钱包的交易
  List<Transaction> getTransactionsByWallet(String walletId) {
    final currentState = state;
    if (currentState is! TransactionStateLoaded) return [];

    return currentState.transactions
        .where(
          (t) => t.fromWalletId == walletId || t.toWalletId == walletId,
        )
        .toList();
  }

  // 获取指定资产的交易
  List<Transaction> getTransactionsByAsset(String assetId) {
    final currentState = state;
    if (currentState is! TransactionStateLoaded) return [];

    return currentState.transactions
        .where(
          (t) => t.fromAssetId == assetId || t.toAssetId == assetId,
        )
        .toList();
  }

  // 向后兼容：获取指定账户的交易
  List<Transaction> getTransactionsByAccount(String accountId) {
    final currentState = state;
    if (currentState is! TransactionStateLoaded) return [];

    return currentState.transactions
        .where(
          (t) => t.fromAccountId == accountId || t.toAccountId == accountId,
        )
        .toList();
  }

  // 获取指定分类的交易
  List<Transaction> getTransactionsByCategory(TransactionCategory category) {
    final currentState = state;
    if (currentState is! TransactionStateLoaded) return [];

    return currentState.transactions
        .where((t) => t.category == category)
        .toList();
  }

  // 获取指定时间范围的交易
  List<Transaction> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    final currentState = state;
    if (currentState is! TransactionStateLoaded) return [];

    return currentState.transactions
        .where(
          (t) =>
              t.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
              t.date.isBefore(endDate.add(const Duration(days: 1))),
        )
        .toList();
  }

  // 获取今日交易
  List<Transaction> getTodayTransactions() {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return getTransactionsByDateRange(startOfDay, endOfDay);
  }

  // 获取本月交易
  List<Transaction> getThisMonthTransactions() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month);
    final endOfMonth = DateTime(now.year, now.month + 1);
    return getTransactionsByDateRange(startOfMonth, endOfMonth);
  }

  // 计算总收入
  double calculateTotalIncome({DateTime? startDate, DateTime? endDate}) {
    final currentState = state;
    if (currentState is! TransactionStateLoaded) return 0.0;

    var filteredTransactions = currentState.transactions;

    if (startDate != null && endDate != null) {
      filteredTransactions = getTransactionsByDateRange(startDate, endDate);
    }

    // 支持新旧交易类型系统
    return filteredTransactions
        .where(
          (t) =>
              t.status == TransactionStatus.confirmed &&
              (t.flow == TransactionFlow.externalToWallet ||
                  t.type == TransactionType.income),
        )
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  // 计算总支出
  double calculateTotalExpense({DateTime? startDate, DateTime? endDate}) {
    final currentState = state;
    if (currentState is! TransactionStateLoaded) return 0.0;

    var filteredTransactions = currentState.transactions;

    if (startDate != null && endDate != null) {
      filteredTransactions = getTransactionsByDateRange(startDate, endDate);
    }

    // 支持新旧交易类型系统
    return filteredTransactions
        .where(
          (t) =>
              t.status == TransactionStatus.confirmed &&
              (t.flow == TransactionFlow.walletToExternal ||
                  t.flow == TransactionFlow.walletToAsset ||
                  t.type == TransactionType.expense),
        )
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  // 计算净收入
  double calculateNetIncome({DateTime? startDate, DateTime? endDate}) =>
      calculateTotalIncome(startDate: startDate, endDate: endDate) -
      calculateTotalExpense(startDate: startDate, endDate: endDate);

  // 按分类统计支出
  Map<TransactionCategory, double> getExpenseByCategory({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final currentState = state;
    if (currentState is! TransactionStateLoaded) return {};

    var filteredTransactions = currentState.transactions;

    if (startDate != null && endDate != null) {
      filteredTransactions = getTransactionsByDateRange(startDate, endDate);
    }

    final categoryExpenses = <TransactionCategory, double>{};

    for (final category in TransactionCategory.values) {
      if (category.isExpense) {
        final categoryTransactions = filteredTransactions.where(
          (t) =>
              t.category == category &&
              t.status == TransactionStatus.confirmed &&
              (t.flow == TransactionFlow.walletToExternal ||
                  t.flow == TransactionFlow.walletToAsset ||
                  t.type == TransactionType.expense),
        );

        categoryExpenses[category] =
            categoryTransactions.fold(0.0, (sum, t) => sum + t.amount);
      }
    }

    return categoryExpenses;
  }

  // 格式化金额
  String formatAmount(double amount, {String currency = 'CNY'}) {
    final formatter = NumberFormat.currency(locale: 'zh_CN', symbol: '¥');
    return formatter.format(amount);
  }

  // 格式化日期
  String formatDate(DateTime date) {
    final formatter = DateFormat('yyyy-MM-dd');
    return formatter.format(date);
  }

  // 格式化时间
  String formatTime(DateTime date) {
    final formatter = DateFormat('HH:mm');
    return formatter.format(date);
  }

  // 格式化日期时间
  String formatDateTime(DateTime date) {
    final formatter = DateFormat('yyyy-MM-dd HH:mm');
    return formatter.format(date);
  }

  // 搜索交易
  List<Transaction> searchTransactions(String query) {
    final currentState = state;
    if (currentState is! TransactionStateLoaded) return [];

    if (query.isEmpty) return currentState.transactions;

    final lowercaseQuery = query.toLowerCase();
    return currentState.transactions
        .where(
          (t) =>
              t.description.toLowerCase().contains(lowercaseQuery) ||
              t.category.displayName.toLowerCase().contains(lowercaseQuery) ||
              (t.notes?.toLowerCase().contains(lowercaseQuery) ?? false) ||
              t.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery)),
        )
        .toList();
  }

  // 刷新数据
  Future<void> refresh() async {
    await loadTransactions();
  }
}

/// Riverpod providers for transaction management
final insightsProviderProvider = Provider<InsightsProvider?>((ref) {
  // This should be overridden where needed
  return null;
});

final transactionProvider =
    StateNotifierProvider<TransactionNotifier, TransactionState>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  final insightsProvider = ref.watch(insightsProviderProvider);
  return TransactionNotifier(storageService, insightsProvider);
});

/// Computed providers for derived transaction data
final transactionListProvider = Provider<List<Transaction>>(
    (ref) => ref.watch(transactionProvider).transactions);

final draftTransactionListProvider = Provider<List<Transaction>>(
    (ref) => ref.watch(transactionProvider).draftTransactions);

final isTransactionLoadingProvider =
    Provider<bool>((ref) => ref.watch(transactionProvider).isLoading);

final transactionErrorProvider = Provider<String?>((ref) {
  final state = ref.watch(transactionProvider);
  return state.isError ? state.errorMessage : null;
});

final todayTransactionsProvider = Provider<List<Transaction>>((ref) {
  final notifier = ref.watch(transactionProvider.notifier);
  return notifier.getTodayTransactions();
});

final thisMonthTransactionsProvider = Provider<List<Transaction>>((ref) {
  final notifier = ref.watch(transactionProvider.notifier);
  return notifier.getThisMonthTransactions();
});

final totalIncomeProvider = Provider<double>((ref) {
  final notifier = ref.watch(transactionProvider.notifier);
  return notifier.calculateTotalIncome();
});

final totalExpenseProvider = Provider<double>((ref) {
  final notifier = ref.watch(transactionProvider.notifier);
  return notifier.calculateTotalExpense();
});

final netIncomeProvider = Provider<double>((ref) {
  final notifier = ref.watch(transactionProvider.notifier);
  return notifier.calculateNetIncome();
});

final expenseByCategoryProvider =
    Provider<Map<TransactionCategory, double>>((ref) {
  final notifier = ref.watch(transactionProvider.notifier);
  return notifier.getExpenseByCategory();
});
