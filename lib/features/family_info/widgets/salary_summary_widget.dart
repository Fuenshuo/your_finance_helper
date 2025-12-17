import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:your_finance_flutter/core/models/bonus_item.dart';
import 'package:your_finance_flutter/core/models/budget.dart';
import 'package:your_finance_flutter/core/services/logging_service.dart';
import 'package:your_finance_flutter/core/services/personal_income_tax_service.dart';
import 'package:your_finance_flutter/core/services/salary_calculation_service.dart';
import 'package:your_finance_flutter/core/theme/app_theme.dart';
import 'package:your_finance_flutter/core/widgets/app_animations.dart';
import 'package:your_finance_flutter/core/widgets/app_card.dart';
import 'package:your_finance_flutter/features/family_info/widgets/expandable_calculation_item.dart';
import 'dart:convert';

// 个税计算详情组件
class TaxCalculationDetailItem extends StatefulWidget {
  const TaxCalculationDetailItem({
    required this.monthlyIncome,
    required this.monthlyDeductions,
    required this.specialDeductionMonthly,
    required this.otherTaxDeductions, // 其他税收扣除
    required this.monthlyTax,
    required this.month,
    required this.cumulativeTaxableIncome, // 累计应纳税所得额
    required this.cumulativeTax, // 累计已预扣税款
    this.yearEndBonusAmount = 0.0, // 年终奖金额
    this.yearEndBonusTax = 0.0, // 年终奖税额
    super.key,
  });

  final double monthlyIncome;
  final double monthlyDeductions;
  final double specialDeductionMonthly;
  final double otherTaxDeductions; // 其他税收扣除
  final double monthlyTax;
  final String month;
  final double cumulativeTaxableIncome; // 累计应纳税所得额
  final double cumulativeTax; // 累计已预扣税款
  final double yearEndBonusAmount; // 年终奖金额
  final double yearEndBonusTax; // 年终奖税额

  @override
  State<TaxCalculationDetailItem> createState() =>
      _TaxCalculationDetailItemState();
}

class _TaxCalculationDetailItemState extends State<TaxCalculationDetailItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    // 计算月收入中除年终奖外的部分
    final monthlyIncomeWithoutBonus =
        widget.monthlyIncome - widget.yearEndBonusAmount;
    final monthlyTaxableIncome = monthlyIncomeWithoutBonus -
        widget.monthlyDeductions -
        5000 -
        widget.otherTaxDeductions;
    // 使用累计应纳税所得额确定税率阶梯，符合年度累积预扣法
    final taxBracket = PersonalIncomeTaxService.getApplicableTaxBracket(
        widget.cumulativeTaxableIncome);
    final taxRate = taxBracket.rate;
    final quickDeduction = taxBracket.deduction;
    final annualTax = widget.cumulativeTaxableIncome * taxRate - quickDeduction;

    return Container(
      margin: EdgeInsets.only(bottom: context.spacing8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 月份标题栏
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Container(
              padding: EdgeInsets.all(context.spacing12),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.03),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${widget.month} 个税计算详情',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Row(
                    children: [
                      Text(
                        '¥${widget.monthlyTax.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade600,
                            ),
                      ),
                      SizedBox(width: context.spacing4),
                      Icon(
                        _isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: Colors.grey,
                        size: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 展开的计算详情
          if (_isExpanded) ...[
            Padding(
              padding: EdgeInsets.all(context.spacing12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 基本信息
                  _buildTaxCalculationStep(
                    '1. 月收入',
                    '¥${widget.monthlyIncome.toStringAsFixed(0)}',
                    Colors.blue,
                    '当月总收入（含年终奖）',
                  ),
                  if (widget.yearEndBonusAmount > 0) ...[
                    _buildTaxCalculationStep(
                      '   其中年终奖',
                      '¥${widget.yearEndBonusAmount.toStringAsFixed(0)}',
                      Colors.purple,
                      '年终奖单独计税',
                    ),
                  ],
                  _buildTaxCalculationStep(
                    '2. 减除费用',
                    '¥5,000',
                    Colors.orange,
                    '基础减除费用',
                  ),
                  _buildTaxCalculationStep(
                    '3. 五险一金',
                    '-¥${widget.monthlyDeductions.toStringAsFixed(0)}',
                    Colors.red,
                    '社保、公积金等',
                  ),
                  _buildTaxCalculationStep(
                    '4. 专项附加扣除',
                    '-¥${widget.specialDeductionMonthly.toStringAsFixed(0)}',
                    Colors.purple,
                    '子女教育、继续教育等',
                  ),
                  if (widget.otherTaxDeductions > 0) ...[
                    _buildTaxCalculationStep(
                      '5. 其他税收扣除',
                      '-¥${widget.otherTaxDeductions.toStringAsFixed(0)}',
                      Colors.brown,
                      '其他可扣除项目',
                    ),
                  ],
                  const Divider(height: 20, color: Colors.grey),

                  // 当月应纳税所得额（不包括年终奖）
                  _buildTaxCalculationStep(
                    '6. 当月应纳税所得额',
                    '¥${monthlyTaxableIncome.toStringAsFixed(0)}',
                    monthlyTaxableIncome > 0 ? Colors.green : Colors.grey,
                    '当月应纳税所得额 = 月收入(不含年终奖) - 基础减除 - 五险一金 - 专项扣除 - 其他税收扣除',
                  ),

                  const Divider(height: 20, color: Colors.grey),

                  // 累计计算
                  _buildTaxCalculationStep(
                    '7. 累计应纳税所得额',
                    '¥${widget.cumulativeTaxableIncome.toStringAsFixed(0)}',
                    widget.cumulativeTaxableIncome > 0
                        ? Colors.blue
                        : Colors.grey,
                    '累计应纳税所得额 = 之前累计 + 当月应纳税所得额（不含年终奖）',
                  ),

                  const Divider(height: 20, color: Colors.grey),

                  // 税率和速算扣除数（基于累计应纳税所得额）
                  _buildTaxCalculationStep(
                    '8. 适用税率',
                    '${(taxRate * 100).toStringAsFixed(0)}%',
                    Colors.blue.shade700,
                    '根据累计应纳税所得额确定税率（年度累积预扣法）',
                  ),
                  _buildTaxCalculationStep(
                    '9. 速算扣除数',
                    '¥${quickDeduction.toStringAsFixed(0)}',
                    Colors.indigo,
                    '对应税率的速算扣除数',
                  ),

                  const Divider(height: 20, color: Colors.grey),

                  // 最终税额计算
                  Container(
                    padding: EdgeInsets.all(context.spacing12),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(6),
                      border:
                          Border.all(color: Colors.red.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '10. 最终税额计算',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red.shade700,
                                  ),
                        ),
                        SizedBox(height: context.spacing4),
                        Text(
                          '累计应纳税额 = 累计应纳税所得额 × 税率 - 速算扣除数',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontFamily: 'monospace',
                                    color: Colors.red.shade600,
                                  ),
                        ),
                        Text(
                          '累计应纳税额 = ¥${widget.cumulativeTaxableIncome.toStringAsFixed(0)} × ${(taxRate * 100).toStringAsFixed(0)}% - ¥${quickDeduction.toStringAsFixed(0)} = ¥${annualTax.toStringAsFixed(0)}',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontFamily: 'monospace',
                                    color: Colors.red.shade700,
                                    fontSize: 11,
                                  ),
                        ),
                        SizedBox(height: context.spacing8),
                        Text(
                          '当月预扣税额 = 累计应纳税额 - 累计已预扣税额',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontFamily: 'monospace',
                                    color: Colors.red.shade600,
                                  ),
                        ),
                        Text(
                          '当月预扣税额 = ¥${annualTax.toStringAsFixed(0)} - ¥${widget.cumulativeTax.toStringAsFixed(0)} = ¥${(widget.monthlyTax - widget.yearEndBonusTax).toStringAsFixed(0)}',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontFamily: 'monospace',
                                    color: Colors.red.shade700,
                                    fontSize: 11,
                                  ),
                        ),
                        if (widget.yearEndBonusAmount > 0) ...[
                          SizedBox(height: context.spacing8),
                          Text(
                            '年终奖税额（单独计税）',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.purple.shade700,
                                    ),
                          ),
                          Text(
                            '年终奖税额 = 年终奖 ÷ 12后适用税率 × 12 - 速算扣除数',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontFamily: 'monospace',
                                      color: Colors.purple.shade600,
                                    ),
                          ),
                          Text(
                            '年终奖税额 = ¥${widget.yearEndBonusTax.toStringAsFixed(0)}',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontFamily: 'monospace',
                                      color: Colors.purple.shade700,
                                      fontSize: 11,
                                    ),
                          ),
                        ],
                        SizedBox(height: context.spacing8),
                        Text(
                          '月总税额 = 当月预扣税额 + 年终奖税额',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red.shade700,
                                  ),
                        ),
                        Text(
                          '月总税额 = ¥${(widget.monthlyTax - widget.yearEndBonusTax).toStringAsFixed(0)} + ¥${widget.yearEndBonusTax.toStringAsFixed(0)} = ¥${widget.monthlyTax.toStringAsFixed(0)}',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontFamily: 'monospace',
                                    color: Colors.red.shade700,
                                    fontSize: 11,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTaxCalculationStep(
    String step,
    String amount,
    Color color,
    String description,
  ) =>
      Container(
        margin: EdgeInsets.only(bottom: context.spacing8),
        padding: EdgeInsets.all(context.spacing8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                step,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: color,
                    ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                amount,
                textAlign: TextAlign.right,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
              ),
            ),
            SizedBox(width: context.spacing8),
            Expanded(
              flex: 5,
              child: Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.secondaryText,
                      fontSize: 10,
                    ),
              ),
            ),
          ],
        ),
      );
}

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
    required this.otherTaxDeductions, // 新增其他税收扣除项
    required this.bonuses,
    required this.salaryDay,
    this.monthlyAllowances, // 月度津贴记录
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
  final double otherTaxDeductions; // 新增其他税收扣除项
  final List<BonusItem> bonuses;
  final int salaryDay;
  final Map<int, AllowanceRecord>? monthlyAllowances; // 月度津贴记录

  @override
  State<SalarySummaryWidget> createState() => _SalarySummaryWidgetState();
}

class _SalarySummaryWidgetState extends State<SalarySummaryWidget> {
  late SalaryCalculationResult _summary;
  bool _isCalculating = true;

  @override
  void initState() {
    super.initState();
    _calculateSummary();
  }

  Future<void> _calculateSummary() async {
    final logger = LoggingService();
    await logger.initialize();

    await logger.log('🧮 开始计算收入汇总:');
    await logger.log('  基本工资: ${widget.basicSalary}');
    await logger.log('  住房补贴: ${widget.housingAllowance}');
    await logger.log('  餐补: ${widget.mealAllowance}');
    await logger.log('  交通补贴: ${widget.transportationAllowance}');
    await logger.log('  其他补贴: ${widget.otherAllowance}');
    await logger.log('  绩效奖金: ${widget.performanceBonus}');
    await logger.log('  其他奖金: ${widget.otherBonuses}');
    await logger.log('  个税: ${widget.personalIncomeTax}');
    await logger.log('  社保: ${widget.socialInsurance}');
    await logger.log('  公积金: ${widget.housingFund}');
    await logger.log('  专项附加扣除: ${widget.otherDeductions}');
    await logger.log('  其他税收扣除: ${widget.otherTaxDeductions}');
    await logger.log('  奖金数量: ${widget.bonuses.length}');

    for (var i = 0; i < widget.bonuses.length; i++) {
      final bonus = widget.bonuses[i];
      await logger.log(
          '  奖金${i + 1}: ${bonus.name}, 类型=${bonus.type}, 金额=${bonus.amount}');
      if (bonus.type == BonusType.quarterlyBonus) {
        await logger.log('    季度奖金发放月份: ${bonus.quarterlyPaymentMonths}');
      }
    }

    _summary = await SalaryCalculationService.calculateIncomeSummary(
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
      monthlyAllowances: widget.monthlyAllowances, // 月度津贴记录
    );

    await logger.log('🧮 收入汇总计算结果:');
    await logger.log('  基本收入: ${_summary.basicIncome}');
    await logger.log('  津贴收入: ${_summary.allowanceIncome}');
    await logger.log('  奖金收入: ${_summary.bonusIncome}');
    await logger.log('  总收入: ${_summary.totalIncome}');
    await logger.log('  总税费: ${_summary.totalTax}');

    setState(() {
      _isCalculating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isCalculating) {
      return const Center(child: CircularProgressIndicator());
    }

    // Log the net income
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final logger = LoggingService();
      logger.initialize().then((_) async {
        await logger.log('  净收入: ${_summary.netIncome}');
      });
    });

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
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 20),
                    onPressed: _copyMonthlyIncomeDetails,
                    tooltip: '复制每月收入详情',
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
                    amount: '¥${_summary.totalIncome.toStringAsFixed(0)}',
                    amountColor: Colors.blue,
                    icon: Icons.account_balance_wallet,
                    monthlyDetails: _generateIncomeMonthlyDetails(),
                    calculationFormula:
                        '税前收入 = 基本工资 + 住房补贴 + 餐补 + 交通补贴 + 其他补贴 + 奖金',
                  ),
                  SizedBox(height: context.spacing12),

                  // 五险一金扣除
                  ExpandableCalculationItem(
                    title: '五险一金扣除',
                    amount:
                        '¥${(widget.socialInsurance + widget.housingFund).toStringAsFixed(0)}',
                    amountColor: Colors.red,
                    icon: Icons.security,
                    monthlyDetails: _generateSocialInsuranceMonthlyDetails(),
                    calculationFormula:
                        '五险一金 = 养老保险 + 医疗保险 + 失业保险 + 工伤保险 + 生育保险 + 住房公积金',
                  ),
                  SizedBox(height: context.spacing12),

                  // 专项附加扣除
                  if (widget.otherDeductions > 0) ...[
                    ExpandableCalculationItem(
                      title: '专项附加扣除',
                      amount: '¥${widget.otherDeductions.toStringAsFixed(0)}',
                      amountColor: Colors.purple,
                      icon: Icons.receipt_long,
                      monthlyDetails:
                          _generateSpecialDeductionsMonthlyDetails(),
                      calculationFormula:
                          '专项附加扣除 = 子女教育 + 继续教育 + 大病医疗 + 住房贷款利息 + 住房租金 + 赡养老人',
                    ),
                    SizedBox(height: context.spacing12),
                  ],

                  // 其他税收扣除
                  if (widget.otherTaxDeductions > 0) ...[
                    ExpandableCalculationItem(
                      title: '其他税收扣除',
                      amount:
                          '¥${widget.otherTaxDeductions.toStringAsFixed(0)}',
                      amountColor: Colors.brown,
                      icon: Icons.receipt_long,
                      monthlyDetails:
                          _generateOtherTaxDeductionsMonthlyDetails(),
                      calculationFormula: '其他税收扣除 = 其他可扣除项目',
                    ),
                    SizedBox(height: context.spacing12),
                  ],

                  // 个税计算详情
                  Container(
                    padding: EdgeInsets.all(context.spacing16),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: Colors.red.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.calculate,
                              color: Colors.red,
                              size: 20,
                            ),
                            SizedBox(width: context.spacing8),
                            Text(
                              '个税计算详情',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red.shade700,
                                  ),
                            ),
                          ],
                        ),
                        SizedBox(height: context.spacing8),
                        Text(
                          '全年个税总额：¥${widget.personalIncomeTax.toStringAsFixed(0)}',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red.shade700,
                                  ),
                        ),
                        SizedBox(height: context.spacing8),
                        Text(
                          '💡 点击下方月份查看详细个税计算过程',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.red.shade600,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: context.spacing12),

                  // 每月个税计算详情
                  ..._generateMonthlyTaxCalculationDetails(),

                  SizedBox(height: context.spacing12),

                  // 扣除总额汇总
                  ExpandableCalculationItem(
                    title: '扣除总额汇总',
                    amount: '¥${_summary.totalTax.toStringAsFixed(0)}',
                    amountColor: Colors.red.shade800,
                    icon: Icons.account_balance_wallet,
                    monthlyDetails: _generateTotalDeductionsMonthlyDetails(),
                    calculationFormula: '扣除总额 = 五险一金 + 专项附加扣除 + 其他税收扣除 + 个税',
                  ),
                ],
              ),
              SizedBox(height: context.spacing16),

              // 实际到手收入
              ExpandableCalculationItem(
                title: '实际到手收入',
                amount: '¥${_summary.netIncome.toStringAsFixed(0)}',
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
                    color: Colors.purple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: Colors.purple.withValues(alpha: 0.3)),
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
                            '¥${_summary.bonusIncome.toStringAsFixed(0)}',
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
                            '¥${(_summary.bonusIncome - _calculateTotalBonusTax()).toStringAsFixed(0)}', // 税后奖金
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
                          color: Colors.blue.withValues(alpha: 0.1),
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
      final month = i + 1;
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

      // 津贴收入（考虑月度津贴变化）
      final allowanceRecord = widget.monthlyAllowances != null &&
              widget.monthlyAllowances!.containsKey(month)
          ? widget.monthlyAllowances![month]!
          : AllowanceRecord(
              housingAllowance: widget.housingAllowance,
              mealAllowance: widget.mealAllowance,
              transportationAllowance: widget.transportationAllowance,
              otherAllowance: widget.otherAllowance,
            );

      // 住房补贴
      if (allowanceRecord.housingAllowance > 0) {
        components.add(
          ComponentItem(
            label: '住房补贴',
            value: '¥${allowanceRecord.housingAllowance.toStringAsFixed(0)}',
            description: '每月住房补贴',
            color: Colors.green,
          ),
        );
      }

      // 餐补
      if (allowanceRecord.mealAllowance > 0) {
        components.add(
          ComponentItem(
            label: '餐补',
            value: '¥${allowanceRecord.mealAllowance.toStringAsFixed(0)}',
            description: '每月餐费补贴',
            color: Colors.orange,
          ),
        );
      }

      // 交通补贴
      if (allowanceRecord.transportationAllowance > 0) {
        components.add(
          ComponentItem(
            label: '交通补贴',
            value:
                '¥${allowanceRecord.transportationAllowance.toStringAsFixed(0)}',
            description: '每月交通补贴',
            color: Colors.purple,
          ),
        );
      }

      // 其他补贴
      if (allowanceRecord.otherAllowance > 0) {
        components.add(
          ComponentItem(
            label: '其他补贴',
            value: '¥${allowanceRecord.otherAllowance.toStringAsFixed(0)}',
            description: '其他补贴总额',
            color: Colors.teal,
          ),
        );
      }

      // 奖金收入
      var totalBonusAmount = 0.0;
      for (final bonus in widget.bonuses) {
        final monthlyBonus = bonus.calculateMonthlyBonus(currentYear, month);

        // 只显示金额大于0的奖金
        if (monthlyBonus > 0) {
          totalBonusAmount += monthlyBonus;

          components.add(
            ComponentItem(
              label: bonus.name,
              value: '¥${monthlyBonus.toStringAsFixed(0)}',
              description: bonus.type == BonusType.thirteenthSalary
                  ? '十三薪 · ${bonus.thirteenthSalaryMonth != null ? "${bonus.thirteenthSalaryMonth}月发放" : "待定月份"}'
                  : bonus.type == BonusType.doublePayBonus
                      ? '双薪 · 年终发放'
                      : bonus.type == BonusType.yearEndBonus
                          ? '年终奖 · 年终奖税率'
                          : '${bonus.frequency == BonusFrequency.quarterly ? "季度奖金" : "奖金"} · 单独计税',
              color: Colors.pink,
            ),
          );
        }
      }

      // 计算总月收入
      final totalMonthIncome = widget.basicSalary +
          allowanceRecord.housingAllowance +
          allowanceRecord.mealAllowance +
          allowanceRecord.transportationAllowance +
          allowanceRecord.otherAllowance +
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

  // 生成五险一金每月详情
  List<MonthlyDetailItem> _generateSocialInsuranceMonthlyDetails() {
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
            label: '养老保险',
            value: '¥${(widget.socialInsurance * 0.4).toStringAsFixed(0)}',
            description: '个人缴纳养老保险',
            color: Colors.red,
          ),
        );
        components.add(
          ComponentItem(
            label: '医疗保险',
            value: '¥${(widget.socialInsurance * 0.3).toStringAsFixed(0)}',
            description: '个人缴纳医疗保险',
            color: Colors.red.shade300,
          ),
        );
        components.add(
          ComponentItem(
            label: '失业保险',
            value: '¥${(widget.socialInsurance * 0.1).toStringAsFixed(0)}',
            description: '个人缴纳失业保险',
            color: Colors.red.shade200,
          ),
        );
        components.add(
          ComponentItem(
            label: '工伤保险',
            value: '¥${(widget.socialInsurance * 0.1).toStringAsFixed(0)}',
            description: '个人缴纳工伤保险',
            color: Colors.red.shade100,
          ),
        );
        components.add(
          ComponentItem(
            label: '生育保险',
            value: '¥${(widget.socialInsurance * 0.1).toStringAsFixed(0)}',
            description: '个人缴纳生育保险',
            color: Colors.pink,
          ),
        );
      }

      // 公积金
      if (widget.housingFund > 0) {
        components.add(
          ComponentItem(
            label: '住房公积金',
            value: '¥${widget.housingFund.toStringAsFixed(0)}',
            description: '个人缴纳住房公积金',
            color: Colors.indigo,
          ),
        );
      }

      final monthlyDeductions = widget.socialInsurance + widget.housingFund;

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

  // 生成专项附加扣除每月详情
  List<MonthlyDetailItem> _generateSpecialDeductionsMonthlyDetails() {
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

      // 这里可以进一步细分专项附加扣除的各个项目
      // 目前统一显示为专项附加扣除总额
      components.add(
        ComponentItem(
          label: '专项附加扣除',
          value: '¥${widget.otherDeductions.toStringAsFixed(0)}',
          description: '子女教育、继续教育、大病医疗、住房贷款利息、住房租金、赡养老人等',
          color: Colors.purple,
        ),
      );

      details.add(
        MonthlyDetailItem.withComponents(
          month: months[i],
          amount: '¥${widget.otherDeductions.toStringAsFixed(0)}',
          components: components,
        ),
      );
    }

    return details;
  }

  // 生成其他税收扣除每月详情
  List<MonthlyDetailItem> _generateOtherTaxDeductionsMonthlyDetails() {
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

      // 其他税收扣除
      components.add(
        ComponentItem(
          label: '其他税收扣除',
          value: '¥${widget.otherTaxDeductions.toStringAsFixed(0)}',
          description: '其他可扣除项目',
          color: Colors.brown,
        ),
      );

      details.add(
        MonthlyDetailItem.withComponents(
          month: months[i],
          amount: '¥${widget.otherTaxDeductions.toStringAsFixed(0)}',
          components: components,
        ),
      );
    }

    return details;
  }

  // 生成每月个税计算详情
  List<Widget> _generateMonthlyTaxCalculationDetails() {
    final currentYear = DateTime.now().year;
    final widgets = <Widget>[];

    // 计算年度累积收入和税费，用于年度累积预扣法
    var cumulativeTaxableIncome = 0.0; // 年度累积应纳税所得额
    var cumulativeTax = 0.0; // 年度累积已预扣税款

    for (var month = 1; month <= 12; month++) {
      // 计算当月收入和扣除（不包括年终奖）
      final baseIncome = widget.basicSalary;

      // 津贴收入（考虑月度津贴变化）
      final allowanceRecord = widget.monthlyAllowances != null &&
              widget.monthlyAllowances!.containsKey(month)
          ? widget.monthlyAllowances![month]!
          : AllowanceRecord(
              housingAllowance: widget.housingAllowance,
              mealAllowance: widget.mealAllowance,
              transportationAllowance: widget.transportationAllowance,
              otherAllowance: widget.otherAllowance,
            );

      final allowanceIncome = allowanceRecord.housingAllowance +
          allowanceRecord.mealAllowance +
          allowanceRecord.transportationAllowance +
          allowanceRecord.otherAllowance;

      // 计算当月奖金（排除年终奖）
      var bonusAmount = 0.0;
      for (final bonus in widget.bonuses) {
        // 年终奖单独计税，不参与每月累计计税
        if (bonus.type != BonusType.yearEndBonus) {
          final monthlyBonus = bonus.calculateMonthlyBonus(currentYear, month);
          bonusAmount += monthlyBonus;
        }
      }

      final totalMonthlyIncome = baseIncome + allowanceIncome + bonusAmount;
      final monthlyDeductions = widget.socialInsurance + widget.housingFund;

      // 计算当月应纳税所得额（基础减除5000元，不包括年终奖）
      final monthlyTaxableIncome =
          PersonalIncomeTaxService.calculateTaxableIncome(
        totalMonthlyIncome,
        monthlyDeductions,
        widget.otherDeductions, // 专项附加扣除
        widget.otherTaxDeductions, // 其他税收扣除
      );

      // 累积当月应纳税所得额（不包括年终奖）
      cumulativeTaxableIncome += monthlyTaxableIncome;

      // 计算年度累积应纳税额
      final annualTax =
          PersonalIncomeTaxService.calculateAnnualTax(cumulativeTaxableIncome);

      // 计算当月应预扣税额（年度累积预扣法，不包括年终奖）
      final monthlyTax = annualTax - cumulativeTax;

      // 累积已预扣税款
      final previousCumulativeTax = cumulativeTax;
      cumulativeTax += monthlyTax;

      // 如果当月有年终奖，需要单独计算其税额
      var yearEndBonusAmount = 0.0;
      var yearEndBonusTax = 0.0;
      for (final bonus in widget.bonuses) {
        if (bonus.type == BonusType.yearEndBonus) {
          final monthlyBonus = bonus.calculateMonthlyBonus(currentYear, month);
          if (monthlyBonus > 0) {
            yearEndBonusAmount = monthlyBonus;
            // 年终奖单独计税
            yearEndBonusTax = PersonalIncomeTaxService.calculateYearEndBonusTax(
                yearEndBonusAmount);
            break;
          }
        }
      }

      widgets.add(
        TaxCalculationDetailItem(
          monthlyIncome: totalMonthlyIncome + yearEndBonusAmount, // 显示总收入包括年终奖
          monthlyDeductions: monthlyDeductions,
          specialDeductionMonthly: widget.otherDeductions,
          otherTaxDeductions: widget.otherTaxDeductions, // 其他税收扣除
          monthlyTax:
              (monthlyTax > 0 ? monthlyTax : 0) + yearEndBonusTax, // 总税额包括年终奖税
          month: '$month月',
          cumulativeTaxableIncome:
              cumulativeTaxableIncome, // 传递累计应纳税所得额（不包括年终奖）
          cumulativeTax: previousCumulativeTax, // 传递累计已预扣税款（计算当月税额前的值，不包括年终奖）
          yearEndBonusAmount: yearEndBonusAmount, // 年终奖金额
          yearEndBonusTax: yearEndBonusTax, // 年终奖税额
        ),
      );
    }

    return widgets;
  }

  // 生成扣除总额每月详情
  List<MonthlyDetailItem> _generateTotalDeductionsMonthlyDetails() {
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

    // 计算年度累积收入和税费，用于年度累积预扣法
    var cumulativeTaxableIncome = 0.0; // 年度累积应纳税所得额
    var cumulativeTax = 0.0; // 年度累积已预扣税款

    for (var i = 0; i < 12; i++) {
      final month = i + 1;
      final components = <ComponentItem>[];

      // 五险一金
      final socialInsuranceAmount = widget.socialInsurance + widget.housingFund;
      if (socialInsuranceAmount > 0) {
        components.add(
          ComponentItem(
            label: '五险一金',
            value: '¥${socialInsuranceAmount.toStringAsFixed(0)}',
            description: '养老、医疗、失业、工伤、生育保险 + 公积金',
            color: Colors.red,
          ),
        );
      }

      // 专项附加扣除
      if (widget.otherDeductions > 0) {
        components.add(
          ComponentItem(
            label: '专项附加扣除',
            value: '¥${widget.otherDeductions.toStringAsFixed(0)}',
            description: '子女教育、继续教育、大病医疗等',
            color: Colors.purple,
          ),
        );
      }

      // 其他税收扣除
      if (widget.otherTaxDeductions > 0) {
        components.add(
          ComponentItem(
            label: '其他税收扣除',
            value: '¥${widget.otherTaxDeductions.toStringAsFixed(0)}',
            description: '其他可扣除项目',
            color: Colors.brown,
          ),
        );
      }

      // 计算当月收入用于个税计算
      final baseIncome = widget.basicSalary;

      // 津贴收入（考虑月度津贴变化）
      final allowanceRecord = widget.monthlyAllowances != null &&
              widget.monthlyAllowances!.containsKey(month)
          ? widget.monthlyAllowances![month]!
          : AllowanceRecord(
              housingAllowance: widget.housingAllowance,
              mealAllowance: widget.mealAllowance,
              transportationAllowance: widget.transportationAllowance,
              otherAllowance: widget.otherAllowance,
            );

      final allowanceIncome = allowanceRecord.housingAllowance +
          allowanceRecord.mealAllowance +
          allowanceRecord.transportationAllowance +
          allowanceRecord.otherAllowance;

      var bonusAmount = 0.0;
      for (final bonus in widget.bonuses) {
        bonusAmount += bonus.calculateMonthlyBonus(currentYear, month);
      }

      final totalMonthlyIncome = baseIncome + allowanceIncome + bonusAmount;

      // 计算当月应纳税所得额（基础减除5000元）
      final monthlyTaxableIncome =
          PersonalIncomeTaxService.calculateTaxableIncome(
        totalMonthlyIncome,
        widget.socialInsurance + widget.housingFund,
        widget.otherDeductions,
        widget.otherTaxDeductions, // 其他税收扣除
      );

      // 累积当月应纳税所得额
      cumulativeTaxableIncome += monthlyTaxableIncome;

      // 计算年度累积应纳税额
      final annualTax =
          PersonalIncomeTaxService.calculateAnnualTax(cumulativeTaxableIncome);

      // 计算当月应预扣税额（年度累积预扣法）
      final monthlyTax = annualTax - cumulativeTax;

      // 累积已预扣税款
      cumulativeTax += monthlyTax;

      if (monthlyTax > 0) {
        components.add(
          ComponentItem(
            label: '个人所得税',
            value: '¥${monthlyTax.toStringAsFixed(0)}',
            description: '工资薪金个人所得税（年度累积预扣）',
            color: Colors.red.shade700,
          ),
        );
      }

      final totalDeductions = socialInsuranceAmount +
          widget.otherDeductions +
          widget.otherTaxDeductions +
          (monthlyTax > 0 ? monthlyTax : 0);

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
      final month = i + 1;
      final components = <ComponentItem>[];

      // 计算收入部分
      final baseIncome = widget.basicSalary;

      // 津贴收入（考虑月度津贴变化）
      final allowanceRecord = widget.monthlyAllowances != null &&
              widget.monthlyAllowances!.containsKey(month)
          ? widget.monthlyAllowances![month]!
          : AllowanceRecord(
              housingAllowance: widget.housingAllowance,
              mealAllowance: widget.mealAllowance,
              transportationAllowance: widget.transportationAllowance,
              otherAllowance: widget.otherAllowance,
            );

      final allowanceIncome = allowanceRecord.housingAllowance +
          allowanceRecord.mealAllowance +
          allowanceRecord.transportationAllowance +
          allowanceRecord.otherAllowance;

      var bonusAmount = 0.0;
      var thirteenthSalaryAmount = 0.0;
      for (final bonus in widget.bonuses) {
        final monthlyBonus = bonus.calculateMonthlyBonus(currentYear, month);
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

      // 显示十三薪（只在有金额时显示）
      final hasThirteenthSalary = widget.bonuses.any(
        (bonus) =>
            bonus.type == BonusType.thirteenthSalary ||
            bonus.type == BonusType.doublePayBonus,
      );

      if (hasThirteenthSalary && thirteenthSalaryAmount > 0) {
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
            value: '+¥${thirteenthSalaryAmount.toStringAsFixed(0)}',
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
        final monthlyBonus = bonus.calculateMonthlyBonus(currentYear, month);
        if (monthlyBonus > 0) {
          final monthlyBonusTax =
              _calculateBonusTaxPerMonth(bonus, monthlyBonus, month);
          totalMonthlyBonusTax += monthlyBonusTax;
        }
      }

      // 计算扣除部分
      final monthlyDeductions = widget.socialInsurance +
          widget.housingFund +
          widget.otherDeductions +
          widget.otherTaxDeductions +
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

      // 其他税收扣除
      if (widget.otherTaxDeductions > 0) {
        components.add(
          ComponentItem(
            label: '其他税收扣除',
            value: '-¥${widget.otherTaxDeductions.toStringAsFixed(0)}',
            description: '其他可扣除项目',
            color: Colors.grey,
          ),
        );
      }

      // 添加奖金税费扣除
      for (final bonus in widget.bonuses) {
        final monthlyBonus = bonus.calculateMonthlyBonus(currentYear, month);
        if (monthlyBonus > 0) {
          final monthlyBonusTax =
              _calculateBonusTaxPerMonth(bonus, monthlyBonus, month);
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

      // 使用年度累积预扣法计算当月税费
      // 这里需要累积计算，但为了简化，我们使用widget.personalIncomeTax作为年度总税费
      final monthlyTax = widget.personalIncomeTax / 12;
      if (monthlyTax > 0) {
        components.add(
          ComponentItem(
            label: '工资个税',
            value: '-¥${monthlyTax.toStringAsFixed(0)}',
            description: '工资薪金个人所得税（年度累积预扣）',
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
    BonusItem bonus,
    double monthlyBonus,
    int month,
  ) {
    if (monthlyBonus <= 0) {
      return 0.0;
    }

    // 根据奖金类型计算月度税费
    switch (bonus.type) {
      case BonusType.yearEndBonus:
        // 年终奖：如果在发放月份，计算全年年终奖税费
        if (month == 12) {
          return PersonalIncomeTaxService.calculateYearEndBonusTax(
            bonus.amount,
          );
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
                color: Colors.grey.withValues(alpha: 0.1),
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

  /// 生成每月收入详情的JSON格式数据
  String _generateMonthlyIncomeDetailsJson() {
    final monthlyDetails = <Map<String, dynamic>>[];
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
      final month = i + 1;
      final components = <Map<String, dynamic>>[];

      // 基本工资
      if (widget.basicSalary > 0) {
        components.add({
          '项目': '基本工资',
          '金额': widget.basicSalary,
          '描述': '每月固定基本工资',
        });
      }

      // 津贴收入（考虑月度津贴变化）
      final allowanceRecord = widget.monthlyAllowances != null &&
              widget.monthlyAllowances!.containsKey(month)
          ? widget.monthlyAllowances![month]!
          : AllowanceRecord(
              housingAllowance: widget.housingAllowance,
              mealAllowance: widget.mealAllowance,
              transportationAllowance: widget.transportationAllowance,
              otherAllowance: widget.otherAllowance,
            );

      // 住房补贴
      if (allowanceRecord.housingAllowance > 0) {
        components.add({
          '项目': '住房补贴',
          '金额': allowanceRecord.housingAllowance,
          '描述': '每月住房补贴',
        });
      }

      // 餐补
      if (allowanceRecord.mealAllowance > 0) {
        components.add({
          '项目': '餐补',
          '金额': allowanceRecord.mealAllowance,
          '描述': '每月餐费补贴',
        });
      }

      // 交通补贴
      if (allowanceRecord.transportationAllowance > 0) {
        components.add({
          '项目': '交通补贴',
          '金额': allowanceRecord.transportationAllowance,
          '描述': '每月交通补贴',
        });
      }

      // 其他补贴
      if (allowanceRecord.otherAllowance > 0) {
        components.add({
          '项目': '其他补贴',
          '金额': allowanceRecord.otherAllowance,
          '描述': '其他补贴总额',
        });
      }

      // 奖金收入
      var totalBonusAmount = 0.0;
      for (final bonus in widget.bonuses) {
        final monthlyBonus = bonus.calculateMonthlyBonus(currentYear, month);

        if (monthlyBonus > 0) {
          totalBonusAmount += monthlyBonus;
          components.add({
            '项目': bonus.name,
            '金额': monthlyBonus,
            '描述': bonus.type == BonusType.thirteenthSalary
                ? '十三薪 · ${bonus.thirteenthSalaryMonth != null ? "${bonus.thirteenthSalaryMonth}月发放" : "待定月份"}'
                : bonus.type == BonusType.doublePayBonus
                    ? '双薪 · 年终发放'
                    : bonus.type == BonusType.yearEndBonus
                        ? '年终奖 · 年终奖税率'
                        : '${bonus.frequency == BonusFrequency.quarterly ? "季度奖金" : "奖金"} · 单独计税',
          });
        }
      }

      // 计算总月收入
      final totalMonthIncome = widget.basicSalary +
          allowanceRecord.housingAllowance +
          allowanceRecord.mealAllowance +
          allowanceRecord.transportationAllowance +
          allowanceRecord.otherAllowance +
          totalBonusAmount;

      monthlyDetails.add({
        '月份': months[i],
        '总额': totalMonthIncome,
        '组成明细': components,
      });
    }

    // 创建完整的JSON结构
    final jsonData = {
      '年度': currentYear,
      '每月收入详情': monthlyDetails,
    };

    // 转换为格式化的JSON字符串
    return const JsonEncoder.withIndent('  ').convert(jsonData);
  }

  /// 复制每月收入详情到剪贴板
  Future<void> _copyMonthlyIncomeDetails() async {
    try {
      final jsonDetails = _generateMonthlyIncomeDetailsJson();
      await Clipboard.setData(ClipboardData(text: jsonDetails));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('每月收入详情已复制到剪贴板'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('复制失败，请重试'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }
}
