import 'package:flutter/material.dart';
import 'package:your_finance_flutter/theme/app_theme.dart';
import 'package:your_finance_flutter/widgets/amount_input_field.dart';
import 'package:your_finance_flutter/widgets/app_animations.dart';
import 'package:your_finance_flutter/widgets/app_card.dart';

class TaxDeductionsWidget extends StatefulWidget {
  const TaxDeductionsWidget({
    required this.personalIncomeTaxController,
    required this.socialInsuranceController,
    required this.housingFundController,
    required this.otherDeductionsController,
    required this.specialDeductionController,
    required this.otherTaxFreeIncomeController,
    required this.autoCalculateTax,
    required this.specialDeductionMonthly,
    required this.onAutoCalculateTaxChanged,
    required this.onSpecialDeductionChanged,
    super.key,
  });
  final TextEditingController personalIncomeTaxController;
  final TextEditingController socialInsuranceController;
  final TextEditingController housingFundController;
  final TextEditingController otherDeductionsController;
  final TextEditingController specialDeductionController;
  final TextEditingController otherTaxFreeIncomeController;
  final bool autoCalculateTax;
  final double specialDeductionMonthly;
  final Function(bool) onAutoCalculateTaxChanged;
  final Function(double) onSpecialDeductionChanged;

  @override
  State<TaxDeductionsWidget> createState() => _TaxDeductionsWidgetState();
}

class _TaxDeductionsWidgetState extends State<TaxDeductionsWidget> {
  @override
  Widget build(BuildContext context) => AppAnimations.animatedListItem(
        index: 3,
        child: AppCard(
          child: Padding(
            padding: EdgeInsets.all(context.spacing16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '扣除项（五险一金等）',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(height: context.spacing16),

                // 个税
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.account_balance,
                          color: Colors.red,
                        ),
                        SizedBox(width: context.spacing8),
                        Text(
                          '个人所得税',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Text(
                              '自动计算',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: context.secondaryText,
                                  ),
                            ),
                            Switch(
                              value: widget.autoCalculateTax,
                              onChanged: widget.onAutoCalculateTaxChanged,
                              activeColor: context.primaryAction,
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: context.spacing8),
                    AmountInputField(
                      controller: widget.personalIncomeTaxController,
                      labelText: widget.autoCalculateTax ? '自动计算结果' : '手动输入',
                      hintText:
                          widget.autoCalculateTax ? '系统自动计算' : '请输入每月个税扣除',
                      prefixIcon: const Icon(
                        Icons.calculate,
                        color: Colors.red,
                      ),
                      enabled: !widget.autoCalculateTax, // 自动计算时禁用手动输入
                    ),
                  ],
                ),
                SizedBox(height: context.spacing16),

                // 社保（五险）
                AmountInputField(
                  controller: widget.socialInsuranceController,
                  labelText: '社保（五险）',
                  hintText: '每月社保扣除',
                  prefixIcon: const Icon(Icons.security, color: Colors.blue),
                ),
                SizedBox(height: context.spacing16),

                // 公积金
                AmountInputField(
                  controller: widget.housingFundController,
                  labelText: '公积金',
                  hintText: '每月公积金扣除',
                  prefixIcon: const Icon(Icons.savings, color: Colors.green),
                ),
                SizedBox(height: context.spacing16),

                // 专项附加扣除
                Container(
                  padding: EdgeInsets.all(context.spacing12),
                  decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.teal.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.account_balance_wallet,
                            color: Colors.teal,
                          ),
                          SizedBox(width: context.spacing8),
                          Expanded(
                            child: Text(
                              '专项附加扣除（月）',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.teal.shade700,
                                  ),
                            ),
                          ),
                          Text(
                            '¥${widget.specialDeductionMonthly.toStringAsFixed(0)}',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal.shade700,
                                ),
                          ),
                        ],
                      ),
                      SizedBox(height: context.spacing8),
                      AmountInputField(
                        labelText: '每月专项附加扣除总额',
                        hintText: '默认5000元，最高5000元/月',
                        prefixIcon: const Icon(
                          Icons.edit,
                          color: Colors.teal,
                        ),
                        controller: widget.specialDeductionController,
                        onChanged: (value) {
                          final newValue =
                              double.tryParse(value ?? '0') ?? 5000;
                          if (newValue != widget.specialDeductionMonthly) {
                            widget.onSpecialDeductionChanged(
                                newValue.clamp(0, 5000));
                          }
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: context.spacing16),

                // 其他免税收入
                AmountInputField(
                  controller: widget.otherTaxFreeIncomeController,
                  labelText: '其他免税收入',
                  hintText: '其他免税收入金额',
                  prefixIcon: const Icon(
                    Icons.money_off,
                    color: Colors.green,
                  ),
                ),
                SizedBox(height: context.spacing16),

                // 其他扣除
                AmountInputField(
                  controller: widget.otherDeductionsController,
                  labelText: '其他扣除',
                  hintText: '其他扣除项',
                  prefixIcon: const Icon(
                    Icons.remove_circle,
                    color: Colors.grey,
                  ),
                ),

                SizedBox(height: context.spacing12),

                // 专项附加扣除说明
                Container(
                  padding: EdgeInsets.all(context.spacing12),
                  decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.teal.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '专项附加扣除说明',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.teal.shade700,
                            ),
                      ),
                      SizedBox(height: context.spacing4),
                      Text(
                        '• 子女教育、继续教育、大病医疗、住房贷款利息、住房租金、赡养老人等专项附加扣除',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.teal.shade700,
                            ),
                      ),
                      Text(
                        '• 每月最高5000元，全年最高6万元',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.teal.shade700,
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
