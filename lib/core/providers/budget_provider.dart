import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:your_finance_flutter/core/models/bonus_item.dart';
import 'package:your_finance_flutter/core/models/budget.dart';
import 'package:your_finance_flutter/core/models/transaction.dart';
import 'package:your_finance_flutter/core/services/storage_service.dart';
import 'package:your_finance_flutter/core/utils/logger.dart';

class BudgetProvider with ChangeNotifier {
  List<EnvelopeBudget> _envelopeBudgets = [];
  List<ZeroBasedBudget> _zeroBasedBudgets = [];
  List<SalaryIncome> _salaryIncomes = []; // 新增：工资收入列表
  List<MonthlyWallet> _monthlyWallets = []; // 新增：每月工资钱包列表
  bool _isLoading = false;
  bool _isInitialized = false; // 新增：初始化状态标记
  String? _error;
  late final StorageService _storageService;

  // Getters
  List<EnvelopeBudget> get envelopeBudgets => _envelopeBudgets;
  List<ZeroBasedBudget> get zeroBasedBudgets => _zeroBasedBudgets;
  List<SalaryIncome> get salaryIncomes => _salaryIncomes; // 新增：工资收入getter
  List<MonthlyWallet> get monthlyWallets => _monthlyWallets; // 新增：每月工资钱包getter
  List<EnvelopeBudget> get activeEnvelopeBudgets =>
      _envelopeBudgets.where((b) => b.status == BudgetStatus.active).toList();
  List<ZeroBasedBudget> get activeZeroBasedBudgets =>
      _zeroBasedBudgets.where((b) => b.status == BudgetStatus.active).toList();
  List<SalaryIncome> get activeSalaryIncomes => _salaryIncomes; // 新增：活跃工资收入
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized; // 新增：初始化状态getter
  String? get error => _error;

  // 初始化预算数据
  Future<void> initialize() async {
    Logger.info('🔄 BudgetProvider 开始初始化');
    _isLoading = true;
    notifyListeners();

    try {
      if (!_isInitialized) {
        _storageService = await StorageService.getInstance();
        Logger.info('✅ StorageService 初始化完成');
      } else {
        Logger.info('♻️ StorageService 已初始化，执行数据刷新');
      }

      // 加载所有数据
      await _loadBudgets();

      _isInitialized = true;
      _isLoading = false;
      _error = null;
      Logger.info('✅ BudgetProvider 初始化完成，工资收入数量: ${_salaryIncomes.length}');
      notifyListeners();
    } catch (e) {
      Logger.error('❌ BudgetProvider 初始化失败: $e');
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // 加载预算数据
  Future<void> _loadBudgets() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      Logger.debug('📊 开始加载预算数据');
      _envelopeBudgets = await _storageService.loadEnvelopeBudgets();
      Logger.debug('✅ 信封预算加载完成: ${_envelopeBudgets.length} 个');

      _zeroBasedBudgets = await _storageService.loadZeroBasedBudgets();
      Logger.debug('✅ 零基预算加载完成: ${_zeroBasedBudgets.length} 个');

      _salaryIncomes = await _storageService.loadSalaryIncomes(); // 新增：加载工资收入
      Logger.debug('✅ 工资收入加载完成: ${_salaryIncomes.length} 个');
      if (_salaryIncomes.isNotEmpty) {
        Logger.debug('💼 工资收入详情:');
        for (var i = 0; i < _salaryIncomes.length; i++) {
          final income = _salaryIncomes[i];
          Logger.debug(
              '  工资收入${i + 1}: ${income.name} - 基本工资=${income.basicSalary}, 奖金数量=${income.bonuses.length}');
          for (var j = 0; j < income.bonuses.length; j++) {
            final bonus = income.bonuses[j];
            Logger.debug(
                '    奖金${j + 1}: ${bonus.name} - ${bonus.quarterlyPaymentMonths}');
          }
        }
      }

      _monthlyWallets =
          await _storageService.loadMonthlyWallets(); // 新增：加载每月工资钱包
      Logger.debug('✅ 每月工资钱包加载完成: ${_monthlyWallets.length} 个');

      if (_salaryIncomes.isNotEmpty) {
        Logger.debug('💼 工资收入详情:');
        for (var i = 0; i < _salaryIncomes.length; i++) {
          final income = _salaryIncomes[i];
          Logger.debug(
            '  ${i + 1}. ${income.name}: 基本工资=${income.basicSalary}, 奖金数量=${income.bonuses.length}',
          );
        }
      }
    } catch (e) {
      Logger.error('❌ 加载预算数据失败: $e');
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
      final index =
          _envelopeBudgets.indexWhere((b) => b.id == updatedBudget.id);
      if (index != -1) {
        _envelopeBudgets[index] =
            updatedBudget.copyWith(updateDate: DateTime.now());
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
      final index =
          _zeroBasedBudgets.indexWhere((b) => b.id == updatedBudget.id);
      if (index != -1) {
        _zeroBasedBudgets[index] =
            updatedBudget.copyWith(updateDate: DateTime.now());
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

  // ========== 工资收入管理 ==========

  // 添加工资收入
  Future<void> addSalaryIncome(SalaryIncome income) async {
    try {
      Logger.debug('📝 添加工资收入: ${income.name}, ID: ${income.id}');
      _salaryIncomes.add(income);
      Logger.debug('📝 工资收入列表长度: ${_salaryIncomes.length}');
      await _storageService.saveSalaryIncomes(_salaryIncomes);
      Logger.info('✅ 工资收入保存成功');
      notifyListeners();
      Logger.debug('📢 通知监听器');
    } catch (e) {
      Logger.error('❌ 添加工资收入失败: $e');
      _error = e.toString();
      notifyListeners();
    }
  }

  // 更新工资收入
  Future<void> updateSalaryIncome(SalaryIncome updatedIncome) async {
    Logger.debug('📝 更新工资收入: ${updatedIncome.name}');
    Logger.debug('📝 查找ID为: ${updatedIncome.id} 的工资收入');
    Logger.debug('📝 当前工资收入列表中的ID:');
    for (var i = 0; i < _salaryIncomes.length; i++) {
      Logger.debug('  ID ${i + 1}: ${_salaryIncomes[i].id}');
    }
    if (_salaryIncomes.isEmpty) {
      Logger.warning('⚠️ 警告: 工资收入列表为空，可能数据尚未加载完成');
    }
    Logger.debug('📝 更新的奖金数量: ${updatedIncome.bonuses.length}');
    for (var i = 0; i < updatedIncome.bonuses.length; i++) {
      final bonus = updatedIncome.bonuses[i];
      Logger.debug('  奖金${i + 1}: ${bonus.name} - ${bonus.quarterlyPaymentMonths}');
    }

    // 如果数据正在加载，等待加载完成
    if (_isLoading) {
      Logger.debug('⏳ 数据正在加载中，等待加载完成...');
      // 等待一段时间让数据加载完成
      await Future<void>.delayed(const Duration(milliseconds: 100));
      // 如果还是在加载，再等一会儿
      if (_isLoading) {
        await Future<void>.delayed(const Duration(milliseconds: 200));
      }
    }

    try {
      final index = _salaryIncomes.indexWhere((i) => i.id == updatedIncome.id);
      Logger.debug('📝 找到索引: $index');
      if (index != -1) {
        _salaryIncomes[index] =
            updatedIncome.copyWith(updateDate: DateTime.now());
        Logger.debug('📝 保存工资收入到存储...');
        await _storageService.saveSalaryIncomes(_salaryIncomes);
        Logger.info('✅ 工资收入保存成功');
        Logger.debug('📢 通知监听器');
        notifyListeners();
      } else {
        Logger.warning('❌ 未找到要更新的工资收入');
        // 如果没找到，可能是数据还没加载完成，尝试重新加载
        if (_salaryIncomes.isEmpty && !_isLoading) {
          Logger.debug('🔄 尝试重新加载工资收入数据...');
          await _loadBudgets();
          // 再次尝试查找
          final newIndex =
              _salaryIncomes.indexWhere((i) => i.id == updatedIncome.id);
          Logger.debug('📝 重新加载后找到索引: $newIndex');
          if (newIndex != -1) {
            _salaryIncomes[newIndex] =
                updatedIncome.copyWith(updateDate: DateTime.now());
            Logger.debug('📝 保存工资收入到存储...');
            await _storageService.saveSalaryIncomes(_salaryIncomes);
            Logger.info('✅ 工资收入保存成功');
            Logger.debug('📢 通知监听器');
            notifyListeners();
          } else {
            Logger.error('❌ 重新加载后仍然未找到要更新的工资收入');
          }
        }
      }
    } catch (e) {
      _error = e.toString();
      Logger.error('❌ 工资收入更新失败: $e');
      notifyListeners();
    }
  }

  // 删除工资收入
  Future<void> deleteSalaryIncome(String incomeId) async {
    try {
      _salaryIncomes.removeWhere((i) => i.id == incomeId);
      await _storageService.saveSalaryIncomes(_salaryIncomes);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
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
    Map<int, AllowanceRecord>? monthlyAllowances, // 月度津贴记录
    List<BonusItem> bonuses = const [],
    double personalIncomeTax = 0.0,
    double socialInsurance = 0.0,
    double housingFund = 0.0,
    double otherDeductions = 0.0,
    double specialDeductionMonthly = 0.0,
    double otherTaxDeductions = 0.0, // 其他税收扣除
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
      monthlyAllowances: monthlyAllowances, // 月度津贴记录
      bonuses: bonuses,
      personalIncomeTax: personalIncomeTax,
      socialInsurance: socialInsurance,
      housingFund: housingFund,
      otherDeductions: otherDeductions,
      specialDeductionMonthly: specialDeductionMonthly,
      otherTaxDeductions: otherTaxDeductions, // 其他税收扣除
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
    final index =
        _salaryIncomes.indexWhere((income) => income.id == salaryIncomeId);
    if (index != -1) {
      final updatedIncome = _salaryIncomes[index].copyWith(
        bonuses: [..._salaryIncomes[index].bonuses, bonus],
      );
      await updateSalaryIncome(updatedIncome);
    }
  }

  // 删除工资收入中的奖金项目
  Future<void> removeBonusFromSalaryIncome(
    String salaryIncomeId,
    String bonusId,
  ) async {
    final index =
        _salaryIncomes.indexWhere((income) => income.id == salaryIncomeId);
    if (index != -1) {
      final updatedBonuses = _salaryIncomes[index]
          .bonuses
          .where((bonus) => bonus.id != bonusId)
          .toList();
      final updatedIncome = _salaryIncomes[index].copyWith(
        bonuses: updatedBonuses,
      );
      await updateSalaryIncome(updatedIncome);
    }
  }

  // 更新工资收入中的奖金项目
  Future<void> updateBonusInSalaryIncome(
    String salaryIncomeId,
    BonusItem updatedBonus,
  ) async {
    final index =
        _salaryIncomes.indexWhere((income) => income.id == salaryIncomeId);
    if (index != -1) {
      final updatedBonuses = _salaryIncomes[index]
          .bonuses
          .map((bonus) => bonus.id == updatedBonus.id ? updatedBonus : bonus)
          .toList();
      final updatedIncome = _salaryIncomes[index].copyWith(
        bonuses: updatedBonuses,
      );
      await updateSalaryIncome(updatedIncome);
    }
  }

  // 获取工资收入的奖金项目列表
  List<BonusItem> getBonusesForSalaryIncome(String salaryIncomeId) {
    final income = _salaryIncomes.firstWhere(
      (income) => income.id == salaryIncomeId,
      orElse: () => throw ArgumentError('Salary income not found'),
    );
    return income.bonuses;
  }

  // 获取总月收入
  double getTotalMonthlyIncome() =>
      _salaryIncomes.fold(0.0, (sum, income) => sum + income.netIncome);

  // 获取下个月总收入
  double getNextMonthTotalIncome() {
    final now = DateTime.now();
    final nextMonth = DateTime(now.year, now.month + 1);

    return _salaryIncomes.fold(0.0, (sum, income) {
      // 如果是月薪或下个月有发薪日
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
      // 检查是否已存在该月的钱包
      final existingWallet = _monthlyWallets.firstWhere(
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
        // 已存在，直接返回
        return existingWallet;
      }

      // 生成新的钱包
      final wallet = MonthlyWallet.fromSalaryIncome(salaryIncome, year, month);
      await addMonthlyWallet(wallet);
      return wallet;
    } catch (e) {
      _error = e.toString();
      return null;
    }
  }

  // 生成指定年份的所有工资钱包
  Future<void> generateYearlyWallets(
    SalaryIncome salaryIncome,
    int year,
  ) async {
    try {
      final wallets = <MonthlyWallet>[];
      final now = DateTime.now();

      // 只生成到当前月份（包括当前月）
      final maxMonth = (year == now.year) ? now.month : 12;

      for (var month = 1; month <= maxMonth; month++) {
        // 检查是否已存在
        final existing = _monthlyWallets.firstWhere(
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
          final wallet =
              MonthlyWallet.fromSalaryIncome(salaryIncome, year, month);
          wallets.add(wallet);
        }
      }

      if (wallets.isNotEmpty) {
        _monthlyWallets.addAll(wallets);
        await _storageService.saveMonthlyWallets(_monthlyWallets);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
    }
  }

  // 添加每月工资钱包
  Future<void> addMonthlyWallet(MonthlyWallet wallet) async {
    try {
      _monthlyWallets.add(wallet);
      await _storageService.saveMonthlyWallets(_monthlyWallets);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // 更新每月工资钱包
  Future<void> updateMonthlyWallet(MonthlyWallet updatedWallet) async {
    try {
      final index = _monthlyWallets.indexWhere((w) => w.id == updatedWallet.id);
      if (index != -1) {
        _monthlyWallets[index] =
            updatedWallet.copyWith(updateDate: DateTime.now());
        await _storageService.saveMonthlyWallets(_monthlyWallets);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // 删除每月工资钱包
  Future<void> removeMonthlyWallet(String walletId) async {
    try {
      _monthlyWallets.removeWhere((w) => w.id == walletId);
      await _storageService.saveMonthlyWallets(_monthlyWallets);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // 获取指定年月的工资钱包
  MonthlyWallet? getMonthlyWallet(int year, int month) {
    try {
      return _monthlyWallets.firstWhere(
        (wallet) => wallet.year == year && wallet.month == month,
      );
    } catch (e) {
      return null;
    }
  }

  // 获取指定年份的所有工资钱包
  List<MonthlyWallet> getYearlyWallets(int year) =>
      _monthlyWallets.where((wallet) => wallet.year == year).toList()
        ..sort((a, b) => a.month.compareTo(b.month));

  // ========== 预算与交易集成 ==========

  // 处理交易对预算的影响
  Future<void> processTransaction(Transaction transaction) async {
    try {
      // 如果是支出交易且关联了信封预算
      if (transaction.type == TransactionType.expense &&
          transaction.envelopeBudgetId != null) {
        await _updateEnvelopeSpentAmount(
          transaction.envelopeBudgetId!,
          transaction.amount,
        );
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // 更新信封已花费金额
  Future<void> _updateEnvelopeSpentAmount(
    String envelopeId,
    double amount,
  ) async {
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
        await _updateEnvelopeSpentAmount(
          transaction.envelopeBudgetId!,
          -transaction.amount,
        );
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
      return _zeroBasedBudgets.firstWhere(
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
    final now = DateTime.now();
    return _envelopeBudgets
        .where(
          (b) =>
              b.status == BudgetStatus.active &&
              b.startDate.isBefore(now) &&
              b.endDate.isAfter(now),
        )
        .toList();
  }

  // 计算总预算分配金额
  double calculateTotalBudgetAllocated() => getCurrentEnvelopeBudgets()
      .fold(0.0, (sum, budget) => sum + budget.allocatedAmount);

  // 计算总预算支出
  double calculateTotalBudgetSpent() => getCurrentEnvelopeBudgets()
      .fold(0.0, (sum, budget) => sum + budget.spentAmount);

  // 计算总预算可用金额
  double calculateTotalBudgetAvailable() => getCurrentEnvelopeBudgets()
      .fold(0.0, (sum, budget) => sum + budget.availableAmount);

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
  List<EnvelopeBudget> getWarningEnvelopes() => getCurrentEnvelopeBudgets()
      .where(
        (b) => b.isWarningThresholdReached && !b.isOverBudget,
      )
      .toList();

  // ========== 预算创建和分配 ==========

  // 创建月度零基预算
  Future<ZeroBasedBudget> createMonthlyZeroBasedBudget({
    required String name,
    required double totalIncome,
    required DateTime month,
  }) async {
    final startDate = DateTime(month.year, month.month);
    final endDate =
        DateTime(month.year, month.month + 1).subtract(const Duration(days: 1));

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
      final zeroBasedIndex =
          _zeroBasedBudgets.indexWhere((b) => b.id == zeroBasedBudgetId);
      if (zeroBasedIndex != -1) {
        final currentZeroBased = _zeroBasedBudgets[zeroBasedIndex];
        final updatedZeroBased = currentZeroBased.copyWith(
          totalAllocated: currentZeroBased.totalAllocated + amount,
          updateDate: DateTime.now(),
        );
        _zeroBasedBudgets[zeroBasedIndex] = updatedZeroBased;
      }

      // 更新信封预算
      final envelopeIndex =
          _envelopeBudgets.indexWhere((b) => b.id == envelopeBudgetId);
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
  String formatPercentage(double percentage) =>
      '${percentage.toStringAsFixed(1)}%';

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
