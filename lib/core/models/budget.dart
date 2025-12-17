import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import 'package:your_finance_flutter/core/models/bonus_item.dart';
import 'package:your_finance_flutter/core/models/transaction.dart';

// 收入类型枚举
enum IncomeType {
  /// 工资收入
  salary('工资收入'),

  /// 奖金收入
  bonus('奖金'),

  /// 补贴收入
  subsidy('补贴'),

  /// 投资收益
  investment('投资收益'),

  /// 兼职收入
  freelance('兼职收入'),

  /// 其他收入
  other('其他收入');

  /// 构造函数
  const IncomeType(this.displayName);

  /// 显示名称
  final String displayName;

  /// 根据显示名称创建收入类型枚举
  static IncomeType fromDisplayName(String displayName) =>
      IncomeType.values.firstWhere(
        (e) => e.displayName == displayName,
        orElse: () => throw ArgumentError('Unknown IncomeType: $displayName'),
      );
}

// 预算类型枚举
enum BudgetType {
  /// 信封预算 - 预先分配固定金额到不同类别
  envelope('信封预算'),

  /// 零基预算 - 每次预算周期重新分配
  zeroBased('零基预算'),

  /// 分类预算 - 按交易分类设置预算限额
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

  /// 从JSON格式反序列化
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
        warningThreshold:
            (json['warningThreshold'] as num?)?.toDouble() ?? 80.0,
        limitThreshold: (json['limitThreshold'] as num?)?.toDouble() ?? 100.0,
        tags: List<String>.from((json['tags'] as List<dynamic>?) ?? []),
        creationDate: DateTime.parse(json['creationDate'] as String),
        updateDate: DateTime.parse(json['updateDate'] as String),
      );

  /// 预算ID
  final String id;

  /// 预算名称
  final String name;

  /// 预算分类
  final TransactionCategory category;

  /// 分配金额
  final double allocatedAmount;

  /// 预算周期
  final BudgetPeriod period;

  /// 开始日期
  final DateTime startDate;

  /// 结束日期
  final DateTime endDate;

  /// 预算描述
  final String? description;

  /// 已支出金额
  final double spentAmount;

  /// 可用金额（计算属性）
  final double availableAmount;

  /// 预算状态
  final BudgetStatus status;

  /// 预算颜色
  final String? color;

  /// 图标名称
  final String? iconName;

  /// 是否为必需支出
  final bool isEssential;

  /// 警告阈值百分比
  final double warningThreshold;

  /// 限制阈值百分比
  final double limitThreshold;

  /// 预算标签
  final List<String> tags;

  /// 创建日期
  final DateTime creationDate;

  /// 更新日期
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
  bool get isWarningThresholdReached => usagePercentage >= warningThreshold;

  // 是否达到限制阈值
  bool get isLimitThresholdReached => usagePercentage >= limitThreshold;

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
        envelopes: (json['envelopes'] as List<dynamic>? ?? [])
            .map((e) => EnvelopeBudget.fromJson(e as Map<String, dynamic>))
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

// 津贴记录模型
class AllowanceRecord extends Equatable {
  const AllowanceRecord({
    required this.housingAllowance,
    required this.mealAllowance,
    required this.transportationAllowance,
    required this.otherAllowance,
  });

  /// 创建默认津贴记录
  factory AllowanceRecord.defaultAllowance({
    double housingAllowance = 0.0,
    double mealAllowance = 0.0,
    double transportationAllowance = 0.0,
    double otherAllowance = 0.0,
  }) =>
      AllowanceRecord(
        housingAllowance: housingAllowance,
        mealAllowance: mealAllowance,
        transportationAllowance: transportationAllowance,
        otherAllowance: otherAllowance,
      );

  /// 从JSON创建实例
  factory AllowanceRecord.fromJson(Map<String, dynamic> json) =>
      AllowanceRecord(
        housingAllowance: json['housingAllowance'] as double,
        mealAllowance: json['mealAllowance'] as double,
        transportationAllowance: json['transportationAllowance'] as double,
        otherAllowance: json['otherAllowance'] as double,
      );

  final double housingAllowance;
  final double mealAllowance;
  final double transportationAllowance;
  final double otherAllowance;

  /// 转换为JSON
  Map<String, dynamic> toJson() => {
        'housingAllowance': housingAllowance,
        'mealAllowance': mealAllowance,
        'transportationAllowance': transportationAllowance,
        'otherAllowance': otherAllowance,
      };

  /// 计算总津贴金额
  double get totalAllowance =>
      housingAllowance +
      mealAllowance +
      transportationAllowance +
      otherAllowance;

  @override
  List<Object?> get props => [
        housingAllowance,
        mealAllowance,
        transportationAllowance,
        otherAllowance,
      ];
}

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
    this.monthlyAllowances, // 月度津贴记录
    this.bonuses = const [],
    this.personalIncomeTax = 0.0,
    this.socialInsurance = 0.0,
    this.housingFund = 0.0,
    this.otherDeductions = 0.0,
    this.specialDeductionMonthly = 0.0,
    this.otherTaxDeductions = 0.0, // 其他税收扣除
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
            otherAllowance,
        totalDeductions = personalIncomeTax +
            socialInsurance +
            housingFund +
            otherDeductions +
            specialDeductionMonthly +
            otherTaxDeductions, // 添加其他税收扣除
        netIncome = (basicSalary +
                housingAllowance +
                mealAllowance +
                transportationAllowance +
                otherAllowance) -
            (personalIncomeTax +
                socialInsurance +
                housingFund +
                otherDeductions +
                specialDeductionMonthly +
                otherTaxDeductions), // 包含专项附加扣除
        creationDate = creationDate ?? DateTime.now(),
        updateDate = updateDate ?? DateTime.now();

  // 反序列化
  factory SalaryIncome.fromJson(Map<String, dynamic> json) {
    // 处理奖金数据：支持新格式和向后兼容旧格式
    var bonuses = <BonusItem>[];
    if (json['bonuses'] != null) {
      // 新格式：直接使用 BonusItem 列表
      try {
        bonuses = (json['bonuses'] as List<dynamic>)
            .map((item) {
              try {
                final bonus = BonusItem.fromJson(item as Map<String, dynamic>);
                return bonus;
              } catch (e) {
                return null;
              }
            })
            .where((item) => item != null)
            .cast<BonusItem>()
            .toList();
      } catch (e) {
        bonuses = [];
      }
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
            paymentCount: 1, // 年终奖一次性发放
            startDate: DateTime(currentYear, 12, 31),
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
            paymentCount: 1, // 其他奖金一次性发放
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
            paymentCount: 1, // 十三薪一次性发放
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
            paymentCount:
                json['quarterlyBonusPaymentCount'] as int? ?? 4, // 从配置中读取发放次数
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

    // 处理月度津贴记录
    Map<int, AllowanceRecord>? monthlyAllowances;
    if (json['monthlyAllowances'] != null) {
      final allowancesMap = json['monthlyAllowances'] as Map<String, dynamic>;
      monthlyAllowances = {};
      for (final entry in allowancesMap.entries) {
        final month = int.parse(entry.key);
        final allowanceRecord = AllowanceRecord.fromJson(
          entry.value as Map<String, dynamic>,
        );
        monthlyAllowances[month] = allowanceRecord;
      }
    }

    // 重新计算netIncome而不是从JSON读取，以修复旧数据的计算错误
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
      monthlyAllowances: monthlyAllowances, // 月度津贴记录
      bonuses: bonuses,
      personalIncomeTax: json['personalIncomeTax'] as double? ?? 0.0,
      socialInsurance: json['socialInsurance'] as double? ?? 0.0,
      housingFund: json['housingFund'] as double? ?? 0.0,
      otherDeductions: json['otherDeductions'] as double? ?? 0.0,
      specialDeductionMonthly:
          json['specialDeductionMonthly'] as double? ?? 0.0,
      otherTaxDeductions:
          json['otherTaxDeductions'] as double? ?? 0.0, // 其他税收扣除
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
      // 不传递netIncome，让构造函数重新计算以修复旧数据错误
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
  final Map<int, AllowanceRecord>? monthlyAllowances; // 月度津贴记录 {月份: 津贴记录}

  // 奖金和福利
  final List<BonusItem> bonuses; // 奖金项目列表

  // 扣除项
  final double personalIncomeTax; // 个税
  final double socialInsurance; // 社保（五险）
  final double housingFund; // 公积金
  final double otherDeductions; // 其他扣除
  final double specialDeductionMonthly; // 专项附加扣除
  final double otherTaxDeductions; // 其他税收扣除

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
    Map<int, AllowanceRecord>? monthlyAllowances, // 月度津贴记录
    List<BonusItem>? bonuses,
    double? personalIncomeTax,
    double? socialInsurance,
    double? housingFund,
    double? otherDeductions,
    double? specialDeductionMonthly,
    double? otherTaxDeductions, // 其他税收扣除
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
        monthlyAllowances:
            monthlyAllowances ?? this.monthlyAllowances, // 月度津贴记录
        bonuses: bonuses ?? this.bonuses,
        personalIncomeTax: personalIncomeTax ?? this.personalIncomeTax,
        socialInsurance: socialInsurance ?? this.socialInsurance,
        housingFund: housingFund ?? this.housingFund,
        otherDeductions: otherDeductions ?? this.otherDeductions,
        specialDeductionMonthly:
            specialDeductionMonthly ?? this.specialDeductionMonthly,
        otherTaxDeductions:
            otherTaxDeductions ?? this.otherTaxDeductions, // 其他税收扣除
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
        'monthlyAllowances': monthlyAllowances?.map(
          (key, value) => MapEntry(key.toString(), value.toJson()),
        ), // 月度津贴记录
        'bonuses': bonuses.map((bonus) => bonus.toJson()).toList(),
        'personalIncomeTax': personalIncomeTax,
        'socialInsurance': socialInsurance,
        'housingFund': housingFund,
        'otherDeductions': otherDeductions,
        'specialDeductionMonthly': specialDeductionMonthly,
        'otherTaxDeductions': otherTaxDeductions, // 其他税收扣除
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

/// 每月工资钱包模型
class MonthlyWallet extends Equatable {
  MonthlyWallet({
    required this.id,
    required this.year,
    required this.month,
    required this.basicSalary,
    required this.housingAllowance,
    required this.mealAllowance,
    required this.transportationAllowance,
    required this.otherAllowance,
    required this.bonuses,
    required this.socialInsurance,
    required this.housingFund,
    required this.otherDeductions,
    required this.specialDeductionMonthly,
    required this.calculatedTax,
    required this.netIncome,
    required this.isPaid,
    this.description,
    this.adjustmentReason,
    DateTime? creationDate,
    DateTime? updateDate,
  })  : creationDate = creationDate ?? DateTime.now(),
        updateDate = updateDate ?? DateTime.now();

  /// 工厂方法：从SalaryIncome和指定年月创建
  factory MonthlyWallet.fromSalaryIncome(
    SalaryIncome salaryIncome,
    int year,
    int month,
  ) {
    // 计算当月的奖金
    final monthlyBonuses = <BonusItem>[];
    for (final bonus in salaryIncome.bonuses) {
      final monthlyAmount = bonus.calculateMonthlyBonus(year, month);
      if (monthlyAmount > 0) {
        monthlyBonuses.add(bonus.copyWith(amount: monthlyAmount));
      }
    }

    // 计算当月税费（这里简化计算，实际应该调用税费计算服务）
    final grossIncome = salaryIncome.basicSalary +
        salaryIncome.housingAllowance +
        salaryIncome.mealAllowance +
        salaryIncome.transportationAllowance +
        salaryIncome.otherAllowance +
        monthlyBonuses.fold(0.0, (sum, bonus) => sum + bonus.amount);

    final deductions = salaryIncome.socialInsurance +
        salaryIncome.housingFund +
        salaryIncome.otherDeductions +
        salaryIncome.specialDeductionMonthly;

    // 简化的税费计算（实际应该使用PersonalIncomeTaxService）
    final taxableIncome = grossIncome - deductions - 5000; // 减去起征点
    final taxRate = taxableIncome <= 0
        ? 0.0
        : taxableIncome <= 36000
            ? 0.03
            : taxableIncome <= 144000
                ? 0.1
                : taxableIncome <= 300000
                    ? 0.2
                    : 0.25;

    final taxDeduction = taxableIncome <= 0
        ? 0.0
        : taxableIncome <= 36000
            ? 0
            : taxableIncome <= 144000
                ? 2520
                : taxableIncome <= 300000
                    ? 16920
                    : 31920;

    final calculatedTax =
        taxableIncome <= 0 ? 0.0 : (taxableIncome * taxRate - taxDeduction);

    final netIncome = grossIncome - deductions - calculatedTax;

    return MonthlyWallet(
      id: const Uuid().v4(),
      year: year,
      month: month,
      basicSalary: salaryIncome.basicSalary,
      housingAllowance: salaryIncome.housingAllowance,
      mealAllowance: salaryIncome.mealAllowance,
      transportationAllowance: salaryIncome.transportationAllowance,
      otherAllowance: salaryIncome.otherAllowance,
      bonuses: monthlyBonuses,
      socialInsurance: salaryIncome.socialInsurance,
      housingFund: salaryIncome.housingFund,
      otherDeductions: salaryIncome.otherDeductions,
      specialDeductionMonthly: salaryIncome.specialDeductionMonthly,
      calculatedTax: calculatedTax,
      netIncome: netIncome,
      isPaid: false,
    );
  }

  /// 从JSON创建实例
  factory MonthlyWallet.fromJson(Map<String, dynamic> json) => MonthlyWallet(
        id: json['id'] as String,
        year: (json['year'] as num).toInt(),
        month: (json['month'] as num).toInt(),
        basicSalary: (json['basicSalary'] as num).toDouble(),
        housingAllowance: (json['housingAllowance'] as num).toDouble(),
        mealAllowance: (json['mealAllowance'] as num).toDouble(),
        transportationAllowance:
            (json['transportationAllowance'] as num).toDouble(),
        otherAllowance: (json['otherAllowance'] as num).toDouble(),
        bonuses: (json['bonuses'] as List<dynamic>)
            .map((item) => BonusItem.fromJson(item as Map<String, dynamic>))
            .toList(),
        socialInsurance: (json['socialInsurance'] as num).toDouble(),
        housingFund: (json['housingFund'] as num).toDouble(),
        otherDeductions: (json['otherDeductions'] as num).toDouble(),
        specialDeductionMonthly:
            (json['specialDeductionMonthly'] as num).toDouble(),
        calculatedTax: (json['calculatedTax'] as num).toDouble(),
        netIncome: (json['netIncome'] as num).toDouble(),
        isPaid: json['isPaid'] as bool,
        description: json['description'] as String?,
        adjustmentReason: json['adjustmentReason'] as String?,
        creationDate: DateTime.parse(json['creationDate'] as String),
        updateDate: DateTime.parse(json['updateDate'] as String),
      );

  /// 唯一标识
  final String id;

  /// 年份
  final int year;

  /// 月份
  final int month;

  /// 基本工资
  final double basicSalary;

  /// 住房补贴
  final double housingAllowance;

  /// 餐费补贴
  final double mealAllowance;

  /// 交通补贴
  final double transportationAllowance;

  /// 其他补贴
  final double otherAllowance;

  /// 当月奖金列表
  final List<BonusItem> bonuses;

  /// 五险
  final double socialInsurance;

  /// 一金
  final double housingFund;

  /// 其他扣除
  final double otherDeductions;

  /// 专项附加扣除
  final double specialDeductionMonthly;

  /// 计算出的税费
  final double calculatedTax;

  /// 到手工资（税后）
  final double netIncome;

  /// 是否已发放
  final bool isPaid;

  /// 描述
  final String? description;

  /// 调整原因
  final String? adjustmentReason;

  /// 创建时间
  final DateTime creationDate;

  /// 更新时间
  final DateTime updateDate;

  /// 总收入（不含奖金）
  double get totalIncome =>
      basicSalary +
      housingAllowance +
      mealAllowance +
      transportationAllowance +
      otherAllowance;

  /// 奖金总计
  double get totalBonuses =>
      bonuses.fold(0.0, (sum, bonus) => sum + bonus.amount);

  /// 总扣除
  double get totalDeductions =>
      socialInsurance +
      housingFund +
      otherDeductions +
      specialDeductionMonthly +
      calculatedTax;

  /// 税前总收入
  double get grossIncome => totalIncome + totalBonuses;

  /// 创建副本
  MonthlyWallet copyWith({
    String? id,
    int? year,
    int? month,
    double? basicSalary,
    double? housingAllowance,
    double? mealAllowance,
    double? transportationAllowance,
    double? otherAllowance,
    List<BonusItem>? bonuses,
    double? socialInsurance,
    double? housingFund,
    double? otherDeductions,
    double? specialDeductionMonthly,
    double? calculatedTax,
    double? netIncome,
    bool? isPaid,
    String? description,
    String? adjustmentReason,
    DateTime? creationDate,
    DateTime? updateDate,
  }) =>
      MonthlyWallet(
        id: id ?? this.id,
        year: year ?? this.year,
        month: month ?? this.month,
        basicSalary: basicSalary ?? this.basicSalary,
        housingAllowance: housingAllowance ?? this.housingAllowance,
        mealAllowance: mealAllowance ?? this.mealAllowance,
        transportationAllowance:
            transportationAllowance ?? this.transportationAllowance,
        otherAllowance: otherAllowance ?? this.otherAllowance,
        bonuses: bonuses ?? this.bonuses,
        socialInsurance: socialInsurance ?? this.socialInsurance,
        housingFund: housingFund ?? this.housingFund,
        otherDeductions: otherDeductions ?? this.otherDeductions,
        specialDeductionMonthly:
            specialDeductionMonthly ?? this.specialDeductionMonthly,
        calculatedTax: calculatedTax ?? this.calculatedTax,
        netIncome: netIncome ?? this.netIncome,
        isPaid: isPaid ?? this.isPaid,
        description: description ?? this.description,
        adjustmentReason: adjustmentReason ?? this.adjustmentReason,
        creationDate: creationDate ?? this.creationDate,
        updateDate: updateDate ?? DateTime.now(),
      );

  /// 转换为JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'year': year,
        'month': month,
        'basicSalary': basicSalary,
        'housingAllowance': housingAllowance,
        'mealAllowance': mealAllowance,
        'transportationAllowance': transportationAllowance,
        'otherAllowance': otherAllowance,
        'bonuses': bonuses.map((b) => b.toJson()).toList(),
        'socialInsurance': socialInsurance,
        'housingFund': housingFund,
        'otherDeductions': otherDeductions,
        'specialDeductionMonthly': specialDeductionMonthly,
        'calculatedTax': calculatedTax,
        'netIncome': netIncome,
        'isPaid': isPaid,
        'description': description,
        'adjustmentReason': adjustmentReason,
        'creationDate': creationDate.toIso8601String(),
        'updateDate': updateDate.toIso8601String(),
      };

  @override
  List<Object?> get props => [
        id,
        year,
        month,
        basicSalary,
        housingAllowance,
        mealAllowance,
        transportationAllowance,
        otherAllowance,
        bonuses,
        socialInsurance,
        housingFund,
        otherDeductions,
        specialDeductionMonthly,
        calculatedTax,
        netIncome,
        isPaid,
        description,
        adjustmentReason,
        creationDate,
        updateDate,
      ];
}
