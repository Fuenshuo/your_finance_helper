import 'package:uuid/uuid.dart';
import 'package:equatable/equatable.dart';
import 'transaction.dart';

// 预算类型枚举
enum BudgetType {
  envelope('信封预算'),
  zeroBased('零基预算'),
  category('分类预算');

  const BudgetType(this.displayName);
  final String displayName;

  static BudgetType fromDisplayName(String displayName) {
    return BudgetType.values.firstWhere(
      (e) => e.displayName == displayName,
      orElse: () => throw ArgumentError('Unknown BudgetType: $displayName'),
    );
  }
}

// 预算周期枚举
enum BudgetPeriod {
  weekly('周'),
  monthly('月'),
  quarterly('季度'),
  yearly('年');

  const BudgetPeriod(this.displayName);
  final String displayName;

  static BudgetPeriod fromDisplayName(String displayName) {
    return BudgetPeriod.values.firstWhere(
      (e) => e.displayName == displayName,
      orElse: () => throw ArgumentError('Unknown BudgetPeriod: $displayName'),
    );
  }
}

// 预算状态枚举
enum BudgetStatus {
  active('活跃'),
  paused('暂停'),
  completed('已完成'),
  cancelled('已取消');

  const BudgetStatus(this.displayName);
  final String displayName;

  static BudgetStatus fromDisplayName(String displayName) {
    return BudgetStatus.values.firstWhere(
      (e) => e.displayName == displayName,
      orElse: () => throw ArgumentError('Unknown BudgetStatus: $displayName'),
    );
  }
}

// 信封预算模型
class EnvelopeBudget extends Equatable {
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

  EnvelopeBudget({
    String? id,
    required this.name,
    this.description,
    required this.category,
    required this.allocatedAmount,
    this.spentAmount = 0.0,
    required this.period,
    required this.startDate,
    required this.endDate,
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
  }) {
    return EnvelopeBudget(
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
  }

  // 获取使用百分比
  double get usagePercentage {
    if (allocatedAmount == 0) return 0.0;
    return (spentAmount / allocatedAmount) * 100;
  }

  // 是否达到警告阈值
  bool get isWarningThresholdReached {
    return usagePercentage >= (warningThreshold ?? 80.0);
  }

  // 是否达到限制阈值
  bool get isLimitThresholdReached {
    return usagePercentage >= (limitThreshold ?? 100.0);
  }

  // 是否超支
  bool get isOverBudget {
    return spentAmount > allocatedAmount;
  }

  // 获取剩余天数
  int get remainingDays {
    final now = DateTime.now();
    if (now.isAfter(endDate)) return 0;
    return endDate.difference(now).inDays;
  }

  // 序列化
  Map<String, dynamic> toJson() {
    return {
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
  }

  // 反序列化
  factory EnvelopeBudget.fromJson(Map<String, dynamic> json) {
    return EnvelopeBudget(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      category: TransactionCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => throw ArgumentError('Unknown TransactionCategory: ${json['category']}'),
      ),
      allocatedAmount: json['allocatedAmount'] as double,
      spentAmount: json['spentAmount'] as double? ?? 0.0,
      period: BudgetPeriod.values.firstWhere(
        (e) => e.name == json['period'],
        orElse: () => throw ArgumentError('Unknown BudgetPeriod: ${json['period']}'),
      ),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      status: BudgetStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => throw ArgumentError('Unknown BudgetStatus: ${json['status']}'),
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
  }

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

  ZeroBasedBudget({
    String? id,
    required this.name,
    this.description,
    required this.totalIncome,
    this.totalAllocated = 0.0,
    this.envelopes = const [],
    required this.period,
    required this.startDate,
    required this.endDate,
    this.status = BudgetStatus.active,
    DateTime? creationDate,
    DateTime? updateDate,
  })  : id = id ?? const Uuid().v4(),
        remainingAmount = totalIncome - totalAllocated,
        creationDate = creationDate ?? DateTime.now(),
        updateDate = updateDate ?? DateTime.now();

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
  }) {
    return ZeroBasedBudget(
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
  }

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
  double get totalSpent {
    return envelopes.fold(0.0, (sum, envelope) => sum + envelope.spentAmount);
  }

  // 获取总可用金额
  double get totalAvailable {
    return envelopes.fold(0.0, (sum, envelope) => sum + envelope.availableAmount);
  }

  // 序列化
  Map<String, dynamic> toJson() {
    return {
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
  }

  // 反序列化
  factory ZeroBasedBudget.fromJson(Map<String, dynamic> json) {
    return ZeroBasedBudget(
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
        orElse: () => throw ArgumentError('Unknown BudgetPeriod: ${json['period']}'),
      ),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      status: BudgetStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => throw ArgumentError('Unknown BudgetStatus: ${json['status']}'),
      ),
      creationDate: DateTime.parse(json['creationDate'] as String),
      updateDate: DateTime.parse(json['updateDate'] as String),
    );
  }

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
