import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

/// 奖金类型枚举
enum BonusType {
  thirteenthSalary, // 十三薪
  yearEndBonus, // 年终奖
  quarterlyBonus, // 季度奖金
  performanceBonus, // 绩效奖金
  projectBonus, // 项目奖金
  holidayBonus, // 节日奖金
  other, // 其他奖金
}

/// BonusType 扩展
extension BonusTypeExtension on BonusType {
  String get typeDisplayName {
    switch (this) {
      case BonusType.thirteenthSalary:
        return '十三薪';
      case BonusType.yearEndBonus:
        return '年终奖';
      case BonusType.quarterlyBonus:
        return '季度奖金';
      case BonusType.performanceBonus:
        return '绩效奖金';
      case BonusType.projectBonus:
        return '项目奖金';
      case BonusType.holidayBonus:
        return '节日奖金';
      case BonusType.other:
        return '其他奖金';
    }
  }
}

/// 奖金生效周期枚举
enum BonusFrequency {
  oneTime, // 一次性
  monthly, // 每月
  quarterly, // 每季度
  semiAnnual, // 每半年
  annual, // 每年
}

/// 奖金项目模型
class BonusItem extends Equatable {
  const BonusItem({
    required this.id,
    required this.name,
    required this.type,
    required this.amount,
    required this.frequency,
    required this.startDate,
    required this.creationDate,
    required this.updateDate,
    this.endDate,
    this.description,
  });

  /// 创建新的奖金项目
  factory BonusItem.create({
    required String name,
    required BonusType type,
    required double amount,
    required BonusFrequency frequency,
    required DateTime startDate,
    DateTime? endDate,
    String? description,
  }) {
    final now = DateTime.now();
    return BonusItem(
      id: const Uuid().v4(),
      name: name,
      type: type,
      amount: amount,
      frequency: frequency,
      startDate: startDate,
      endDate: endDate,
      description: description,
      creationDate: now,
      updateDate: now,
    );
  }

  /// 从JSON创建实例
  factory BonusItem.fromJson(Map<String, dynamic> json) => BonusItem(
        id: json['id'] as String,
        name: json['name'] as String,
        type: BonusType.values[json['type'] as int],
        amount: (json['amount'] as num).toDouble(),
        frequency: BonusFrequency.values[json['frequency'] as int],
        startDate: DateTime.parse(json['startDate'] as String),
        endDate: json['endDate'] != null
            ? DateTime.parse(json['endDate'] as String)
            : null,
        description: json['description'] as String?,
        creationDate: DateTime.parse(json['creationDate'] as String),
        updateDate: DateTime.parse(json['updateDate'] as String),
      );
  final String id;
  final String name;
  final BonusType type;
  final double amount;
  final BonusFrequency frequency;
  final DateTime startDate;
  final DateTime? endDate; // 可选的结束日期，为空表示持续有效
  final String? description;
  final DateTime creationDate;
  final DateTime updateDate;

  /// 获取奖金类型显示名称
  String get typeDisplayName {
    switch (type) {
      case BonusType.thirteenthSalary:
        return '十三薪';
      case BonusType.yearEndBonus:
        return '年终奖';
      case BonusType.quarterlyBonus:
        return '季度奖金';
      case BonusType.performanceBonus:
        return '绩效奖金';
      case BonusType.projectBonus:
        return '项目奖金';
      case BonusType.holidayBonus:
        return '节日奖金';
      case BonusType.other:
        return '其他奖金';
    }
  }

  /// 获取生效周期显示名称
  String get frequencyDisplayName {
    switch (frequency) {
      case BonusFrequency.oneTime:
        return '一次性';
      case BonusFrequency.monthly:
        return '每月';
      case BonusFrequency.quarterly:
        return '每季度';
      case BonusFrequency.semiAnnual:
        return '每半年';
      case BonusFrequency.annual:
        return '每年';
    }
  }

  /// 计算指定年份的奖金金额
  double calculateAnnualBonus(int year) {
    final yearStart = DateTime(year);
    final yearEnd = DateTime(year, 12, 31);

    // 检查奖金项目是否在指定年份有效
    final effectiveStart =
        startDate.isBefore(yearStart) ? yearStart : startDate;
    final effectiveEnd =
        endDate != null && endDate!.isBefore(yearEnd) ? endDate! : yearEnd;

    if (effectiveStart.isAfter(effectiveEnd)) {
      return 0;
    }

    switch (frequency) {
      case BonusFrequency.oneTime:
        // 一次性奖金：如果生效时间在指定年份内，则返回全额
        return startDate.year == year ? amount : 0;

      case BonusFrequency.monthly:
        // 每月奖金：计算生效月份数
        final months = _calculateEffectiveMonths(effectiveStart, effectiveEnd);
        return amount * months;

      case BonusFrequency.quarterly:
        // 每季度奖金：计算生效季度数
        final quarters =
            _calculateEffectiveQuarters(effectiveStart, effectiveEnd);
        return amount * quarters;

      case BonusFrequency.semiAnnual:
        // 每半年奖金：计算生效半年数
        final semiYears =
            _calculateEffectiveSemiYears(effectiveStart, effectiveEnd);
        return amount * semiYears;

      case BonusFrequency.annual:
        // 每年奖金：如果在指定年份有任何生效时间，则返回全额
        return effectiveStart.year <= year && effectiveEnd.year >= year
            ? amount
            : 0;
    }
  }

  /// 计算生效月份数
  int _calculateEffectiveMonths(DateTime start, DateTime end) {
    var months = 0;
    var current = DateTime(start.year, start.month);

    while (current.isBefore(end) ||
        current.isAtSameMomentAs(DateTime(end.year, end.month))) {
      months++;
      current = DateTime(current.year, current.month + 1);
    }

    return months;
  }

  /// 计算生效季度数
  int _calculateEffectiveQuarters(DateTime start, DateTime end) {
    var quarters = 0;
    var current = DateTime(start.year, ((start.month - 1) ~/ 3) * 3 + 1);

    while (current.isBefore(end) ||
        current.isAtSameMomentAs(
            DateTime(end.year, ((end.month - 1) ~/ 3) * 3 + 1))) {
      quarters++;
      final nextQuarter = current.month + 3;
      current = DateTime(current.year + (nextQuarter > 12 ? 1 : 0),
          (nextQuarter - 1) % 12 + 1);
    }

    return quarters;
  }

  /// 计算生效半年数
  int _calculateEffectiveSemiYears(DateTime start, DateTime end) {
    var semiYears = 0;
    var current = DateTime(start.year, start.month <= 6 ? 1 : 7);

    while (current.isBefore(end) ||
        current.isAtSameMomentAs(DateTime(end.year, end.month <= 6 ? 1 : 7))) {
      semiYears++;
      final nextHalf = current.month <= 6 ? 7 : 1;
      final nextYear = current.month <= 6 ? current.year : current.year + 1;
      current = DateTime(nextYear, nextHalf);
    }

    return semiYears;
  }

  /// 创建副本
  BonusItem copyWith({
    String? id,
    String? name,
    BonusType? type,
    double? amount,
    BonusFrequency? frequency,
    DateTime? startDate,
    DateTime? endDate,
    String? description,
    DateTime? creationDate,
    DateTime? updateDate,
  }) =>
      BonusItem(
        id: id ?? this.id,
        name: name ?? this.name,
        type: type ?? this.type,
        amount: amount ?? this.amount,
        frequency: frequency ?? this.frequency,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        description: description ?? this.description,
        creationDate: creationDate ?? this.creationDate,
        updateDate: updateDate ?? DateTime.now(),
      );

  /// 转换为JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type.index,
        'amount': amount,
        'frequency': frequency.index,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
        'description': description,
        'creationDate': creationDate.toIso8601String(),
        'updateDate': updateDate.toIso8601String(),
      };

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        amount,
        frequency,
        startDate,
        endDate,
        description,
        creationDate,
        updateDate,
      ];
}
