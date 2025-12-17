import 'package:flutter/material.dart';
import 'package:your_finance_flutter/core/models/bonus_item.dart';
import 'package:your_finance_flutter/core/theme/app_design_tokens.dart';
import 'package:your_finance_flutter/core/widgets/composite/actionable_list_item.dart';

/// Individual bonus item widget - handles display and actions for a single bonus
/// Uses standard ActionableListItem for consistent UI
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
  Widget build(BuildContext context) {
    return ActionableListItem(
      key: ValueKey(bonus.id),
      title: bonus.name,
      leading: Icon(
        _getBonusTypeIcon(bonus.type),
        color: _getBonusTypeColor(bonus.type),
        size: 20,
      ),
      subtitle: _buildSubtitle(context),
      actions: [
        IconButton(
          onPressed: onEdit,
          icon: Icon(
            Icons.edit,
            size: 18,
            color: AppDesignTokens.primaryAction(context),
          ),
          tooltip: '编辑',
          padding: EdgeInsets.all(AppDesignTokens.spacing4),
          constraints: const BoxConstraints(),
        ),
        SizedBox(width: AppDesignTokens.spacing4),
        IconButton(
          onPressed: onDelete,
          icon: Icon(
            Icons.delete,
            size: 18,
            color: AppDesignTokens.errorColor,
          ),
          tooltip: '删除',
          padding: EdgeInsets.all(AppDesignTokens.spacing4),
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  String _buildSubtitle(BuildContext context) {
    final parts = <String>[];

    // 金额（始终显示）
    parts.add('¥${bonus.amount.toStringAsFixed(0)}');

    // 根据奖金类型显示关键日期信息（简化显示）
    if (bonus.type == BonusType.thirteenthSalary ||
        bonus.type == BonusType.yearEndBonus) {
      // 十三薪和年终奖：只显示归属日期（最重要的信息）
      parts.add('归属：${_formatDate(bonus.attributionDate ?? bonus.startDate)}');
    } else if (bonus.type == BonusType.quarterlyBonus) {
      // 季度奖金：显示归属日期
      parts.add('归属：${_formatDate(bonus.attributionDate ?? bonus.startDate)}');
    } else {
      // 其他奖金类型：显示周期信息
      parts.add('周期：${bonus.frequencyDisplayName}');
    }

    return parts.join(' • ');
  }

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
