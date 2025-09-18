import 'package:flutter/material.dart';
import 'package:your_finance_flutter/core/models/bonus_item.dart';
import 'package:your_finance_flutter/core/services/personal_income_tax_service.dart';
import 'package:your_finance_flutter/core/services/salary_calculation_service.dart';
import 'package:your_finance_flutter/core/theme/app_theme.dart';
import 'package:your_finance_flutter/core/widgets/app_animations.dart';
import 'package:your_finance_flutter/core/widgets/app_card.dart';
import 'package:your_finance_flutter/features/family_info/widgets/expandable_calculation_item.dart';

class SalarySummaryWidget extends StatefulWidget {
  const SalarySummaryWidget({
    required this.basicSalary,
    required this.housingAllowance,
    required this.mealAllowance,
    required this.transportationAllowance,
    required this.otherAllowance,
    required this.performanceBonus,
    required this.otherBonuses,
    required this.personalIncomeTax,
    required this.socialInsurance,
    required this.housingFund,
    required this.otherDeductions,
    required this.bonuses,
    required this.salaryDay,
    super.key,
  });

  final double basicSalary;
  final double housingAllowance;
  final double mealAllowance;
  final double transportationAllowance;
  final double otherAllowance;
  final double performanceBonus;
  final double otherBonuses;
  final double personalIncomeTax;
  final double socialInsurance;
  final double housingFund;
  final double otherDeductions;
  final List<BonusItem> bonuses;
  final int salaryDay;

  @override
  State<SalarySummaryWidget> createState() => _SalarySummaryWidgetState();
}

class _SalarySummaryWidgetState extends State<SalarySummaryWidget> {
  @override
  Widget build(BuildContext context) {
    final summary = SalaryCalculationService.calculateIncomeSummary(
      basicSalary: widget.basicSalary,
      housingAllowance: widget.housingAllowance,
      mealAllowance: widget.mealAllowance,
      transportationAllowance: widget.transportationAllowance,
      otherAllowance: widget.otherAllowance,
      performanceBonus: widget.performanceBonus,
      otherBonuses: widget.otherBonuses,
      personalIncomeTax: widget.personalIncomeTax,
      socialInsurance: widget.socialInsurance,
      housingFund: widget.housingFund,
      otherDeductions: widget.otherDeductions,
      bonuses: widget.bonuses,
    );

    return AppAnimations.animatedListItem(
      index: 4,
      child: AppCard(
        child: Padding(
          padding: EdgeInsets.all(context.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.analytics, color: Colors.blue),
                  SizedBox(width: context.spacing8),
                  Text(
                    '收入汇总',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              SizedBox(height: context.spacing16),

              // 可展开的计算详情
              Column(
                children: [
                  // 税前收入
                  ExpandableCalculationItem(
                    title: '税前收入',
                    amount: '¥${summary.totalIncome.toStringAsFixed(0)}',
                    amountColor: Colors.blue,
                    icon: Icons.account_balance_wallet,
                    monthlyDetails: _generateIncomeMonthlyDetails(),
                    calculationFormula:
                        '税前收入 = 基本工资 + 住房补贴 + 餐补 + 交通补贴 + 其他补贴 + 奖金',
                  ),
                  SizedBox(height: context.spacing12),

                  // 扣除总额
                  ExpandableCalculationItem(
                    title: '扣除总额',
                    amount: '¥${summary.totalTax.toStringAsFixed(0)}',
                    amountColor: Colors.red,
                    icon: Icons.remove_circle,
                    monthlyDetails: _generateTaxMonthlyDetails(),
                    calculationFormula: '扣除总额 = 五险一金 + 专项附加扣除 + 其他扣除 + 个税',
                  ),
                  SizedBox(height: context.spacing12),

                  // 其他扣除
                  ExpandableCalculationItem(
                    title: '其他扣除',
                    amount:
                        '¥${(widget.socialInsurance + widget.housingFund + widget.otherDeductions).toStringAsFixed(0)}',
                    amountColor: Colors.orange,
                    icon: Icons.info,
                    monthlyDetails: _generateOtherDeductionsMonthlyDetails(),
                    calculationFormula: '其他扣除 = 社保 + 公积金 + 专项附加扣除 + 其他税前扣除',
                  ),
                ],
              ),
              SizedBox(height: context.spacing16),

              // 实际到手收入
              ExpandableCalculationItem(
                title: '实际到手收入',
                amount: '¥${summary.netIncome.toStringAsFixed(0)}',
                amountColor: Colors.green,
                icon: Icons.account_balance_wallet,
                monthlyDetails: _generateNetIncomeMonthlyDetails(),
                calculationFormula: '实际到手收入 = 税前收入 - 扣除总额',
              ),

              // 奖金税收详情
              if (widget.bonuses.isNotEmpty) ...[
                SizedBox(height: context.spacing16),
                Container(
                  padding: EdgeInsets.all(context.spacing12),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.purple.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '奖金税收详情（摊平计算）',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.purple.shade700,
                            ),
                      ),
                      SizedBox(height: context.spacing8),

                      // 奖金明细
                      ...widget.bonuses.map((bonus) {
                        final bonusAmount =
                            bonus.calculateAnnualBonus(DateTime.now().year);
                        if (bonusAmount > 0) {
                          return _buildBonusDetailWithSpreadTax(
                            bonus,
                            bonusAmount,
                          );
                        }
                        return const SizedBox.shrink();
                      }),

                      SizedBox(height: context.spacing8),
                      const Divider(height: 1, color: Colors.purple),
                      SizedBox(height: context.spacing8),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '奖金总额',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.purple.shade700,
                                ),
                          ),
                          Text(
                            '¥${summary.bonusIncome.toStringAsFixed(0)}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purple.shade700,
                                ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '奖金税收（全年）',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.purple.shade700,
                                ),
                          ),
                          Text(
                            '¥${_calculateTotalBonusTax().toStringAsFixed(0)}', // 计算全年奖金税费总和
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.red.shade600,
                                ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '税后奖金',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.purple.shade700,
                                ),
                          ),
                          Text(
                            '¥${(summary.bonusIncome - _calculateTotalBonusTax()).toStringAsFixed(0)}', // 税后奖金
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade600,
                                ),
                          ),
                        ],
                      ),
                      SizedBox(height: context.spacing8),
                      Container(
                        padding: EdgeInsets.all(context.spacing8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '💡 奖金税收已按月摊平计算，与工资合并计税，更准确反映实际税负',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.blue.shade700,
                                    fontSize: 11,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              SizedBox(height: context.spacing8),
              Text(
                '每月 ${widget.salaryDay} 日发放',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: context.secondaryText,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 生成收入每月详情
  List<MonthlyDetailItem> _generateIncomeMonthlyDetails() {
    final details = <MonthlyDetailItem>[];
    final currentYear = DateTime.now().year;
    final months = [
      '1月',
      '2月',
      '3月',
      '4月',
      '5月',
      '6月',
      '7月',
      '8月',
      '9月',
      '10月',
      '11月',
      '12月',
    ];

    for (var i = 0; i < 12; i++) {
      final components = <ComponentItem>[];

      // 基本工资
      if (widget.basicSalary > 0) {
        components.add(
          ComponentItem(
            label: '基本工资',
            value: '¥${widget.basicSalary.toStringAsFixed(0)}',
            description: '每月固定基本工资',
            color: Colors.blue,
          ),
        );
      }

      // 住房补贴
      if (widget.housingAllowance > 0) {
        components.add(
          ComponentItem(
            label: '住房补贴',
            value: '¥${widget.housingAllowance.toStringAsFixed(0)}',
            description: '每月住房补贴',
            color: Colors.green,
          ),
        );
      }

      // 餐补
      if (widget.mealAllowance > 0) {
        components.add(
          ComponentItem(
            label: '餐补',
            value: '¥${widget.mealAllowance.toStringAsFixed(0)}',
            description: '每月餐费补贴',
            color: Colors.orange,
          ),
        );
      }

      // 交通补贴
      if (widget.transportationAllowance > 0) {
        components.add(
          ComponentItem(
            label: '交通补贴',
            value: '¥${widget.transportationAllowance.toStringAsFixed(0)}',
            description: '每月交通补贴',
            color: Colors.purple,
          ),
        );
      }

      // 其他补贴
      if (widget.otherAllowance > 0) {
        components.add(
          ComponentItem(
            label: '其他补贴',
            value: '¥${widget.otherAllowance.toStringAsFixed(0)}',
            description: '其他补贴总额',
            color: Colors.teal,
          ),
        );
      }

      // 奖金收入
      var totalBonusAmount = 0.0;
      for (final bonus in widget.bonuses) {
        final monthlyBonus = bonus.calculateMonthlyBonus(currentYear, i + 1);

        // 对于十三薪和双薪，即使金额为0也要显示（因为它们是一次性奖金）
        final shouldShowBonus = monthlyBonus > 0 ||
            bonus.type == BonusType.thirteenthSalary ||
            bonus.type == BonusType.doublePayBonus;

        if (shouldShowBonus) {
          if (monthlyBonus > 0) {
            totalBonusAmount += monthlyBonus;
          }

          components.add(
            ComponentItem(
              label: bonus.name,
              value: monthlyBonus > 0
                  ? '¥${monthlyBonus.toStringAsFixed(0)}'
                  : '¥0',
              description: bonus.type == BonusType.thirteenthSalary
                  ? '十三薪 · ${bonus.thirteenthSalaryMonth != null ? "${bonus.thirteenthSalaryMonth}月发放" : "待定月份"}'
                  : bonus.type == BonusType.doublePayBonus
                      ? '双薪 · 年终发放'
                      : '${bonus.frequency == BonusFrequency.quarterly ? "季度奖金" : "年终奖金"} · ${bonus.type == BonusType.yearEndBonus ? "年终奖税率" : "单独计税"}',
              color: Colors.pink,
            ),
          );
        }
      }

      // 计算总月收入
      final totalMonthIncome = widget.basicSalary +
          widget.housingAllowance +
          widget.mealAllowance +
          widget.transportationAllowance +
          widget.otherAllowance +
          totalBonusAmount;

      details.add(
        MonthlyDetailItem.withComponents(
          month: months[i],
          amount: '¥${totalMonthIncome.toStringAsFixed(0)}',
          components: components,
        ),
      );
    }

    return details;
  }

  // 生成税费每月详情
  List<MonthlyDetailItem> _generateTaxMonthlyDetails() {
    final details = <MonthlyDetailItem>[];
    final currentYear = DateTime.now().year;
    final months = [
      '1月',
      '2月',
      '3月',
      '4月',
      '5月',
      '6月',
      '7月',
      '8月',
      '9月',
      '10月',
      '11月',
      '12月',
    ];

    for (var i = 0; i < 12; i++) {
      final components = <ComponentItem>[];

      // 计算总月收入用于税费计算
      final baseIncome = widget.basicSalary;
      final allowanceIncome = widget.housingAllowance +
          widget.mealAllowance +
          widget.transportationAllowance +
          widget.otherAllowance;

      var bonusAmount = 0.0;
      var thirteenthSalaryAmount = 0.0;
      for (final bonus in widget.bonuses) {
        final monthlyBonus = bonus.calculateMonthlyBonus(currentYear, i + 1);
        if (bonus.type == BonusType.thirteenthSalary ||
            bonus.type == BonusType.doublePayBonus) {
          thirteenthSalaryAmount += monthlyBonus;
        } else {
          bonusAmount += monthlyBonus;
        }
      }

      final totalMonthlyIncome =
          baseIncome + allowanceIncome + bonusAmount + thirteenthSalaryAmount;

      // 社保
      if (widget.socialInsurance > 0) {
        components.add(
          ComponentItem(
            label: '社保',
            value: '¥${widget.socialInsurance.toStringAsFixed(0)}',
            description: '五险一金中的社保部分',
            color: Colors.red,
          ),
        );
      }

      // 公积金
      if (widget.housingFund > 0) {
        components.add(
          ComponentItem(
            label: '公积金',
            value: '¥${widget.housingFund.toStringAsFixed(0)}',
            description: '住房公积金',
            color: Colors.indigo,
          ),
        );
      }

      // 专项附加扣除
      if (widget.otherDeductions > 0) {
        components.add(
          ComponentItem(
            label: '专项附加扣除',
            value: '¥${widget.otherDeductions.toStringAsFixed(0)}',
            description: '专项附加扣除项目',
            color: Colors.brown,
          ),
        );
      }

      // 计算奖金税务的摊平计算
      var totalMonthlyBonusTax = 0.0;
      for (final bonus in widget.bonuses) {
        final monthlyBonus = bonus.calculateMonthlyBonus(currentYear, i + 1);
        if (monthlyBonus > 0) {
          final monthlyBonusTax =
              _calculateBonusTaxPerMonth(bonus, monthlyBonus, i + 1);
          totalMonthlyBonusTax += monthlyBonusTax;

          if (monthlyBonusTax > 0) {
            components.add(
              ComponentItem(
                label: '${bonus.name}税费',
                value: '¥${monthlyBonusTax.toStringAsFixed(0)}',
                description: _getBonusTaxDescription(bonus),
                color: Colors.pink.shade700,
              ),
            );
          }
        }
      }

      // 个税部分（包含奖金税后的工资税）
      final monthlyTax = SalaryCalculationService.calculateMonthlyTax(
        monthlyIncome: totalMonthlyIncome,
        monthlyDeductions: widget.socialInsurance + widget.housingFund,
        specialDeductionMonthly: widget.otherDeductions,
        otherTaxFreeMonthly: 0,
      );

      if (monthlyTax > 0) {
        components.add(
          ComponentItem(
            label: '工资个税',
            value: '¥${monthlyTax.toStringAsFixed(0)}',
            description: '工资部分预扣个税',
            color: Colors.red.shade700,
          ),
        );
      }

      // 计算总扣除额（包含奖金税）
      final totalDeductions = widget.socialInsurance +
          widget.housingFund +
          widget.otherDeductions +
          monthlyTax +
          totalMonthlyBonusTax;

      details.add(
        MonthlyDetailItem.withComponents(
          month: months[i],
          amount: '¥${totalDeductions.toStringAsFixed(0)}',
          components: components,
        ),
      );
    }

    return details;
  }

  // 生成其他扣除每月详情
  List<MonthlyDetailItem> _generateOtherDeductionsMonthlyDetails() {
    final details = <MonthlyDetailItem>[];
    final months = [
      '1月',
      '2月',
      '3月',
      '4月',
      '5月',
      '6月',
      '7月',
      '8月',
      '9月',
      '10月',
      '11月',
      '12月',
    ];

    for (var i = 0; i < 12; i++) {
      final components = <ComponentItem>[];

      // 社保
      if (widget.socialInsurance > 0) {
        components.add(
          ComponentItem(
            label: '社保',
            value: '¥${widget.socialInsurance.toStringAsFixed(0)}',
            description: '五险一金中的社保部分',
            color: Colors.red,
          ),
        );
      }

      // 公积金
      if (widget.housingFund > 0) {
        components.add(
          ComponentItem(
            label: '公积金',
            value: '¥${widget.housingFund.toStringAsFixed(0)}',
            description: '住房公积金',
            color: Colors.indigo,
          ),
        );
      }

      // 专项附加扣除
      if (widget.otherDeductions > 0) {
        components.add(
          ComponentItem(
            label: '专项附加扣除',
            value: '¥${widget.otherDeductions.toStringAsFixed(0)}',
            description: '专项附加扣除项目',
            color: Colors.brown,
          ),
        );
      }

      final monthlyDeductions =
          widget.socialInsurance + widget.housingFund + widget.otherDeductions;

      details.add(
        MonthlyDetailItem.withComponents(
          month: months[i],
          amount: '¥${monthlyDeductions.toStringAsFixed(0)}',
          components: components,
        ),
      );
    }

    return details;
  }

  // 生成实际到手收入每月详情
  List<MonthlyDetailItem> _generateNetIncomeMonthlyDetails() {
    final details = <MonthlyDetailItem>[];
    final currentYear = DateTime.now().year;
    final months = [
      '1月',
      '2月',
      '3月',
      '4月',
      '5月',
      '6月',
      '7月',
      '8月',
      '9月',
      '10月',
      '11月',
      '12月',
    ];

    for (var i = 0; i < 12; i++) {
      final components = <ComponentItem>[];

      // 计算收入部分
      final baseIncome = widget.basicSalary;
      final allowanceIncome = widget.housingAllowance +
          widget.mealAllowance +
          widget.transportationAllowance +
          widget.otherAllowance;

      var bonusAmount = 0.0;
      var thirteenthSalaryAmount = 0.0;
      for (final bonus in widget.bonuses) {
        final monthlyBonus = bonus.calculateMonthlyBonus(currentYear, i + 1);
        if (bonus.type == BonusType.thirteenthSalary ||
            bonus.type == BonusType.doublePayBonus) {
          thirteenthSalaryAmount += monthlyBonus;
        } else {
          bonusAmount += monthlyBonus;
        }
      }

      final totalMonthlyIncome =
          baseIncome + allowanceIncome + bonusAmount + thirteenthSalaryAmount;

      // 添加收入组成部分
      if (baseIncome > 0) {
        components.add(
          ComponentItem(
            label: '基本工资',
            value: '+¥${baseIncome.toStringAsFixed(0)}',
            description: '每月固定基本工资',
            color: Colors.blue,
          ),
        );
      }

      if (allowanceIncome > 0) {
        components.add(
          ComponentItem(
            label: '补贴收入',
            value: '+¥${allowanceIncome.toStringAsFixed(0)}',
            description: '住房、餐补、交通等补贴',
            color: Colors.green,
          ),
        );
      }

      if (bonusAmount > 0) {
        components.add(
          ComponentItem(
            label: '奖金收入',
            value: '+¥${bonusAmount.toStringAsFixed(0)}',
            description: '各类奖金收入',
            color: Colors.pink,
          ),
        );
      }

      // 显示十三薪（即使金额为0也要显示，因为它是一次性奖金）
      final hasThirteenthSalary = widget.bonuses.any(
        (bonus) =>
            bonus.type == BonusType.thirteenthSalary ||
            bonus.type == BonusType.doublePayBonus,
      );

      if (hasThirteenthSalary) {
        final thirteenthSalaryBonus = widget.bonuses.firstWhere(
          (bonus) =>
              bonus.type == BonusType.thirteenthSalary ||
              bonus.type == BonusType.doublePayBonus,
        );

        components.add(
          ComponentItem(
            label: thirteenthSalaryBonus.type == BonusType.thirteenthSalary
                ? '十三薪'
                : '双薪',
            value: thirteenthSalaryAmount > 0
                ? '+¥${thirteenthSalaryAmount.toStringAsFixed(0)}'
                : '+¥0',
            description: thirteenthSalaryBonus.type ==
                    BonusType.thirteenthSalary
                ? '十三薪 · ${thirteenthSalaryBonus.thirteenthSalaryMonth != null ? "${thirteenthSalaryBonus.thirteenthSalaryMonth}月发放" : "待定月份"}'
                : '双薪 · 年终发放',
            color: Colors.purple,
          ),
        );
      }

      // 计算奖金税务的摊平计算
      var totalMonthlyBonusTax = 0.0;
      for (final bonus in widget.bonuses) {
        final monthlyBonus = bonus.calculateMonthlyBonus(currentYear, i + 1);
        if (monthlyBonus > 0) {
          final monthlyBonusTax =
              _calculateBonusTaxPerMonth(bonus, monthlyBonus, i + 1);
          totalMonthlyBonusTax += monthlyBonusTax;
        }
      }

      // 计算扣除部分
      final monthlyDeductions = widget.socialInsurance +
          widget.housingFund +
          widget.otherDeductions +
          (widget.personalIncomeTax / 12) + // 估算月度工资个税
          totalMonthlyBonusTax; // 奖金税费

      // 添加扣除组成部分
      if (widget.socialInsurance > 0) {
        components.add(
          ComponentItem(
            label: '社保扣除',
            value: '-¥${widget.socialInsurance.toStringAsFixed(0)}',
            description: '五险一金中的社保部分',
            color: Colors.red,
          ),
        );
      }

      if (widget.housingFund > 0) {
        components.add(
          ComponentItem(
            label: '公积金扣除',
            value: '-¥${widget.housingFund.toStringAsFixed(0)}',
            description: '住房公积金',
            color: Colors.indigo,
          ),
        );
      }

      // 专项附加扣除
      if (widget.otherDeductions > 0) {
        components.add(
          ComponentItem(
            label: '专项附加扣除',
            value: '-¥${widget.otherDeductions.toStringAsFixed(0)}',
            description: '专项附加扣除项目',
            color: Colors.brown,
          ),
        );
      }

      // 添加奖金税费扣除
      for (final bonus in widget.bonuses) {
        final monthlyBonus = bonus.calculateMonthlyBonus(currentYear, i + 1);
        if (monthlyBonus > 0) {
          final monthlyBonusTax =
              _calculateBonusTaxPerMonth(bonus, monthlyBonus, i + 1);
          if (monthlyBonusTax > 0) {
            components.add(
              ComponentItem(
                label: '${bonus.name}税费',
                value: '-¥${monthlyBonusTax.toStringAsFixed(0)}',
                description: _getBonusTaxDescription(bonus),
                color: Colors.pink.shade700,
              ),
            );
          }
        }
      }

      final monthlyTax = widget.personalIncomeTax / 12;
      if (monthlyTax > 0) {
        components.add(
          ComponentItem(
            label: '工资个税',
            value: '-¥${monthlyTax.toStringAsFixed(0)}',
            description: '工资部分预扣个税',
            color: Colors.red.shade700,
          ),
        );
      }

      final netMonthlyIncome = totalMonthlyIncome - monthlyDeductions;

      details.add(
        MonthlyDetailItem.withComponents(
          month: months[i],
          amount: '¥${netMonthlyIncome.toStringAsFixed(0)}',
          components: components,
        ),
      );
    }

    return details;
  }

  String _getBonusTypeDescription(BonusItem bonus) {
    final frequencyText = bonus.frequency == BonusFrequency.quarterly
        ? '季度奖金'
        : bonus.frequency == BonusFrequency.oneTime
            ? '一次性奖金'
            : '定期奖金';

    final taxMethodText =
        bonus.type == BonusType.yearEndBonus ? '年终奖税率单独计税' : '与工资合并计税';

    return '$frequencyText · $taxMethodText';
  }

  Widget _buildBonusDetailRow(String label, double amount, double tax) =>
      Padding(
        padding: EdgeInsets.symmetric(vertical: context.spacing4),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.secondaryText,
                    ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                '¥${amount.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.primaryText,
                      fontWeight: FontWeight.w500,
                    ),
                textAlign: TextAlign.right,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                '¥${tax.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.red.shade600,
                    ),
                textAlign: TextAlign.right,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                '¥${(amount - tax).toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.green.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      );

  /// 计算奖金每月税费（摊平计算）
  double _calculateBonusTaxPerMonth(
      BonusItem bonus, double monthlyBonus, int month) {
    if (monthlyBonus <= 0) {
      return 0.0;
    }

    // 根据奖金类型计算月度税费
    switch (bonus.type) {
      case BonusType.yearEndBonus:
        // 年终奖：如果在发放月份，计算全年年终奖税费
        if (month == 12) {
          return PersonalIncomeTaxService.calculateYearEndBonusTax(
              bonus.amount);
        }
        return 0.0;

      case BonusType.quarterlyBonus:
        // 季度奖金：按季度发放月份计算季度税费
        final quarterlyMonths = bonus.quarterlyPaymentMonths ?? [3, 6, 9, 12];
        if (quarterlyMonths.contains(month)) {
          // 计算季度奖金的税费（简化为10%税率）
          final quarterlyAmount = bonus.amount / bonus.paymentCount;
          return quarterlyAmount * 0.1;
        }
        return 0.0;

      case BonusType.thirteenthSalary:
      case BonusType.doublePayBonus:
        // 十三薪和双薪：一次性发放，按月平均摊平税费
        if (monthlyBonus > 0) {
          final totalTax = bonus.amount * 0.1; // 简化为10%税率
          return totalTax / 12; // 每月摊平
        }
        return 0.0;

      case BonusType.other:
        // 其他奖金：按发放次数平均摊平
        if (monthlyBonus > 0) {
          final totalTax = bonus.amount * 0.1; // 简化为10%税率
          return totalTax / bonus.paymentCount;
        }
        return 0.0;
    }
  }

  /// 获取奖金税费描述
  String _getBonusTaxDescription(BonusItem bonus) {
    switch (bonus.type) {
      case BonusType.yearEndBonus:
        return '年终奖 · 单独计税';
      case BonusType.quarterlyBonus:
        return '季度奖金 · 与工资合并计税';
      case BonusType.thirteenthSalary:
        return '十三薪 · 月度摊平计税';
      case BonusType.doublePayBonus:
        return '双薪 · 月度摊平计税';
      case BonusType.other:
        return '其他奖金 · 按发放次数摊平';
    }
  }

  /// 计算全年奖金税费总和（摊平计算）
  double _calculateTotalBonusTax() {
    final currentYear = DateTime.now().year;
    var totalTax = 0.0;

    for (final bonus in widget.bonuses) {
      for (var month = 1; month <= 12; month++) {
        final monthlyBonus = bonus.calculateMonthlyBonus(currentYear, month);
        if (monthlyBonus > 0) {
          final monthlyBonusTax =
              _calculateBonusTaxPerMonth(bonus, monthlyBonus, month);
          totalTax += monthlyBonusTax;
        }
      }
    }

    return totalTax;
  }

  /// 构建奖金详情（包含摊平税收计算）
  Widget _buildBonusDetailWithSpreadTax(BonusItem bonus, double amount) {
    final currentYear = DateTime.now().year;
    var totalTax = 0.0;
    final monthlyBreakdown = <String>[];

    for (var month = 1; month <= 12; month++) {
      final monthlyBonus = bonus.calculateMonthlyBonus(currentYear, month);
      if (monthlyBonus > 0) {
        final monthlyBonusTax =
            _calculateBonusTaxPerMonth(bonus, monthlyBonus, month);
        totalTax += monthlyBonusTax;
        if (monthlyBonusTax > 0) {
          monthlyBreakdown
              .add('$month月: ¥${monthlyBonusTax.toStringAsFixed(0)}');
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 奖金标题和金额
        _buildBonusDetailRow(bonus.name, amount, totalTax),

        // 计算公式
        Padding(
          padding:
              EdgeInsets.only(left: context.spacing16, top: context.spacing4),
          child: Text(
            _getBonusSpreadTaxFormula(bonus, amount),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.blue.shade600,
                  fontSize: 11,
                ),
          ),
        ),

        // 月度摊平详情
        if (monthlyBreakdown.isNotEmpty) ...[
          Padding(
            padding: EdgeInsets.only(
              left: context.spacing16,
              top: context.spacing4,
              bottom: context.spacing8,
            ),
            child: Container(
              padding: EdgeInsets.all(context.spacing8),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '月度税费摊平:',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700,
                          fontSize: 10,
                        ),
                  ),
                  SizedBox(height: context.spacing4),
                  Text(
                    monthlyBreakdown.join(' | '),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                          fontSize: 10,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],

        // 奖金类型说明
        Padding(
          padding: EdgeInsets.only(
            left: context.spacing16,
            bottom: context.spacing8,
          ),
          child: Text(
            _getBonusTypeDescription(bonus),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.secondaryText,
                  fontSize: 10,
                ),
          ),
        ),
      ],
    );
  }

  /// 获取奖金摊平税收计算公式
  String _getBonusSpreadTaxFormula(BonusItem bonus, double amount) {
    switch (bonus.type) {
      case BonusType.yearEndBonus:
        return '计算公式: 年终奖 ¥${amount.toStringAsFixed(0)}，12月单独计税';

      case BonusType.quarterlyBonus:
        return '计算公式: ¥${amount.toStringAsFixed(0)} ÷ ${bonus.paymentCount}次，按季度发放摊平计税';

      case BonusType.thirteenthSalary:
        return '计算公式: 十三薪 ¥${amount.toStringAsFixed(0)}，全年12个月平均摊平计税';

      case BonusType.doublePayBonus:
        return '计算公式: 双薪 ¥${amount.toStringAsFixed(0)}，全年12个月平均摊平计税';

      case BonusType.other:
        return '计算公式: ¥${amount.toStringAsFixed(0)} ÷ ${bonus.paymentCount}次发放，按月摊平计税';
    }
  }
}
