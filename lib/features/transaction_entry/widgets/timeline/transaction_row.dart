import 'package:flutter/material.dart';
import 'package:your_finance_flutter/features/transaction_entry/models/draft_transaction.dart';

/// 交易行组件
class TransactionRow extends StatelessWidget {
  const TransactionRow({
    required this.draft,
    required this.onTap,
    required this.onDelete,
    super.key,
  });
  final DraftTransaction draft;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // 类型图标
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getTypeColor(draft.type).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getTypeIcon(draft.type),
                color: _getTypeColor(draft.type),
                size: 20,
              ),
            ),

            const SizedBox(width: 12),

            // 交易信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    draft.description ?? '未命名交易',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${draft.categoryId ?? '未分类'} • ${draft.accountId ?? '未指定账户'}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // 金额
            Text(
              draft.amount != null
                  ? '¥${draft.amount!.toStringAsFixed(2)}'
                  : '未确定',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: draft.amount != null && draft.amount! >= 0
                    ? colorScheme.primary
                    : colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),

            // 删除按钮
            IconButton(
              onPressed: onDelete,
              icon: Icon(
                Icons.delete_outline,
                color: colorScheme.error,
                size: 20,
              ),
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
              padding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(TransactionType? type) {
    switch (type) {
      case TransactionType.expense:
        return Colors.red;
      case TransactionType.income:
        return Colors.green;
      case TransactionType.transfer:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(TransactionType? type) {
    switch (type) {
      case TransactionType.expense:
        return Icons.remove_circle_outline;
      case TransactionType.income:
        return Icons.add_circle_outline;
      case TransactionType.transfer:
        return Icons.swap_horiz;
      default:
        return Icons.help_outline;
    }
  }
}
