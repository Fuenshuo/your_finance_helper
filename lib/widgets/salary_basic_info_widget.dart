import 'package:flutter/material.dart';
import 'package:your_finance_flutter/theme/app_theme.dart';
import 'package:your_finance_flutter/utils/salary_form_validators.dart';
import 'package:your_finance_flutter/widgets/app_animations.dart';
import 'package:your_finance_flutter/widgets/app_card.dart';

class SalaryBasicInfoWidget extends StatefulWidget {
  const SalaryBasicInfoWidget({
    required this.nameController,
    required this.basicSalaryController,
    required this.salaryDay,
    required this.isMidYearMode,
    required this.useAutoCalculation,
    required this.onSalaryDayChanged,
    required this.onMidYearModeChanged,
    required this.onAutoCalculationChanged,
    super.key,
  });
  final TextEditingController nameController;
  final TextEditingController basicSalaryController;
  final int salaryDay;
  final bool isMidYearMode;
  final bool useAutoCalculation;
  final Function(int) onSalaryDayChanged;
  final Function(bool) onMidYearModeChanged;
  final Function(bool) onAutoCalculationChanged;

  @override
  State<SalaryBasicInfoWidget> createState() => _SalaryBasicInfoWidgetState();
}

class _SalaryBasicInfoWidgetState extends State<SalaryBasicInfoWidget> {
  @override
  Widget build(BuildContext context) => AppAnimations.animatedListItem(
        index: 0,
        child: AppCard(
          child: Padding(
            padding: EdgeInsets.all(context.spacing16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '基本信息',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(height: context.spacing16),

                // 收入名称
                TextFormField(
                  controller: widget.nameController,
                  decoration: InputDecoration(
                    labelText: '收入名称',
                    hintText: '如：主职工资、兼职收入',
                    prefixIcon: const Icon(Icons.work),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: SalaryFormValidators.validateIncomeName,
                ),
                SizedBox(height: context.spacing16),

                // 发工资日期
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      color: Colors.blue,
                    ),
                    SizedBox(width: context.spacing12),
                    Text(
                      '每月',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    Expanded(
                      child: Slider(
                        value: widget.salaryDay.toDouble(),
                        min: 1,
                        max: 31,
                        divisions: 30,
                        label: '${widget.salaryDay}日',
                        onChanged: (value) {
                          widget.onSalaryDayChanged(value.toInt());
                        },
                      ),
                    ),
                    Text(
                      '${widget.salaryDay}日',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.primaryAction,
                          ),
                    ),
                  ],
                ),
                SizedBox(height: context.spacing16),

                // 税收计算模式选择
                Container(
                  padding: EdgeInsets.all(context.spacing12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.blue.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.settings,
                            color: Colors.blue,
                          ),
                          SizedBox(width: context.spacing8),
                          Text(
                            '税收计算模式',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade700,
                                ),
                          ),
                          const Spacer(),
                          Switch(
                            value: widget.isMidYearMode,
                            onChanged: widget.onMidYearModeChanged,
                            activeColor: context.primaryAction,
                          ),
                        ],
                      ),
                      SizedBox(height: context.spacing8),
                      Text(
                        widget.isMidYearMode
                            ? '年中模式：已收几个月工资？系统将基于累计数据计算剩余月份的个税'
                            : '标准模式：从年初开始计算全年个税',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.blue.shade700,
                            ),
                      ),
                    ],
                  ),
                ),

                // 年中模式下的自动计算开关
                if (widget.isMidYearMode) ...[
                  SizedBox(height: context.spacing16),
                  Row(
                    children: [
                      Text(
                        '数据来源',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      const Spacer(),
                      Text(
                        '手动输入',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Switch(
                        value: widget.useAutoCalculation,
                        onChanged: widget.onAutoCalculationChanged,
                      ),
                      Text(
                        '自动计算',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      );
}
