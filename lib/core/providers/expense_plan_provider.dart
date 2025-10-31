import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:your_finance_flutter/core/models/expense_plan.dart';
import 'package:your_finance_flutter/core/services/storage_service.dart';
import 'package:your_finance_flutter/core/utils/logger.dart';

/// 支出计划状态管理
class ExpensePlanProvider with ChangeNotifier {
  List<ExpensePlan> _expensePlans = [];
  bool _isLoading = false;
  String? _error;
  late final StorageService _storageService;

  // Getters
  List<ExpensePlan> get expensePlans => _expensePlans;
  List<ExpensePlan> get activeExpensePlans => _expensePlans
      .where((plan) => plan.status == ExpensePlanStatus.active)
      .toList();
  List<ExpensePlan> get periodicExpensePlans => activeExpensePlans
      .where((plan) => plan.type == ExpensePlanType.periodic)
      .toList();
  List<ExpensePlan> get budgetExpensePlans => activeExpensePlans
      .where((plan) => plan.type == ExpensePlanType.budget)
      .toList();
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// 初始化
  Future<void> initialize() async {
    Logger.debug('🔄 ExpensePlanProvider 初始化开始');
    _storageService = await StorageService.getInstance();
    Logger.debug('✅ StorageService 初始化完成');
    await _loadExpensePlans();
    Logger.debug('✅ ExpensePlanProvider 初始化完成，支出计划数量: ${_expensePlans.length}');
  }

  /// 加载支出计划数据
  Future<void> _loadExpensePlans() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      Logger.debug('📊 开始加载支出计划数据');
      final loadedPlans = await _storageService.loadExpensePlans();
      _expensePlans = loadedPlans.map((plan) => plan as ExpensePlan).toList();
      Logger.debug('✅ 支出计划加载完成: ${_expensePlans.length} 个');

      if (_expensePlans.isNotEmpty) {
        Logger.debug('💰 支出计划详情:');
        for (var i = 0; i < _expensePlans.length; i++) {
          final plan = _expensePlans[i];
          Logger.debug(
            '  ${i + 1}. ${plan.name}: ¥${plan.amount} (${plan.frequency.displayName})',
          );
        }
      }
    } catch (e) {
      Logger.debug('❌ 加载支出计划数据失败: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 添加支出计划
  Future<void> addExpensePlan(ExpensePlan plan) async {
    try {
      Logger.debug('➕ 添加支出计划: ${plan.name}');
      _expensePlans.add(plan);
      await _storageService.saveExpensePlans(_expensePlans);
      notifyListeners();
      Logger.debug('✅ 支出计划添加成功: ${plan.name}');
    } catch (e) {
      Logger.debug('❌ 添加支出计划失败: $e');
      _error = e.toString();
      notifyListeners();
    }
  }

  /// 更新支出计划
  Future<void> updateExpensePlan(ExpensePlan updatedPlan) async {
    try {
      Logger.debug('🔄 更新支出计划: ${updatedPlan.name}');
      final index =
          _expensePlans.indexWhere((plan) => plan.id == updatedPlan.id);
      if (index != -1) {
        _expensePlans[index] = updatedPlan.copyWith(updateDate: DateTime.now());
        await _storageService.saveExpensePlans(_expensePlans);
        notifyListeners();
        Logger.debug('✅ 支出计划更新成功: ${updatedPlan.name}');
      } else {
        throw Exception('支出计划不存在');
      }
    } catch (e) {
      Logger.debug('❌ 更新支出计划失败: $e');
      _error = e.toString();
      notifyListeners();
    }
  }

  /// 删除支出计划
  Future<void> deleteExpensePlan(String planId) async {
    try {
      Logger.debug('🗑️ 删除支出计划: $planId');
      final planIndex = _expensePlans.indexWhere((plan) => plan.id == planId);
      if (planIndex != -1) {
        final planName = _expensePlans[planIndex].name;
        _expensePlans.removeAt(planIndex);
        await _storageService.saveExpensePlans(_expensePlans);
        notifyListeners();
        Logger.debug('✅ 支出计划删除成功: $planName');
      }
    } catch (e) {
      Logger.debug('❌ 删除支出计划失败: $e');
      _error = e.toString();
      notifyListeners();
    }
  }

  /// 记录支出计划执行
  Future<void> executeExpensePlan(String planId) async {
    try {
      final index = _expensePlans.indexWhere((plan) => plan.id == planId);
      if (index != -1) {
        _expensePlans[index] = _expensePlans[index].recordExecution();
        await _storageService.saveExpensePlans(_expensePlans);
        notifyListeners();
        Logger.debug('✅ 支出计划执行记录成功: ${_expensePlans[index].name}');
      }
    } catch (e) {
      Logger.debug('❌ 记录支出计划执行失败: $e');
      _error = e.toString();
      notifyListeners();
    }
  }

  /// 暂停支出计划
  Future<void> pauseExpensePlan(String planId) async {
    try {
      final index = _expensePlans.indexWhere((plan) => plan.id == planId);
      if (index != -1) {
        _expensePlans[index] = _expensePlans[index].pause();
        await _storageService.saveExpensePlans(_expensePlans);
        notifyListeners();
        Logger.debug('⏸️ 支出计划暂停成功: ${_expensePlans[index].name}');
      }
    } catch (e) {
      Logger.debug('❌ 暂停支出计划失败: $e');
      _error = e.toString();
      notifyListeners();
    }
  }

  /// 恢复支出计划
  Future<void> resumeExpensePlan(String planId) async {
    try {
      final index = _expensePlans.indexWhere((plan) => plan.id == planId);
      if (index != -1) {
        _expensePlans[index] = _expensePlans[index].resume();
        await _storageService.saveExpensePlans(_expensePlans);
        notifyListeners();
        Logger.debug('▶️ 支出计划恢复成功: ${_expensePlans[index].name}');
      }
    } catch (e) {
      Logger.debug('❌ 恢复支出计划失败: $e');
      _error = e.toString();
      notifyListeners();
    }
  }

  /// 获取指定日期应该执行的支出计划
  List<ExpensePlan> getPlansToExecuteToday() {
    final today = DateTime.now();
    return activeExpensePlans
        .where((plan) => plan.shouldExecuteOn(today))
        .toList();
  }

  /// 获取指定日期范围内的支出计划
  List<ExpensePlan> getPlansInDateRange(DateTime startDate, DateTime endDate) =>
      _expensePlans
          .where(
            (plan) =>
                plan.startDate.isBefore(endDate) &&
                (plan.endDate == null || plan.endDate!.isAfter(startDate)),
          )
          .toList();

  /// 获取月度支出统计
  double getMonthlyExpenseTotal(int year, int month) => activeExpensePlans
      .where((plan) => plan.frequency == ExpenseFrequency.monthly)
      .fold(0.0, (sum, plan) => sum + plan.amount);

  /// 获取年度支出统计
  double getYearlyExpenseTotal(int year) => activeExpensePlans
      .where((plan) => plan.frequency == ExpenseFrequency.yearly)
      .fold(0.0, (sum, plan) => sum + plan.amount);

  /// 获取按分类分组的支出统计
  Map<String, double> getExpenseByCategory() {
    final categoryTotals = <String, double>{};

    for (final plan in activeExpensePlans) {
      final category = plan.categoryId ?? '未分类';
      categoryTotals[category] = (categoryTotals[category] ?? 0) + plan.amount;
    }

    return categoryTotals;
  }

  /// 获取按频率分组的支出统计
  Map<ExpenseFrequency, double> getExpenseByFrequency() {
    final frequencyTotals = <ExpenseFrequency, double>{};

    for (final plan in activeExpensePlans) {
      frequencyTotals[plan.frequency] =
          (frequencyTotals[plan.frequency] ?? 0) + plan.amount;
    }

    return frequencyTotals;
  }

  /// 按钱包ID获取支出计划
  List<ExpensePlan> getPlansByWalletId(String walletId) =>
      _expensePlans.where((plan) => plan.walletId == walletId).toList();

  /// 按类型获取支出计划
  List<ExpensePlan> getPlansByType(ExpensePlanType type) =>
      _expensePlans.where((plan) => plan.type == type).toList();

  /// 按状态获取支出计划
  List<ExpensePlan> getPlansByStatus(ExpensePlanStatus status) =>
      _expensePlans.where((plan) => plan.status == status).toList();

  /// 获取总支出计划金额
  double get totalExpenseAmount =>
      activeExpensePlans.fold(0.0, (sum, plan) => sum + plan.amount);

  /// 获取周期性支出金额
  double get periodicExpenseAmount =>
      periodicExpensePlans.fold(0.0, (sum, plan) => sum + plan.amount);

  /// 获取预算计划金额
  double get budgetExpenseAmount =>
      budgetExpensePlans.fold(0.0, (sum, plan) => sum + plan.amount);

  /// 获取今天到期的还款计划
  List<ExpensePlan> getDueTodayPlans() {
    final today = DateTime.now();
    return activeExpensePlans.where((plan) {
      // 只检查有贷款关联的计划
      if (plan.loanAccountId == null) return false;

      // 检查是否今天到期（可以根据业务逻辑调整为到期前几天提醒）
      final daysUntilDue = plan.startDate.difference(today).inDays;
      return daysUntilDue <= 0 && daysUntilDue >= -3; // 到期当天和过期3天内的提醒
    }).toList();
  }

  /// 获取即将到期的还款计划（未来7天内）
  List<ExpensePlan> getUpcomingDuePlans() {
    final today = DateTime.now();
    final nextWeek = today.add(const Duration(days: 7));

    return activeExpensePlans.where((plan) {
      // 只检查有贷款关联的计划
      if (plan.loanAccountId == null) return false;

      // 检查是否在未来7天内到期
      return plan.startDate.isAfter(today) &&
             plan.startDate.isBefore(nextWeek);
    }).toList();
  }

  /// 获取所有未完成的还款计划
  List<ExpensePlan> getPendingRepaymentPlans() {
    return activeExpensePlans.where((plan) =>
      plan.loanAccountId != null
    ).toList();
  }

  /// 刷新数据
  Future<void> refresh() async {
    await _loadExpensePlans();
  }

  /// 清空错误
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
