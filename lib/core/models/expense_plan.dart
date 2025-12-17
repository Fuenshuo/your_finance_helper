import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

/// 支出计划类型枚举
enum ExpensePlanType {
  /// 周期性支出 - 定期固定支出，如房租、水电费等
  periodic,

  /// 预算计划 - 约束型支出上限，如餐饮预算等
  budget,
}

/// 支出频率枚举
enum ExpenseFrequency {
  daily,
  weekly,
  monthly,
  quarterly,
  yearly,
}

/// 支出计划状态
enum ExpensePlanStatus {
  active,
  paused,
  completed,
  cancelled,
}

/// 支出计划模型
class ExpensePlan extends Equatable {
  ExpensePlan({
    required this.id,
    required this.name,
    required this.type,
    required this.amount,
    required this.frequency,
    required this.walletId,
    required this.startDate,
    this.description = '',
    this.categoryId,
    this.loanAccountId, // 关联的贷款账户ID（用于还款计划）
    this.endDate,
    this.status = ExpensePlanStatus.active,
    this.executionCount = 0,
    DateTime? lastExecution,
    DateTime? creationDate,
    DateTime? updateDate,
  })  : lastExecution = lastExecution ?? DateTime.now(),
        creationDate = creationDate ?? DateTime.now(),
        updateDate = updateDate ?? DateTime.now();

  /// 创建新的支出计划
  factory ExpensePlan.create({
    required String name,
    required ExpensePlanType type,
    required double amount,
    required ExpenseFrequency frequency,
    required String walletId,
    required DateTime startDate,
    String description = '',
    String? categoryId,
    String? loanAccountId, // 关联的贷款账户ID
    DateTime? endDate,
  }) =>
      ExpensePlan(
        id: const Uuid().v4(),
        name: name,
        description: description,
        type: type,
        amount: amount,
        frequency: frequency,
        walletId: walletId,
        categoryId: categoryId,
        loanAccountId: loanAccountId,
        startDate: startDate,
        endDate: endDate,
        creationDate: DateTime.now(),
        updateDate: DateTime.now(),
      );

  /// 从JSON创建
  factory ExpensePlan.fromJson(Map<String, dynamic> json) => ExpensePlan(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String? ?? '',
        type: ExpensePlanType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => ExpensePlanType.periodic,
        ),
        amount: (json['amount'] as num).toDouble(),
        frequency: ExpenseFrequency.values.firstWhere(
          (e) => e.name == json['frequency'],
          orElse: () => ExpenseFrequency.monthly,
        ),
        walletId: json['walletId'] as String,
        categoryId: json['categoryId'] as String?,
        loanAccountId: json['loanAccountId'] as String?,
        startDate: DateTime.parse(json['startDate'] as String),
        endDate: json['endDate'] != null
            ? DateTime.parse(json['endDate'] as String)
            : null,
        status: ExpensePlanStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => ExpensePlanStatus.active,
        ),
        executionCount: json['executionCount'] as int? ?? 0,
        lastExecution: json['lastExecution'] != null
            ? DateTime.parse(json['lastExecution'] as String)
            : DateTime.now(),
        creationDate: json['creationDate'] != null
            ? DateTime.parse(json['creationDate'] as String)
            : DateTime.now(),
        updateDate: json['updateDate'] != null
            ? DateTime.parse(json['updateDate'] as String)
            : DateTime.now(),
      );
  final String id;
  final String name;
  final String description;
  final ExpensePlanType type;
  final double amount;
  final ExpenseFrequency frequency;
  final String walletId;
  final String? categoryId; // 可选的支出分类
  final String? loanAccountId; // 关联的贷款账户ID（用于还款计划）
  final DateTime startDate;
  final DateTime? endDate;
  final ExpensePlanStatus status;
  final int executionCount; // 执行次数
  final DateTime lastExecution; // 最后执行时间
  final DateTime creationDate;
  final DateTime updateDate;

  /// 复制并更新支出计划
  ExpensePlan copyWith({
    String? id,
    String? name,
    String? description,
    ExpensePlanType? type,
    double? amount,
    ExpenseFrequency? frequency,
    String? walletId,
    String? categoryId,
    String? loanAccountId,
    DateTime? startDate,
    DateTime? endDate,
    ExpensePlanStatus? status,
    int? executionCount,
    DateTime? lastExecution,
    DateTime? creationDate,
    DateTime? updateDate,
  }) =>
      ExpensePlan(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description ?? this.description,
        type: type ?? this.type,
        amount: amount ?? this.amount,
        frequency: frequency ?? this.frequency,
        walletId: walletId ?? this.walletId,
        categoryId: categoryId ?? this.categoryId,
        loanAccountId: loanAccountId ?? this.loanAccountId,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        status: status ?? this.status,
        executionCount: executionCount ?? this.executionCount,
        lastExecution: lastExecution ?? this.lastExecution,
        creationDate: creationDate ?? this.creationDate,
        updateDate: updateDate ?? this.updateDate,
      );

  /// 检查计划是否应该在指定日期执行
  bool shouldExecuteOn(DateTime date) {
    if (status != ExpensePlanStatus.active) return false;
    if (date.isBefore(startDate)) return false;
    if (endDate != null && date.isAfter(endDate!)) return false;

    switch (frequency) {
      case ExpenseFrequency.daily:
        return true; // 每天都执行
      case ExpenseFrequency.weekly:
        return date.weekday == startDate.weekday;
      case ExpenseFrequency.monthly:
        return date.day == startDate.day;
      case ExpenseFrequency.quarterly:
        // 每季度执行一次，与开始日期同一天
        final monthsDiff =
            (date.year - startDate.year) * 12 + date.month - startDate.month;
        return monthsDiff % 3 == 0 && date.day == startDate.day;
      case ExpenseFrequency.yearly:
        return date.month == startDate.month && date.day == startDate.day;
    }
  }

  /// 记录执行
  ExpensePlan recordExecution() => copyWith(
        executionCount: executionCount + 1,
        lastExecution: DateTime.now(),
        updateDate: DateTime.now(),
      );

  /// 暂停计划
  ExpensePlan pause() => copyWith(
        status: ExpensePlanStatus.paused,
        updateDate: DateTime.now(),
      );

  /// 恢复计划
  ExpensePlan resume() => copyWith(
        status: ExpensePlanStatus.active,
        updateDate: DateTime.now(),
      );

  /// 完成计划
  ExpensePlan complete() => copyWith(
        status: ExpensePlanStatus.completed,
        updateDate: DateTime.now(),
      );

  /// 取消计划
  ExpensePlan cancel() => copyWith(
        status: ExpensePlanStatus.cancelled,
        updateDate: DateTime.now(),
      );

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        type,
        amount,
        frequency,
        walletId,
        categoryId,
        startDate,
        endDate,
        status,
        executionCount,
        lastExecution,
        creationDate,
        updateDate,
      ];

  /// 转换为JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'type': type.name,
        'amount': amount,
        'frequency': frequency.name,
        'walletId': walletId,
        'categoryId': categoryId,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
        'status': status.name,
        'executionCount': executionCount,
        'lastExecution': lastExecution.toIso8601String(),
        'creationDate': creationDate.toIso8601String(),
        'updateDate': updateDate.toIso8601String(),
      };
}

/// 支出计划扩展方法
extension ExpensePlanTypeExtension on ExpensePlanType {
  String get displayName {
    switch (this) {
      case ExpensePlanType.periodic:
        return '周期性支出';
      case ExpensePlanType.budget:
        return '预算计划';
    }
  }

  String get description {
    switch (this) {
      case ExpensePlanType.periodic:
        return '定期固定支出，如房租、水电费、保险等';
      case ExpensePlanType.budget:
        return '设置支出上限，约束消费行为';
    }
  }

  IconData get icon {
    switch (this) {
      case ExpensePlanType.periodic:
        return Icons.schedule;
      case ExpensePlanType.budget:
        return Icons.account_balance_wallet;
    }
  }
}

extension ExpenseFrequencyExtension on ExpenseFrequency {
  String get displayName {
    switch (this) {
      case ExpenseFrequency.daily:
        return '每日';
      case ExpenseFrequency.weekly:
        return '每周';
      case ExpenseFrequency.monthly:
        return '每月';
      case ExpenseFrequency.quarterly:
        return '每季度';
      case ExpenseFrequency.yearly:
        return '每年';
    }
  }

  int get daysInterval {
    switch (this) {
      case ExpenseFrequency.daily:
        return 1;
      case ExpenseFrequency.weekly:
        return 7;
      case ExpenseFrequency.monthly:
        return 30;
      case ExpenseFrequency.quarterly:
        return 90;
      case ExpenseFrequency.yearly:
        return 365;
    }
  }
}

extension ExpensePlanStatusExtension on ExpensePlanStatus {
  String get displayName {
    switch (this) {
      case ExpensePlanStatus.active:
        return '进行中';
      case ExpensePlanStatus.paused:
        return '已暂停';
      case ExpensePlanStatus.completed:
        return '已完成';
      case ExpensePlanStatus.cancelled:
        return '已取消';
    }
  }

  Color get color {
    switch (this) {
      case ExpensePlanStatus.active:
        return const Color(0xFF4CAF50); // 绿色
      case ExpensePlanStatus.paused:
        return const Color(0xFFFF9800); // 橙色
      case ExpensePlanStatus.completed:
        return const Color(0xFF2196F3); // 蓝色
      case ExpensePlanStatus.cancelled:
        return const Color(0xFFF44336); // 红色
    }
  }
}
