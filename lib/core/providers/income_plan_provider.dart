import 'package:flutter/foundation.dart';
import 'package:your_finance_flutter/core/models/bonus_item.dart';
import 'package:your_finance_flutter/core/models/budget.dart';
import 'package:your_finance_flutter/core/models/income_plan.dart';
import 'package:your_finance_flutter/core/models/transaction.dart';
import 'package:your_finance_flutter/core/providers/transaction_provider.dart';
import 'package:your_finance_flutter/core/services/storage_service.dart';

class IncomePlanProvider with ChangeNotifier {
  List<IncomePlan> _incomePlans = [];
  bool _isLoading = false;
  String? _error;
  late final StorageService _storageService;

  // Getters
  List<IncomePlan> get incomePlans => _incomePlans;
  List<IncomePlan> get activeIncomePlans =>
      _incomePlans.where((plan) => plan.isActive).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;

  // 初始化
  Future<void> initialize() async {
    _storageService = await StorageService.getInstance();
    await _loadIncomePlans();
  }

  // 加载收入计划数据
  Future<void> _loadIncomePlans() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      print('📊 开始加载收入计划数据');
      final loadedPlans = await _storageService.loadIncomePlans();
      _incomePlans = loadedPlans.map((plan) => plan as IncomePlan).toList();
      print('✅ 收入计划加载完成: ${_incomePlans.length} 个');
    } catch (e) {
      print('❌ 加载收入计划数据失败: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 添加收入计划
  Future<void> addIncomePlan(IncomePlan plan) async {
    try {
      print('➕ 添加收入计划: ${plan.name}');
      _incomePlans.add(plan);
      await _storageService.saveIncomePlans(_incomePlans);
      notifyListeners();
      print('✅ 收入计划添加成功: ${plan.name}');
    } catch (e) {
      print('❌ 添加收入计划失败: $e');
      _error = e.toString();
      notifyListeners();
    }
  }

  // 更新收入计划
  Future<void> updateIncomePlan(IncomePlan updatedPlan) async {
    try {
      final index =
          _incomePlans.indexWhere((plan) => plan.id == updatedPlan.id);
      if (index != -1) {
        _incomePlans[index] = updatedPlan;
        // TODO: 保存到存储服务
        // await _storageService.saveIncomePlans(_incomePlans);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // 删除收入计划
  Future<void> deleteIncomePlan(String planId) async {
    try {
      _incomePlans.removeWhere((plan) => plan.id == planId);
      // TODO: 保存到存储服务
      // await _storageService.saveIncomePlans(_incomePlans);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // 根据ID获取收入计划
  IncomePlan? getIncomePlanById(String planId) {
    try {
      return _incomePlans.firstWhere((plan) => plan.id == planId);
    } catch (e) {
      return null;
    }
  }

  // 获取需要今天执行的收入计划
  List<IncomePlan> getPlansToExecuteToday() {
    final today = DateTime.now();
    return activeIncomePlans
        .where((plan) => plan.shouldExecuteOn(today))
        .toList();
  }

  // 执行收入计划
  Future<void> executeIncomePlan(
    String planId,
    double actualAmount, {
    String? description,
  }) async {
    try {
      final planIndex = _incomePlans.indexWhere((plan) => plan.id == planId);
      if (planIndex != -1) {
        final plan = _incomePlans[planIndex];

        // 更新计划统计信息
        final updatedPlan = plan.copyWith(
          lastExecutionDate: DateTime.now(),
          nextExecutionDate: plan.getNextExecutionDate(),
          totalExecuted: plan.totalExecuted + actualAmount,
          executionCount: plan.executionCount + 1,
          updateDate: DateTime.now(),
        );

        _incomePlans[planIndex] = updatedPlan;

        // TODO: 保存执行记录和更新后的计划到存储服务

        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // 获取月度收入统计
  double getMonthlyIncomeTotal(int year, int month) => activeIncomePlans
      .where((plan) => plan.frequency == IncomeFrequency.monthly)
      .fold(0.0, (sum, plan) => sum + plan.amount);

  /// 从工资收入创建收入计划
  Future<void> createIncomePlanFromSalary(
    SalaryIncome salaryIncome,
    String walletId,
  ) async {
    try {
      print('💰 从工资创建收入计划: ${salaryIncome.name}');

      // 计算每月固定收入（扣除一次性奖金）
      final monthlyFixedIncome = _calculateMonthlyFixedIncome(salaryIncome);

      // 创建每月固定收入计划
      final monthlyPlan = IncomePlan.create(
        name: '${salaryIncome.name} - 月薪',
        description: '每月固定工资收入（已扣除五险一金和个税）',
        amount: monthlyFixedIncome,
        frequency: IncomeFrequency.monthly,
        walletId: walletId,
        salaryIncomeId: salaryIncome.id,
        startDate: DateTime.now(),
      );

      await addIncomePlan(monthlyPlan);

      // 为每个奖金项目创建单独的收入计划
      for (final bonus in salaryIncome.bonuses) {
        final bonusPlan = IncomePlan.create(
          name: '${salaryIncome.name} - ${bonus.name}',
          description: '奖金收入（${bonus.frequency.displayName}）',
          amount: bonus.amount / bonus.paymentCount, // 平均到每次发放
          frequency: _convertBonusFrequency(bonus.frequency),
          walletId: walletId,
          salaryIncomeId: salaryIncome.id,
          startDate: bonus.startDate,
        );

        await addIncomePlan(bonusPlan);
      }

      print(
        '✅ 成功从工资创建收入计划: 每月固定 ¥$monthlyFixedIncome, 奖金 ${salaryIncome.bonuses.length} 项',
      );
    } catch (e) {
      print('❌ 从工资创建收入计划失败: $e');
      _error = e.toString();
      notifyListeners();
    }
  }

  /// 计算每月固定收入（扣除一次性奖金）
  double _calculateMonthlyFixedIncome(SalaryIncome salaryIncome) {
    // 每月固定收入 = 基本工资 + 补贴 - 五险一金 - 个税 - 专项附加扣除
    final fixedIncome = salaryIncome.basicSalary +
        salaryIncome.housingAllowance +
        salaryIncome.mealAllowance +
        salaryIncome.transportationAllowance +
        salaryIncome.otherAllowance;

    // 扣除五险一金和个税（专项附加扣除每月已扣除）
    final deductions = salaryIncome.socialInsurance +
        salaryIncome.housingFund +
        salaryIncome.personalIncomeTax;

    return fixedIncome - deductions;
  }

  /// 转换奖金频率到收入频率
  IncomeFrequency _convertBonusFrequency(BonusFrequency bonusFrequency) {
    switch (bonusFrequency) {
      case BonusFrequency.monthly:
        return IncomeFrequency.monthly;
      case BonusFrequency.quarterly:
        return IncomeFrequency.quarterly;
      case BonusFrequency.semiAnnual:
        return IncomeFrequency.monthly; // 半年奖按月平摊
      case BonusFrequency.annual:
        return IncomeFrequency.yearly;
      case BonusFrequency.oneTime:
        return IncomeFrequency.yearly; // 一次性奖金按年处理
    }
  }

  /// 获取与工资关联的收入计划
  List<IncomePlan> getPlansBySalaryId(String salaryIncomeId) => _incomePlans
      .where((plan) => plan.salaryIncomeId == salaryIncomeId)
      .toList();

  /// 检查工资是否已创建收入计划
  bool hasIncomePlanForSalary(String salaryIncomeId) =>
      _incomePlans.any((plan) => plan.salaryIncomeId == salaryIncomeId);

  // 获取年度收入统计
  double getYearlyIncomeTotal(int year) => activeIncomePlans
      .where((plan) => plan.frequency == IncomeFrequency.yearly)
      .fold(0.0, (sum, plan) => sum + plan.amount);

  /// 自动执行收入计划，生成相应的收入交易
  Future<void> autoExecuteIncomePlans(TransactionProvider transactionProvider) async {
    final now = DateTime.now();
    final executedPlans = <IncomePlan>[];

    print('🔄 开始自动执行收入计划，当前时间: $now');

    for (final plan in activeIncomePlans) {
      if (_shouldExecutePlan(plan, now)) {
        try {
          print('💰 执行收入计划: ${plan.name}');
          await _executeIncomePlan(plan, transactionProvider);
          executedPlans.add(plan);
        } catch (e) {
          print('❌ 执行收入计划失败: ${plan.name}, 错误: $e');
        }
      }
    }

    if (executedPlans.isNotEmpty) {
      // 更新执行时间并保存
      for (final plan in executedPlans) {
        final updatedPlan = plan.copyWith(lastExecutionDate: now);
        await updateIncomePlan(updatedPlan);
      }
      print('✅ 自动执行完成，共执行了 ${executedPlans.length} 个收入计划');
    } else {
      print('ℹ️ 没有需要执行的收入计划');
    }
  }

  /// 检查收入计划是否应该执行
  bool _shouldExecutePlan(IncomePlan plan, DateTime now) {
    final lastExecution = plan.lastExecutionDate ?? plan.startDate;

    switch (plan.frequency) {
      case IncomeFrequency.daily:
        return now.difference(lastExecution).inDays >= 1;
      case IncomeFrequency.weekly:
        return now.difference(lastExecution).inDays >= 7;
      case IncomeFrequency.monthly:
        return now.month > lastExecution.month ||
               (now.month == lastExecution.month && now.year > lastExecution.year);
      case IncomeFrequency.quarterly:
        final currentQuarter = ((now.month - 1) ~/ 3) + 1;
        final lastQuarter = ((lastExecution.month - 1) ~/ 3) + 1;
        return currentQuarter > lastQuarter || now.year > lastExecution.year;
      case IncomeFrequency.yearly:
        return now.year > lastExecution.year;
      case IncomeFrequency.oneTime:
        // 一次性收入只执行一次
        return plan.lastExecutionDate == null;
    }
  }

  /// 执行单个收入计划，创建收入交易
  Future<void> _executeIncomePlan(IncomePlan plan, TransactionProvider transactionProvider) async {
    // 创建收入交易
    final transaction = Transaction(
      description: '${plan.name} - 自动收入',
      amount: plan.amount,
      type: TransactionType.income,
      category: TransactionCategory.salary, // 工资收入类别
      toWalletId: plan.walletId, // 收入到指定的钱包
      date: DateTime.now(),
      tags: ['自动收入', plan.name],
      incomePlanId: plan.id, // 关联到收入计划
      isAutoGenerated: true, // 标记为自动生成
    );

    await transactionProvider.addTransaction(transaction);
    print('✅ 已创建收入交易: ${transaction.description}, 金额: ¥${transaction.amount}');
  }

  // 刷新数据
  Future<void> refresh() async {
    await _loadIncomePlans();
  }

  // 清除错误
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
