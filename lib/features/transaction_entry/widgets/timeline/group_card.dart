import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/draft_transaction.dart';
import 'transaction_row.dart';

/// 分组卡片组件 - 按日期分组显示交易
class GroupCard extends StatelessWidget {
  final DateTime date;
  final List<DraftTransaction> drafts;
  final Function(DraftTransaction) onDraftSelected;
  final Function(DraftTransaction) onDraftDeleted;

  const GroupCard({
    super.key,
    required this.date,
    required this.drafts,
    required this.onDraftSelected,
    required this.onDraftDeleted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // 计算当日总金额
    final totalAmount = drafts.fold<double>(
      0,
      (sum, draft) => sum + (draft.amount ?? 0),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 分组头部
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Text(
                  DateFormat('MM月dd日 EEEE', 'zh_CN').format(date),
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Text(
                  '¥${totalAmount.toStringAsFixed(2)}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: totalAmount >= 0
                        ? colorScheme.primary
                        : colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // 交易列表
          ...drafts.map((draft) => TransactionRow(
            draft: draft,
            onTap: () => onDraftSelected(draft),
            onDelete: () => onDraftDeleted(draft),
          )),
        ],
      ),
    );
  }
}

