import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../services/storage_service.dart';

class TransactionProvider with ChangeNotifier {
  List<Transaction> _transactions = [];
  List<Transaction> _draftTransactions = []; // 草稿交易
  bool _isLoading = false;
  String? _error;
  late final StorageService _storageService;

  // Getters
  List<Transaction> get transactions => _transactions;
  List<Transaction> get draftTransactions => _draftTransactions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // 初始化
  Future<void> initialize() async {
    _storageService = await StorageService.getInstance();
    await _loadTransactions();
  }

  // 加载交易数据
  Future<void> _loadTransactions() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _transactions = await _storageService.loadTransactions();
      _draftTransactions = await _storageService.loadDraftTransactions();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 添加交易
  Future<void> addTransaction(Transaction transaction) async {
    try {
      _transactions.add(transaction);
      await _storageService.saveTransactions(_transactions);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // 更新交易
  Future<void> updateTransaction(Transaction updatedTransaction) async {
    try {
      final index = _transactions.indexWhere((t) => t.id == updatedTransaction.id);
      if (index != -1) {
        _transactions[index] = updatedTransaction.copyWith(updateDate: DateTime.now());
        await _storageService.saveTransactions(_transactions);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // 删除交易
  Future<void> deleteTransaction(String transactionId) async {
    try {
      _transactions.removeWhere((t) => t.id == transactionId);
      await _storageService.saveTransactions(_transactions);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // 添加草稿交易
  Future<void> addDraftTransaction(Transaction transaction) async {
    try {
      _draftTransactions.add(transaction);
      await _storageService.saveDraftTransactions(_draftTransactions);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // 确认草稿交易
  Future<void> confirmDraftTransaction(String draftId) async {
    try {
      final draftIndex = _draftTransactions.indexWhere((t) => t.id == draftId);
      if (draftIndex != -1) {
        final draft = _draftTransactions[draftIndex];
        final confirmedTransaction = draft.copyWith(
          status: TransactionStatus.confirmed,
          updateDate: DateTime.now(),
        );
        
        _transactions.add(confirmedTransaction);
        _draftTransactions.removeAt(draftIndex);
        
        await _storageService.saveTransactions(_transactions);
        await _storageService.saveDraftTransactions(_draftTransactions);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // 删除草稿交易
  Future<void> deleteDraftTransaction(String draftId) async {
    try {
      _draftTransactions.removeWhere((t) => t.id == draftId);
      await _storageService.saveDraftTransactions(_draftTransactions);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // 获取指定账户的交易
  List<Transaction> getTransactionsByAccount(String accountId) {
    return _transactions.where((t) => 
      t.fromAccountId == accountId || t.toAccountId == accountId
    ).toList();
  }

  // 获取指定分类的交易
  List<Transaction> getTransactionsByCategory(TransactionCategory category) {
    return _transactions.where((t) => t.category == category).toList();
  }

  // 获取指定时间范围的交易
  List<Transaction> getTransactionsByDateRange(DateTime startDate, DateTime endDate) {
    return _transactions.where((t) => 
      t.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
      t.date.isBefore(endDate.add(const Duration(days: 1)))
    ).toList();
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
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 1);
    return getTransactionsByDateRange(startOfMonth, endOfMonth);
  }

  // 计算总收入
  double calculateTotalIncome({DateTime? startDate, DateTime? endDate}) {
    List<Transaction> transactions = _transactions;
    
    if (startDate != null && endDate != null) {
      transactions = getTransactionsByDateRange(startDate, endDate);
    }
    
    return transactions
        .where((t) => t.type == TransactionType.income && t.status == TransactionStatus.confirmed)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  // 计算总支出
  double calculateTotalExpense({DateTime? startDate, DateTime? endDate}) {
    List<Transaction> transactions = _transactions;
    
    if (startDate != null && endDate != null) {
      transactions = getTransactionsByDateRange(startDate, endDate);
    }
    
    return transactions
        .where((t) => t.type == TransactionType.expense && t.status == TransactionStatus.confirmed)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  // 计算净收入
  double calculateNetIncome({DateTime? startDate, DateTime? endDate}) {
    return calculateTotalIncome(startDate: startDate, endDate: endDate) - 
           calculateTotalExpense(startDate: startDate, endDate: endDate);
  }

  // 按分类统计支出
  Map<TransactionCategory, double> getExpenseByCategory({DateTime? startDate, DateTime? endDate}) {
    List<Transaction> transactions = _transactions;
    
    if (startDate != null && endDate != null) {
      transactions = getTransactionsByDateRange(startDate, endDate);
    }
    
    final Map<TransactionCategory, double> categoryExpenses = {};
    
    for (final category in TransactionCategory.values) {
      if (category.isExpense) {
        final categoryTransactions = transactions.where((t) => 
          t.category == category && 
          t.type == TransactionType.expense && 
          t.status == TransactionStatus.confirmed
        );
        
        categoryExpenses[category] = categoryTransactions.fold(0.0, (sum, t) => sum + t.amount);
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
    if (query.isEmpty) return _transactions;
    
    final lowercaseQuery = query.toLowerCase();
    return _transactions.where((t) =>
      t.description.toLowerCase().contains(lowercaseQuery) ||
      t.category.displayName.toLowerCase().contains(lowercaseQuery) ||
      (t.notes?.toLowerCase().contains(lowercaseQuery) ?? false) ||
      t.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery))
    ).toList();
  }

  // 清除错误
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // 刷新数据
  Future<void> refresh() async {
    await _loadTransactions();
  }
}
