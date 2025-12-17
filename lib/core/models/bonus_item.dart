import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import 'package:your_finance_flutter/core/utils/logger.dart';

/// 奖金类型枚举
enum BonusType {
  thirteenthSalary, // 十三薪
  yearEndBonus, // 年终奖
  quarterlyBonus, // 季度奖金
  doublePayBonus, // 回奖金（年底双薪）
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
      case BonusType.doublePayBonus:
        return '回奖金';
      case BonusType.other:
        return '其他奖金';
    }
  }

  String get inputHint {
    switch (this) {
      case BonusType.thirteenthSalary:
        return '输入十三薪总额';
      case BonusType.yearEndBonus:
        return '输入年终奖总额';
      case BonusType.quarterlyBonus:
        return '输入每季度奖金金额';
      case BonusType.doublePayBonus:
        return '输入回奖金总额';
      case BonusType.other:
        return '输入奖金总额';
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

/// BonusFrequency扩展
extension BonusFrequencyExtension on BonusFrequency {
  String get displayName {
    switch (this) {
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
}

/// 奖金项目模型
class BonusItem extends Equatable {
  const BonusItem({
    required this.id,
    required this.name,
    required this.type,
    required this.amount,
    required this.frequency,
    required this.paymentCount,
    required this.startDate,
    required this.creationDate,
    required this.updateDate,
    this.endDate,
    this.description,
    this.quarterlyPaymentMonths, // 季度奖金发放月份配置
    this.thirteenthSalaryMonth, // 十三薪发放月份
    this.awardDate, // 奖金授予日期（奖金什么时候公布的）
    this.attributionDate, // 奖金归属日期（奖金什么时候发放的）
  });

  /// 创建新的奖金项目
  factory BonusItem.create({
    required String name,
    required BonusType type,
    required double amount,
    required BonusFrequency frequency,
    required int paymentCount,
    required DateTime startDate,
    DateTime? endDate,
    String? description,
    List<int>? quarterlyPaymentMonths, // 季度奖金发放月份配置
    int? thirteenthSalaryMonth, // 十三薪发放月份
    DateTime? awardDate, // 奖金授予日期
    DateTime? attributionDate, // 奖金归属日期
  }) {
    final now = DateTime.now();
    return BonusItem(
      id: const Uuid().v4(),
      name: name,
      type: type,
      amount: amount,
      frequency: frequency,
      paymentCount: paymentCount,
      startDate: startDate,
      endDate: endDate,
      description: description,
      quarterlyPaymentMonths: quarterlyPaymentMonths ??
          (type == BonusType.quarterlyBonus
              ? <int>[] // 新增时默认为空，让用户自己选择
              : null),
      thirteenthSalaryMonth: thirteenthSalaryMonth,
      awardDate: awardDate,
      attributionDate: attributionDate,
      creationDate: now,
      updateDate: now,
    );
  }

  /// 从JSON创建实例
  factory BonusItem.fromJson(Map<String, dynamic> json) {
    final type = BonusType.values[json['type'] as int];
    final startDate = DateTime.parse(json['startDate'] as String);

    return BonusItem(
      id: json['id'] as String,
      name: json['name'] as String,
      type: type,
      amount: (json['amount'] as num).toDouble(),
      frequency: BonusFrequency.values[json['frequency'] as int],
      paymentCount: json['paymentCount'] != null
          ? (json['paymentCount'] as num).toInt()
          : (type == BonusType.quarterlyBonus ? 4 : 1), // 向后兼容：季度奖金默认4次，其他默认1次
      startDate: startDate,
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
      description: json['description'] as String?,
      quarterlyPaymentMonths: json['quarterlyPaymentMonths'] != null
          ? List<int>.from(json['quarterlyPaymentMonths'] as List)
          : (type == BonusType.quarterlyBonus
              ? BonusItem.calculateQuarterlyPaymentMonths(startDate)
              : null), // 根据开始日期计算发放月份
      thirteenthSalaryMonth: json['thirteenthSalaryMonth'] != null
          ? (json['thirteenthSalaryMonth'] as num).toInt()
          : (type == BonusType.thirteenthSalary
              ? startDate.month
              : null), // 默认使用startDate的月份
      awardDate: json['awardDate'] != null
          ? DateTime.parse(json['awardDate'] as String)
          : null, // 奖金授予日期
      attributionDate: json['attributionDate'] != null
          ? DateTime.parse(json['attributionDate'] as String)
          : null, // 奖金归属日期
      creationDate: DateTime.parse(json['creationDate'] as String),
      updateDate: DateTime.parse(json['updateDate'] as String),
    );
  }
  final String id;
  final String name;
  final BonusType type;
  final double amount;
  final BonusFrequency frequency;
  final int paymentCount;
  final DateTime startDate;
  final DateTime? endDate; // 可选的结束日期，为空表示持续有效
  final String? description;
  final List<int>? quarterlyPaymentMonths; // 季度奖金发放月份配置
  final int? thirteenthSalaryMonth; // 十三薪发放月份
  final DateTime creationDate;
  final DateTime updateDate;
  final DateTime? awardDate; // 奖金授予日期（奖金什么时候公布的）
  final DateTime? attributionDate; // 奖金归属日期（奖金什么时候发放的）

  /// 获取奖金类型显示名称
  String get typeDisplayName {
    switch (type) {
      case BonusType.thirteenthSalary:
        return '十三薪';
      case BonusType.yearEndBonus:
        return '年终奖';
      case BonusType.quarterlyBonus:
        return '季度奖金';
      case BonusType.doublePayBonus:
        return '回奖金';
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

  /// 计算指定年月的奖金金额
  double calculateMonthlyBonus(int year, int month) {
    final date = DateTime(year, month);
    Logger.debug(
      '🎁 计算奖金月份: $name, 年=$year, 月=$month, 开始日期=$startDate, 类型=$type, 频率=$frequency',
    );

    // 检查奖金是否在指定日期有效
    // 对于十三薪和年终奖，我们特殊处理日期检查
    if (type == BonusType.thirteenthSalary ||
        type == BonusType.doublePayBonus) {
      // 特殊处理十三薪和双薪
    } else if (type == BonusType.yearEndBonus &&
        frequency == BonusFrequency.oneTime) {
      // 特殊处理一次性年终奖 - 只需检查年份
      if (startDate.year > year) {
        Logger.debug('  奖金开始年份在目标年份之后，返回0');
        return 0;
      }

      if (endDate != null && endDate!.year < year) {
        Logger.debug('  奖金结束年份在目标年份之前，返回0');
        return 0;
      }
    } else {
      // 其他奖金的日期检查
      if (startDate.isAfter(date)) {
        Logger.debug('  奖金开始日期在目标日期之后，返回0');
        return 0; // 奖金开始日期在目标日期之后
      }

      if (endDate != null && endDate!.isBefore(date)) {
        Logger.debug('  奖金结束日期在目标日期之前，返回0');
        return 0; // 奖金结束日期在目标日期之前
      }
    }

    switch (frequency) {
      case BonusFrequency.oneTime:
        // 一次性奖金：只在生效月份发放
        if (type == BonusType.thirteenthSalary ||
            type == BonusType.doublePayBonus) {
          // 十三薪和回奖金：使用指定的发放月份
          final bonusMonth = type == BonusType.thirteenthSalary &&
                  thirteenthSalaryMonth != null
              ? thirteenthSalaryMonth!
              : (attributionDate ?? startDate).month; // 如果没有归属日期，则使用开始日期的月份

          final result =
              (attributionDate ?? startDate).year <= year && bonusMonth == month
                  ? amount
                  : 0.0;
          Logger.debug('  一次性奖金(十三薪/回奖金): 月份=$bonusMonth, 结果=$result');
          return result;
        } else if (type == BonusType.yearEndBonus) {
          // 一次性年终奖：在归属日期指定的月份发放
          // attributionDate表示奖金归属的日期，例如2025-04-15表示2025年4月获得的奖金
          final targetDate = attributionDate ?? startDate; // 如果没有归属日期，则使用开始日期
          final result = targetDate.year == year && targetDate.month == month
              ? amount
              : 0.0;
          Logger.debug('  一次性年终奖: 结果=$result');
          return result;
        }
        final result =
            startDate.year == year && startDate.month == month ? amount : 0.0;
        Logger.debug('  一次性奖金: 结果=$result');
        return result;
      case BonusFrequency.monthly:
        // 月度奖金：每月发放
        Logger.debug('  月度奖金: 返回=$amount');
        return amount;
      case BonusFrequency.quarterly:
        // 季度奖金：使用配置的发放月份
        final quarterlyMonths = quarterlyPaymentMonths ?? [3, 6, 9, 12];
        Logger.debug('  季度奖金配置月份: $quarterlyMonths');

        // 如果当前月份不是配置的季度发放月份，返回0
        if (!quarterlyMonths.contains(month)) {
          Logger.debug('  当前月份不在季度发放月份中，返回0');
          return 0.0;
        }

        // 检查是否已经过了发放次数
        if (paymentCount <= 0) {
          Logger.debug('  发放次数为0，返回0');
          return 0.0;
        }

        // 计算到目前为止应该发放的次数
        var expectedPayments = 0;
        for (final qMonth in quarterlyMonths) {
          if (qMonth < month || (qMonth == month && startDate.year <= year)) {
            expectedPayments++;
          }
        }

        // 如果已经超过了发放次数，返回0
        if (expectedPayments > paymentCount) {
          Logger.debug('  已超过发放次数($expectedPayments > $paymentCount)，返回0');
          return 0.0;
        }

        final quarterlyAmount = amount / paymentCount; // 每次发放的季度金额
        Logger.debug('  季度奖金: 每次金额=$quarterlyAmount, 发放次数=$paymentCount');

        // 返回季度奖金金额
        Logger.debug('  季度奖金: 返回=$quarterlyAmount');
        return quarterlyAmount;
      case BonusFrequency.semiAnnual:
        // 半年奖金：上半年6月，下半年12月
        final result = (month == 6 || month == 12) ? amount : 0.0;
        Logger.debug('  半年奖金: 月份=$month, 结果=$result');
        return result;
      case BonusFrequency.annual:
        // 年度奖金：12月发放
        final result = month == 12 ? amount : 0.0;
        Logger.debug('  年度奖金: 月份=$month, 结果=$result');
        return result;
    }
  }

  /// 计算指定年份的奖金金额
  double calculateAnnualBonus(int year) {
    // 检查奖金是否在指定年份有效
    if (startDate.year > year) {
      return 0; // 奖金开始日期在目标年份之后
    }

    if (endDate != null && endDate!.year < year) {
      return 0; // 奖金结束日期在目标年份之前
    }

    switch (frequency) {
      case BonusFrequency.oneTime:
        // 一次性奖金：检查是否在有效年度内
        if (startDate.year <= year &&
            (endDate == null || endDate!.year >= year)) {
          // 检查是否已发放或在年度内
          if (startDate.isBefore(DateTime(year + 1)) &&
              (endDate == null || endDate!.isAfter(DateTime(year)))) {
            return amount; // 在年度内，返回全额
          }
        }
        return 0; // 不在年度内，不计入收入

      case BonusFrequency.annual:
        // 年度奖金：检查是否已经发放
        final now = DateTime.now();
        if (startDate.isBefore(now) || startDate.isAtSameMomentAs(now)) {
          return amount; // 已发放，返回全额
        }
        return 0; // 未发放，不计入收入

      case BonusFrequency.quarterly:
        // 季度奖金：计算已经发放的季度数
        return _calculateQuarterlyBonus(year, DateTime.now());

      case BonusFrequency.monthly:
        // 月度奖金：计算已经发放的月份数
        return _calculateMonthlyBonus(year, DateTime.now());

      case BonusFrequency.semiAnnual:
        // 半年奖金：计算已经发放的半年数
        return _calculateSemiAnnualBonus(year, DateTime.now());
    }
  }

  /// 计算季度奖金已发放金额 (考虑累进税率)
  double _calculateQuarterlyBonus(int year, DateTime currentDate) {
    // 季度发放月份：使用配置的发放月份
    final quarterlyMonths = quarterlyPaymentMonths ?? [3, 6, 9, 12];
    const salaryDay = 15; // 假设每月15日发放

    // 如果奖金开始日期在当前日期之后，返回0
    if (startDate.isAfter(currentDate)) {
      return 0.0;
    }

    // 计算已发放的季度奖金次数
    var paidCount = 0;

    // 遍历年内的每个季度发放月份
    for (final month in quarterlyMonths) {
      final paymentDate = DateTime(year, month, salaryDay);

      // 检查这个发放日期是否已过且在奖金有效期内
      if (paymentDate.isBefore(currentDate) ||
          paymentDate.isAtSameMomentAs(currentDate)) {
        // 检查这个发放日期是否在奖金的有效期内
        if (!paymentDate.isBefore(startDate) &&
            (endDate == null || !paymentDate.isAfter(endDate!))) {
          paidCount++;
        }
      }
    }

    // 计算每季度应发金额
    final baseAmount = amount / paymentCount;
    return baseAmount * paidCount;
  }

  /// 计算月度奖金已发放金额
  double _calculateMonthlyBonus(int year, DateTime currentDate) {
    final bonusPerMonth = amount / 12; // 每月奖金

    var paidMonths = 0;
    final yearStart = startDate.year == year ? startDate.month : 1;
    final maxMonth = currentDate.year == year
        ? currentDate.month
        : (endDate != null && endDate!.year == year ? endDate!.month : 12);

    for (var month = yearStart; month <= maxMonth; month++) {
      final monthEndDate = DateTime(
        year,
        month,
        month == 2
            ? 28
            : (month == 4 || month == 6 || month == 9 || month == 11)
                ? 30
                : 31,
      );

      if (monthEndDate.isBefore(currentDate) ||
          monthEndDate.isAtSameMomentAs(currentDate)) {
        paidMonths++;
      }
    }

    return bonusPerMonth * paidMonths;
  }

  /// 计算半年奖金已发放金额
  double _calculateSemiAnnualBonus(int year, DateTime currentDate) {
    final bonusPerHalf = amount / 2; // 每半年的奖金

    var paidHalfs = 0;
    final halfYears = [6, 12]; // 半年结束月份

    for (final halfMonth in halfYears) {
      final halfEndDate = DateTime(
        year,
        halfMonth,
        halfMonth == 2 ? 28 : 30,
      ); // 半年结束日期

      if (halfEndDate.isBefore(startDate)) {
        continue;
      }

      if (halfEndDate.isBefore(currentDate) ||
          halfEndDate.isAtSameMomentAs(currentDate)) {
        paidHalfs++;
      }
    }

    return bonusPerHalf * paidHalfs;
  }

  /// 创建副本
  BonusItem copyWith({
    String? id,
    String? name,
    BonusType? type,
    double? amount,
    BonusFrequency? frequency,
    int? paymentCount,
    DateTime? startDate,
    DateTime? endDate,
    String? description,
    List<int>? quarterlyPaymentMonths,
    int? thirteenthSalaryMonth,
    DateTime? creationDate,
    DateTime? updateDate,
    DateTime? awardDate, // 奖金授予日期
    DateTime? attributionDate, // 奖金归属日期
  }) =>
      BonusItem(
        id: id ?? this.id,
        name: name ?? this.name,
        type: type ?? this.type,
        amount: amount ?? this.amount,
        frequency: frequency ?? this.frequency,
        paymentCount: paymentCount ?? this.paymentCount,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        description: description ?? this.description,
        quarterlyPaymentMonths:
            quarterlyPaymentMonths ?? this.quarterlyPaymentMonths,
        thirteenthSalaryMonth:
            thirteenthSalaryMonth ?? this.thirteenthSalaryMonth,
        awardDate: awardDate ?? this.awardDate,
        attributionDate: attributionDate ?? this.attributionDate,
        creationDate: creationDate ?? this.creationDate,
        updateDate: updateDate ?? DateTime.now(),
      );

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    final json = {
      'id': id,
      'name': name,
      'type': type.index,
      'amount': amount,
      'frequency': frequency.index,
      'paymentCount': paymentCount,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'description': description,
      'quarterlyPaymentMonths': quarterlyPaymentMonths,
      'thirteenthSalaryMonth': thirteenthSalaryMonth,
      'awardDate': awardDate?.toIso8601String(), // 奖金授予日期
      'attributionDate': attributionDate?.toIso8601String(), // 奖金归属日期
      'creationDate': creationDate.toIso8601String(),
      'updateDate': updateDate.toIso8601String(),
    };

    return json;
  }

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        amount,
        frequency,
        paymentCount,
        startDate,
        endDate,
        description,
        quarterlyPaymentMonths,
        thirteenthSalaryMonth,
        creationDate,
        updateDate,
        awardDate, // 奖金授予日期
        attributionDate, // 奖金归属日期
      ];

  /// 根据开始日期计算季度奖金的发放月份
  /// 从开始月份开始，每3个月发放一次
  static List<int> calculateQuarterlyPaymentMonths(DateTime startDate) {
    final startMonth = startDate.month;
    final months = <int>[];

    // 从开始月份开始，每3个月添加一次
    for (var i = 0; i < 4; i++) {
      final month = ((startMonth - 1 + i * 3) % 12) + 1;
      months.add(month);
    }

    return months;
  }
}
