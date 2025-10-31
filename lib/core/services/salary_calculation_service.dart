import 'package:your_finance_flutter/core/models/bonus_item.dart';
import 'package:your_finance_flutter/core/models/budget.dart';
import 'package:your_finance_flutter/core/services/logging_service.dart';
import 'package:your_finance_flutter/core/services/personal_income_tax_service.dart';
import 'package:your_finance_flutter/core/utils/logger.dart';



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

  /// 计算指定月份的津贴收入
  /// @param salaryIncome 工资收入对象
  /// @param month 月份 (1-12)
  /// @return 该月份的津贴收入
  static double calculateMonthlyAllowance(SalaryIncome salaryIncome, int month) {
    // 检查是否有该月份的特殊津贴记录
    if (salaryIncome.monthlyAllowances != null &&
        salaryIncome.monthlyAllowances!.containsKey(month)) {
      final allowanceRecord = salaryIncome.monthlyAllowances![month]!;
      return allowanceRecord.totalAllowance;
    }

    // 使用默认津贴
    return salaryIncome.housingAllowance +
        salaryIncome.mealAllowance +
        salaryIncome.transportationAllowance +
        salaryIncome.otherAllowance;
  }

  /// 获取指定月份的津贴明细
  /// @param salaryIncome 工资收入对象
  /// @param month 月份 (1-12)
  /// @return 该月份的津贴记录
  static AllowanceRecord getMonthlyAllowanceRecord(
      SalaryIncome salaryIncome, int month) {
    // 检查是否有该月份的特殊津贴记录
    if (salaryIncome.monthlyAllowances != null &&
        salaryIncome.monthlyAllowances!.containsKey(month)) {
      return salaryIncome.monthlyAllowances![month]!;
    }

    // 使用默认津贴
    return AllowanceRecord.defaultAllowance(
      housingAllowance: salaryIncome.housingAllowance,
      mealAllowance: salaryIncome.mealAllowance,
      transportationAllowance: salaryIncome.transportationAllowance,
      otherAllowance: salaryIncome.otherAllowance,
    );
  }

  /// 计算自动累计收入（用于年中模式）
  static Future<SalaryCalculationResult> calculateAutoCumulative({
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
    Map<int, AllowanceRecord>? monthlyAllowances, // 月度津贴记录
  }) async {
    final logger = LoggingService();
    await logger.initialize();
    
    await logger.log('🧮 开始年度累积预扣法计算:');
    await logger.log('  完成月数: $completedMonths');
    await logger.log('  基本工资: $basicSalary');
    await logger.log('  住房补贴: $housingAllowance');
    await logger.log('  餐补: $mealAllowance');
    await logger.log('  交通补贴: $transportationAllowance');
    await logger.log('  其他补贴: $otherAllowance');
    await logger.log('  绩效奖金: $performanceBonus');
    await logger.log('  社保: $socialInsurance');
    await logger.log('  公积金: $housingFund');
    await logger.log('  专项附加扣除: $specialDeductionMonthly');
    await logger.log('  其他免税收入: $otherTaxFreeIncome');
    await logger.log('  奖金数量: ${bonuses.length}');
    
    for (var i = 0; i < bonuses.length; i++) {
      final bonus = bonuses[i];
      await logger.log('  奖金${i + 1}: ${bonus.name}, 类型=${bonus.type}, 金额=${bonus.amount}');
      if (bonus.type == BonusType.quarterlyBonus) {
        await logger.log('    季度奖金发放月份: ${bonus.quarterlyPaymentMonths}');
      }
    }

    final currentYear = DateTime.now().year;
    const startMonth = 1; // 从1月开始
    final endMonth = completedMonths;

    // 计算基本收入（考虑工资历史调整）
    var totalBasicIncome = 0.0;

    // 如果有工资历史记录，则按时间段计算，否则使用当前工资
    if (salaryHistory.isNotEmpty) {
      Logger.debug('  存在工资历史记录，按时间段计算');
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
          Logger.debug('    时间段: ${effectiveStart} 到 ${effectiveEnd}, 月数: $monthsInPeriod, 收入: $periodIncome');
        }
      }
    } else {
      // 没有工资历史，使用当前工资
      totalBasicIncome = basicSalary * completedMonths;
      Logger.debug('  无工资历史记录，使用当前工资: $basicSalary * $completedMonths = $totalBasicIncome');
    }

    // 计算津贴收入（考虑月度津贴变化）
    var totalAllowanceIncome = 0.0;
    Logger.debug('  开始计算津贴收入:');
    for (var month = 1; month <= completedMonths; month++) {
      // 计算指定月份的津贴
      double monthlyAllowance;
      if (monthlyAllowances != null && monthlyAllowances.containsKey(month)) {
        // 使用月度特殊津贴
        final allowanceRecord = monthlyAllowances[month]!;
        monthlyAllowance = allowanceRecord.totalAllowance;
        Logger.debug('    ${month}月津贴 (特殊): ¥${monthlyAllowance.toStringAsFixed(0)}');
      } else {
        // 使用默认津贴
        monthlyAllowance = housingAllowance +
            mealAllowance +
            transportationAllowance +
            otherAllowance;
        Logger.debug('    ${month}月津贴 (默认): ¥${monthlyAllowance.toStringAsFixed(0)}');
      }
      totalAllowanceIncome += monthlyAllowance;
    }
    Logger.debug('  津贴总收入: $totalAllowanceIncome');

    // 计算奖金收入
    var totalBonusIncome = 0.0;
    Logger.debug('  开始计算奖金收入:');
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
            final monthlyBonus = bonus.calculateMonthlyBonus(currentYear, month);
            bonusPeriodIncome += monthlyBonus;
            if (monthlyBonus > 0) {
              Logger.debug('    ${bonus.name} 在 ${month}月 发放: $monthlyBonus');
            }
          }
        }
      }
      totalBonusIncome += bonusPeriodIncome;
      Logger.debug('    ${bonus.name} 总收入: $bonusPeriodIncome');
    }
    Logger.debug('  奖金总收入: $totalBonusIncome');

    // 计算年度五险一金和专项附加扣除
    final annualSocialInsurance = socialInsurance * completedMonths;
    final annualHousingFund = housingFund * completedMonths;
    final annualSpecialDeduction =
        (specialDeductionMonthly * completedMonths) + otherTaxFreeIncome;
    Logger.debug('  年度社保: $annualSocialInsurance');
    Logger.debug('  年度公积金: $annualHousingFund');
    Logger.debug('  年度专项附加扣除: $annualSpecialDeduction');

    // 计算累计个税（使用年度累积预扣法）
    var totalTax = 0.0;
    var cumulativeTaxableIncome = 0.0; // 累计应纳税所得额
    var cumulativeTax = 0.0; // 累计已预扣税款
    
    Logger.debug('  开始年度累积预扣法计算个税:');
    for (var month = 1; month <= completedMonths; month++) {
      // 计算当月收入（基本工资+津贴）
      final monthBasicIncome = basicSalary; // 基本工资通常不变
      
      // 计算指定月份的津贴
      double monthAllowanceIncome;
      if (monthlyAllowances != null && monthlyAllowances.containsKey(month)) {
        // 使用月度特殊津贴
        final allowanceRecord = monthlyAllowances[month]!;
        monthAllowanceIncome = allowanceRecord.totalAllowance;
      } else {
        // 使用默认津贴
        monthAllowanceIncome = housingAllowance +
            mealAllowance +
            transportationAllowance +
            otherAllowance;
      }
      
      final monthTotalIncome = monthBasicIncome + monthAllowanceIncome;
      
      // 计算当月奖金
      var monthBonusIncome = 0.0;
      for (final bonus in bonuses) {
        final monthlyBonus = bonus.calculateMonthlyBonus(currentYear, month);
        monthBonusIncome += monthlyBonus;
        if (monthlyBonus > 0) {
          Logger.debug('    ${month}月奖金: ${bonus.name} = $monthlyBonus');
        }
      }
      
      // 当月总收入（含奖金）
      final monthGrossIncome = monthTotalIncome + monthBonusIncome;
      
      // 计算当月扣除项
      final monthDeductions = socialInsurance + housingFund;
      final monthSpecialDeduction = specialDeductionMonthly;
      
      // 计算当月应纳税所得额
      final monthTaxableIncome = PersonalIncomeTaxService.calculateTaxableIncome(
        monthGrossIncome,
        monthDeductions,
        monthSpecialDeduction,
        0, // otherTaxFreeMonthly 暂时不支持
      );
      
      // 累计应纳税所得额
      cumulativeTaxableIncome += monthTaxableIncome;
      
      // 计算年度累计应纳税额
      final annualTax = PersonalIncomeTaxService.calculateAnnualTax(cumulativeTaxableIncome);
      
      // 计算当月应预扣税额
      final monthTax = annualTax - cumulativeTax;
      
      // 累计已预扣税款
      cumulativeTax += monthTax;
      
      totalTax += monthTax > 0 ? monthTax : 0;
      
      Logger.debug('    ${month}月: 收入=$monthGrossIncome, 扣除=$monthDeductions, 专项扣除=$monthSpecialDeduction, 应税所得=$monthTaxableIncome, 累计应税=$cumulativeTaxableIncome, 年度税额=$annualTax, 当月税额=$monthTax, 累计税额=$cumulativeTax');
    }

    // 奖金税收单独计算（年终奖等特殊奖金）
    var bonusTaxTotal = 0.0;
    Logger.debug('  开始计算奖金税收:');
    for (final bonus in bonuses) {
      // 只有年终奖使用单独计税方法
      if (bonus.type == BonusType.yearEndBonus && bonus.frequency == BonusFrequency.oneTime) {
        final yearEndTax = PersonalIncomeTaxService.calculateYearEndBonusTax(bonus.amount);
        bonusTaxTotal += yearEndTax;
        Logger.debug('    ${bonus.name} (年终奖) 税收: $yearEndTax');
      }
      // 其他奖金已在年度累积预扣法中计算
    }

    totalTax += bonusTaxTotal;
    Logger.debug('  奖金税收总计: $bonusTaxTotal');
    Logger.debug('  总税收: $totalTax');

    // 总收入 = 基本工资+津贴 + 奖金
    final totalIncome = totalBasicIncome + totalAllowanceIncome + totalBonusIncome;
    final netIncome = totalIncome - totalTax;

    Logger.debug('🧮 年度累积计算完成:');
    Logger.debug('  基本收入: $totalBasicIncome');
    Logger.debug('  津贴收入: $totalAllowanceIncome');
    Logger.debug('  奖金收入: $totalBonusIncome');
    Logger.debug('  总收入: $totalIncome');
    Logger.debug('  总税费: $totalTax');
    Logger.debug('  净收入: $netIncome');

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
  static Future<SalaryCalculationResult> calculateIncomeSummary({
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
    Map<int, AllowanceRecord>? monthlyAllowances, // 月度津贴记录
  }) async {
    final logger = LoggingService();
    await logger.initialize();
    
    await logger.log('🧮 开始计算收入汇总:');
    await logger.log('  基本工资: $basicSalary');
    await logger.log('  住房补贴: $housingAllowance');
    await logger.log('  餐补: $mealAllowance');
    await logger.log('  交通补贴: $transportationAllowance');
    await logger.log('  其他补贴: $otherAllowance');
    await logger.log('  绩效奖金: $performanceBonus');
    await logger.log('  其他奖金: $otherBonuses');
    await logger.log('  个税: $personalIncomeTax');
    await logger.log('  社保: $socialInsurance');
    await logger.log('  公积金: $housingFund');
    await logger.log('  其他扣除: $otherDeductions');
    await logger.log('  奖金数量: ${bonuses.length}');
    
    for (var i = 0; i < bonuses.length; i++) {
      final bonus = bonuses[i];
      await logger.log('  奖金${i + 1}: ${bonus.name}, 类型=${bonus.type}, 金额=${bonus.amount}');
      if (bonus.type == BonusType.quarterlyBonus) {
        await logger.log('    季度奖金发放月份: ${bonus.quarterlyPaymentMonths}');
      }
    }

    // 计算月收入（不含一次性收入，考虑月度津贴变化）
    var totalMonthlyIncome = 0.0;
    for (var month = 1; month <= 12; month++) {
      // 计算指定月份的津贴
      double monthAllowanceIncome;
      if (monthlyAllowances != null && monthlyAllowances.containsKey(month)) {
        // 使用月度特殊津贴
        final allowanceRecord = monthlyAllowances[month]!;
        monthAllowanceIncome = allowanceRecord.totalAllowance;
      } else {
        // 使用默认津贴
        monthAllowanceIncome = housingAllowance +
            mealAllowance +
            transportationAllowance +
            otherAllowance +
            performanceBonus;
      }
      totalMonthlyIncome += basicSalary + monthAllowanceIncome;
    }
    
    await logger.log('  月收入总额(基本+津贴): $totalMonthlyIncome');

    // 计算年度奖金总额
    final annualBonuses = bonuses.fold(
      0.0,
      (sum, bonus) => sum + bonus.calculateAnnualBonus(DateTime.now().year),
    );
    
    await logger.log('  年度奖金总额: $annualBonuses');

    // 总收入 = 月收入 + 奖金
    final grossIncome = totalMonthlyIncome + otherBonuses + annualBonuses;
    await logger.log('  总收入: $grossIncome');

    // 使用传入的税费（因为这是预览界面传入的计算结果）
    final totalTax = personalIncomeTax;
    await logger.log('  总税费: $totalTax');

    // 总扣除 = 税费 + 社保*12 + 公积金*12 + 其他扣除*12
    final totalDeductions = totalTax +
        socialInsurance * 12 +
        housingFund * 12 +
        otherDeductions * 12;
        
    await logger.log('  总扣除: $totalDeductions');

    final netIncome = grossIncome - totalDeductions;
    await logger.log('  净收入: $netIncome');

    return SalaryCalculationResult(
      basicIncome: totalMonthlyIncome - (housingAllowance + mealAllowance + transportationAllowance + otherAllowance + performanceBonus) * 12, // 年度基本收入
      allowanceIncome: totalMonthlyIncome - basicSalary * 12, // 年度津贴收入
      bonusIncome: annualBonuses + otherBonuses, // 奖金收入
      totalIncome: grossIncome,
      totalTax: totalTax,
      netIncome: netIncome,
    );
  }
}
