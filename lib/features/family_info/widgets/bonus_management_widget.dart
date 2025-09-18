import 'package:flutter/material.dart';
import 'package:your_finance_flutter/core/models/bonus_item.dart';
import 'package:your_finance_flutter/core/theme/app_theme.dart';
import 'package:your_finance_flutter/core/widgets/app_animations.dart';
import 'package:your_finance_flutter/core/widgets/app_card.dart';
import 'package:your_finance_flutter/features/family_info/widgets/bonus_dialog_manager.dart';
import 'package:your_finance_flutter/features/family_info/widgets/bonus_item_widget.dart';

/// Main widget for managing bonuses - follows KISS principle by delegating to specialized components
class BonusManagementWidget extends StatefulWidget {
  const BonusManagementWidget({
    required this.bonuses,
    required this.onBonusesChanged,
    super.key,
  });

  final List<BonusItem> bonuses;
  final void Function(List<BonusItem>) onBonusesChanged;

  @override
  State<BonusManagementWidget> createState() => _BonusManagementWidgetState();
}

class _BonusManagementWidgetState extends State<BonusManagementWidget> {
  late List<BonusItem> _tempBonuses;

  @override
  void initState() {
    super.initState();
    _tempBonuses = List.from(widget.bonuses);
  }

  @override
  Widget build(BuildContext context) => AppAnimations.animatedListItem(
        index: 2,
        child: AppCard(
          child: Padding(
            padding: EdgeInsets.all(context.spacing16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with title and add button
                _buildHeader(context),

                SizedBox(height: context.spacing16),

                // Bonus list or empty state
                _buildBonusList(context),

                // Tax information (only show if there are bonuses)
                if (_tempBonuses.isNotEmpty) ...[
                  SizedBox(height: context.spacing16),
                  _buildTaxInfo(context),
                ],
              ],
            ),
          ),
        ),
      );

  Widget _buildHeader(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '奖金和福利',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          ElevatedButton.icon(
            onPressed: _handleAddBonus,
            icon: const Icon(Icons.add),
            label: const Text('添加奖金'),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.primaryAction,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      );

  Widget _buildBonusList(BuildContext context) {
    if (_tempBonuses.isEmpty) {
      return _buildEmptyState(context);
    } else {
      return Column(
        children: _tempBonuses
            .map(
              (bonus) => BonusItemWidget(
                bonus: bonus,
                onEdit: () => _handleEditBonus(bonus),
                onDelete: () => _handleDeleteBonus(bonus),
              ),
            )
            .toList(),
      );
    }
  }

  Widget _buildEmptyState(BuildContext context) => Container(
        padding: EdgeInsets.all(context.spacing16),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.grey.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.info_outline,
              color: Colors.grey,
              size: 20,
            ),
            SizedBox(width: context.spacing8),
            Expanded(
              child: Text(
                '暂无奖金项目，点击上方按钮添加',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
              ),
            ),
          ],
        ),
      );

  Widget _buildTaxInfo(BuildContext context) => Container(
        padding: EdgeInsets.all(context.spacing12),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.blue.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.info_outline,
              color: Colors.blue,
              size: 20,
            ),
            SizedBox(width: context.spacing8),
            Expanded(
              child: Text(
                '奖金税收说明：\n'
                '• 年终奖按全年一次性奖金税率计算\n'
                '• 十三薪按全年一次性奖金税率计算\n'
                '• 其他奖金按领取当月税率计算',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.blue.shade700,
                    ),
              ),
            ),
          ],
        ),
      );

  Future<void> _handleAddBonus() async {
    final newBonus = await BonusDialogManager.showAddDialog(context);
    if (newBonus != null) {
      setState(() {
        _tempBonuses.add(newBonus);
      });
      widget.onBonusesChanged(List.from(_tempBonuses));
    }
  }

  Future<void> _handleEditBonus(BonusItem bonus) async {
    final updatedBonus =
        await BonusDialogManager.showEditDialog(context, bonus);
    if (updatedBonus != null) {
      setState(() {
        final index = _tempBonuses.indexWhere((b) => b.id == bonus.id);
        if (index != -1) {
          _tempBonuses[index] = updatedBonus;
        }
      });
      widget.onBonusesChanged(List.from(_tempBonuses));
    }
  }

  Future<void> _handleDeleteBonus(BonusItem bonus) async {
    final shouldDelete =
        await BonusDialogManager.showDeleteDialog(context, bonus);
    if (shouldDelete) {
      setState(() {
        _tempBonuses.removeWhere((b) => b.id == bonus.id);
      });
      widget.onBonusesChanged(List.from(_tempBonuses));
    }
  }
}
