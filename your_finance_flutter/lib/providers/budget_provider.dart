import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../models/budget.dart';
import '../models/transaction.dart';
import '../services/storage_service.dart';

class BudgetProvider with ChangeNotifier {
  List<EnvelopeBudget> _envelopeBudgets = [];
  List<ZeroBasedBudget> _zeroBasedBudgets = [];
  bool _isLoading = false;
  String? _error;
  late final StorageService _storageService;

  // Getters
  List<EnvelopeBudget> get envelopeBudgets => _envelopeBudgets;
  List<ZeroBasedBudget> get zeroBasedBudgets => _zeroBasedBudgets;
  List<EnvelopeBudget> get activeEnvelopeBudgets => 
      _envelopeBudgets.where((b) => b.status == BudgetStatus.active).toList();
  List<ZeroBasedBudget> get activeZeroBasedBudgets => 
      _zeroBasedBudgets.where((b) => b.status == BudgetStatus.active).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;

  // 初始化
  Future<void> initialize() async {
    _storageService = await StorageService.getInstance();
    await _loadBudgets();
  }

  // 加载预算数据
  Future<void> _loadBudgets() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _envelopeBudgets = await _storageService.loadEnvelopeBudgets();
      _zeroBasedBudgets = await _storageService.loadZeroBasedBudgets();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ========== 信封预算管理 ==========

  // 添加信封预算
  Future<void> addEnvelopeBudget(EnvelopeBudget budget) async {
    try {
      _envelopeBudgets.add(budget);
      await _storageService.saveEnvelopeBudgets(_envelopeBudgets);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // 更新信封预算
  Future<void> updateEnvelopeBudget(EnvelopeBudget updatedBudget) async {
    try {
      final index = _envelopeBudgets.indexWhere((b) => b.id == updatedBudget.id);
      if (index != -1) {
        _envelopeBudgets[index] = updatedBudget.copyWith(updateDate: DateTime.now());
        await _storageService.saveEnvelopeBudgets(_envelopeBudgets);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // 删除信封预算
  Future<void> deleteEnvelopeBudget(String budgetId) async {
    try {
      _envelopeBudgets.removeWhere((b) => b.id == budgetId);
      await _storageService.saveEnvelopeBudgets(_envelopeBudgets);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // ========== 零基预算管理 ==========

  // 添加零基预算
  Future<void> addZeroBasedBudget(ZeroBasedBudget budget) async {
    try {
      _zeroBasedBudgets.add(budget);
      await _storageService.saveZeroBasedBudgets(_zeroBasedBudgets);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // 更新零基预算
  Future<void> updateZeroBasedBudget(ZeroBasedBudget updatedBudget) async {
    try {
      final index = _zeroBasedBudgets.indexWhere((b) => b.id == updatedBudget.id);
      if (index != -1) {
        _zeroBasedBudgets[index] = updatedBudget.copyWith(updateDate: DateTime.now());
        await _storageService.saveZeroBasedBudgets(_zeroBasedBudgets);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // 删除零基预算
  Future<void> deleteZeroBasedBudget(String budgetId) async {
    try {
      _zeroBasedBudgets.removeWhere((b) => b.id == budgetId);
      await _storageService.saveZeroBasedBudgets(_zeroBasedBudgets);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // ========== 预算与交易集成 ==========

  // 处理交易对预算的影响
  Future<void> processTransaction(Transaction transaction) async {
    try {
      // 如果是支出交易且关联了信封预算
      if (transaction.type == TransactionType.expense && 
          transaction.envelopeBudgetId != null) {
        await _updateEnvelopeSpentAmount(transaction.envelopeBudgetId!, transaction.amount);
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // 更新信封已花费金额
  Future<void> _updateEnvelopeSpentAmount(String envelopeId, double amount) async {
    final index = _envelopeBudgets.indexWhere((b) => b.id == envelopeId);
    if (index != -1) {
      final currentBudget = _envelopeBudgets[index];
      final updatedBudget = currentBudget.copyWith(
        spentAmount: currentBudget.spentAmount + amount,
        updateDate: DateTime.now(),
      );
      _envelopeBudgets[index] = updatedBudget;
      await _storageService.saveEnvelopeBudgets(_envelopeBudgets);
      notifyListeners();
    }
  }

  // 撤销交易对预算的影响
  Future<void> revertTransaction(Transaction transaction) async {
    try {
      if (transaction.type == TransactionType.expense && 
          transaction.envelopeBudgetId != null) {
        await _updateEnvelopeSpentAmount(transaction.envelopeBudgetId!, -transaction.amount);
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // ========== 预算计算和统计 ==========

  // 获取当前活跃的零基预算
  ZeroBasedBudget? getCurrentZeroBasedBudget() {
    final now = DateTime.now();
    try {
      return _zeroBasedBudgets.firstWhere((b) => 
        b.status == BudgetStatus.active &&
        b.startDate.isBefore(now) &&
        b.endDate.isAfter(now)
      );
    } catch (e) {
      return null;
    }
  }

  // 获取当前活跃的信封预算
  List<EnvelopeBudget> getCurrentEnvelopeBudgets() {
    final now = DateTime.now();
    return _envelopeBudgets.where((b) => 
      b.status == BudgetStatus.active &&
      b.startDate.isBefore(now) &&
      b.endDate.isAfter(now)
    ).toList();
  }

  // 计算总预算分配金额
  double calculateTotalBudgetAllocated() {
    return getCurrentEnvelopeBudgets().fold(0.0, (sum, budget) => sum + budget.allocatedAmount);
  }

  // 计算总预算支出
  double calculateTotalBudgetSpent() {
    return getCurrentEnvelopeBudgets().fold(0.0, (sum, budget) => sum + budget.spentAmount);
  }

  // 计算总预算可用金额
  double calculateTotalBudgetAvailable() {
    return getCurrentEnvelopeBudgets().fold(0.0, (sum, budget) => sum + budget.availableAmount);
  }

  // 按分类统计预算
  Map<TransactionCategory, double> getBudgetByCategory() {
    final Map<TransactionCategory, double> categoryBudgets = {};
    
    for (final budget in getCurrentEnvelopeBudgets()) {
      categoryBudgets[budget.category] = budget.allocatedAmount;
    }
    
    return categoryBudgets;
  }

  // 按分类统计支出
  Map<TransactionCategory, double> getSpentByCategory() {
    final Map<TransactionCategory, double> categorySpent = {};
    
    for (final budget in getCurrentEnvelopeBudgets()) {
      categorySpent[budget.category] = budget.spentAmount;
    }
    
    return categorySpent;
  }

  // 获取超支的信封
  List<EnvelopeBudget> getOverBudgetEnvelopes() {
    return getCurrentEnvelopeBudgets().where((b) => b.isOverBudget).toList();
  }

  // 获取达到警告阈值的信封
  List<EnvelopeBudget> getWarningEnvelopes() {
    return getCurrentEnvelopeBudgets().where((b) => 
      b.isWarningThresholdReached && !b.isOverBudget
    ).toList();
  }

  // ========== 预算创建和分配 ==========

  // 创建月度零基预算
  Future<ZeroBasedBudget> createMonthlyZeroBasedBudget({
    required String name,
    required double totalIncome,
    required DateTime month,
  }) async {
    final startDate = DateTime(month.year, month.month, 1);
    final endDate = DateTime(month.year, month.month + 1, 1).subtract(const Duration(days: 1));
    
    final budget = ZeroBasedBudget(
      name: name,
      totalIncome: totalIncome,
      period: BudgetPeriod.monthly,
      startDate: startDate,
      endDate: endDate,
    );
    
    await addZeroBasedBudget(budget);
    return budget;
  }

  // 为分类创建信封预算
  Future<EnvelopeBudget> createEnvelopeBudget({
    required String name,
    required TransactionCategory category,
    required double allocatedAmount,
    required BudgetPeriod period,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final budget = EnvelopeBudget(
      name: name,
      category: category,
      allocatedAmount: allocatedAmount,
      period: period,
      startDate: startDate,
      endDate: endDate,
    );
    
    await addEnvelopeBudget(budget);
    return budget;
  }

  // 从零基预算分配金额到信封
  Future<void> allocateToEnvelope({
    required String zeroBasedBudgetId,
    required String envelopeBudgetId,
    required double amount,
  }) async {
    try {
      // 更新零基预算
      final zeroBasedIndex = _zeroBasedBudgets.indexWhere((b) => b.id == zeroBasedBudgetId);
      if (zeroBasedIndex != -1) {
        final currentZeroBased = _zeroBasedBudgets[zeroBasedIndex];
        final updatedZeroBased = currentZeroBased.copyWith(
          totalAllocated: currentZeroBased.totalAllocated + amount,
          updateDate: DateTime.now(),
        );
        _zeroBasedBudgets[zeroBasedIndex] = updatedZeroBased;
      }
      
      // 更新信封预算
      final envelopeIndex = _envelopeBudgets.indexWhere((b) => b.id == envelopeBudgetId);
      if (envelopeIndex != -1) {
        final currentEnvelope = _envelopeBudgets[envelopeIndex];
        final updatedEnvelope = currentEnvelope.copyWith(
          allocatedAmount: currentEnvelope.allocatedAmount + amount,
          updateDate: DateTime.now(),
        );
        _envelopeBudgets[envelopeIndex] = updatedEnvelope;
      }
      
      await _storageService.saveZeroBasedBudgets(_zeroBasedBudgets);
      await _storageService.saveEnvelopeBudgets(_envelopeBudgets);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // ========== 工具方法 ==========

  // 格式化金额
  String formatAmount(double amount, {String currency = 'CNY'}) {
    final formatter = NumberFormat.currency(locale: 'zh_CN', symbol: '¥');
    return formatter.format(amount);
  }

  // 格式化百分比
  String formatPercentage(double percentage) {
    return '${percentage.toStringAsFixed(1)}%';
  }

  // 获取预算状态颜色
  String getBudgetStatusColor(EnvelopeBudget budget) {
    if (budget.isOverBudget) return '#F44336'; // 红色 - 超支
    if (budget.isWarningThresholdReached) return '#FF9800'; // 橙色 - 警告
    return '#4CAF50'; // 绿色 - 正常
  }

  // 清除错误
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // 刷新数据
  Future<void> refresh() async {
    await _loadBudgets();
  }
}
