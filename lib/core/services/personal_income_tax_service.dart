import 'package:your_finance_flutter/core/models/bonus_item.dart';

/// 中国个人所得税计算服务
/// 根据2021年最新税率表实现自动计算功能
class PersonalIncomeTaxService {
  /// 个人所得税税率阶梯（工资薪金）
  static const List<TaxBracket> _taxBrackets = [
    TaxBracket(threshold: 0, rate: 0.03, deduction: 0),
    TaxBracket(threshold: 36000, rate: 0.10, deduction: 2520),
    TaxBracket(threshold: 144000, rate: 0.20, deduction: 16920),
    TaxBracket(threshold: 300000, rate: 0.25, deduction: 31920),
    TaxBracket(threshold: 420000, rate: 0.30, deduction: 52920),
    TaxBracket(threshold: 660000, rate: 0.35, deduction: 85920),
    TaxBracket(threshold: 960000, rate: 0.45, deduction: 181920),
  ];

  /// 年终奖专用税率阶梯
  static const List<TaxBracket> _yearEndBonusTaxBrackets = [
    TaxBracket(threshold: 0, rate: 0.03, deduction: 0),
    TaxBracket(threshold: 3000, rate: 0.10, deduction: 210),
    TaxBracket(threshold: 12000, rate: 0.20, deduction: 1410),
    TaxBracket(threshold: 25000, rate: 0.25, deduction: 2660),
    TaxBracket(threshold: 35000, rate: 0.30, deduction: 4410),
    TaxBracket(threshold: 55000, rate: 0.35, deduction: 7160),
    TaxBracket(threshold: 80000, rate: 0.45, deduction: 15160),
  ];

  /// 计算年度应纳税所得额
  /// 根据公式：本年应税收入合计 = 本年收入合计 - 本年起征点合计 - 累计扣除合计本年 - 本年其他免税合计
  /// @param annualIncome 年收入总额
  /// @param deductions 年扣除项总额（五险一金等）
  /// @param specialDeductionAnnual 年专项附加扣除总额
  /// @param otherTaxFreeIncome 年其他免税收入总额
  /// @return 应纳税所得额
  static double calculateTaxableIncome(
    double annualIncome,
    double deductions,
    double specialDeductionAnnual,
    double otherTaxFreeIncome,
  ) {
    // 本年应税收入合计 = 本年收入合计 - 本年起征点合计 - 累计扣除合计本年 - 本年其他免税合计
    final taxableIncome =
        annualIncome - deductions - specialDeductionAnnual - otherTaxFreeIncome;
    return taxableIncome > 0 ? taxableIncome : 0;
  }

  /// 计算年度个人所得税
  /// @param annualTaxableIncome 年应纳税所得额
  /// @return 年度应纳税额
  static double calculateAnnualTax(double annualTaxableIncome) {
    if (annualTaxableIncome <= 0) return 0;

    // 找到适用的税率阶梯
    for (var i = _taxBrackets.length - 1; i >= 0; i--) {
      final bracket = _taxBrackets[i];
      if (annualTaxableIncome > bracket.threshold) {
        // 计算应纳税额
        final taxableAmount = annualTaxableIncome - bracket.threshold;
        return taxableAmount * bracket.rate + bracket.deduction;
      }
    }

    return 0;
  }

  /// 计算月度个人所得税预扣预缴（标准模式）
  /// @param monthlyIncome 月收入
  /// @param monthlyDeductions 月扣除项
  /// @param previousMonthTax 本年已预扣税款
  /// @param previousMonths 月数（不含当月）
  /// @return 月度应预扣税额
  static double calculateMonthlyTax(
    double monthlyIncome,
    double monthlyDeductions,
    double previousMonthTax,
    int previousMonths,
  ) {
    // 计算当月应纳税所得额
    final monthlyTaxableIncome =
        calculateTaxableIncome(monthlyIncome, monthlyDeductions, 0, 0);

    // 计算本年累计应纳税所得额
    final annualTaxableIncome = monthlyTaxableIncome * (previousMonths + 1);

    // 计算本年累计应纳税额
    final annualTax = calculateAnnualTax(annualTaxableIncome);

    // 计算本年已预扣税款
    final totalPreviousTax = previousMonthTax * previousMonths;

    // 计算当月应预扣税额
    final monthlyTax = annualTax - totalPreviousTax;

    return monthlyTax > 0 ? monthlyTax : 0;
  }

  /// 计算月度个人所得税预扣预缴（年中开始模式）
  /// @param monthlyIncome 月收入
  /// @param monthlyDeductions 月扣除项
  /// @param cumulativeTaxableIncome 本年累计应纳税所得额（包含当月）
  /// @param cumulativeTax 本年累计已预扣税款
  /// @param remainingMonths 剩余月数（不含当月）
  /// @param specialDeductionMonthly 月专项附加扣除
  /// @param otherTaxFreeMonthly 月其他免税收入
  /// @return 月度应预扣税额
  static double calculateMonthlyTaxMidYear(
    double monthlyIncome,
    double monthlyDeductions,
    double cumulativeTaxableIncome,
    double cumulativeTax,
    int remainingMonths, {
    double specialDeductionMonthly = 0,
    double otherTaxFreeMonthly = 0,
  }) {
    // 计算当月应纳税所得额
    final monthlyTaxableIncome = calculateTaxableIncome(
      monthlyIncome,
      monthlyDeductions,
      specialDeductionMonthly * 12,
      otherTaxFreeMonthly * 12,
    );

    // 计算全年累计应纳税所得额
    final annualTaxableIncome =
        cumulativeTaxableIncome + (monthlyTaxableIncome * remainingMonths);

    // 计算全年应纳税额
    final annualTax = calculateAnnualTax(annualTaxableIncome);

    // 计算当月应预扣税额
    final monthlyTax = annualTax - cumulativeTax;

    return monthlyTax > 0 ? monthlyTax : 0;
  }

  /// 计算全年税款分布
  /// @param annualIncome 年收入
  /// @param annualDeductions 年扣除项
  /// @return 每月税款列表
  static List<double> calculateAnnualTaxDistribution(
    double annualIncome,
    double annualDeductions,
  ) {
    final monthlyIncome = annualIncome / 12;
    final monthlyDeductions = annualDeductions / 12;

    final monthlyTaxes = <double>[];
    var previousMonthTax = 0.0;

    for (var month = 0; month < 12; month++) {
      final monthlyTax = calculateMonthlyTax(
        monthlyIncome,
        monthlyDeductions,
        previousMonthTax,
        month,
      );
      monthlyTaxes.add(monthlyTax);
      previousMonthTax = monthlyTax;
    }

    return monthlyTaxes;
  }

  /// 获取税率阶梯信息（用于显示）
  static List<TaxBracket> getTaxBrackets() => _taxBrackets;

  /// 获取当前适用的税率信息
  /// @param annualTaxableIncome 年应纳税所得额
  /// @return 当前适用的税率阶梯
  static TaxBracket getApplicableTaxBracket(double annualTaxableIncome) {
    for (var i = _taxBrackets.length - 1; i >= 0; i--) {
      if (annualTaxableIncome > _taxBrackets[i].threshold) {
        return _taxBrackets[i];
      }
    }
    return _taxBrackets.first;
  }

  /// 计算税后收入
  /// @param grossIncome 税前收入
  /// @param taxAmount 税额
  /// @return 税后收入
  static double calculateNetIncome(double grossIncome, double taxAmount) =>
      grossIncome - taxAmount;

  /// 计算年终奖个人所得税
  /// 年终奖计税方法：年终奖 ÷ 12，适用年终奖专用月度税率表，税额 × 12
  /// @param yearEndBonus 年终奖金额
  /// @return 年终奖应纳税额
  static double calculateYearEndBonusTax(double yearEndBonus) {
    if (yearEndBonus <= 0) return 0;

    // 年终奖按月均分计算
    final monthlyBonus = yearEndBonus / 12;

    // 找到适用的税率阶梯（使用年终奖专用税率阶梯）
    for (var i = _yearEndBonusTaxBrackets.length - 1; i >= 0; i--) {
      final bracket = _yearEndBonusTaxBrackets[i];
      if (monthlyBonus > bracket.threshold) {
        // 计算应纳税额（月税额 × 12）
        final monthlyTax = (monthlyBonus - bracket.threshold) * bracket.rate +
            bracket.deduction;
        return monthlyTax * 12;
      }
    }

    return 0;
  }

  /// 计算一次性奖金个人所得税
  /// @param bonusAmount 奖金金额
  /// @param bonusType 奖金类型 ('year-end':年终奖, 'quarterly':季度奖金, 'other':其他奖金)
  /// @return 奖金应纳税额
  static double calculateBonusTax(double bonusAmount, String bonusType) {
    if (bonusAmount <= 0) return 0;

    switch (bonusType) {
      case 'year-end':
        return calculateYearEndBonusTax(bonusAmount);
      case 'quarterly':
      case 'other':
      default:
        // 其他奖金按当月收入累加计算
        return calculateMonthlyTax(bonusAmount, 0, 0, 0);
    }
  }

  /// 计算全年奖金分布和税收
  /// @param yearEndBonus 年终奖
  /// @param quarterlyBonus 季度奖金
  /// @param thirteenthSalary 十三薪
  /// @return 包含税收信息的奖金汇总
  static BonusTaxSummary calculateBonusTaxSummary({
    double yearEndBonus = 0,
    double quarterlyBonus = 0,
    double thirteenthSalary = 0,
    double otherBonus = 0,
  }) {
    final yearEndTax = calculateBonusTax(yearEndBonus, 'year-end');
    final quarterlyTax = calculateBonusTax(quarterlyBonus, 'quarterly');
    final thirteenthTax = calculateMonthlyTax(thirteenthSalary, 0, 0, 0);
    final otherTax = calculateBonusTax(otherBonus, 'other');

    final totalBonus =
        yearEndBonus + quarterlyBonus + thirteenthSalary + otherBonus;
    final totalTax = yearEndTax + quarterlyTax + thirteenthTax + otherTax;
    final netBonus = totalBonus - totalTax;

    return BonusTaxSummary(
      yearEndBonus: yearEndBonus,
      yearEndTax: yearEndTax,
      quarterlyBonus: quarterlyBonus,
      quarterlyTax: quarterlyTax,
      thirteenthSalary: thirteenthSalary,
      thirteenthTax: thirteenthTax,
      otherBonus: otherBonus,
      otherTax: otherTax,
      totalBonus: totalBonus,
      totalTax: totalTax,
      netBonus: netBonus,
    );
  }
}

/// 税率阶梯类
class TaxBracket {
  const TaxBracket({
    required this.threshold,
    required this.rate,
    required this.deduction,
  });

  /// 阶梯起征点
  final double threshold;

  /// 税率
  final double rate;

  /// 速算扣除数
  final double deduction;

  /// 获取阶梯描述
  String get description {
    if (threshold == 0) {
      return '不超过${threshold.toInt()}元';
    }
    return '超过${threshold.toInt()}元的部分';
  }

  /// 获取税率百分比字符串
  String get ratePercentage => '${(rate * 100).toInt()}%';

  @override
  String toString() =>
      'TaxBracket(threshold: $threshold, rate: $rate, deduction: $deduction)';
}

/// 个人所得税计算结果
class TaxCalculationResult {
  const TaxCalculationResult({
    required this.annualTaxableIncome,
    required this.annualTax,
    required this.monthlyTaxes,
    required this.applicableBracket,
    required this.netIncome,
  });

  /// 年应纳税所得额
  final double annualTaxableIncome;

  /// 年应纳税额
  final double annualTax;

  /// 每月税款分布
  final List<double> monthlyTaxes;

  /// 适用的税率阶梯
  final TaxBracket applicableBracket;

  /// 税后收入
  final double netIncome;

  /// 获取平均月税额
  double get averageMonthlyTax =>
      monthlyTaxes.isNotEmpty ? annualTax / monthlyTaxes.length : 0;

  /// 获取当前月税额（最后一月）
  double get currentMonthTax => monthlyTaxes.isNotEmpty ? monthlyTaxes.last : 0;
}

/// 奖金税收汇总类
class BonusTaxSummary {
  const BonusTaxSummary({
    required this.yearEndBonus,
    required this.yearEndTax,
    required this.quarterlyBonus,
    required this.quarterlyTax,
    required this.thirteenthSalary,
    required this.thirteenthTax,
    required this.otherBonus,
    required this.otherTax,
    required this.totalBonus,
    required this.totalTax,
    required this.netBonus,
  });

  /// 年终奖金额
  final double yearEndBonus;

  /// 年终奖税收
  final double yearEndTax;

  /// 季度奖金金额
  final double quarterlyBonus;

  /// 季度奖金税收
  final double quarterlyTax;

  /// 十三薪金额
  final double thirteenthSalary;

  /// 十三薪税收
  final double thirteenthTax;

  /// 其他奖金金额
  final double otherBonus;

  /// 其他奖金税收
  final double otherTax;

  /// 奖金总额
  final double totalBonus;

  /// 税收总额
  final double totalTax;

  /// 税后奖金总额
  final double netBonus;

  /// 获取年终奖税后金额
  double get netYearEndBonus => yearEndBonus - yearEndTax;

  /// 获取季度奖金税后金额
  double get netQuarterlyBonus => quarterlyBonus - quarterlyTax;

  /// 获取十三薪税后金额
  double get netThirteenthSalary => thirteenthSalary - thirteenthTax;

  /// 获取其他奖金税后金额
  double get netOtherBonus => otherBonus - otherTax;

  @override
  String toString() => 'BonusTaxSummary('
      'totalBonus: ¥${totalBonus.toStringAsFixed(0)}, '
      'totalTax: ¥${totalTax.toStringAsFixed(0)}, '
      'netBonus: ¥${netBonus.toStringAsFixed(0)})';
}

/// 计算基于奖金项目的税费
class BonusTaxCalculator {
  /// 计算指定年份的所有奖金税费
  static BonusTaxSummary calculateAnnualBonusTax(
    List<BonusItem> bonuses,
    int year,
    double monthlyIncome, // 月基本工资+津贴
    double monthlyDeductions, // 月五险一金
    double specialDeductionMonthly, // 月专项附加扣除
    double otherTaxFreeMonthly, // 月其他免税收入
  ) {
    print('🏆 开始计算年度奖金税费: year=$year, bonuses=${bonuses.length}个');
    print('  月收入: $monthlyIncome');
    print('  月扣除: $monthlyDeductions');
    print('  月专项扣除: $specialDeductionMonthly');
    var totalBonus = 0.0;
    var totalTax = 0.0;

    // 分别计算不同类型的奖金税费
    for (final bonus in bonuses) {
      print(
        '🎁 处理奖金: ${bonus.name}, 类型=${bonus.type}, 金额=${bonus.amount}, 频率=${bonus.frequency}',
      );
      if (bonus.type == BonusType.quarterlyBonus) {
        print('  季度奖金发放月份: ${bonus.quarterlyPaymentMonths}');
      }
      final annualBonusAmount = bonus.calculateAnnualBonus(year);
      print('📊 年度奖金金额: $annualBonusAmount');
      if (annualBonusAmount > 0) {
        totalBonus += annualBonusAmount;

        // 根据奖金类型计算税费
        final bonusTax = _calculateBonusTaxByType(
          bonus,
          annualBonusAmount,
          monthlyIncome,
          monthlyDeductions,
          specialDeductionMonthly,
          otherTaxFreeMonthly,
        );
        print('💸 奖金税费: $bonusTax');
        totalTax += bonusTax;
      }
    }

    print('📈 奖金汇总: 总奖金=$totalBonus, 总税费=$totalTax');

    return BonusTaxSummary(
      yearEndBonus: _getTotalBonusByType(bonuses, BonusType.yearEndBonus, year),
      yearEndTax: _calculateSpecificBonusTax(
        bonuses,
        BonusType.yearEndBonus,
        year,
        monthlyIncome,
        monthlyDeductions,
        specialDeductionMonthly,
        otherTaxFreeMonthly,
      ),
      quarterlyBonus:
          _getTotalBonusByType(bonuses, BonusType.quarterlyBonus, year),
      quarterlyTax: _calculateSpecificBonusTax(
        bonuses,
        BonusType.quarterlyBonus,
        year,
        monthlyIncome,
        monthlyDeductions,
        specialDeductionMonthly,
        otherTaxFreeMonthly,
      ),
      thirteenthSalary:
          _getTotalBonusByType(bonuses, BonusType.thirteenthSalary, year),
      thirteenthTax: _calculateSpecificBonusTax(
        bonuses,
        BonusType.thirteenthSalary,
        year,
        monthlyIncome,
        monthlyDeductions,
        specialDeductionMonthly,
        otherTaxFreeMonthly,
      ),
      otherBonus: _getTotalBonusByType(bonuses, BonusType.other, year),
      otherTax: _calculateSpecificBonusTax(
        bonuses,
        BonusType.other,
        year,
        monthlyIncome,
        monthlyDeductions,
        specialDeductionMonthly,
        otherTaxFreeMonthly,
      ),
      totalBonus: totalBonus,
      totalTax: totalTax,
      netBonus: totalBonus - totalTax,
    );
  }

  /// 根据奖金类型计算税费
  static double _calculateBonusTaxByType(
    BonusItem bonus,
    double annualBonusAmount,
    double monthlyIncome,
    double monthlyDeductions,
    double specialDeductionMonthly,
    double otherTaxFreeMonthly,
  ) {
    print('🧮 计算奖金税费: ${bonus.name}, 类型=${bonus.type}, 年度金额=$annualBonusAmount');
    
    switch (bonus.type) {
      case BonusType.yearEndBonus:
        // 年终奖：单独按年终奖税率计算
        final tax = calculateYearEndBonusTax(annualBonusAmount);
        print('  年终奖税费: $tax');
        return tax;

      case BonusType.thirteenthSalary:
      case BonusType.doublePayBonus:
        // 十三薪、回奖金：与每月工资合并计算税率
        final monthlyTax = _calculateMonthlyBonusTax(
          annualBonusAmount / 12, // 按月均分
          monthlyIncome,
          monthlyDeductions,
          specialDeductionMonthly,
          otherTaxFreeMonthly,
        );
        final tax = monthlyTax * 12; // 乘回12个月
        print('  十三薪/回奖金税费: 月税费=$monthlyTax, 年税费=$tax');
        return tax;
        
      case BonusType.quarterlyBonus:
        // 季度奖金：按季度发放月份计算税费
        // 季度奖金应该在发放月份与工资合并计税，这里简化处理为按月均分计算
        final monthlyTax = _calculateMonthlyBonusTax(
          annualBonusAmount / 12, // 按月均分
          monthlyIncome,
          monthlyDeductions,
          specialDeductionMonthly,
          otherTaxFreeMonthly,
        );
        final tax = monthlyTax * 12; // 乘回12个月
        print('  季度奖金税费: 月税费=$monthlyTax, 年税费=$tax');
        return tax;

      case BonusType.other:
        // 其他奖金：与每月工资合并计算税率
        final monthlyTax = _calculateMonthlyBonusTax(
          annualBonusAmount / 12, // 按月均分
          monthlyIncome,
          monthlyDeductions,
          specialDeductionMonthly,
          otherTaxFreeMonthly,
        );
        final tax = monthlyTax * 12; // 乘回12个月
        print('  其他奖金税费: 月税费=$monthlyTax, 年税费=$tax');
        return tax;
    }

    return 0;
  }

  /// 计算一次性奖金税费
  static double calculateYearEndBonusTax(double bonusAmount) {
    // 年终奖单独计税：使用年终奖专用税率计算
    return PersonalIncomeTaxService.calculateYearEndBonusTax(bonusAmount);
  }

  /// 计算每月奖金的税费
  static double _calculateMonthlyBonusTax(
    double monthlyBonusAmount,
    double monthlyBaseIncome,
    double monthlyDeductions,
    double specialDeductionMonthly,
    double otherTaxFreeMonthly,
  ) {
    print('🧮 计算月奖金税费: 奖金=$monthlyBonusAmount, 基本收入=$monthlyBaseIncome, 扣除=$monthlyDeductions, 专项扣除=$specialDeductionMonthly');
    final totalMonthlyIncome = monthlyBaseIncome + monthlyBonusAmount;
    print('  总月收入: $totalMonthlyIncome');
    
    final tax = PersonalIncomeTaxService.calculateMonthlyTax(
      totalMonthlyIncome,
      monthlyDeductions,
      0, // 假设没有前期预扣税款
      0, // 当月
    );
    
    print('  月税费: $tax');
    return tax;
  }

  /// 获取指定类型的奖金总额
  static double _getTotalBonusByType(
    List<BonusItem> bonuses,
    BonusType type,
    int year,
  ) =>
      bonuses
          .where((bonus) => bonus.type == type)
          .fold(0.0, (sum, bonus) => sum + bonus.calculateAnnualBonus(year));

  /// 计算指定类型奖金的税费
  static double _calculateSpecificBonusTax(
    List<BonusItem> bonuses,
    BonusType type,
    int year,
    double monthlyIncome,
    double monthlyDeductions,
    double specialDeductionMonthly,
    double otherTaxFreeMonthly,
  ) {
    final totalBonus = _getTotalBonusByType(bonuses, type, year);
    if (totalBonus == 0) return 0;

    // 创建临时奖金项目来计算税费
    final tempBonus = BonusItem.create(
      name: '临时',
      type: type,
      amount: totalBonus,
      frequency: BonusFrequency.oneTime,
      paymentCount: 1, // 临时奖金一次性发放
      startDate: DateTime(year, 12, 31),
    );

    return _calculateBonusTaxByType(
      tempBonus,
      totalBonus,
      monthlyIncome,
      monthlyDeductions,
      specialDeductionMonthly,
      otherTaxFreeMonthly,
    );
  }
}
