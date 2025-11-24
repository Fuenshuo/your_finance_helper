import 'package:flutter/material.dart';
import 'package:your_finance_flutter/core/theme/app_design_tokens.dart';
import 'package:your_finance_flutter/core/widgets/amount_input_field.dart';
import 'package:your_finance_flutter/core/widgets/app_animations.dart';
import 'package:your_finance_flutter/core/widgets/app_card.dart';

class TaxDeductionsWidget extends StatefulWidget {
  const TaxDeductionsWidget({
    required this.personalIncomeTaxController,
    required this.socialInsuranceController,
    required this.housingFundController,
    required this.otherDeductionsController,
    required this.specialDeductionController,
    required this.otherTaxFreeIncomeController,
    required this.otherTaxDeductionsController, // 其他税收扣除
    required this.specialDeductionMonthly,
    required this.onSpecialDeductionChanged,
    super.key,
  });
  final TextEditingController personalIncomeTaxController;
  final TextEditingController socialInsuranceController;
  final TextEditingController housingFundController;
  final TextEditingController otherDeductionsController;
  final TextEditingController specialDeductionController;
  final TextEditingController otherTaxFreeIncomeController;
  final TextEditingController otherTaxDeductionsController; // 其他税收扣除
  final double specialDeductionMonthly;
  final void Function(double) onSpecialDeductionChanged;

  @override
  State<TaxDeductionsWidget> createState() => _TaxDeductionsWidgetState();
}

class _TaxDeductionsWidgetState extends State<TaxDeductionsWidget> {
  @override
  Widget build(BuildContext context) => AppAnimations.animatedListItem(
        index: 3,
        child: AppCard(
          child: Padding(
            padding: const EdgeInsets.all(AppDesignTokens.spacing16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '扣除项（五险一金等）',
                  style: AppDesignTokens.title1(context),
                ),
                const SizedBox(height: AppDesignTokens.spacing16),

                // 个税（记录实际扣除）
                AmountInputField(
                  controller: widget.personalIncomeTaxController,
                  labelText: '个人所得税',
                  hintText: '从工资条上查看本月个税金额',
                  prefixIcon: Icon(
                    Icons.money_off,
                    color: AppDesignTokens.errorColor,
                  ),
                ),
                const SizedBox(height: AppDesignTokens.spacing16),

                // 社保（五险）（Phase 1.4 将改为只读展示）
                AmountInputField(
                  controller: widget.socialInsuranceController,
                  labelText: '社保（五险）',
                  hintText: '每月社保扣除',
                  prefixIcon: Icon(
                    Icons.security,
                    color: AppDesignTokens.primaryAction(context),
                  ),
                ),
                const SizedBox(height: AppDesignTokens.spacing16),

                // 公积金（Phase 1.4 将改为只读展示）
                AmountInputField(
                  controller: widget.housingFundController,
                  labelText: '公积金',
                  hintText: '每月公积金扣除',
                  prefixIcon: Icon(
                    Icons.savings,
                    color: AppDesignTokens.successColor(context),
                  ),
                ),
                const SizedBox(height: AppDesignTokens.spacing16),

                // 专项附加扣除
                Container(
                  padding: const EdgeInsets.all(AppDesignTokens.spacing12),
                  decoration: BoxDecoration(
                    color:
                        AppDesignTokens.primaryAction(context).withOpacity(0.1),
                    borderRadius:
                        BorderRadius.circular(AppDesignTokens.radiusMedium(context)),
                    border: Border.all(
                      color: AppDesignTokens.primaryAction(context)
                          .withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.account_balance_wallet,
                            color: AppDesignTokens.primaryAction(context),
                          ),
                          const SizedBox(width: AppDesignTokens.spacing8),
                          Expanded(
                            child: Text(
                              '专项附加扣除（月）',
                              style: AppDesignTokens.headline(context).copyWith(
                                color: AppDesignTokens.primaryAction(context),
                              ),
                            ),
                          ),
                          Text(
                            '¥${widget.specialDeductionMonthly.toStringAsFixed(0)}',
                            style: AppDesignTokens.headline(context).copyWith(
                              color: AppDesignTokens.primaryAction(context),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDesignTokens.spacing8),
                      AmountInputField(
                        labelText: '每月专项附加扣除总额',
                        hintText: '默认5000元，最高5000元/月',
                        prefixIcon: Icon(
                          Icons.edit,
                          color: AppDesignTokens.primaryAction(context),
                        ),
                        controller: widget.specialDeductionController,
                        onChanged: (value) {
                          final newValue = double.tryParse(value) ?? 5000;
                          if (newValue != widget.specialDeductionMonthly) {
                            widget.onSpecialDeductionChanged(
                              newValue.clamp(0, 5000),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDesignTokens.spacing16),

                // 其他免税收入
                AmountInputField(
                  controller: widget.otherTaxFreeIncomeController,
                  labelText: '其他免税收入',
                  hintText: '其他免税收入金额',
                  prefixIcon: Icon(
                    Icons.money_off,
                    color: AppDesignTokens.successColor(context),
                  ),
                ),
                const SizedBox(height: AppDesignTokens.spacing16),

                // 其他扣除
                AmountInputField(
                  controller: widget.otherDeductionsController,
                  labelText: '其他扣除',
                  hintText: '其他扣除项',
                  prefixIcon: Icon(
                    Icons.remove_circle,
                    color: AppDesignTokens.secondaryText(context),
                  ),
                ),

                const SizedBox(height: AppDesignTokens.spacing16),

                // 其他税收扣除
                AmountInputField(
                  controller: widget.otherTaxDeductionsController,
                  labelText: '其他税收扣除',
                  hintText: '其他可扣除的税收项目',
                  prefixIcon: Icon(
                    Icons.remove_circle_outline,
                    color: AppDesignTokens.secondaryText(context),
                  ),
                ),

                const SizedBox(height: AppDesignTokens.spacing12),

                // 专项附加扣除说明
                Container(
                  padding: const EdgeInsets.all(AppDesignTokens.spacing12),
                  decoration: BoxDecoration(
                    color:
                        AppDesignTokens.primaryAction(context).withOpacity(0.1),
                    borderRadius:
                        BorderRadius.circular(AppDesignTokens.radiusMedium(context)),
                    border: Border.all(
                      color: AppDesignTokens.primaryAction(context)
                          .withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '专项附加扣除说明',
                        style: AppDesignTokens.headline(context).copyWith(
                          color: AppDesignTokens.primaryAction(context),
                        ),
                      ),
                      const SizedBox(height: AppDesignTokens.spacing4),
                      Text(
                        '• 子女教育、继续教育、大病医疗、住房贷款利息、住房租金、赡养老人等专项附加扣除',
                        style: AppDesignTokens.caption(context).copyWith(
                          color: AppDesignTokens.primaryAction(context)
                              .withOpacity(0.8),
                        ),
                      ),
                      Text(
                        '• 每月最高5000元，全年最高6万元',
                        style: AppDesignTokens.caption(context).copyWith(
                          color: AppDesignTokens.primaryAction(context)
                              .withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
