/// 个税计算器
///
/// 负责纯粹的税务计算逻辑，不依赖于 Flutter 或 UI。
/// 实现中国个人所得税的月度预缴计算、年度汇算清缴，以及全年一次性奖金单独计税。
/// 政策时效性：基于中国2023年起实施的个税政策（延续至2027年）。
class TaxCalculator {
  /// 免征额（起征点），单位：元/月。
  /// 根据最新政策，为5000元/月。
  static const double defaultThreshold = 5000.0;
  static const double _annualThreshold = defaultThreshold * 12.0; // 60000.0

  // ----------------------------------------------------
  // 中国个人所得税【年度综合所得】超额累进税率表（累计预扣和汇算清缴均使用此表）
  // ----------------------------------------------------
  /// 格式：[('lower':下限, 'upper':上限, 'rate':税率, 'deduction':速算扣除数)]
  /// 注意：这里的上下限是年度应纳税所得额。
  static const List<Map<String, double>> _annualComprehensiveTaxRateTable = [
    {
      'lower': 0.0,
      'upper': 36000.0,
      'rate': 0.03,
      'deduction': 0.0,
    }, // 不超过36000元：3%
    {
      'lower': 36000.0,
      'upper': 144000.0,
      'rate': 0.10,
      'deduction': 2520.0,
    }, // 超过36000至144000元：10%
    {
      'lower': 144000.0,
      'upper': 300000.0,
      'rate': 0.20,
      'deduction': 16920.0,
    }, // 超过144000至300000元：20%
    {
      'lower': 300000.0,
      'upper': 420000.0,
      'rate': 0.25,
      'deduction': 31920.0,
    }, // 超过300000至420000元：25%
    {
      'lower': 420000.0,
      'upper': 660000.0,
      'rate': 0.30,
      'deduction': 52920.0,
    }, // 超过420000至660000元：30%
    {
      'lower': 660000.0,
      'upper': 960000.0,
      'rate': 0.35,
      'deduction': 85920.0,
    }, // 超过660000至960000元：35%
    {
      'lower': 960000.0,
      'upper': double.infinity,
      'rate': 0.45,
      'deduction': 181920.0,
    }, // 超过960000元：45%
  ];

  // ----------------------------------------------------
  // 中国个人所得税【全年一次性奖金】单独计税使用的月度换算税率表
  // ----------------------------------------------------
  /// 注意：这里的上下限是奖金除以12后的月度金额。
  static const List<Map<String, double>> _monthlyConvertedTaxRateTable = [
    {
      'lower': 0.0,
      'upper': 3000.0,
      'rate': 0.03,
      'deduction': 0.0,
    }, // 不超过3000元：3%
    {
      'lower': 3000.0,
      'upper': 12000.0,
      'rate': 0.10,
      'deduction': 210.0,
    }, // 超过3000至12000元：10%
    {
      'lower': 12000.0,
      'upper': 25000.0,
      'rate': 0.20,
      'deduction': 1410.0,
    }, // 超过12000至25000元：20%
    {
      'lower': 25000.0,
      'upper': 35000.0,
      'rate': 0.25,
      'deduction': 2660.0,
    }, // 超过25000至35000元：25%
    {
      'lower': 35000.0,
      'upper': 55000.0,
      'rate': 0.30,
      'deduction': 4410.0,
    }, // 超过35000至55000元：30%
    {
      'lower': 55000.0,
      'upper': 80000.0,
      'rate': 0.35,
      'deduction': 7160.0,
    }, // 超过55000至80000元：35%
    {
      'lower': 80000.0,
      'upper': double.infinity,
      'rate': 0.45,
      'deduction': 15160.0,
    }, // 超过80000元：45%
  ];

  /// ----------------------------------------------------
  /// 1. 标准月度预缴计算 (估算稳态税额)
  /// ----------------------------------------------------
  /// 估算在税前收入和扣除项稳定不变的情况下，每月应预缴的税额。
  ///
  /// **计算逻辑**：
  /// 1. 月度应纳税所得额 = 税前收入 - 免征额 - 五险一金 - 专项附加扣除/12
  /// 2. 年度应纳税所得额 = 月度应纳税所得额 × 12
  /// 3. 按照**年度综合所得税率表**计算年度应缴税额
  /// 4. 月度预缴税额 = 年度税额 / 12
  /// 5. 税后收入 = 税前收入 - 五险一金 - 月度预缴税额
  ///
  /// **参数说明**：
  /// - [preTaxIncome] 税前月收入（单位：元）
  /// - [socialSecurity] 五险一金月缴费额（单位：元）
  /// - [annualDeduction] 年度专项附加扣除总额（单位：元）
  /// - [threshold] 免征额，默认为5000元/月
  ///
  /// **返回值**：
  /// - 'taxableIncome': 月度应纳税所得额（元）
  /// - 'annualTaxableIncome': 年度应纳税所得额（元）
  /// - 'annualTax': 年度应缴税额（元）
  /// - 'monthlyTax': 月度预缴税额（元）
  /// - 'postTaxIncome': 税后月收入（元）
  /// - 'taxRate': 适用税率（0-1之间的小数）
  Map<String, double> calculateMonthlyTax({
    required double preTaxIncome,
    required double socialSecurity,
    required double annualDeduction,
    double threshold = defaultThreshold,
  }) {
    // 1. 计算月度应纳税所得额
    // 专项附加扣除按月均摊
    final monthlyDeduction = annualDeduction / 12.0;
    final monthlyTaxableIncome =
        preTaxIncome - threshold - socialSecurity - monthlyDeduction;

    // 边界处理：应纳税所得额 <= 0
    if (monthlyTaxableIncome <= 0) {
      return {
        'taxableIncome': monthlyTaxableIncome,
        'annualTaxableIncome': 0.0,
        'annualTax': 0.0,
        'monthlyTax': 0.0,
        'postTaxIncome': preTaxIncome - socialSecurity,
        'taxRate': 0.0,
      };
    }

    // 2. 估算年度应纳税所得额
    final annualTaxableIncome = monthlyTaxableIncome * 12.0;

    // 3. 根据年度应纳税所得额，查找适用的税率和速算扣除数 (使用年度综合所得表)
    final taxBracket =
        _findTaxBracket(annualTaxableIncome, _annualComprehensiveTaxRateTable);
    final taxRate = taxBracket['rate']!;
    final quickDeduction = taxBracket['deduction']!;

    // 4. 计算年度应缴税额（使用速算扣除法）
    final annualTax = annualTaxableIncome * taxRate - quickDeduction;
    final annualTaxFinal = annualTax > 0 ? annualTax : 0.0;

    // 5. 计算月度预缴税额
    final monthlyTax = annualTaxFinal / 12.0;

    // 6. 计算税后月收入
    final postTaxIncome = preTaxIncome - socialSecurity - monthlyTax;

    return {
      'taxableIncome': monthlyTaxableIncome,
      'annualTaxableIncome': annualTaxableIncome,
      'annualTax': annualTaxFinal,
      'monthlyTax': monthlyTax,
      'postTaxIncome': postTaxIncome,
      'taxRate': taxRate,
    };
  }

  /// ----------------------------------------------------
  /// 2. 全年一次性奖金单独计税
  /// ----------------------------------------------------
  /// 计算全年一次性奖金的单独计税额。政策延续至2027年12月31日。
  ///
  /// **计算逻辑**：
  /// 1. 计算月均奖金：奖金总额 / 12
  /// 2. 按照**月度换算税率表**，查找月均奖金对应的税率和速算扣除数
  /// 3. 税额 = 奖金总额 × 适用税率 - 速算扣除数
  ///
  /// **参数说明**：
  /// - [bonusAmount] 全年一次性奖金总额（单位：元）
  ///
  /// **返回值**：
  /// - 'taxAmount': 奖金应缴税额（元）
  /// - 'taxRate': 适用税率（0-1之间的小数）
  Map<String, double> calculateOneTimeBonusTax({
    required double bonusAmount,
  }) {
    if (bonusAmount <= 0) {
      return {
        'taxAmount': 0.0,
        'taxRate': 0.0,
      };
    }

    // 1. 计算月均奖金
    final monthlyEquivalent = bonusAmount / 12.0;

    // 2. 根据月均奖金，查找适用的税率和速算扣除数 (使用月度换算表)
    final taxBracket =
        _findTaxBracket(monthlyEquivalent, _monthlyConvertedTaxRateTable);
    final taxRate = taxBracket['rate']!;
    final quickDeduction = taxBracket['deduction']!;

    // 3. 计算应缴税额
    final taxAmount = bonusAmount * taxRate - quickDeduction;

    return {
      'taxAmount': taxAmount > 0 ? taxAmount : 0.0,
      'taxRate': taxRate,
    };
  }

  /// ----------------------------------------------------
  /// 3. 年度汇算清缴计算
  /// ----------------------------------------------------
  /// 根据全年累计收入和扣除，计算年度应缴税额，并与已预缴税额对比。
  ///
  /// **参数说明**：
  /// - [annualPreTaxIncome] 年度税前收入总额（单位：元）
  /// - [annualSocialSecurity] 年度五险一金缴费总额（单位：元）
  /// - [annualDeduction] 年度专项附加扣除总额（单位：元）
  /// - [prepaidTax] 已预缴税额总额（单位：元）
  ///
  /// **返回值**：
  /// - 'annualTaxableIncome': 年度应纳税所得额（元）
  /// - 'annualTax': 年度应缴税额（元）
  /// - 'prepaidTax': 已预缴税额（元）
  /// - 'taxToPay': 应补缴税额（元，负数表示应退还）
  /// - 'taxRate': 适用税率（0-1之间的小数）
  Map<String, double> calculateAnnualSettlement({
    required double annualPreTaxIncome,
    required double annualSocialSecurity,
    required double annualDeduction,
    required double prepaidTax,
  }) {
    // 1. 计算年度应纳税所得额
    final annualTaxableIncome = annualPreTaxIncome -
        _annualThreshold -
        annualSocialSecurity -
        annualDeduction;

    // 边界处理：应纳税所得额 <= 0
    if (annualTaxableIncome <= 0) {
      return {
        'annualTaxableIncome': annualTaxableIncome,
        'annualTax': 0.0,
        'prepaidTax': prepaidTax,
        'taxToPay': -prepaidTax, // 应退还已预缴的税额
        'taxRate': 0.0,
      };
    }

    // 2. 查找适用的税率和速算扣除数 (使用年度综合所得表)
    final taxBracket =
        _findTaxBracket(annualTaxableIncome, _annualComprehensiveTaxRateTable);
    final taxRate = taxBracket['rate']!;
    final quickDeduction = taxBracket['deduction']!;

    // 3. 计算年度应缴税额
    final annualTax = annualTaxableIncome * taxRate - quickDeduction;
    final annualTaxFinal = annualTax > 0 ? annualTax : 0.0;

    // 4. 计算应补缴或应退还的税额
    final taxToPay = annualTaxFinal - prepaidTax;

    return {
      'annualTaxableIncome': annualTaxableIncome,
      'annualTax': annualTaxFinal,
      'prepaidTax': prepaidTax,
      'taxToPay': taxToPay,
      'taxRate': taxRate,
    };
  }

  /// ----------------------------------------------------
  /// 辅助方法
  /// ----------------------------------------------------

  /// 查找适用的税率档次
  ///
  /// [taxableIncome] 应纳税所得额（可能是年度总额或月均额）
  /// [rateTable] 使用的税率表（年度综合所得表或月度换算表）
  ///
  /// 返回包含 'rate' 和 'deduction' 的 Map
  Map<String, double> _findTaxBracket(
    double taxableIncome,
    List<Map<String, double>> rateTable,
  ) {
    for (final bracket in rateTable) {
      final lower = bracket['lower']!;
      final upper = bracket['upper']!;

      // 由于浮点数比较可能存在误差，这里使用 >= lower 和 < upper 的逻辑
      // 最后一档使用 >= lower
      if (taxableIncome >= lower && taxableIncome < upper) {
        return {
          'rate': bracket['rate']!,
          'deduction': bracket['deduction']!,
        };
      }
    }

    // 匹配最高档
    return {
      'rate': rateTable.last['rate']!,
      'deduction': rateTable.last['deduction']!,
    };
  }

  /// 获取税率表信息（用于展示或调试）
  ///
  /// [isBonusTable] 是否返回年终奖月度换算税率表
  List<Map<String, dynamic>> getTaxRateTable({bool isBonusTable = false}) {
    final table = isBonusTable
        ? _monthlyConvertedTaxRateTable
        : _annualComprehensiveTaxRateTable;

    return table
        .map(
          (bracket) => {
            'type': isBonusTable ? 'MonthlyEquivalent' : 'AnnualCumulative',
            'lower': bracket['lower'],
            'upper':
                bracket['upper'] == double.infinity ? null : bracket['upper']!,
            'rate': bracket['rate'],
            'ratePercent': '${(bracket['rate']! * 100).toStringAsFixed(0)}%',
            'deduction': bracket['deduction'],
          },
        )
        .toList();
  }
}
