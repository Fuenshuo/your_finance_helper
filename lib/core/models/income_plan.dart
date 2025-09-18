import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

/// 收入频率枚举
enum IncomeFrequency {
  oneTime('一次性'),
  daily('每日'),
  weekly('每周'),
  monthly('每月'),
  quarterly('每季度'),
  yearly('每年');

  const IncomeFrequency(this.displayName);
  final String displayName;

  static IncomeFrequency fromDisplayName(String displayName) =>
      IncomeFrequency.values.firstWhere(
        (e) => e.displayName == displayName,
        orElse: () => IncomeFrequency.monthly,
      );
}

/// 收入计划模型
class IncomePlan extends Equatable {
  const IncomePlan({
    required this.id,
    required this.name,
    required this.amount,
    required this.frequency,
    required this.walletId,
    required this.startDate,
    this.description,
    this.endDate,
    this.isActive = true,
    this.category = '工资收入',
    this.tags = const [],
    required this.creationDate,
    required this.updateDate,
    this.lastExecutionDate,
    this.nextExecutionDate,
    this.totalExecuted = 0.0,
    this.executionCount = 0,
    this.salaryIncomeId, // 关联的工资收入ID（如果是详细工资类型）
  });

  final String id;
  final String name;
  final double amount;
  final IncomeFrequency frequency;
  final String walletId; // 关联的钱包ID
  final DateTime startDate;
  final String? description;
  final DateTime? endDate;
  final bool isActive;
  final String category;
  final List<String> tags;
  final DateTime creationDate;
  final DateTime updateDate;
  final DateTime? lastExecutionDate;
  final DateTime? nextExecutionDate;
  final double totalExecuted;
  final int executionCount;
  final String? salaryIncomeId; // 如果是从工资设置创建的，关联工资收入ID

  factory IncomePlan.fromJson(Map<String, dynamic> json) => IncomePlan(
        id: json['id'] as String,
        name: json['name'] as String,
        amount: (json['amount'] as num).toDouble(),
        frequency: IncomeFrequency.values.firstWhere(
          (e) => e.name == json['frequency'],
          orElse: () => IncomeFrequency.monthly,
        ),
        walletId: json['walletId'] as String,
        startDate: DateTime.parse(json['startDate'] as String),
        description: json['description'] as String?,
        endDate: json['endDate'] != null
            ? DateTime.parse(json['endDate'] as String)
            : null,
        isActive: json['isActive'] as bool? ?? true,
        category: json['category'] as String? ?? '工资收入',
        tags: List<String>.from(json['tags'] as List<dynamic>? ?? []),
        creationDate: DateTime.parse(json['creationDate'] as String),
        updateDate: DateTime.parse(json['updateDate'] as String),
        lastExecutionDate: json['lastExecutionDate'] != null
            ? DateTime.parse(json['lastExecutionDate'] as String)
            : null,
        nextExecutionDate: json['nextExecutionDate'] != null
            ? DateTime.parse(json['nextExecutionDate'] as String)
            : null,
        totalExecuted: (json['totalExecuted'] as num?)?.toDouble() ?? 0.0,
        executionCount: json['executionCount'] as int? ?? 0,
        salaryIncomeId: json['salaryIncomeId'] as String?,
      );

  /// 创建新的收入计划
  factory IncomePlan.create({
    required String name,
    required double amount,
    required IncomeFrequency frequency,
    required String walletId,
    required DateTime startDate,
    String? description,
    DateTime? endDate,
    String? category,
    List<String>? tags,
    String? salaryIncomeId,
  }) {
    const uuid = Uuid();
    final now = DateTime.now();

    return IncomePlan(
      id: uuid.v4(),
      name: name,
      amount: amount,
      frequency: frequency,
      walletId: walletId,
      startDate: startDate,
      description: description,
      endDate: endDate,
      category: category ?? '工资收入', // 提供默认值
      tags: tags ?? const [], // 提供默认值
      creationDate: now,
      updateDate: now,
      salaryIncomeId: salaryIncomeId,
    );
  }

  IncomePlan copyWith({
    String? id,
    String? name,
    double? amount,
    IncomeFrequency? frequency,
    String? walletId,
    DateTime? startDate,
    String? description,
    DateTime? endDate,
    bool? isActive,
    String? category,
    List<String>? tags,
    DateTime? creationDate,
    DateTime? updateDate,
    DateTime? lastExecutionDate,
    DateTime? nextExecutionDate,
    double? totalExecuted,
    int? executionCount,
    String? salaryIncomeId,
  }) =>
      IncomePlan(
        id: id ?? this.id,
        name: name ?? this.name,
        amount: amount ?? this.amount,
        frequency: frequency ?? this.frequency,
        walletId: walletId ?? this.walletId,
        startDate: startDate ?? this.startDate,
        description: description ?? this.description,
        endDate: endDate ?? this.endDate,
        isActive: isActive ?? this.isActive,
        category: category ?? this.category,
        tags: tags ?? this.tags,
        creationDate: creationDate ?? this.creationDate,
        updateDate: updateDate ?? DateTime.now(),
        lastExecutionDate: lastExecutionDate ?? this.lastExecutionDate,
        nextExecutionDate: nextExecutionDate ?? this.nextExecutionDate,
        totalExecuted: totalExecuted ?? this.totalExecuted,
        executionCount: executionCount ?? this.executionCount,
        salaryIncomeId: salaryIncomeId ?? this.salaryIncomeId,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'amount': amount,
        'frequency': frequency.name,
        'walletId': walletId,
        'startDate': startDate.toIso8601String(),
        'description': description,
        'endDate': endDate?.toIso8601String(),
        'isActive': isActive,
        'category': category,
        'tags': tags,
        'creationDate': creationDate.toIso8601String(),
        'updateDate': updateDate.toIso8601String(),
        'lastExecutionDate': lastExecutionDate?.toIso8601String(),
        'nextExecutionDate': nextExecutionDate?.toIso8601String(),
        'totalExecuted': totalExecuted,
        'executionCount': executionCount,
        'salaryIncomeId': salaryIncomeId,
      };

  /// 计算下次执行日期
  DateTime? getNextExecutionDate() {
    if (!isActive) return null;

    final now = DateTime.now();
    var nextDate = startDate;

    switch (frequency) {
      case IncomeFrequency.oneTime:
        return startDate.isAfter(now) ? startDate : null;
      case IncomeFrequency.daily:
        while (nextDate.isBefore(now) || nextDate.isAtSameMomentAs(now)) {
          nextDate = nextDate.add(const Duration(days: 1));
        }
        break;
      case IncomeFrequency.weekly:
        while (nextDate.isBefore(now) || nextDate.isAtSameMomentAs(now)) {
          nextDate = nextDate.add(const Duration(days: 7));
        }
        break;
      case IncomeFrequency.monthly:
        while (nextDate.isBefore(now) || nextDate.isAtSameMomentAs(now)) {
          nextDate = DateTime(
            nextDate.year,
            nextDate.month + 1,
            nextDate.day,
          );
        }
        break;
      case IncomeFrequency.quarterly:
        while (nextDate.isBefore(now) || nextDate.isAtSameMomentAs(now)) {
          nextDate = DateTime(
            nextDate.year,
            nextDate.month + 3,
            nextDate.day,
          );
        }
        break;
      case IncomeFrequency.yearly:
        while (nextDate.isBefore(now) || nextDate.isAtSameMomentAs(now)) {
          nextDate = DateTime(
            nextDate.year + 1,
            nextDate.month,
            nextDate.day,
          );
        }
        break;
    }

    return nextDate;
  }

  /// 判断是否应该在指定日期执行
  bool shouldExecuteOn(DateTime date) {
    if (!isActive) return false;

    final nextExecution = getNextExecutionDate();
    if (nextExecution == null) return false;

    return nextExecution.year == date.year &&
        nextExecution.month == date.month &&
        nextExecution.day == date.day;
  }

  /// 是否为详细工资类型的收入计划
  bool get isDetailedSalary => salaryIncomeId != null;

  @override
  List<Object?> get props => [
        id,
        name,
        amount,
        frequency,
        walletId,
        startDate,
        description,
        endDate,
        isActive,
        category,
        tags,
        creationDate,
        updateDate,
        lastExecutionDate,
        nextExecutionDate,
        totalExecuted,
        executionCount,
        salaryIncomeId,
      ];
}

/// 收入计划执行记录
class IncomePlanExecution extends Equatable {
  const IncomePlanExecution({
    required this.id,
    required this.planId,
    required this.executionDate,
    required this.amount,
    this.description,
    required this.creationDate,
  });

  final String id;
  final String planId;
  final DateTime executionDate;
  final double amount;
  final String? description;
  final DateTime creationDate;

  factory IncomePlanExecution.fromJson(Map<String, dynamic> json) =>
      IncomePlanExecution(
        id: json['id'] as String,
        planId: json['planId'] as String,
        executionDate: DateTime.parse(json['executionDate'] as String),
        amount: (json['amount'] as num).toDouble(),
        description: json['description'] as String?,
        creationDate: DateTime.parse(json['creationDate'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'planId': planId,
        'executionDate': executionDate.toIso8601String(),
        'amount': amount,
        'description': description,
        'creationDate': creationDate.toIso8601String(),
      };

  @override
  List<Object?> get props => [
        id,
        planId,
        executionDate,
        amount,
        description,
        creationDate,
      ];
}
