import 'package:flutter/material.dart';
import 'package:your_finance_flutter/models/bonus_item.dart';
import 'package:your_finance_flutter/services/salary_calculation_service.dart';
import 'package:your_finance_flutter/theme/app_theme.dart';
import 'package:your_finance_flutter/widgets/app_animations.dart';
import 'package:your_finance_flutter/widgets/app_card.dart';

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

              // 汇总信息
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryItem(
                      '税前收入',
                      '¥${summary.totalIncome.toStringAsFixed(0)}',
                      Colors.blue,
                    ),
                  ),
                  SizedBox(width: context.spacing16),
                  Expanded(
                    child: _buildSummaryItem(
                      '扣除总额',
                      '¥${summary.totalTax.toStringAsFixed(0)}',
                      Colors.red,
                    ),
                  ),
                ],
              ),
              SizedBox(height: context.spacing16),

              // 实际到手收入
              Container(
                padding: EdgeInsets.all(context.spacing16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '实际到手收入',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      '¥${summary.netIncome.toStringAsFixed(0)}',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                    ),
                  ],
                ),
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
                        '奖金税收详情',
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
                          return _buildBonusDetailRow(
                            bonus.name,
                            bonusAmount,
                            _getBonusTaxForItem(bonus),
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
                            '奖金税收',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.purple.shade700,
                                ),
                          ),
                          Text(
                            '¥${(summary.bonusIncome * 0.1).toStringAsFixed(0)}', // 简化计算
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
                            '¥${(summary.bonusIncome * 0.9).toStringAsFixed(0)}', // 简化计算
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

  Widget _buildSummaryItem(String label, String value, Color color) =>
      Container(
        padding: EdgeInsets.all(context.spacing12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.secondaryText,
                  ),
            ),
            SizedBox(height: context.spacing4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
          ],
        ),
      );

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

  double _getBonusTaxForItem(BonusItem bonus) {
    // 简化的奖金税收计算
    return bonus.amount * 0.1; // 假设10%的税率
  }
}
