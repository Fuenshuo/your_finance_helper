import 'package:your_finance_flutter/models/bonus_item.dart';
import 'package:your_finance_flutter/services/personal_income_tax_service.dart';

class SalaryCalculationResult {
  const SalaryCalculationResult({
    required this.basicIncome,
    required this.allowanceIncome,
    required this.bonusIncome,
    required this.totalIncome,
    required this.totalTax,
    required this.netIncome,
  });
  final double basicIncome;
  final double allowanceIncome;
  final double bonusIncome;
  final double totalIncome;
  final double totalTax;
  final double netIncome;
}

class SalaryCalculationService {
  /// 计算两个日期之间的月数差异
  static int calculateMonthsBetween(DateTime start, DateTime end) {
    if (start.isAfter(end)) return 0;

    var months = 0;
    var current = DateTime(start.year, start.month);

    // 算到结束日期所在月份的1日之前，这样就不会多算一个月
    while (current.isBefore(DateTime(end.year, end.month))) {
      months++;
      current = DateTime(current.year, current.month + 1);
    }

    return months;
  }

  /// 计算自动累计收入（用于年中模式）
  static SalaryCalculationResult calculateAutoCumulative({
    required int completedMonths,
    required Map<DateTime, double> salaryHistory,
    required double basicSalary,
    required double housingAllowance,
    required double mealAllowance,
    required double transportationAllowance,
    required double otherAllowance,
    required double performanceBonus,
    required double socialInsurance,
    required double housingFund,
    required double specialDeductionMonthly,
    required double otherTaxFreeIncome,
    required List<BonusItem> bonuses,
  }) {
    final currentYear = DateTime.now().year;
    const startMonth = 1; // 从1月开始
    final endMonth = completedMonths;

    // 计算基本收入（考虑工资历史调整）
    var totalBasicIncome = 0.0;

    // 如果有工资历史记录，则按时间段计算，否则使用当前工资
    if (salaryHistory.isNotEmpty) {
      // 将工资历史按时间排序
      final sortedHistory = salaryHistory.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key));

      final periodStart = DateTime(currentYear); // 1月1日
      final periodEnd = DateTime(currentYear, endMonth + 1, 0); // 当月最后一天

      // 计算每个工资调整时间段的收入
      for (var i = 0; i < sortedHistory.length; i++) {
        final currentEntry = sortedHistory[i];
        final nextEntry =
            i < sortedHistory.length - 1 ? sortedHistory[i + 1] : null;

        // 计算这个工资水平的生效时间段
        final effectiveStart = currentEntry.key.isBefore(periodStart)
            ? periodStart
            : currentEntry.key;

        // 对于变更日期，如果是月末，则这个月算作新工资
        DateTime effectiveEnd;
        if (nextEntry != null) {
          // 检查是否是月末（最后一天）
          final lastDayOfMonth =
              DateTime(nextEntry.key.year, nextEntry.key.month + 1, 0);
          DateTime adjustedNextEntryKey;
          if (nextEntry.key.day == lastDayOfMonth.day) {
            // 如果是月末，工资变更从下个月开始生效
            adjustedNextEntryKey =
                DateTime(nextEntry.key.year, nextEntry.key.month + 1);
          } else {
            // 如果不是月末，当月就开始生效新工资
            adjustedNextEntryKey = nextEntry.key;
          }
          effectiveEnd = adjustedNextEntryKey.isBefore(periodEnd)
              ? adjustedNextEntryKey
              : periodEnd;
        } else {
          effectiveEnd = periodEnd;
        }

        if (effectiveStart.isBefore(effectiveEnd) ||
            effectiveStart.isAtSameMomentAs(effectiveEnd)) {
          // 计算这个时间段的月数
          final monthsInPeriod =
              calculateMonthsBetween(effectiveStart, effectiveEnd);
          final periodIncome = currentEntry.value * monthsInPeriod;
          totalBasicIncome += periodIncome;
        }
      }
    } else {
      // 没有工资历史，使用当前工资
      totalBasicIncome = basicSalary * completedMonths;
    }

    // 计算津贴收入（假设津贴不变）
    final monthlyAllowance = housingAllowance +
        mealAllowance +
        transportationAllowance +
        otherAllowance +
        performanceBonus;
    final totalAllowanceIncome = monthlyAllowance * completedMonths;

    // 计算奖金收入
    var totalBonusIncome = 0.0;
    for (final bonus in bonuses) {
      var bonusPeriodIncome = 0.0;

      // 计算奖金在指定月份内的收入
      for (var month = startMonth; month <= endMonth; month++) {
        final date = DateTime(currentYear, month);
        if (bonus.startDate.isBefore(date) ||
            bonus.startDate.isAtSameMomentAs(date)) {
          if (bonus.endDate == null ||
              bonus.endDate!.isAfter(date) ||
              bonus.endDate!.isAtSameMomentAs(date)) {
            switch (bonus.frequency) {
              case BonusFrequency.monthly:
                bonusPeriodIncome += bonus.amount;
              case BonusFrequency.quarterly:
                if (month % 3 == 0) {
                  bonusPeriodIncome += bonus.amount;
                }
              case BonusFrequency.semiAnnual:
                if (month == 6 || month == 12) {
                  bonusPeriodIncome += bonus.amount;
                }
              case BonusFrequency.annual:
                if (month == 12) {
                  bonusPeriodIncome += bonus.amount;
                }
              case BonusFrequency.oneTime:
                // 一次性奖金：只在生效月份计算一次
                if (bonus.startDate.year == currentYear &&
                    bonus.startDate.month == month) {
                  bonusPeriodIncome += bonus.amount;
                }
            }
          }
        }
      }
      totalBonusIncome += bonusPeriodIncome;
    }

    final totalIncome =
        totalBasicIncome + totalAllowanceIncome + totalBonusIncome;

    // 计算累计个税（简化计算，这里只是估算）
    var totalTax = 0.0;
    for (var month = 1; month <= completedMonths; month++) {
      final monthIncome = basicSalary + monthlyAllowance;

      if (monthIncome > 0) {
        final taxableIncome = monthIncome -
            socialInsurance -
            housingFund -
            specialDeductionMonthly;
        if (taxableIncome > 0) {
          final tax = PersonalIncomeTaxService.calculateMonthlyTax(
            monthIncome,
            socialInsurance + housingFund,
            totalTax, // 前期已扣税款
            month - 1, // 月序
          );
          totalTax += tax;
        }
      }
    }

    // 加上奖金的税费
    final bonusTaxSummary = BonusTaxCalculator.calculateAnnualBonusTax(
      bonuses,
      currentYear,
      basicSalary + monthlyAllowance,
      socialInsurance + housingFund,
      specialDeductionMonthly,
      otherTaxFreeIncome / 12,
    );

    totalTax += bonusTaxSummary.totalTax;
    final netIncome = totalIncome - totalTax;

    return SalaryCalculationResult(
      basicIncome: totalBasicIncome,
      allowanceIncome: totalAllowanceIncome,
      bonusIncome: totalBonusIncome,
      totalIncome: totalIncome,
      totalTax: totalTax,
      netIncome: netIncome,
    );
  }

  /// 计算月税费
  static double calculateMonthlyTax({
    required double monthlyIncome,
    required double monthlyDeductions,
    required bool isMidYearMode,
    required double cumulativeIncome,
    required double cumulativeTax,
    required int remainingMonths,
    required double specialDeductionMonthly,
    required double otherTaxFreeMonthly,
  }) {
    if (monthlyIncome <= 0) return 0;

    if (isMidYearMode) {
      // 年中模式：基于累计数据计算
      return PersonalIncomeTaxService.calculateMonthlyTaxMidYear(
        monthlyIncome,
        monthlyDeductions,
        cumulativeIncome, // 累计应纳税所得额
        cumulativeTax, // 累计已预扣税款
        remainingMonths, // 剩余月份数
        specialDeductionMonthly: specialDeductionMonthly,
        otherTaxFreeMonthly: otherTaxFreeMonthly,
      );
    } else {
      // 标准模式：从年初开始计算
      return PersonalIncomeTaxService.calculateMonthlyTax(
        monthlyIncome,
        monthlyDeductions,
        0, // 假设之前没有预扣税款
        0, // 第一月
      );
    }
  }

  /// 计算详细专项附加扣除金额
  static double calculateDetailedDeductions({
    required int childrenCount,
    required int elderlyCount,
    required bool continuingEducation,
    required String educationType,
    required bool housingLoanInterest,
    required bool rentalHousing,
    required String cityLevel,
    required int infantCount,
    required bool personalPension,
    required double pensionContribution,
  }) {
    var total = 0.0;

    // 子女教育：每月1000元/子女
    total += childrenCount * 1000;

    // 赡养老人：每月2000元/人
    total += elderlyCount * 2000;

    // 继续教育
    if (continuingEducation) {
      if (educationType == 'degree') {
        total += 400; // 学历继续教育每月400元
      } else {
        total += 300; // 职业资格继续教育每月300元（3600/12）
      }
    }

    // 贷款利息：每月1000元
    if (housingLoanInterest) {
      total += 1000;
    }

    // 住房租金
    if (rentalHousing) {
      switch (cityLevel) {
        case 'first':
          total += 1500; // 一线城市
        case 'second':
          total += 1100; // 二线城市
        case 'third':
          total += 800; // 三线城市
      }
    }

    // 婴幼儿照护费：每月1000元/子女
    total += infantCount * 1000;

    // 个人养老金：实际缴费金额（不超过12000元/年）
    if (personalPension) {
      total += (pensionContribution / 12).clamp(0.0, 1000.0); // 每月不超过1000元
    }

    return total;
  }

  /// 获取租金金额描述
  static String getRentalAmount(String cityLevel) {
    switch (cityLevel) {
      case 'first':
        return '¥1,500/月（一线城市）';
      case 'second':
        return '¥1,100/月（二线城市）';
      case 'third':
        return '¥800/月（三线城市）';
      default:
        return '¥800/月';
    }
  }

  /// 计算收入汇总
  static SalaryCalculationResult calculateIncomeSummary({
    required double basicSalary,
    required double housingAllowance,
    required double mealAllowance,
    required double transportationAllowance,
    required double otherAllowance,
    required double performanceBonus,
    required double otherBonuses,
    required double personalIncomeTax,
    required double socialInsurance,
    required double housingFund,
    required double otherDeductions,
    required List<BonusItem> bonuses,
  }) {
    // 计算月收入（不含一次性收入）
    final monthlyIncome = basicSalary +
        housingAllowance +
        mealAllowance +
        transportationAllowance +
        otherAllowance +
        performanceBonus;

    // 计算年度奖金总额
    final annualBonuses = bonuses.fold(
      0.0,
      (sum, bonus) => sum + bonus.calculateAnnualBonus(DateTime.now().year),
    );

    final grossIncome = monthlyIncome + otherBonuses + annualBonuses;

    // 计算奖金税收
    final bonusTaxSummary = BonusTaxCalculator.calculateAnnualBonusTax(
      bonuses,
      DateTime.now().year,
      monthlyIncome,
      socialInsurance + housingFund,
      5000, // 默认专项附加扣除
      0, // 其他免税收入
    );

    final totalDeductions = personalIncomeTax +
        socialInsurance +
        housingFund +
        otherDeductions +
        bonusTaxSummary.totalTax;

    final netIncome = grossIncome - totalDeductions;

    return SalaryCalculationResult(
      basicIncome: monthlyIncome,
      allowanceIncome: 0, // 津贴已包含在monthlyIncome中
      bonusIncome: annualBonuses,
      totalIncome: grossIncome,
      totalTax: totalDeductions,
      netIncome: netIncome,
    );
  }
}

// 奖金税收计算器（需要从personal_income_tax_service中导入）
class BonusTaxCalculator {
  static dynamic calculateAnnualBonusTax(
    List<BonusItem> bonuses,
    int currentYear,
    double monthlyIncome,
    double monthlyDeductions,
    double specialDeductionMonthly,
    double otherTaxFreeMonthly,
  ) {
    // 这里需要调用实际的奖金税收计算逻辑
    // 暂时返回一个模拟的结果
    return _MockBonusTaxResult(
      totalTax: bonuses.fold(0.0, (sum, bonus) => sum + bonus.amount * 0.1),
      netBonus: bonuses.fold(0.0, (sum, bonus) => sum + bonus.amount * 0.9),
    );
  }
}

class _MockBonusTaxResult {
  const _MockBonusTaxResult({
    required this.totalTax,
    required this.netBonus,
  });
  final double totalTax;
  final double netBonus;
}
