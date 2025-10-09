import 'package:flutter/material.dart';
import 'package:your_finance_flutter/core/models/bonus_item.dart';
import 'package:your_finance_flutter/core/theme/app_theme.dart';

/// Individual bonus item widget - handles display and actions for a single bonus
class BonusItemWidget extends StatelessWidget {
  const BonusItemWidget({
    required this.bonus,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });
  final BonusItem bonus;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => Container(
        key: ValueKey(bonus.id),
        margin: EdgeInsets.only(bottom: context.spacing12),
        padding: EdgeInsets.all(context.spacing12),
        decoration: BoxDecoration(
          color: _getBonusTypeColor(bonus.type).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _getBonusTypeColor(bonus.type).withOpacity(0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      _getBonusTypeIcon(bonus.type),
                      color: _getBonusTypeColor(bonus.type),
                      size: 20,
                    ),
                    SizedBox(width: context.spacing8),
                    Text(
                      bonus.name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit, size: 16),
                      tooltip: '编辑',
                    ),
                    IconButton(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete, size: 16),
                      tooltip: '删除',
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: context.spacing8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '金额：¥${bonus.amount.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade700,
                            ),
                      ),
                      // 根据奖金类型显示不同的日期信息
                      if (bonus.type == BonusType.thirteenthSalary ||
                          bonus.type == BonusType.yearEndBonus) ...[
                        // 十三薪和年终奖显示授予日期和归属日期
                        if (bonus.awardDate != null)
                          Text(
                            '授予：${_formatDate(bonus.awardDate!)}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey.shade700,
                                ),
                          ),
                        Text(
                          '归属：${_formatDate(bonus.attributionDate ?? bonus.startDate)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade700,
                              ),
                        ),
                      ] else if (bonus.type == BonusType.quarterlyBonus) ...[
                        // 季度奖金显示授予日期和归属日期
                        if (bonus.awardDate != null)
                          Text(
                            '授予：${_formatDate(bonus.awardDate!)}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey.shade700,
                                ),
                          ),
                        Text(
                          '归属：${_formatDate(bonus.attributionDate ?? bonus.startDate)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade700,
                              ),
                        ),
                        if (bonus.quarterlyPaymentMonths != null &&
                            bonus.quarterlyPaymentMonths!.isNotEmpty &&
                            bonus.paymentCount > 0)
                          Text(
                            '最后归属：${_calculateLastAwardDate(bonus)}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey.shade700,
                                ),
                          ),
                      ] else ...[
                        // 其他奖金类型显示周期信息
                        Text(
                          '周期：${bonus.frequencyDisplayName}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade700,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // 不再显示开始日期和结束日期
                    if (bonus.endDate != null && 
                        bonus.type != BonusType.thirteenthSalary &&
                        bonus.type != BonusType.yearEndBonus &&
                        bonus.type != BonusType.quarterlyBonus)
                      Text(
                        '结束：${_formatDate(bonus.endDate!)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade700,
                            ),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      );

  Color _getBonusTypeColor(BonusType type) {
    switch (type) {
      case BonusType.thirteenthSalary:
        return Colors.purple;
      case BonusType.yearEndBonus:
        return Colors.red;
      case BonusType.quarterlyBonus:
        return Colors.green;
      case BonusType.doublePayBonus:
        return Colors.orange;
      case BonusType.other:
        return Colors.grey;
    }
  }

  IconData _getBonusTypeIcon(BonusType type) {
    switch (type) {
      case BonusType.thirteenthSalary:
        return Icons.calendar_view_month;
      case BonusType.yearEndBonus:
        return Icons.celebration;
      case BonusType.quarterlyBonus:
        return Icons.calendar_view_week;
      case BonusType.doublePayBonus:
        return Icons.account_balance_wallet;
      case BonusType.other:
        return Icons.star;
    }
  }

  String _formatDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  /// 计算季度奖金的最后授予日期
  String _calculateLastAwardDate(BonusItem bonus) {
    // 确保必要的数据存在
    if (bonus.quarterlyPaymentMonths == null || 
        bonus.quarterlyPaymentMonths!.isEmpty || 
        bonus.paymentCount <= 0) {
      return _formatDate(bonus.attributionDate ?? bonus.startDate);
    }

    try {
      // 获取季度发放月份并排序
      final sortedMonths = List<int>.from(bonus.quarterlyPaymentMonths!)
        ..sort();
      
      // 获取基准日期（授予日期或开始日期）
      final baseDate = bonus.attributionDate ?? bonus.startDate;
      
      // 找到授予日期之后的第一个发放月份
      int firstYear = baseDate.year;
      int firstMonthIndex = -1;
      
      // 查找第一个发放月份
      for (int i = 0; i < sortedMonths.length; i++) {
        if (sortedMonths[i] > baseDate.month) {
          firstMonthIndex = i;
          break;
        }
      }
      
      // 如果当年没有合适的月份，则从下一年开始
      if (firstMonthIndex == -1) {
        firstYear++;
        firstMonthIndex = 0;
      }
      
      // 计算第bonus.paymentCount次发放的日期
      // 从第一次发放开始计算，第bonus.paymentCount次就是最后一次
      final times = bonus.paymentCount - 1; // 从0开始计数
      final totalOffset = firstMonthIndex + times;
      final rounds = totalOffset ~/ sortedMonths.length;
      final monthIndex = totalOffset % sortedMonths.length;
      
      final targetYear = firstYear + rounds;
      final targetMonth = sortedMonths[monthIndex];
      
      // 使用月份的最后一天
      final lastDay = _getDaysInMonth(targetYear, targetMonth);
      
      return '$targetYear-${targetMonth.toString().padLeft(2, '0')}-${lastDay.toString().padLeft(2, '0')}';
    } catch (e) {
      // 如果计算出错，回退到归属日期或开始日期
      return _formatDate(bonus.attributionDate ?? bonus.startDate);
    }
  }

  /// 获取指定年月的天数
  int _getDaysInMonth(int year, int month) {
    if (month == 2) {
      // 闰年判断
      if ((year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)) {
        return 29;
      }
      return 28;
    }
    
    if ([4, 6, 9, 11].contains(month)) {
      return 30;
    }
    
    return 31;
  }
}
