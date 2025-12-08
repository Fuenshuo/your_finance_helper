import 'package:flutter/material.dart';
import 'package:your_finance_flutter/core/models/bonus_item.dart';
import 'package:your_finance_flutter/core/theme/app_theme.dart';
import 'package:your_finance_flutter/features/family_info/widgets/quarterly_bonus_calculator.dart';
import 'package:your_finance_flutter/features/transaction_flow/widgets/payment_timeline_widget.dart';

/// Simplified manager class for bonus-related dialogs
class BonusDialogManager {
  /// Show dialog to add a new bonus
  static Future<BonusItem?> showAddDialog(BuildContext context) async =>
      _showBonusDialog(context, null);

  /// Show dialog to edit an existing bonus
  static Future<BonusItem?> showEditDialog(
    BuildContext context,
    BonusItem bonus,
  ) async =>
      _showBonusDialog(context, bonus);

  /// Show delete confirmation dialog
  static Future<bool> showDeleteDialog(
    BuildContext context,
    BonusItem bonus,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除奖金"${bonus.name}"吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  static Future<BonusItem?> _showBonusDialog(
    BuildContext context,
    BonusItem? bonus,
  ) async {
    final formKey = GlobalKey<FormState>();
    var name = bonus?.name ?? '';
    final type = bonus?.type ?? BonusType.quarterlyBonus;
    var amount = bonus?.amount ?? 0.0;
    final frequency = bonus?.frequency ?? BonusFrequency.quarterly;
    var description = bonus?.description ?? '';

    // Quarterly bonus specific state
    var quarterlyStartDate = bonus?.startDate ?? DateTime.now();
    var quarterlyPaymentCount =
        bonus?.paymentCount ?? 4; // Default to 4 quarters

    return showDialog<BonusItem>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(bonus == null ? '添加奖金' : '编辑奖金'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bonus name
                  TextFormField(
                    initialValue: name,
                    decoration: const InputDecoration(
                      labelText: '奖金名称',
                      hintText: '如：年终奖、绩效奖金等',
                      contentPadding: EdgeInsets.only(
                        top: 20,
                        bottom: 12,
                        left: 12,
                        right: 12,
                      ),
                    ),
                    validator: (value) =>
                        value?.isEmpty ?? true ? '请输入奖金名称' : null,
                    onChanged: (value) => name = value,
                  ),
                  const SizedBox(height: 16),

                  // Bonus amount
                  TextFormField(
                    initialValue: amount > 0 ? amount.toString() : '',
                    decoration: const InputDecoration(
                      labelText: '奖金总额',
                      hintText: '请输入奖金总额',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value?.isEmpty ?? true) return '请输入奖金总额';
                      final numValue = double.tryParse(value!);
                      if (numValue == null || numValue <= 0) {
                        return '请输入有效的金额';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      final numValue = double.tryParse(value);
                      if (numValue != null) {
                        amount = numValue;
                        setState(() {});
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  if (type == BonusType.quarterlyBonus)
                    _buildQuarterlyBonusInputWithBonus(
                      context,
                      quarterlyStartDate,
                      quarterlyPaymentCount,
                      amount,
                      bonus,
                      (date) {
                        quarterlyStartDate = date;
                        setState(() {});
                      },
                      (count) {
                        quarterlyPaymentCount = count;
                        setState(() {});
                      },
                    ),

                  // Description
                  TextFormField(
                    initialValue: description,
                    decoration: const InputDecoration(
                      labelText: '备注',
                      hintText: '可选备注信息',
                    ),
                    maxLines: 2,
                    onChanged: (value) => description = value,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  final newBonus = BonusItem(
                    id: bonus?.id ??
                        DateTime.now().millisecondsSinceEpoch.toString(),
                    name: name,
                    type: type,
                    amount: amount,
                    frequency: frequency,
                    paymentCount: type == BonusType.quarterlyBonus
                        ? quarterlyPaymentCount
                        : 1, // 其他奖金类型默认1次发放
                    startDate: quarterlyStartDate,
                    creationDate: bonus?.creationDate ?? DateTime.now(),
                    updateDate: DateTime.now(),
                    quarterlyPaymentMonths: type == BonusType.quarterlyBonus
                        ? QuarterlyBonusCalculator.customQuarterlyMonths
                        : null,
                    endDate: type == BonusType.quarterlyBonus
                        ? QuarterlyBonusCalculator.calculateEndDate(
                            quarterlyStartDate,
                            quarterlyPaymentCount,
                          )
                        : null,
                    description: description.isEmpty ? null : description,
                  );
                  Navigator.of(context).pop(newBonus);
                }
              },
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildQuarterlyBonusInputWithBonus(
    BuildContext context,
    DateTime quarterlyStartDate,
    int quarterlyPaymentCount,
    double amount,
    BonusItem? bonus,
    Function(DateTime) onStartDateChanged,
    Function(int) onPaymentCountChanged,
  ) {
    // Calculate quarterly payment dates with bonus-specific months
    final quarterlyMonths = bonus?.quarterlyPaymentMonths ?? [3, 6, 9, 12];
    final paymentDates =
        QuarterlyBonusCalculator.calculatePaymentDatesFromCountWithMonths(
      quarterlyStartDate,
      quarterlyPaymentCount,
      quarterlyMonths,
    );

    final amountPerPayment =
        quarterlyPaymentCount > 0 ? (amount / quarterlyPaymentCount) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Quarterly payment schedule
        const Text(
          '发放计划：',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '总金额: ¥${amount.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                '发放次数: $quarterlyPaymentCount 次',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              if (paymentDates.isNotEmpty) ...[
                const SizedBox(height: 8),
                ...paymentDates.take(5).map(
                      (date) => Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(
                          '${date.year}年${date.month}月${date.day}日 - ¥${amountPerPayment.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                if (paymentDates.length > 5)
                  Text(
                    '... 还有 ${paymentDates.length - 5} 次发放',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Quarterly months configuration
        Row(
          children: [
            const Text(
              '季度发放月份配置：',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.info_outline,
              size: 16,
              color: quarterlyMonths.length >= 4 ? Colors.red : Colors.blue,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '💡 季度奖金最多可选择4个发放月份，已选择 ${quarterlyMonths.length}/4 个',
          style: TextStyle(
            fontSize: 12,
            color: quarterlyMonths.length >= 4 ? Colors.red : Colors.blue,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: List.generate(12, (index) {
            final month = index + 1;
            final isSelected = quarterlyMonths.contains(month);
            final isDisabled = !isSelected &&
                !QuarterlyBonusCalculator.canAddQuarterlyMonthForMonths(
                    quarterlyMonths);

            return FilterChip(
              label: Text('$month月'),
              selected: isSelected,
              onSelected: isDisabled
                  ? null
                  : (selected) {
                      // Update the bonus's quarterlyPaymentMonths
                      final updatedMonths = List<int>.from(quarterlyMonths);
                      if (selected && !isSelected) {
                        updatedMonths.add(month);
                        updatedMonths.sort();
                      } else if (!selected && isSelected) {
                        updatedMonths.remove(month);
                      }

                      // Update the bonus with new months
                      if (bonus != null) {
                        // This will be properly handled when we integrate with the parent
                      }

                      // Trigger rebuild
                      (context as Element).markNeedsBuild();
                    },
            );
          }),
        ),
        const SizedBox(height: 4),
        const Text(
          '⚠️ 注意：每个奖金项目的发放月份是独立的，更改不会影响其他奖金项目',
          style: TextStyle(fontSize: 11, color: Colors.orange),
        ),
      ],
    );
  }

  static Widget _buildQuarterlyBonusInput(
    BuildContext context,
    DateTime quarterlyStartDate,
    int quarterlyPaymentCount,
    double amount,
    Function(DateTime) onStartDateChanged,
    Function(int) onPaymentCountChanged,
  ) {
    // Calculate quarterly payment dates (only if months are configured)
    final paymentDates = QuarterlyBonusCalculator.isValidForCalculation()
        ? QuarterlyBonusCalculator.calculatePaymentDatesFromCount(
            quarterlyStartDate,
            quarterlyPaymentCount,
          )
        : <DateTime>[];

    final amountPerPayment =
        quarterlyPaymentCount > 0 ? (amount / quarterlyPaymentCount) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        // Start year-month selection
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: quarterlyStartDate,
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
            );
            if (picked != null) {
              onStartDateChanged(picked);
            }
          },
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: '开始年月',
              border: OutlineInputBorder(),
            ),
            child: Text(
              '${quarterlyStartDate.year}年${quarterlyStartDate.month}月',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Payment count selection
        Row(
          children: [
            const Text('发放次数：'),
            const SizedBox(width: 8),
            Expanded(
              child: Wrap(
                spacing: 8,
                children: [4, 8, 12, 16]
                    .map(
                      (count) => ChoiceChip(
                        label: Text('$count次'),
                        selected: quarterlyPaymentCount == count,
                        onSelected: (selected) {
                          if (selected) {
                            onPaymentCountChanged(count);
                          }
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Payment preview - Timeline
        Container(
          padding: EdgeInsets.all(context.spacing12),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary info
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '共$quarterlyPaymentCount次发放',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                  ),
                  SizedBox(height: context.spacing4),
                  Text(
                    '每次发放：¥${amountPerPayment.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.green.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  SizedBox(height: context.spacing4),
                  Text(
                    '总金额：¥${amount.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                ],
              ),
              SizedBox(height: context.spacing12),

              // Simple timeline widget
              PaymentTimelineWidget(
                paymentDates: paymentDates,
                amountPerPayment: amountPerPayment,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
