import 'package:flutter/material.dart';
import 'package:your_finance_flutter/core/theme/app_design_tokens.dart';
import 'package:your_finance_flutter/core/utils/salary_form_validators.dart';
import 'package:your_finance_flutter/core/widgets/app_animations.dart';
import 'package:your_finance_flutter/core/widgets/app_card.dart';
import 'package:your_finance_flutter/core/widgets/app_text_field.dart';

class SalaryBasicInfoWidget extends StatefulWidget {
  const SalaryBasicInfoWidget({
    required this.nameController,
    required this.basicSalaryController,
    required this.salaryDay,
    required this.onSalaryDayChanged,
    this.isMidYearMode = false,
    this.useAutoCalculation = false,
    this.onMidYearModeChanged,
    this.onAutoCalculationChanged,
    super.key,
  });
  final TextEditingController nameController;
  final TextEditingController basicSalaryController;
  final int salaryDay;
  final void Function(int) onSalaryDayChanged;
  final bool isMidYearMode;
  final bool useAutoCalculation;
  final ValueChanged<bool>? onMidYearModeChanged;
  final ValueChanged<bool>? onAutoCalculationChanged;

  @override
  State<SalaryBasicInfoWidget> createState() => _SalaryBasicInfoWidgetState();
}

class _SalaryBasicInfoWidgetState extends State<SalaryBasicInfoWidget> {
  @override
  Widget build(BuildContext context) => AppAnimations.animatedListItem(
        index: 0,
        child: AppCard(
          child: Padding(
            padding: EdgeInsets.all(AppDesignTokens.spacing16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '基本信息',
                  style: AppDesignTokens.title1(context),
                ),
                SizedBox(height: AppDesignTokens.spacing16),

                // 收入名称
                AppTextField(
                  controller: widget.nameController,
                  labelText: '收入名称',
                  hintText: '如：主职工资、兼职收入',
                  prefixIcon: const Icon(Icons.work),
                  validator: SalaryFormValidators.validateIncomeName,
                ),
                SizedBox(height: AppDesignTokens.spacing16),

                // 发工资日期
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: AppDesignTokens.primaryAction(context),
                    ),
                    SizedBox(width: AppDesignTokens.spacing12),
                    Text(
                      '每月',
                      style: AppDesignTokens.body(context),
                    ),
                    Expanded(
                      child: Slider(
                        value: widget.salaryDay.toDouble(),
                        min: 1,
                        max: 31,
                        divisions: 30,
                        label: '${widget.salaryDay}日',
                        activeColor: AppDesignTokens.primaryAction(context),
                        onChanged: (value) {
                          widget.onSalaryDayChanged(value.toInt());
                        },
                      ),
                    ),
                    Text(
                      '${widget.salaryDay}日',
                      style: AppDesignTokens.headline(context).copyWith(
                        color: AppDesignTokens.primaryAction(context),
                      ),
                    ),
                  ],
                ),

                // Mode toggles
                if (widget.onMidYearModeChanged != null) ...[
                  SizedBox(height: AppDesignTokens.spacing16),
                  SwitchListTile.adaptive(
                    title: const Text('启用补录模式（年中调整）'),
                    subtitle: const Text('根据今年已发工资重新计算累计数据'),
                    value: widget.isMidYearMode,
                    onChanged: widget.onMidYearModeChanged,
                  ),
                ],
                if (widget.onAutoCalculationChanged != null) ...[
                  SwitchListTile.adaptive(
                    title: const Text('自动估算累计金额'),
                    subtitle: const Text('开启后会根据当前补贴/税费估算累计值'),
                    value: widget.useAutoCalculation,
                    onChanged: widget.onAutoCalculationChanged,
                  ),
                ],
              ],
            ),
          ),
        ),
      );
}
