import 'package:your_finance_flutter/core/models/bonus_item.dart';
import 'package:your_finance_flutter/core/services/personal_income_tax_service.dart';

// 奖金税收计算器（从personal_income_tax_service中导入使用）
class BonusTaxCalculator {
  static BonusTaxSummary calculateAnnualBonusTax(
    List<BonusItem> bonuses,
    int currentYear,
    double monthlyIncome,
    double monthlyDeductions,
    double specialDeductionMonthly,
    double otherTaxFreeMonthly,
  ) {
    // 这里需要调用实际的奖金税收计算逻辑
    // 暂时返回一个模拟的结果，等待BonusTaxCalculator类被正确导入
    return BonusTaxSummary(
      yearEndBonus: 0,
      yearEndTax: 0,
      quarterlyBonus: 0,
      quarterlyTax: 0,
      thirteenthSalary: 0,
      thirteenthTax: 0,
      otherBonus: 0,
      otherTax: 0,
      totalBonus: bonuses.fold(0.0, (sum, bonus) => sum + bonus.amount),
      totalTax: bonuses.fold(0.0, (sum, bonus) => sum + bonus.amount * 0.1),
      netBonus: bonuses.fold(0.0, (sum, bonus) => sum + bonus.amount * 0.9),
    );
  }
}

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
    required double otherTaxFreeMonthly,
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
            // 使用BonusItem的计算方法，计算指定月份的奖金
            bonusPeriodIncome +=
                bonus.calculateMonthlyBonus(currentYear, month);
          }
        }
      }
      totalBonusIncome += bonusPeriodIncome;
    }

    // 计算年度五险一金和专项附加扣除
    final annualSocialInsurance = socialInsurance * completedMonths;
    final annualHousingFund = housingFund * completedMonths;
    final annualSpecialDeduction =
        (specialDeductionMonthly * completedMonths) + otherTaxFreeIncome;

    // 计算累计个税（只计算基本工资+津贴，不含奖金）
    var totalTax = 0.0;
    for (var month = 1; month <= completedMonths; month++) {
      final monthIncome = basicSalary + monthlyAllowance; // 不含奖金

      if (monthIncome > 0) {
        // 计算月度应纳税所得额
        final monthlySocialInsurance = socialInsurance;
        final monthlyHousingFund = housingFund;
        final monthlySpecialDeduction =
            specialDeductionMonthly + (otherTaxFreeIncome / 12);

        final taxableIncome = monthIncome -
            monthlySocialInsurance -
            monthlyHousingFund -
            monthlySpecialDeduction;

        if (taxableIncome > 0) {
          final tax = PersonalIncomeTaxService.calculateMonthlyTax(
            monthIncome,
            monthlySocialInsurance + monthlyHousingFund,
            totalTax, // 前期已扣税款
            month - 1, // 月序
          );
          totalTax += tax;
        }
      }
    }

    // 奖金税收单独计算（不与工资合并计税）
    var bonusTaxTotal = 0.0;
    for (final bonus in bonuses) {
      if (bonus.type == BonusType.yearEndBonus) {
        // 年终奖：单独计税，使用年终奖税率
        final yearEndTax =
            PersonalIncomeTaxService.calculateYearEndBonusTax(bonus.amount);
        bonusTaxTotal += yearEndTax;
      } else if (bonus.type == BonusType.quarterlyBonus) {
        // 季度奖金：与工资合并计税，但单独计算
        // 这里应该按照季度发放的时间点计算税费
        final quarterlyTax = bonus.amount * 0.1; // 简化为10%税率，实际应该更精确
        bonusTaxTotal += quarterlyTax;
      } else {
        // 其他奖金：按照普通奖金税率计算
        final otherTax = bonus.amount * 0.1; // 简化为10%税率，实际应该更精确
        bonusTaxTotal += otherTax;
      }
    }

    totalTax += bonusTaxTotal;

    // 总收入 = 基本工资+津贴 + 奖金
    final totalIncome =
        totalBasicIncome + totalAllowanceIncome + totalBonusIncome;
    final netIncome = totalIncome - totalTax;

    return SalaryCalculationResult(
      basicIncome: totalBasicIncome,
      allowanceIncome: totalAllowanceIncome,
      bonusIncome: totalBonusIncome,
      totalIncome: totalIncome,
      totalTax: totalTax, // 已经包含了工资税 + 奖金税
      netIncome: netIncome,
    );
  }

  /// 计算月税费（简化版）
  static double calculateMonthlyTax({
    required double monthlyIncome,
    required double monthlyDeductions,
    required double specialDeductionMonthly,
    required double otherTaxFreeMonthly,
  }) {
    if (monthlyIncome <= 0) return 0;

    // 计算月度应纳税所得额（包含专项附加扣除）
    final monthlyTaxableIncome =
        PersonalIncomeTaxService.calculateTaxableIncome(
      monthlyIncome,
      monthlyDeductions,
      specialDeductionMonthly,
      otherTaxFreeMonthly,
    );

    // 简化计算：使用年度税率表估算月度税费
    // 这里使用当月收入乘以平均税率作为估算
    final estimatedAnnualTaxableIncome = monthlyTaxableIncome * 12;
    final annualTax = PersonalIncomeTaxService.calculateAnnualTax(
      estimatedAnnualTaxableIncome,
    );
    final monthlyTax = annualTax / 12;

    return monthlyTax > 0 ? monthlyTax : 0;
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

    // 总收入 = 基本工资+津贴 + 奖金
    final grossIncome = monthlyIncome + otherBonuses + annualBonuses;

    // 计算工资税收（不含奖金）
    final salaryTax = PersonalIncomeTaxService.calculateMonthlyTax(
      monthlyIncome, // 只计算工资部分
      socialInsurance + housingFund,
      0, // 假设这是第一月
      0, // 月序
    );

    // 计算奖金税收（单独计税）
    var bonusTaxTotal = 0.0;
    for (final bonus in bonuses) {
      if (bonus.type == BonusType.yearEndBonus) {
        // 年终奖：单独计税
        final yearEndTax =
            PersonalIncomeTaxService.calculateYearEndBonusTax(bonus.amount);
        bonusTaxTotal += yearEndTax;
      } else if (bonus.type == BonusType.quarterlyBonus) {
        // 季度奖金：单独计税
        final quarterlyTax = bonus.amount * 0.1; // 简化为10%税率
        bonusTaxTotal += quarterlyTax;
      } else {
        // 其他奖金：单独计税
        final otherTax = bonus.amount * 0.1; // 简化为10%税率
        bonusTaxTotal += otherTax;
      }
    }

    final totalDeductions = salaryTax +
        socialInsurance +
        housingFund +
        otherDeductions +
        bonusTaxTotal;

    final netIncome = grossIncome - totalDeductions;

    return SalaryCalculationResult(
      basicIncome: monthlyIncome,
      allowanceIncome: 0, // 津贴已包含在monthlyIncome中
      bonusIncome: annualBonuses,
      totalIncome: grossIncome,
      totalTax: salaryTax + bonusTaxTotal, // 工资税 + 奖金税
      netIncome: netIncome,
    );
  }
}
