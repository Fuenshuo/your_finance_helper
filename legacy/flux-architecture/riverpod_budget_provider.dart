import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:your_finance_flutter/core/models/bonus_item.dart';
import 'package:your_finance_flutter/core/models/budget.dart';
import 'package:your_finance_flutter/core/models/transaction.dart';
import 'package:your_finance_flutter/core/providers/shared_providers.dart';
import 'package:your_finance_flutter/core/utils/logger.dart';

/// Budget state for Riverpod
@immutable
sealed class BudgetState {
  const BudgetState();

  bool get isInitial => this is BudgetStateInitial;
  bool get isLoading => this is BudgetStateLoading;
  bool get isLoaded => this is BudgetStateLoaded;
  bool get isError => this is BudgetStateError;

  List<EnvelopeBudget> get envelopeBudgets => this is BudgetStateLoaded ? (this as BudgetStateLoaded).envelopeBudgets : [];
  List<ZeroBasedBudget> get zeroBasedBudgets => this is BudgetStateLoaded ? (this as BudgetStateLoaded).zeroBasedBudgets : [];
  List<SalaryIncome> get salaryIncomes => this is BudgetStateLoaded ? (this as BudgetStateLoaded).salaryIncomes : [];
  List<MonthlyWallet> get monthlyWallets => this is BudgetStateLoaded ? (this as BudgetStateLoaded).monthlyWallets : [];
  bool get isInitialized => this is BudgetStateLoaded ? (this as BudgetStateLoaded).isInitialized : false;
  String get errorMessage => this is BudgetStateError ? (this as BudgetStateError).message : '';
}

class BudgetStateInitial extends BudgetState {
  const BudgetStateInitial();
}

class BudgetStateLoading extends BudgetState {
  const BudgetStateLoading();
}

class BudgetStateLoaded extends BudgetState {
  const BudgetStateLoaded(
    this.envelopeBudgets,
    this.zeroBasedBudgets,
    this.salaryIncomes,
    this.monthlyWallets, {
    required this.isInitialized,
  });

  final List<EnvelopeBudget> envelopeBudgets;
  final List<ZeroBasedBudget> zeroBasedBudgets;
  final List<SalaryIncome> salaryIncomes;
  final List<MonthlyWallet> monthlyWallets;
  final bool isInitialized;

  List<EnvelopeBudget> get activeEnvelopeBudgets =>
      envelopeBudgets.where((b) => b.status == BudgetStatus.active).toList();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BudgetStateLoaded &&
          runtimeType == other.runtimeType &&
          listEquals(envelopeBudgets, other.envelopeBudgets) &&
          listEquals(zeroBasedBudgets, other.zeroBasedBudgets) &&
          listEquals(salaryIncomes, other.salaryIncomes) &&
          listEquals(monthlyWallets, other.monthlyWallets) &&
          isInitialized == other.isInitialized;

  @override
  int get hashCode => Object.hash(
        envelopeBudgets,
        zeroBasedBudgets,
        salaryIncomes,
        monthlyWallets,
        isInitialized,
      );
}

class BudgetStateError extends BudgetState {
  const BudgetStateError(this.message);

  final String message;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BudgetStateError &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;
}

/// Budget notifier for Riverpod state management
class BudgetNotifier extends StateNotifier<BudgetState> {
  BudgetNotifier(this._storageService) : super(const BudgetStateInitial()) {
    initialize();
  }

  final StorageService _storageService;
  bool _isInitialized = false;

  Future<void> initialize() async {
    Logger.info('[INIT] BudgetNotifier 开始初始化');
    state = const BudgetStateLoading();
    try {
      await loadBudgets();
      state = BudgetStateLoaded(
        [],
        [],
        [],
        [],
        isInitialized: true,
      );
      _isInitialized = true;
      Logger.info('[SUCCESS] BudgetNotifier 初始化完成');
    } catch (e) {
      Logger.error('[ERROR] BudgetNotifier 初始化失败: $e');
      state = BudgetStateError(e.toString());
    }
  }

  // 加载预算数据
  Future<void> loadBudgets() async {
    try {
      Logger.debug('[CHART] 开始加载预算数据');

      final envelopeBudgets = await _storageService.loadEnvelopeBudgets();
      Logger.debug('✅ 信封预算加载完成: ${envelopeBudgets.length} 个');

      final zeroBasedBudgets = await _storageService.loadZeroBasedBudgets();
      Logger.debug('✅ 零基预算加载完成: ${zeroBasedBudgets.length} 个');

      final salaryIncomes = await _storageService.loadSalaryIncomes();
      Logger.debug('✅ 工资收入加载完成: ${salaryIncomes.length} 个');

      final monthlyWallets = await _storageService.loadMonthlyWallets();
      Logger.debug('✅ 每月工资钱包加载完成: ${monthlyWallets.length} 个');

      state = BudgetStateLoaded(
        envelopeBudgets,
        zeroBasedBudgets,
        salaryIncomes,
        monthlyWallets,
        isInitialized: true,
      );

      Logger.debug('[SUCCESS] 预算数据加载完成');
    } catch (e) {
      Logger.error('❌ 加载预算数据失败: $e');
      state = BudgetStateError(e.toString());
    }
  }

  // ========== 信封预算管理 ==========

  // 添加信封预算
  Future<void> addEnvelopeBudget(EnvelopeBudget budget) async {
    try {
      final currentState = state;
      if (currentState is! BudgetStateLoaded) return;

      final newBudgets = [...currentState.envelopeBudgets, budget];
      await _storageService.saveEnvelopeBudgets(newBudgets);

      state = BudgetStateLoaded(
        newBudgets,
        currentState.zeroBasedBudgets,
        currentState.salaryIncomes,
        currentState.monthlyWallets,
        isInitialized: currentState.isInitialized,
      );
    } catch (e) {
      state = BudgetStateError(e.toString());
    }
  }

  // 更新信封预算
  Future<void> updateEnvelopeBudget(EnvelopeBudget updatedBudget) async {
    try {
      final currentState = state;
      if (currentState is! BudgetStateLoaded) return;

      final newBudgets = currentState.envelopeBudgets.map((b) =>
          b.id == updatedBudget.id ? updatedBudget.copyWith(updateDate: DateTime.now()) : b
      ).toList();

      await _storageService.saveEnvelopeBudgets(newBudgets);

      state = BudgetStateLoaded(
        newBudgets,
        currentState.zeroBasedBudgets,
        currentState.salaryIncomes,
        currentState.monthlyWallets,
        isInitialized: currentState.isInitialized,
      );
    } catch (e) {
      state = BudgetStateError(e.toString());
    }
  }

  // 删除信封预算
  Future<void> deleteEnvelopeBudget(String budgetId) async {
    try {
      final currentState = state;
      if (currentState is! BudgetStateLoaded) return;

      final newBudgets = currentState.envelopeBudgets.where((b) => b.id != budgetId).toList();
      await _storageService.saveEnvelopeBudgets(newBudgets);

      state = BudgetStateLoaded(
        newBudgets,
        currentState.zeroBasedBudgets,
        currentState.salaryIncomes,
        currentState.monthlyWallets,
        isInitialized: currentState.isInitialized,
      );
    } catch (e) {
      state = BudgetStateError(e.toString());
    }
  }

  // ========== 零基预算管理 ==========

  // 添加零基预算
  Future<void> addZeroBasedBudget(ZeroBasedBudget budget) async {
    try {
      final currentState = state;
      if (currentState is! BudgetStateLoaded) return;

      final newBudgets = [...currentState.zeroBasedBudgets, budget];
      await _storageService.saveZeroBasedBudgets(newBudgets);

      state = BudgetStateLoaded(
        currentState.envelopeBudgets,
        newBudgets,
        currentState.salaryIncomes,
        currentState.monthlyWallets,
        isInitialized: currentState.isInitialized,
      );
    } catch (e) {
      state = BudgetStateError(e.toString());
    }
  }

  // 更新零基预算
  Future<void> updateZeroBasedBudget(ZeroBasedBudget updatedBudget) async {
    try {
      final currentState = state;
      if (currentState is! BudgetStateLoaded) return;

      final newBudgets = currentState.zeroBasedBudgets.map((b) =>
          b.id == updatedBudget.id ? updatedBudget.copyWith(updateDate: DateTime.now()) : b
      ).toList();

      await _storageService.saveZeroBasedBudgets(newBudgets);

      state = BudgetStateLoaded(
        currentState.envelopeBudgets,
        newBudgets,
        currentState.salaryIncomes,
        currentState.monthlyWallets,
        isInitialized: currentState.isInitialized,
      );
    } catch (e) {
      state = BudgetStateError(e.toString());
    }
  }

  // 删除零基预算
  Future<void> deleteZeroBasedBudget(String budgetId) async {
    try {
      final currentState = state;
      if (currentState is! BudgetStateLoaded) return;

      final newBudgets = currentState.zeroBasedBudgets.where((b) => b.id != budgetId).toList();
      await _storageService.saveZeroBasedBudgets(newBudgets);

      state = BudgetStateLoaded(
        currentState.envelopeBudgets,
        newBudgets,
        currentState.salaryIncomes,
        currentState.monthlyWallets,
        isInitialized: currentState.isInitialized,
      );
    } catch (e) {
      state = BudgetStateError(e.toString());
    }
  }

  // ========== 工资收入管理 ==========

  // 添加工资收入
  Future<void> addSalaryIncome(SalaryIncome income) async {
    try {
      Logger.debug('[NOTE] 添加工资收入: ${income.name}, ID: ${income.id}');
      final currentState = state;
      if (currentState is! BudgetStateLoaded) return;

      final newIncomes = [...currentState.salaryIncomes, income];
      await _storageService.saveSalaryIncomes(newIncomes);

      state = BudgetStateLoaded(
        currentState.envelopeBudgets,
        currentState.zeroBasedBudgets,
        newIncomes,
        currentState.monthlyWallets,
        isInitialized: currentState.isInitialized,
      );

      Logger.info('✅ 工资收入保存成功');
    } catch (e) {
      Logger.error('❌ 添加工资收入失败: $e');
      state = BudgetStateError(e.toString());
    }
  }

  // 更新工资收入
  Future<void> updateSalaryIncome(SalaryIncome updatedIncome) async {
    Logger.debug('[NOTE] 更新工资收入: ${updatedIncome.name}');
    try {
      final currentState = state;
      if (currentState is! BudgetStateLoaded) return;

      final newIncomes = currentState.salaryIncomes.map((i) =>
          i.id == updatedIncome.id ? updatedIncome.copyWith(updateDate: DateTime.now()) : i
      ).toList();

      await _storageService.saveSalaryIncomes(newIncomes);

      state = BudgetStateLoaded(
        currentState.envelopeBudgets,
        currentState.zeroBasedBudgets,
        newIncomes,
        currentState.monthlyWallets,
        isInitialized: currentState.isInitialized,
      );

      Logger.info('✅ 工资收入保存成功');
    } catch (e) {
      Logger.error('❌ 工资收入更新失败: $e');
      state = BudgetStateError(e.toString());
    }
  }

  // 删除工资收入
  Future<void> deleteSalaryIncome(String incomeId) async {
    try {
      final currentState = state;
      if (currentState is! BudgetStateLoaded) return;

      final newIncomes = currentState.salaryIncomes.where((i) => i.id != incomeId).toList();
      await _storageService.saveSalaryIncomes(newIncomes);

      state = BudgetStateLoaded(
        currentState.envelopeBudgets,
        currentState.zeroBasedBudgets,
        newIncomes,
        currentState.monthlyWallets,
        isInitialized: currentState.isInitialized,
      );
    } catch (e) {
      state = BudgetStateError(e.toString());
    }
  }

  // 创建工资收入
  Future<SalaryIncome> createSalaryIncome({
    required String name,
    required double basicSalary,
    required int salaryDay,
    double housingAllowance = 0.0,
    double mealAllowance = 0.0,
    double transportationAllowance = 0.0,
    double otherAllowance = 0.0,
    Map<DateTime, double>? salaryHistory,
    Map<int, AllowanceRecord>? monthlyAllowances,
    List<BonusItem> bonuses = const [],
    double personalIncomeTax = 0.0,
    double socialInsurance = 0.0,
    double housingFund = 0.0,
    double otherDeductions = 0.0,
    double specialDeductionMonthly = 0.0,
    double otherTaxDeductions = 0.0,
    String? description,
  }) async {
    final income = SalaryIncome(
      name: name,
      description: description,
      basicSalary: basicSalary,
      salaryHistory: salaryHistory,
      housingAllowance: housingAllowance,
      mealAllowance: mealAllowance,
      transportationAllowance: transportationAllowance,
      otherAllowance: otherAllowance,
      monthlyAllowances: monthlyAllowances,
      bonuses: bonuses,
      personalIncomeTax: personalIncomeTax,
      socialInsurance: socialInsurance,
      housingFund: housingFund,
      otherDeductions: otherDeductions,
      specialDeductionMonthly: specialDeductionMonthly,
      otherTaxDeductions: otherTaxDeductions,
      salaryDay: salaryDay,
    );

    await addSalaryIncome(income);
    return income;
  }

  // 添加奖金项目到工资收入
  Future<void> addBonusToSalaryIncome(
    String salaryIncomeId,
    BonusItem bonus,
  ) async {
    try {
      final currentState = state;
      if (currentState is! BudgetStateLoaded) return;

      final incomeIndex = currentState.salaryIncomes.indexWhere((income) => income.id == salaryIncomeId);
      if (incomeIndex == -1) return;

      final updatedIncome = currentState.salaryIncomes[incomeIndex].copyWith(
        bonuses: [...currentState.salaryIncomes[incomeIndex].bonuses, bonus],
      );

      await updateSalaryIncome(updatedIncome);
    } catch (e) {
      state = BudgetStateError(e.toString());
    }
  }

  // 删除工资收入中的奖金项目
  Future<void> removeBonusFromSalaryIncome(
    String salaryIncomeId,
    String bonusId,
  ) async {
    try {
      final currentState = state;
      if (currentState is! BudgetStateLoaded) return;

      final incomeIndex = currentState.salaryIncomes.indexWhere((income) => income.id == salaryIncomeId);
      if (incomeIndex == -1) return;

      final updatedBonuses = currentState.salaryIncomes[incomeIndex]
          .bonuses
          .where((bonus) => bonus.id != bonusId)
          .toList();

      final updatedIncome = currentState.salaryIncomes[incomeIndex].copyWith(
        bonuses: updatedBonuses,
      );

      await updateSalaryIncome(updatedIncome);
    } catch (e) {
      state = BudgetStateError(e.toString());
    }
  }

  // 更新工资收入中的奖金项目
  Future<void> updateBonusInSalaryIncome(
    String salaryIncomeId,
    BonusItem updatedBonus,
  ) async {
    try {
      final currentState = state;
      if (currentState is! BudgetStateLoaded) return;

      final incomeIndex = currentState.salaryIncomes.indexWhere((income) => income.id == salaryIncomeId);
      if (incomeIndex == -1) return;

      final updatedBonuses = currentState.salaryIncomes[incomeIndex]
          .bonuses
          .map((bonus) => bonus.id == updatedBonus.id ? updatedBonus : bonus)
          .toList();

      final updatedIncome = currentState.salaryIncomes[incomeIndex].copyWith(
        bonuses: updatedBonuses,
      );

      await updateSalaryIncome(updatedIncome);
    } catch (e) {
      state = BudgetStateError(e.toString());
    }
  }

  // 获取工资收入的奖金项目列表
  List<BonusItem> getBonusesForSalaryIncome(String salaryIncomeId) {
    final currentState = state;
    if (currentState is! BudgetStateLoaded) return [];

    final income = currentState.salaryIncomes.firstWhere(
      (income) => income.id == salaryIncomeId,
      orElse: () => throw ArgumentError('Salary income not found'),
    );
    return income.bonuses;
  }

  // 获取总月收入
  double getTotalMonthlyIncome() {
    final currentState = state;
    if (currentState is! BudgetStateLoaded) return 0.0;

    return currentState.salaryIncomes.fold(0.0, (sum, income) => sum + income.netIncome);
  }

  // 获取下个月总收入
  double getNextMonthTotalIncome() {
    final currentState = state;
    if (currentState is! BudgetStateLoaded) return 0.0;

    final now = DateTime.now();
    final nextMonth = DateTime(now.year, now.month + 1);

    return currentState.salaryIncomes.fold(0.0, (sum, income) {
      if (income.period == BudgetPeriod.monthly ||
          income.getNextSalaryDate().month == nextMonth.month) {
        return sum + income.netIncome;
      }
      return sum;
    });
  }

  // ========== 每月工资钱包管理 ==========

  // 生成指定年月的工资钱包
  Future<MonthlyWallet?> generateMonthlyWallet(
    SalaryIncome salaryIncome,
    int year,
    int month,
  ) async {
    try {
      final currentState = state;
      if (currentState is! BudgetStateLoaded) return null;

      // 检查是否已存在该月的钱包
      final existingWallet = currentState.monthlyWallets.firstWhere(
        (wallet) => wallet.year == year && wallet.month == month,
        orElse: () => MonthlyWallet(
          id: '',
          year: year,
          month: month,
          basicSalary: 0,
          housingAllowance: 0,
          mealAllowance: 0,
          transportationAllowance: 0,
          otherAllowance: 0,
          bonuses: const [],
          socialInsurance: 0,
          housingFund: 0,
          otherDeductions: 0,
          specialDeductionMonthly: 0,
          calculatedTax: 0,
          netIncome: 0,
          isPaid: false,
        ),
      );

      if (existingWallet.id.isNotEmpty) {
        return existingWallet;
      }

      // 生成新的钱包
      final wallet = MonthlyWallet.fromSalaryIncome(salaryIncome, year, month);
      await addMonthlyWallet(wallet);
      return wallet;
    } catch (e) {
      state = BudgetStateError(e.toString());
      return null;
    }
  }

  // 生成指定年份的所有工资钱包
  Future<void> generateYearlyWallets(
    SalaryIncome salaryIncome,
    int year,
  ) async {
    try {
      final currentState = state;
      if (currentState is! BudgetStateLoaded) return;

      final wallets = <MonthlyWallet>[];
      final now = DateTime.now();

      // 只生成到当前月份（包括当前月）
      final maxMonth = (year == now.year) ? now.month : 12;

      for (var month = 1; month <= maxMonth; month++) {
        // 检查是否已存在
        final existing = currentState.monthlyWallets.firstWhere(
          (w) => w.year == year && w.month == month,
          orElse: () => MonthlyWallet(
            id: '',
            year: year,
            month: month,
            basicSalary: 0,
            housingAllowance: 0,
            mealAllowance: 0,
            transportationAllowance: 0,
            otherAllowance: 0,
            bonuses: const [],
            socialInsurance: 0,
            housingFund: 0,
            otherDeductions: 0,
            specialDeductionMonthly: 0,
            calculatedTax: 0,
            netIncome: 0,
            isPaid: false,
          ),
        );

        if (existing.id.isEmpty) {
          // 生成新钱包
          final wallet = MonthlyWallet.fromSalaryIncome(salaryIncome, year, month);
          wallets.add(wallet);
        }
      }

      if (wallets.isNotEmpty) {
        final newWallets = [...currentState.monthlyWallets, ...wallets];
        await _storageService.saveMonthlyWallets(newWallets);

        state = BudgetStateLoaded(
          currentState.envelopeBudgets,
          currentState.zeroBasedBudgets,
          currentState.salaryIncomes,
          newWallets,
          isInitialized: currentState.isInitialized,
        );
      }
    } catch (e) {
      state = BudgetStateError(e.toString());
    }
  }

  // 添加每月工资钱包
  Future<void> addMonthlyWallet(MonthlyWallet wallet) async {
    try {
      final currentState = state;
      if (currentState is! BudgetStateLoaded) return;

      final newWallets = [...currentState.monthlyWallets, wallet];
      await _storageService.saveMonthlyWallets(newWallets);

      state = BudgetStateLoaded(
        currentState.envelopeBudgets,
        currentState.zeroBasedBudgets,
        currentState.salaryIncomes,
        newWallets,
        isInitialized: currentState.isInitialized,
      );
    } catch (e) {
      state = BudgetStateError(e.toString());
    }
  }

  // 更新每月工资钱包
  Future<void> updateMonthlyWallet(MonthlyWallet updatedWallet) async {
    try {
      final currentState = state;
      if (currentState is! BudgetStateLoaded) return;

      final newWallets = currentState.monthlyWallets.map((w) =>
          w.id == updatedWallet.id ? updatedWallet.copyWith(updateDate: DateTime.now()) : w
      ).toList();

      await _storageService.saveMonthlyWallets(newWallets);

      state = BudgetStateLoaded(
        currentState.envelopeBudgets,
        currentState.zeroBasedBudgets,
        currentState.salaryIncomes,
        newWallets,
        isInitialized: currentState.isInitialized,
      );
    } catch (e) {
      state = BudgetStateError(e.toString());
    }
  }

  // 删除每月工资钱包
  Future<void> removeMonthlyWallet(String walletId) async {
    try {
      final currentState = state;
      if (currentState is! BudgetStateLoaded) return;

      final newWallets = currentState.monthlyWallets.where((w) => w.id != walletId).toList();
      await _storageService.saveMonthlyWallets(newWallets);

      state = BudgetStateLoaded(
        currentState.envelopeBudgets,
        currentState.zeroBasedBudgets,
        currentState.salaryIncomes,
        newWallets,
        isInitialized: currentState.isInitialized,
      );
    } catch (e) {
      state = BudgetStateError(e.toString());
    }
  }

  // 获取指定年月的工资钱包
  MonthlyWallet? getMonthlyWallet(int year, int month) {
    final currentState = state;
    if (currentState is! BudgetStateLoaded) return null;

    try {
      return currentState.monthlyWallets.firstWhere(
        (wallet) => wallet.year == year && wallet.month == month,
      );
    } catch (e) {
      return null;
    }
  }

  // 获取指定年份的所有工资钱包
  List<MonthlyWallet> getYearlyWallets(int year) {
    final currentState = state;
    if (currentState is! BudgetStateLoaded) return [];

    return currentState.monthlyWallets.where((wallet) => wallet.year == year).toList()
      ..sort((a, b) => a.month.compareTo(b.month));
  }

  // ========== 预算与交易集成 ==========

  // 处理交易对预算的影响
  Future<void> processTransaction(Transaction transaction) async {
    try {
      final currentState = state;
      if (currentState is! BudgetStateLoaded) return;

      // 如果是支出交易且关联了信封预算
      if (transaction.type == TransactionType.expense &&
          transaction.envelopeBudgetId != null) {
        await _updateEnvelopeSpentAmount(
          currentState,
          transaction.envelopeBudgetId!,
          transaction.amount,
        );
      }
    } catch (e) {
      state = BudgetStateError(e.toString());
    }
  }

  // 更新信封已花费金额
  Future<void> _updateEnvelopeSpentAmount(
    BudgetStateLoaded currentState,
    String envelopeId,
    double amount,
  ) async {
    final index = currentState.envelopeBudgets.indexWhere((b) => b.id == envelopeId);
    if (index != -1) {
      final currentBudget = currentState.envelopeBudgets[index];
      final updatedBudget = currentBudget.copyWith(
        spentAmount: currentBudget.spentAmount + amount,
        updateDate: DateTime.now(),
      );

      final newBudgets = [...currentState.envelopeBudgets];
      newBudgets[index] = updatedBudget;

      await _storageService.saveEnvelopeBudgets(newBudgets);

      state = BudgetStateLoaded(
        newBudgets,
        currentState.zeroBasedBudgets,
        currentState.salaryIncomes,
        currentState.monthlyWallets,
        isInitialized: currentState.isInitialized,
      );
    }
  }

  // 撤销交易对预算的影响
  Future<void> revertTransaction(Transaction transaction) async {
    try {
      final currentState = state;
      if (currentState is! BudgetStateLoaded) return;

      if (transaction.type == TransactionType.expense &&
          transaction.envelopeBudgetId != null) {
        await _updateEnvelopeSpentAmount(
          currentState,
          transaction.envelopeBudgetId!,
          -transaction.amount,
        );
      }
    } catch (e) {
      state = BudgetStateError(e.toString());
    }
  }

  // ========== 预算计算和统计 ==========

  // 获取当前活跃的零基预算
  ZeroBasedBudget? getCurrentZeroBasedBudget() {
    final currentState = state;
    if (currentState is! BudgetStateLoaded) return null;

    final now = DateTime.now();
    try {
      return currentState.zeroBasedBudgets.firstWhere(
        (b) =>
            b.status == BudgetStatus.active &&
            b.startDate.isBefore(now) &&
            b.endDate.isAfter(now),
      );
    } catch (e) {
      return null;
    }
  }

  // 获取当前活跃的信封预算
  List<EnvelopeBudget> getCurrentEnvelopeBudgets() {
    final currentState = state;
    if (currentState is! BudgetStateLoaded) return [];

    final now = DateTime.now();
    return currentState.envelopeBudgets
        .where(
          (b) =>
              b.status == BudgetStatus.active &&
              b.startDate.isBefore(now) &&
              b.endDate.isAfter(now),
        )
        .toList();
  }

  // 计算总预算分配金额
  double calculateTotalBudgetAllocated() =>
      getCurrentEnvelopeBudgets().fold(0.0, (sum, budget) => sum + budget.allocatedAmount);

  // 计算总预算支出
  double calculateTotalBudgetSpent() =>
      getCurrentEnvelopeBudgets().fold(0.0, (sum, budget) => sum + budget.spentAmount);

  // 计算总预算可用金额
  double calculateTotalBudgetAvailable() =>
      getCurrentEnvelopeBudgets().fold(0.0, (sum, budget) => sum + budget.availableAmount);

  // 按分类统计预算
  Map<TransactionCategory, double> getBudgetByCategory() {
    final categoryBudgets = <TransactionCategory, double>{};

    for (final budget in getCurrentEnvelopeBudgets()) {
      categoryBudgets[budget.category] = budget.allocatedAmount;
    }

    return categoryBudgets;
  }

  // 按分类统计支出
  Map<TransactionCategory, double> getSpentByCategory() {
    final categorySpent = <TransactionCategory, double>{};

    for (final budget in getCurrentEnvelopeBudgets()) {
      categorySpent[budget.category] = budget.spentAmount;
    }

    return categorySpent;
  }

  // 获取超支的信封
  List<EnvelopeBudget> getOverBudgetEnvelopes() =>
      getCurrentEnvelopeBudgets().where((b) => b.isOverBudget).toList();

  // 获取达到警告阈值的信封
  List<EnvelopeBudget> getWarningEnvelopes() =>
      getCurrentEnvelopeBudgets().where((b) => b.isWarningThresholdReached && !b.isOverBudget).toList();

  // ========== 预算创建和分配 ==========

  // 创建月度零基预算
  Future<ZeroBasedBudget> createMonthlyZeroBasedBudget({
    required String name,
    required double totalIncome,
    required DateTime month,
  }) async {
    final startDate = DateTime(month.year, month.month);
    final endDate = DateTime(month.year, month.month + 1).subtract(const Duration(days: 1));

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
      final currentState = state;
      if (currentState is! BudgetStateLoaded) return;

      // 更新零基预算
      final zeroBasedIndex = currentState.zeroBasedBudgets.indexWhere((b) => b.id == zeroBasedBudgetId);
      if (zeroBasedIndex != -1) {
        final currentZeroBased = currentState.zeroBasedBudgets[zeroBasedIndex];
        final updatedZeroBased = currentZeroBased.copyWith(
          totalAllocated: currentZeroBased.totalAllocated + amount,
          updateDate: DateTime.now(),
        );

        final newZeroBasedBudgets = [...currentState.zeroBasedBudgets];
        newZeroBasedBudgets[zeroBasedIndex] = updatedZeroBased;

        await _storageService.saveZeroBasedBudgets(newZeroBasedBudgets);
      }

      // 更新信封预算
      final envelopeIndex = currentState.envelopeBudgets.indexWhere((b) => b.id == envelopeBudgetId);
      if (envelopeIndex != -1) {
        final currentEnvelope = currentState.envelopeBudgets[envelopeIndex];
        final updatedEnvelope = currentEnvelope.copyWith(
          allocatedAmount: currentEnvelope.allocatedAmount + amount,
          updateDate: DateTime.now(),
        );

        final newEnvelopeBudgets = [...currentState.envelopeBudgets];
        newEnvelopeBudgets[envelopeIndex] = updatedEnvelope;

        await _storageService.saveEnvelopeBudgets(newEnvelopeBudgets);
      }

      // 更新状态
      state = BudgetStateLoaded(
        currentState.envelopeBudgets,
        currentState.zeroBasedBudgets,
        currentState.salaryIncomes,
        currentState.monthlyWallets,
        isInitialized: currentState.isInitialized,
      );
    } catch (e) {
      state = BudgetStateError(e.toString());
    }
  }

  // ========== 工具方法 ==========

  // 格式化金额
  String formatAmount(double amount, {String currency = 'CNY'}) {
    final formatter = NumberFormat.currency(locale: 'zh_CN', symbol: '¥');
    return formatter.format(amount);
  }

  // 格式化百分比
  String formatPercentage(double percentage) => '${percentage.toStringAsFixed(1)}%';

  // 获取预算状态颜色
  String getBudgetStatusColor(EnvelopeBudget budget) {
    if (budget.isOverBudget) return '#F44336'; // 红色 - 超支
    if (budget.isWarningThresholdReached) return '#FF9800'; // 橙色 - 警告
    return '#4CAF50'; // 绿色 - 正常
  }

  // 刷新数据
  Future<void> refresh() async {
    await loadBudgets();
  }
}

/// Riverpod providers for budget management
final budgetProvider = StateNotifierProvider<BudgetNotifier, BudgetState>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  return BudgetNotifier(storageService);
});

/// Computed providers for derived budget data
final envelopeBudgetsProvider = Provider<List<EnvelopeBudget>>((ref) {
  return ref.watch(budgetProvider).envelopeBudgets;
});

final zeroBasedBudgetsProvider = Provider<List<ZeroBasedBudget>>((ref) {
  return ref.watch(budgetProvider).zeroBasedBudgets;
});

final salaryIncomesProvider = Provider<List<SalaryIncome>>((ref) {
  return ref.watch(budgetProvider).salaryIncomes;
});

final monthlyWalletsProvider = Provider<List<MonthlyWallet>>((ref) {
  return ref.watch(budgetProvider).monthlyWallets;
});

final activeEnvelopeBudgetsProvider = Provider<List<EnvelopeBudget>>((ref) {
  final state = ref.watch(budgetProvider);
  return state.isLoaded ? state.envelopeBudgets.where((b) => b.status == BudgetStatus.active).toList() : [];
});

final isBudgetLoadingProvider = Provider<bool>((ref) {
  return ref.watch(budgetProvider).isLoading;
});

final isBudgetInitializedProvider = Provider<bool>((ref) {
  return ref.watch(budgetProvider).isInitialized;
});

final budgetErrorProvider = Provider<String?>((ref) {
  final state = ref.watch(budgetProvider);
  return state.isError ? state.errorMessage : null;
});

final currentZeroBasedBudgetProvider = Provider<ZeroBasedBudget?>((ref) {
  final notifier = ref.watch(budgetProvider.notifier);
  return notifier.getCurrentZeroBasedBudget();
});

final currentEnvelopeBudgetsProvider = Provider<List<EnvelopeBudget>>((ref) {
  final notifier = ref.watch(budgetProvider.notifier);
  return notifier.getCurrentEnvelopeBudgets();
});

final totalBudgetAllocatedProvider = Provider<double>((ref) {
  final notifier = ref.watch(budgetProvider.notifier);
  return notifier.calculateTotalBudgetAllocated();
});

final totalBudgetSpentProvider = Provider<double>((ref) {
  final notifier = ref.watch(budgetProvider.notifier);
  return notifier.calculateTotalBudgetSpent();
});

final totalBudgetAvailableProvider = Provider<double>((ref) {
  final notifier = ref.watch(budgetProvider.notifier);
  return notifier.calculateTotalBudgetAvailable();
});

final budgetByCategoryProvider = Provider<Map<TransactionCategory, double>>((ref) {
  final notifier = ref.watch(budgetProvider.notifier);
  return notifier.getBudgetByCategory();
});

final spentByCategoryProvider = Provider<Map<TransactionCategory, double>>((ref) {
  final notifier = ref.watch(budgetProvider.notifier);
  return notifier.getSpentByCategory();
});

final overBudgetEnvelopesProvider = Provider<List<EnvelopeBudget>>((ref) {
  final notifier = ref.watch(budgetProvider.notifier);
  return notifier.getOverBudgetEnvelopes();
});

final warningEnvelopesProvider = Provider<List<EnvelopeBudget>>((ref) {
  final notifier = ref.watch(budgetProvider.notifier);
  return notifier.getWarningEnvelopes();
});

final totalMonthlyIncomeProvider = Provider<double>((ref) {
  final notifier = ref.watch(budgetProvider.notifier);
  return notifier.getTotalMonthlyIncome();
});

final nextMonthTotalIncomeProvider = Provider<double>((ref) {
  final notifier = ref.watch(budgetProvider.notifier);
  return notifier.getNextMonthTotalIncome();
});
