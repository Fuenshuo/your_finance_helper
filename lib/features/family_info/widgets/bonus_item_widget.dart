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
                      Text(
                        '周期：${bonus.frequencyDisplayName}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade700,
                            ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '开始：${_formatDate(bonus.startDate)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade700,
                          ),
                    ),
                    if (bonus.endDate != null)
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
}
