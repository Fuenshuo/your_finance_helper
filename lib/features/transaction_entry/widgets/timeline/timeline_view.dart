import 'package:flutter/material.dart';
import 'package:your_finance_flutter/features/transaction_entry/models/draft_transaction.dart';
import 'package:your_finance_flutter/features/transaction_entry/widgets/timeline/group_card.dart';

/// 时间线视图组件
class TimelineView extends StatefulWidget {
  const TimelineView({
    required this.drafts,
    required this.onDraftSelected,
    required this.onDraftDeleted,
    super.key,
  });
  final List<DraftTransaction> drafts;
  final void Function(DraftTransaction) onDraftSelected;
  final void Function(DraftTransaction) onDraftDeleted;

  @override
  State<TimelineView> createState() => _TimelineViewState();
}

class _TimelineViewState extends State<TimelineView> {
  @override
  Widget build(BuildContext context) {
    if (widget.drafts.isEmpty) {
      return _buildEmptyState();
    }

    // 按日期分组草稿
    final groupedDrafts = _groupDraftsByDate(widget.drafts);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupedDrafts.length,
      itemBuilder: (context, index) {
        final entry = groupedDrafts.entries.elementAt(index);
        return GroupCard(
          date: entry.key,
          drafts: entry.value,
          onDraftSelected: widget.onDraftSelected,
          onDraftDeleted: widget.onDraftDeleted,
        );
      },
    );
  }

  Widget _buildEmptyState() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              '暂无交易记录',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '输入交易信息开始记录',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.4),
                  ),
            ),
          ],
        ),
      );

  Map<DateTime, List<DraftTransaction>> _groupDraftsByDate(
    List<DraftTransaction> drafts,
  ) {
    final grouped = <DateTime, List<DraftTransaction>>{};

    for (final draft in drafts) {
      final date = DateTime(
        draft.transactionDate?.year ?? draft.createdAt.year,
        draft.transactionDate?.month ?? draft.createdAt.month,
        draft.transactionDate?.day ?? draft.createdAt.day,
      );

      if (grouped.containsKey(date)) {
        grouped[date]!.add(draft);
      } else {
        grouped[date] = [draft];
      }
    }

    // 按日期倒序排列
    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    final sortedGrouped = <DateTime, List<DraftTransaction>>{};

    for (final key in sortedKeys) {
      sortedGrouped[key] = grouped[key]!;
    }

    return sortedGrouped;
  }
}
