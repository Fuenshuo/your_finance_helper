import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import 'package:your_finance_flutter/models/bonus_item.dart';
import 'package:your_finance_flutter/models/transaction.dart';

// 收入类型枚举
enum IncomeType {
  salary('工资收入'),
  bonus('奖金'),
  subsidy('补贴'),
  investment('投资收益'),
  freelance('兼职收入'),
  other('其他收入');

  const IncomeType(this.displayName);
  final String displayName;

  static IncomeType fromDisplayName(String displayName) =>
      IncomeType.values.firstWhere(
        (e) => e.displayName == displayName,
        orElse: () => throw ArgumentError('Unknown IncomeType: $displayName'),
      );
}

// 预算类型枚举
enum BudgetType {
  envelope('信封预算'),
  zeroBased('零基预算'),
  category('分类预算');

  const BudgetType(this.displayName);
  final String displayName;

  static BudgetType fromDisplayName(String displayName) =>
      BudgetType.values.firstWhere(
        (e) => e.displayName == displayName,
        orElse: () => throw ArgumentError('Unknown BudgetType: $displayName'),
      );
}

// 预算周期枚举
enum BudgetPeriod {
  weekly('周'),
  monthly('月'),
  quarterly('季度'),
  yearly('年');

  const BudgetPeriod(this.displayName);
  final String displayName;

  static BudgetPeriod fromDisplayName(String displayName) =>
      BudgetPeriod.values.firstWhere(
        (e) => e.displayName == displayName,
        orElse: () => throw ArgumentError('Unknown BudgetPeriod: $displayName'),
      );
}

// 预算状态枚举
enum BudgetStatus {
  active('活跃'),
  paused('暂停'),
  completed('已完成'),
  cancelled('已取消');

  const BudgetStatus(this.displayName);
  final String displayName;

  static BudgetStatus fromDisplayName(String displayName) =>
      BudgetStatus.values.firstWhere(
        (e) => e.displayName == displayName,
        orElse: () => throw ArgumentError('Unknown BudgetStatus: $displayName'),
      );
}

// 信封预算模型
class EnvelopeBudget extends Equatable {
  EnvelopeBudget({
    required this.name,
    required this.category,
    required this.allocatedAmount,
    required this.period,
    required this.startDate,
    required this.endDate,
    String? id,
    this.description,
    this.spentAmount = 0.0,
    this.status = BudgetStatus.active,
    this.color,
    this.iconName,
    this.isEssential = false,
    this.warningThreshold = 80.0, // 默认80%警告
    this.limitThreshold = 100.0, // 默认100%限制
    this.tags = const [],
    DateTime? creationDate,
    DateTime? updateDate,
  })  : id = id ?? const Uuid().v4(),
        availableAmount = allocatedAmount - spentAmount,
        creationDate = creationDate ?? DateTime.now(),
        updateDate = updateDate ?? DateTime.now();

  // 反序列化
  factory EnvelopeBudget.fromJson(Map<String, dynamic> json) => EnvelopeBudget(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String?,
        category: TransactionCategory.values.firstWhere(
          (e) => e.name == json['category'],
          orElse: () => throw ArgumentError(
            'Unknown TransactionCategory: ${json['category']}',
          ),
        ),
        allocatedAmount: json['allocatedAmount'] as double,
        spentAmount: json['spentAmount'] as double? ?? 0.0,
        period: BudgetPeriod.values.firstWhere(
          (e) => e.name == json['period'],
          orElse: () =>
              throw ArgumentError('Unknown BudgetPeriod: ${json['period']}'),
        ),
        startDate: DateTime.parse(json['startDate'] as String),
        endDate: DateTime.parse(json['endDate'] as String),
        status: BudgetStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () =>
              throw ArgumentError('Unknown BudgetStatus: ${json['status']}'),
        ),
        color: json['color'] as String?,
        iconName: json['iconName'] as String?,
        isEssential: json['isEssential'] as bool? ?? false,
        warningThreshold: json['warningThreshold'] as double?,
        limitThreshold: json['limitThreshold'] as double?,
        tags: List<String>.from(json['tags'] ?? []),
        creationDate: DateTime.parse(json['creationDate'] as String),
        updateDate: DateTime.parse(json['updateDate'] as String),
      );
  final String id;
  final String name;
  final String? description;
  final TransactionCategory category;
  final double allocatedAmount; // 分配的金额
  final double spentAmount; // 已花费金额
  final double availableAmount; // 可用金额
  final BudgetPeriod period;
  final DateTime startDate;
  final DateTime endDate;
  final BudgetStatus status;
  final String? color; // 信封颜色
  final String? iconName; // 图标名称
  final bool isEssential; // 是否为必需支出
  final double? warningThreshold; // 警告阈值（百分比）
  final double? limitThreshold; // 限制阈值（百分比）
  final List<String> tags;
  final DateTime creationDate;
  final DateTime updateDate;

  // 复制并修改
  EnvelopeBudget copyWith({
    String? id,
    String? name,
    String? description,
    TransactionCategory? category,
    double? allocatedAmount,
    double? spentAmount,
    BudgetPeriod? period,
    DateTime? startDate,
    DateTime? endDate,
    BudgetStatus? status,
    String? color,
    String? iconName,
    bool? isEssential,
    double? warningThreshold,
    double? limitThreshold,
    List<String>? tags,
    DateTime? creationDate,
    DateTime? updateDate,
  }) =>
      EnvelopeBudget(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description ?? this.description,
        category: category ?? this.category,
        allocatedAmount: allocatedAmount ?? this.allocatedAmount,
        spentAmount: spentAmount ?? this.spentAmount,
        period: period ?? this.period,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        status: status ?? this.status,
        color: color ?? this.color,
        iconName: iconName ?? this.iconName,
        isEssential: isEssential ?? this.isEssential,
        warningThreshold: warningThreshold ?? this.warningThreshold,
        limitThreshold: limitThreshold ?? this.limitThreshold,
        tags: tags ?? this.tags,
        creationDate: creationDate ?? this.creationDate,
        updateDate: updateDate ?? DateTime.now(),
      );

  // 获取使用百分比
  double get usagePercentage {
    if (allocatedAmount == 0) return 0.0;
    return (spentAmount / allocatedAmount) * 100;
  }

  // 是否达到警告阈值
  bool get isWarningThresholdReached =>
      usagePercentage >= (warningThreshold ?? 80.0);

  // 是否达到限制阈值
  bool get isLimitThresholdReached =>
      usagePercentage >= (limitThreshold ?? 100.0);

  // 是否超支
  bool get isOverBudget => spentAmount > allocatedAmount;

  // 获取剩余天数
  int get remainingDays {
    final now = DateTime.now();
    if (now.isAfter(endDate)) return 0;
    return endDate.difference(now).inDays;
  }

  // 序列化
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'category': category.name,
        'allocatedAmount': allocatedAmount,
        'spentAmount': spentAmount,
        'period': period.name,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'status': status.name,
        'color': color,
        'iconName': iconName,
        'isEssential': isEssential,
        'warningThreshold': warningThreshold,
        'limitThreshold': limitThreshold,
        'tags': tags,
        'creationDate': creationDate.toIso8601String(),
        'updateDate': updateDate.toIso8601String(),
      };

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        category,
        allocatedAmount,
        spentAmount,
        period,
        startDate,
        endDate,
        status,
        color,
        iconName,
        isEssential,
        warningThreshold,
        limitThreshold,
        tags,
        creationDate,
        updateDate,
      ];
}

// 零基预算模型
class ZeroBasedBudget extends Equatable {
  ZeroBasedBudget({
    required this.name,
    required this.totalIncome,
    required this.period,
    required this.startDate,
    required this.endDate,
    String? id,
    this.description,
    this.totalAllocated = 0.0,
    this.envelopes = const [],
    this.status = BudgetStatus.active,
    DateTime? creationDate,
    DateTime? updateDate,
  })  : id = id ?? const Uuid().v4(),
        remainingAmount = totalIncome - totalAllocated,
        creationDate = creationDate ?? DateTime.now(),
        updateDate = updateDate ?? DateTime.now();

  // 反序列化
  factory ZeroBasedBudget.fromJson(Map<String, dynamic> json) =>
      ZeroBasedBudget(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String?,
        totalIncome: json['totalIncome'] as double,
        totalAllocated: json['totalAllocated'] as double? ?? 0.0,
        envelopes: (json['envelopes'] as List)
            .map((e) => EnvelopeBudget.fromJson(e))
            .toList(),
        period: BudgetPeriod.values.firstWhere(
          (e) => e.name == json['period'],
          orElse: () =>
              throw ArgumentError('Unknown BudgetPeriod: ${json['period']}'),
        ),
        startDate: DateTime.parse(json['startDate'] as String),
        endDate: DateTime.parse(json['endDate'] as String),
        status: BudgetStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () =>
              throw ArgumentError('Unknown BudgetStatus: ${json['status']}'),
        ),
        creationDate: DateTime.parse(json['creationDate'] as String),
        updateDate: DateTime.parse(json['updateDate'] as String),
      );
  final String id;
  final String name;
  final String? description;
  final double totalIncome; // 总收入
  final double totalAllocated; // 总分配金额
  final double remainingAmount; // 剩余未分配金额
  final List<EnvelopeBudget> envelopes; // 包含的信封
  final BudgetPeriod period;
  final DateTime startDate;
  final DateTime endDate;
  final BudgetStatus status;
  final DateTime creationDate;
  final DateTime updateDate;

  // 复制并修改
  ZeroBasedBudget copyWith({
    String? id,
    String? name,
    String? description,
    double? totalIncome,
    double? totalAllocated,
    List<EnvelopeBudget>? envelopes,
    BudgetPeriod? period,
    DateTime? startDate,
    DateTime? endDate,
    BudgetStatus? status,
    DateTime? creationDate,
    DateTime? updateDate,
  }) =>
      ZeroBasedBudget(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description ?? this.description,
        totalIncome: totalIncome ?? this.totalIncome,
        totalAllocated: totalAllocated ?? this.totalAllocated,
        envelopes: envelopes ?? this.envelopes,
        period: period ?? this.period,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        status: status ?? this.status,
        creationDate: creationDate ?? this.creationDate,
        updateDate: updateDate ?? DateTime.now(),
      );

  // 获取分配百分比
  double get allocationPercentage {
    if (totalIncome == 0) return 0.0;
    return (totalAllocated / totalIncome) * 100;
  }

  // 是否完全分配
  bool get isFullyAllocated {
    return remainingAmount <= 0.01; // 考虑浮点数精度
  }

  // 获取总支出
  double get totalSpent =>
      envelopes.fold(0.0, (sum, envelope) => sum + envelope.spentAmount);

  // 获取总可用金额
  double get totalAvailable =>
      envelopes.fold(0.0, (sum, envelope) => sum + envelope.availableAmount);

  // 序列化
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'totalIncome': totalIncome,
        'totalAllocated': totalAllocated,
        'envelopes': envelopes.map((e) => e.toJson()).toList(),
        'period': period.name,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'status': status.name,
        'creationDate': creationDate.toIso8601String(),
        'updateDate': updateDate.toIso8601String(),
      };

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        totalIncome,
        totalAllocated,
        envelopes,
        period,
        startDate,
        endDate,
        status,
        creationDate,
        updateDate,
      ];
}

// 计算总奖金金额的辅助函数
double _calculateTotalBonuses(List<BonusItem> bonuses, int year) =>
    bonuses.fold(0.0, (sum, bonus) => sum + bonus.calculateAnnualBonus(year));

// 工资收入模型
class SalaryIncome extends Equatable {
  SalaryIncome({
    required this.name,
    required this.basicSalary,
    required this.salaryDay,
    String? id,
    this.description,
    this.salaryHistory,
    this.housingAllowance = 0.0,
    this.mealAllowance = 0.0,
    this.transportationAllowance = 0.0,
    this.otherAllowance = 0.0,
    this.bonuses = const [],
    this.personalIncomeTax = 0.0,
    this.socialInsurance = 0.0,
    this.housingFund = 0.0,
    this.otherDeductions = 0.0,
    this.period = BudgetPeriod.monthly,
    this.lastSalaryDate,
    this.nextSalaryDate,
    this.incomeType = IncomeType.salary,
    DateTime? creationDate,
    DateTime? updateDate,
  })  : id = id ?? const Uuid().v4(),
        grossIncome = basicSalary +
            housingAllowance +
            mealAllowance +
            transportationAllowance +
            otherAllowance +
            _calculateTotalBonuses(bonuses, DateTime.now().year),
        totalDeductions =
            personalIncomeTax + socialInsurance + housingFund + otherDeductions,
        netIncome = (basicSalary +
                housingAllowance +
                mealAllowance +
                transportationAllowance +
                otherAllowance +
                _calculateTotalBonuses(bonuses, DateTime.now().year)) -
            (personalIncomeTax +
                socialInsurance +
                housingFund +
                otherDeductions),
        creationDate = creationDate ?? DateTime.now(),
        updateDate = updateDate ?? DateTime.now();

  // 反序列化
  factory SalaryIncome.fromJson(Map<String, dynamic> json) {
    // 处理奖金数据：支持新格式和向后兼容旧格式
    var bonuses = <BonusItem>[];
    if (json['bonuses'] != null) {
      // 新格式：直接使用 BonusItem 列表
      bonuses = (json['bonuses'] as List<dynamic>)
          .map((item) => BonusItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      // 向后兼容：从旧的奖金字段创建 BonusItem
      final now = DateTime.now();
      final currentYear = now.year;

      if ((json['yearEndBonus'] as double? ?? 0.0) > 0) {
        bonuses.add(
          BonusItem.create(
            name: '年终奖',
            type: BonusType.yearEndBonus,
            amount: json['yearEndBonus'] as double? ?? 0.0,
            frequency: BonusFrequency.oneTime,
            startDate: DateTime(currentYear, 12, 31),
          ),
        );
      }

      if ((json['performanceBonus'] as double? ?? 0.0) > 0) {
        bonuses.add(
          BonusItem.create(
            name: '绩效奖金',
            type: BonusType.performanceBonus,
            amount: json['performanceBonus'] as double? ?? 0.0,
            frequency: BonusFrequency.monthly,
            startDate: DateTime(currentYear),
          ),
        );
      }

      if ((json['otherBonuses'] as double? ?? 0.0) > 0) {
        bonuses.add(
          BonusItem.create(
            name: '其他奖金',
            type: BonusType.other,
            amount: json['otherBonuses'] as double? ?? 0.0,
            frequency: BonusFrequency.oneTime,
            startDate: DateTime(currentYear, 12, 31),
          ),
        );
      }

      if ((json['thirteenthSalary'] as double? ?? 0.0) > 0) {
        bonuses.add(
          BonusItem.create(
            name: '十三薪',
            type: BonusType.thirteenthSalary,
            amount: json['thirteenthSalary'] as double? ?? 0.0,
            frequency: BonusFrequency.oneTime,
            startDate: DateTime(currentYear, 12, 31),
          ),
        );
      }

      if ((json['quarterlyBonus'] as double? ?? 0.0) > 0) {
        bonuses.add(
          BonusItem.create(
            name: '季度奖金',
            type: BonusType.quarterlyBonus,
            amount: json['quarterlyBonus'] as double? ?? 0.0,
            frequency: BonusFrequency.quarterly,
            startDate: DateTime(currentYear),
          ),
        );
      }
    }

    // 处理工资历史
    Map<DateTime, double>? salaryHistory;
    if (json['salaryHistory'] != null) {
      final historyMap = json['salaryHistory'] as Map<String, dynamic>;
      salaryHistory = {};
      for (final entry in historyMap.entries) {
        salaryHistory[DateTime.parse(entry.key)] =
            (entry.value as num).toDouble();
      }
    }

    return SalaryIncome(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      basicSalary: json['basicSalary'] as double,
      salaryHistory: salaryHistory,
      housingAllowance: json['housingAllowance'] as double? ?? 0.0,
      mealAllowance: json['mealAllowance'] as double? ?? 0.0,
      transportationAllowance:
          json['transportationAllowance'] as double? ?? 0.0,
      otherAllowance: json['otherAllowance'] as double? ?? 0.0,
      bonuses: bonuses,
      personalIncomeTax: json['personalIncomeTax'] as double? ?? 0.0,
      socialInsurance: json['socialInsurance'] as double? ?? 0.0,
      housingFund: json['housingFund'] as double? ?? 0.0,
      otherDeductions: json['otherDeductions'] as double? ?? 0.0,
      salaryDay: json['salaryDay'] as int,
      period: BudgetPeriod.values.firstWhere(
        (e) => e.name == json['period'],
        orElse: () => BudgetPeriod.monthly,
      ),
      lastSalaryDate: json['lastSalaryDate'] != null
          ? DateTime.parse(json['lastSalaryDate'] as String)
          : null,
      nextSalaryDate: json['nextSalaryDate'] != null
          ? DateTime.parse(json['nextSalaryDate'] as String)
          : null,
      incomeType: IncomeType.values.firstWhere(
        (e) => e.name == json['incomeType'],
        orElse: () => IncomeType.salary,
      ),
      creationDate: DateTime.parse(json['creationDate'] as String),
      updateDate: DateTime.parse(json['updateDate'] as String),
    );
  }
  final String id;
  final String name; // 收入名称，如"主职工资"
  final String? description;

  // 工资构成（支持历史变化）
  final double basicSalary; // 基本工资
  final Map<DateTime, double>? salaryHistory; // 工资历史记录 {生效日期: 工资金额}
  final double housingAllowance; // 住房补贴
  final double mealAllowance; // 餐补
  final double transportationAllowance; // 交通补贴
  final double otherAllowance; // 其他补贴

  // 奖金和福利
  final List<BonusItem> bonuses; // 奖金项目列表

  // 扣除项
  final double personalIncomeTax; // 个税
  final double socialInsurance; // 社保（五险）
  final double housingFund; // 公积金
  final double otherDeductions; // 其他扣除

  // 计算字段
  final double grossIncome; // 税前收入
  final double netIncome; // 税后收入（实际到手）
  final double totalDeductions; // 总扣除额

  // 时间信息
  final int salaryDay; // 发工资日期（每月几号）
  final BudgetPeriod period; // 发放周期
  final DateTime? lastSalaryDate; // 上次发工资日期
  final DateTime? nextSalaryDate; // 下次发工资日期

  final IncomeType incomeType;
  final DateTime creationDate;
  final DateTime updateDate;

  // 复制并修改
  SalaryIncome copyWith({
    String? id,
    String? name,
    String? description,
    double? basicSalary,
    Map<DateTime, double>? salaryHistory,
    double? housingAllowance,
    double? mealAllowance,
    double? transportationAllowance,
    double? otherAllowance,
    List<BonusItem>? bonuses,
    double? personalIncomeTax,
    double? socialInsurance,
    double? housingFund,
    double? otherDeductions,
    int? salaryDay,
    BudgetPeriod? period,
    DateTime? lastSalaryDate,
    DateTime? nextSalaryDate,
    IncomeType? incomeType,
    DateTime? creationDate,
    DateTime? updateDate,
  }) =>
      SalaryIncome(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description ?? this.description,
        basicSalary: basicSalary ?? this.basicSalary,
        salaryHistory: salaryHistory ?? this.salaryHistory,
        housingAllowance: housingAllowance ?? this.housingAllowance,
        mealAllowance: mealAllowance ?? this.mealAllowance,
        transportationAllowance:
            transportationAllowance ?? this.transportationAllowance,
        otherAllowance: otherAllowance ?? this.otherAllowance,
        bonuses: bonuses ?? this.bonuses,
        personalIncomeTax: personalIncomeTax ?? this.personalIncomeTax,
        socialInsurance: socialInsurance ?? this.socialInsurance,
        housingFund: housingFund ?? this.housingFund,
        otherDeductions: otherDeductions ?? this.otherDeductions,
        salaryDay: salaryDay ?? this.salaryDay,
        period: period ?? this.period,
        lastSalaryDate: lastSalaryDate ?? this.lastSalaryDate,
        nextSalaryDate: nextSalaryDate ?? this.nextSalaryDate,
        incomeType: incomeType ?? this.incomeType,
        creationDate: creationDate ?? this.creationDate,
        updateDate: updateDate ?? DateTime.now(),
      );

  // 获取下次发工资日期
  DateTime getNextSalaryDate() {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month, salaryDay);

    if (currentMonth.isAfter(now)) {
      return currentMonth;
    } else {
      return DateTime(now.year, now.month + 1, salaryDay);
    }
  }

  // 获取指定时间的工资（考虑历史变化）
  double getSalaryAtDate(DateTime date) {
    if (salaryHistory == null || salaryHistory!.isEmpty) {
      return basicSalary;
    }

    // 找到该日期之前最后一次工资变化
    final sortedEntries = salaryHistory!.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    for (var i = sortedEntries.length - 1; i >= 0; i--) {
      if (sortedEntries[i].key.isBefore(date) ||
          sortedEntries[i].key.isAtSameMomentAs(date)) {
        return sortedEntries[i].value;
      }
    }

    // 如果没有找到历史记录，返回当前基本工资
    return basicSalary;
  }

  // 添加工资变化记录
  SalaryIncome addSalaryChange(DateTime effectiveDate, double newSalary) {
    final updatedHistory = Map<DateTime, double>.from(salaryHistory ?? {});
    updatedHistory[effectiveDate] = newSalary;

    return copyWith(salaryHistory: updatedHistory);
  }

  // 获取工资变化历史（按时间排序）
  List<MapEntry<DateTime, double>> get salaryChangeHistory {
    if (salaryHistory == null) return [];
    return salaryHistory!.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
  }

  // 获取距下次发工资的天数
  int get daysUntilNextSalary {
    final nextDate = getNextSalaryDate();
    return nextDate.difference(DateTime.now()).inDays;
  }

  // 序列化
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'basicSalary': basicSalary,
        'salaryHistory': salaryHistory?.map(
          (key, value) => MapEntry(key.toIso8601String(), value),
        ),
        'housingAllowance': housingAllowance,
        'mealAllowance': mealAllowance,
        'transportationAllowance': transportationAllowance,
        'otherAllowance': otherAllowance,
        'bonuses': bonuses.map((bonus) => bonus.toJson()).toList(),
        'personalIncomeTax': personalIncomeTax,
        'socialInsurance': socialInsurance,
        'housingFund': housingFund,
        'otherDeductions': otherDeductions,
        'grossIncome': grossIncome,
        'netIncome': netIncome,
        'totalDeductions': totalDeductions,
        'salaryDay': salaryDay,
        'period': period.name,
        'lastSalaryDate': lastSalaryDate?.toIso8601String(),
        'nextSalaryDate': nextSalaryDate?.toIso8601String(),
        'incomeType': incomeType.name,
        'creationDate': creationDate.toIso8601String(),
        'updateDate': updateDate.toIso8601String(),
      };

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        basicSalary,
        salaryHistory,
        housingAllowance,
        mealAllowance,
        transportationAllowance,
        otherAllowance,
        bonuses,
        personalIncomeTax,
        socialInsurance,
        housingFund,
        otherDeductions,
        grossIncome,
        netIncome,
        totalDeductions,
        salaryDay,
        period,
        lastSalaryDate,
        nextSalaryDate,
        incomeType,
        creationDate,
        updateDate,
      ];
}
