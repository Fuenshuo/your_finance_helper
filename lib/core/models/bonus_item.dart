import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

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
              ? [3, 6, 9, 12]
              : null), // 默认3、6、9、12月
      thirteenthSalaryMonth: thirteenthSalaryMonth,
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
              ? [3, 6, 9, 12]
              : null), // 默认3、6、9、12月
      thirteenthSalaryMonth: json['thirteenthSalaryMonth'] != null
          ? (json['thirteenthSalaryMonth'] as num).toInt()
          : (type == BonusType.thirteenthSalary
              ? startDate.month
              : null), // 默认使用startDate的月份
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

    // 检查奖金是否在指定日期有效
    if (startDate.isAfter(date)) {
      return 0; // 奖金开始日期在目标日期之后
    }

    if (endDate != null && endDate!.isBefore(date)) {
      return 0; // 奖金结束日期在目标日期之前
    }

    switch (frequency) {
      case BonusFrequency.oneTime:
        // 一次性奖金：只在生效月份发放
        if (type == BonusType.thirteenthSalary ||
            type == BonusType.doublePayBonus) {
          // 十三薪和回奖金：金额应该等于基本工资，这里返回全额，后续在计算时处理
          final bonusMonth = type == BonusType.thirteenthSalary &&
                  thirteenthSalaryMonth != null
              ? thirteenthSalaryMonth!
              : startDate.month;
          return startDate.year == year && bonusMonth == month ? amount : 0.0;
        }
        return startDate.year == year && startDate.month == month
            ? amount
            : 0.0;
      case BonusFrequency.monthly:
        // 月度奖金：每月发放
        return amount;
      case BonusFrequency.quarterly:
        // 季度奖金：使用配置的发放月份
        final quarterlyMonths = quarterlyPaymentMonths ?? [3, 6, 9, 12];

        // 如果当前月份不是配置的季度发放月份，返回0
        if (!quarterlyMonths.contains(month)) {
          return 0.0;
        }

        final quarterlyAmount = amount / paymentCount; // 每次发放的季度金额

        // 计算从开始日期到指定年月的季度差
        final startYear = startDate.year;
        final startQuarter = ((startDate.month - 1) ~/ 3) + 1; // 开始季度 (1-4)
        final targetQuarter = ((month - 1) ~/ 3) + 1; // 目标季度 (1-4)
        final quartersSinceStart =
            (year - startYear) * 4 + (targetQuarter - startQuarter);

        // 如果还没到开始发放的季度，返回0
        if (quartersSinceStart < 0) {
          return 0.0;
        }

        // 如果已经发放完所有季度，返回0
        if (quartersSinceStart >= paymentCount) {
          return 0.0;
        }

        // 返回季度奖金金额
        return quarterlyAmount;
      case BonusFrequency.semiAnnual:
        // 半年奖金：上半年6月，下半年12月
        return (month == 6 || month == 12) ? amount : 0.0;
      case BonusFrequency.annual:
        // 年度奖金：12月发放
        return month == 12 ? amount : 0.0;
    }
  }

  /// 计算指定年份的奖金金额
  double calculateAnnualBonus(int year) {
    final now = DateTime.now();
    final yearStart = DateTime(year);
    final yearEnd = DateTime(year, 12, 31);

    // 检查奖金是否在指定年份有效
    if (startDate.year > year) {
      return 0; // 奖金开始日期在目标年份之后
    }

    if (endDate != null && endDate!.year < year) {
      return 0; // 奖金结束日期在目标年份之前
    }

    switch (frequency) {
      case BonusFrequency.oneTime:
        // 一次性奖金：检查是否已经发放
        if (startDate.isBefore(now) || startDate.isAtSameMomentAs(now)) {
          return amount; // 已发放，返回全额
        }
        return 0; // 未发放，不计入收入

      case BonusFrequency.annual:
        // 年度奖金：检查是否已经发放
        if (startDate.isBefore(now) || startDate.isAtSameMomentAs(now)) {
          return amount; // 已发放，返回全额
        }
        return 0; // 未发放，不计入收入

      case BonusFrequency.quarterly:
        // 季度奖金：计算已经发放的季度数
        return _calculateQuarterlyBonus(year, now);

      case BonusFrequency.monthly:
        // 月度奖金：计算已经发放的月份数
        return _calculateMonthlyBonus(year, now);

      case BonusFrequency.semiAnnual:
        // 半年奖金：计算已经发放的半年数
        return _calculateSemiAnnualBonus(year, now);
    }
  }

  /// 计算季度奖金已发放金额 (考虑累进税率)
  double _calculateQuarterlyBonus(int year, DateTime currentDate) {
    // 季度发放月份：使用配置的发放月份
    final quarterlyMonths = quarterlyPaymentMonths ?? [3, 6, 9, 12];
    const salaryDay = 15; // 假设每月15日发放

    // 如果当前日期在开始日期之前，返回0
    if (currentDate.isBefore(startDate)) {
      return 0.0;
    }

    // 如果当前月份不是季度发放月份，返回0
    if (!quarterlyMonths.contains(currentDate.month)) {
      // 计算下个季度发放信息用于预览
      var nextQuarterMonth = 0;
      var nextQuarterYear = currentDate.year;

      for (final month in quarterlyMonths) {
        if (month > currentDate.month) {
          nextQuarterMonth = month;
          break;
        }
      }

      if (nextQuarterMonth == 0) {
        nextQuarterMonth = quarterlyMonths[0];
        nextQuarterYear++;
      }

      // 计算到下个季度的发放次数
      var nextPaidCount = 0;
      var tempYear = startDate.year;
      var tempMonth = startDate.month;

      // 找到第一个发放月份
      var tempFound = false;
      for (var i = 0; i < quarterlyMonths.length; i++) {
        final qMonth = quarterlyMonths[i];
        if (qMonth > startDate.month) {
          tempMonth = qMonth;
          tempFound = true;
          break;
        } else if (qMonth == startDate.month) {
          if (startDate.day <= salaryDay) {
            tempMonth = qMonth;
            tempFound = true;
          } else {
            if (i == quarterlyMonths.length - 1) {
              tempYear++;
              tempMonth = quarterlyMonths[0];
            } else {
              tempMonth = quarterlyMonths[i + 1];
            }
            tempFound = true;
          }
          break;
        }
      }

      if (!tempFound) {
        tempYear++;
        tempMonth = quarterlyMonths[0];
      }

      // 计算到下个季度的发放次数
      while (tempYear < nextQuarterYear ||
          (tempYear == nextQuarterYear && tempMonth <= nextQuarterMonth)) {
        final quarterlyDate = DateTime(tempYear, tempMonth, salaryDay);
        if (!quarterlyDate.isBefore(startDate)) {
          nextPaidCount++;
        }

        var nextIdx = quarterlyMonths.indexOf(tempMonth) + 1;
        if (nextIdx >= quarterlyMonths.length) {
          nextIdx = 0;
          tempYear++;
        }
        tempMonth = quarterlyMonths[nextIdx];

        if (nextPaidCount >= paymentCount) break;
        if (tempYear > currentDate.year + 10) break;
      }

      // 显示下个季度发放预览
      if (nextPaidCount <= paymentCount) {
        final previewAmount = amount / paymentCount;
      }

      return 0.0;
    }

    // 计算当前是第几个季度发放 (需要在预览逻辑之前计算)
    var paidCount = 0;
    var checkYear = startDate.year;
    var checkMonth = startDate.month;

    // 找到第一个季度发放月份
    var foundFirstQuarterlyMonth = false;
    for (var i = 0; i < quarterlyMonths.length; i++) {
      final quarterlyMonth = quarterlyMonths[i];

      if (quarterlyMonth > startDate.month) {
        checkMonth = quarterlyMonth;
        foundFirstQuarterlyMonth = true;
        break;
      } else if (quarterlyMonth == startDate.month) {
        if (startDate.day <= salaryDay) {
          checkMonth = quarterlyMonth;
          foundFirstQuarterlyMonth = true;
        } else {
          if (i == quarterlyMonths.length - 1) {
            checkYear++;
            checkMonth = quarterlyMonths[0];
          } else {
            checkMonth = quarterlyMonths[i + 1];
          }
          foundFirstQuarterlyMonth = true;
        }
        break;
      }
    }

    if (!foundFirstQuarterlyMonth) {
      checkYear++;
      checkMonth = quarterlyMonths[0];
    }

    // 计算已经过去的季度发放次数
    while (checkYear < currentDate.year ||
        (checkYear == currentDate.year && checkMonth <= currentDate.month)) {
      final quarterlyDate = DateTime(checkYear, checkMonth, salaryDay);
      if (!quarterlyDate.isBefore(startDate)) {
        paidCount++;
      }

      var nextIdx = quarterlyMonths.indexOf(checkMonth) + 1;
      if (nextIdx >= quarterlyMonths.length) {
        nextIdx = 0;
        checkYear++;
      }
      checkMonth = quarterlyMonths[nextIdx];

      if (paidCount >= paymentCount) break;
      if (checkYear > currentDate.year + 10) break;
    }

    // 如果当前日期还没到发放日，返回0
    if (currentDate.day < salaryDay) {
      return 0.0;
    }

    // 如果还没到发放次数，返回0
    if (paidCount <= 0 || paidCount > paymentCount) {
      return 0.0;
    }

    // 计算季度奖金的税前金额
    // 按照季度奖金总额除以发放次数得到每季度应发金额
    final baseAmount = amount / paymentCount;
    final paymentAmount = baseAmount; // 税前金额

    // 注意：根据税务文档，季度奖金应与工资收入合并计税
    // 此处仅计算基础金额，实际税额在工资计算时一并处理
    return paymentAmount;
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
          DateTime(end.year, ((end.month - 1) ~/ 3) * 3 + 1),
        )) {
      quarters++;
      final nextQuarter = current.month + 3;
      current = DateTime(
        current.year + (nextQuarter > 12 ? 1 : 0),
        (nextQuarter - 1) % 12 + 1,
      );
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
    int? paymentCount,
    DateTime? startDate,
    DateTime? endDate,
    String? description,
    List<int>? quarterlyPaymentMonths,
    int? thirteenthSalaryMonth,
    DateTime? creationDate,
    DateTime? updateDate,
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
      ];
}
