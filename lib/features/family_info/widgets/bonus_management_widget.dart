import 'package:flutter/material.dart';
import 'package:your_finance_flutter/core/models/bonus_item.dart';
import 'package:your_finance_flutter/core/theme/app_design_tokens.dart';
import 'package:your_finance_flutter/core/widgets/app_animations.dart';
import 'package:your_finance_flutter/core/widgets/app_card.dart';
import 'package:your_finance_flutter/core/widgets/app_empty_state.dart';
import 'package:your_finance_flutter/core/widgets/app_primary_button.dart';
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
  void didUpdateWidget(BonusManagementWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update _tempBonuses when widget.bonuses changes
    if (oldWidget.bonuses != widget.bonuses) {
      _tempBonuses = List.from(widget.bonuses);
    }
  }

  @override
  Widget build(BuildContext context) => AppAnimations.animatedListItem(
        index: 2,
        child: AppCard(
          child: Padding(
            padding: EdgeInsets.all(AppDesignTokens.spacing16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with title and add button
                _buildHeader(context),

                SizedBox(height: AppDesignTokens.spacing16),

                // Bonus list or empty state
                // 使用 ConstrainedBox 限制最大高度，让列表可以在内部滚动
                // 如果列表项较少，会自动收缩；如果较多，会在内部滚动
                // 最大高度设置为屏幕的60%，确保有足够的空间显示内容
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.6, // 最大高度为屏幕的60%
                  ),
                  child: _buildBonusList(context),
                ),

                // Tax information (only show if there are bonuses)
                if (_tempBonuses.isNotEmpty) ...[
                  SizedBox(height: AppDesignTokens.spacing16),
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
            style: AppDesignTokens.title1(context),
          ),
          AppPrimaryButton(
            label: '添加奖金',
            icon: Icons.add,
            onPressed: _handleAddBonus,
          ),
        ],
      );

  Widget _buildBonusList(BuildContext context) {
    if (_tempBonuses.isEmpty) {
      return _buildEmptyState(context);
    } else {
      // ✅ 正确方案：使用 ListView.separated 替代 Column
      // shrinkWrap: true - 当内容较少时，只占用实际需要的空间
      // 当内容超过最大高度时，ListView 会在内部滚动（外层 ConstrainedBox 限制高度）
      return ListView.separated(
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(), // 允许内部滚动，但使用 ClampingScrollPhysics 避免过度滚动
        itemCount: _tempBonuses.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: AppDesignTokens.dividerColor(context),
        ),
        itemBuilder: (context, index) {
          final bonus = _tempBonuses[index];
          return BonusItemWidget(
            bonus: bonus,
            onEdit: () => _handleEditBonus(bonus),
            onDelete: () => _handleDeleteBonus(bonus),
          );
        },
      );
    }
  }

  Widget _buildEmptyState(BuildContext context) => AppEmptyState(
        icon: Icons.info_outline,
        title: '暂无奖金项目',
        subtitle: '点击上方按钮添加奖金和福利',
      );

  Widget _buildTaxInfo(BuildContext context) => Container(
        padding: EdgeInsets.all(AppDesignTokens.spacing12),
        decoration: BoxDecoration(
          color: AppDesignTokens.primaryAction(context).withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppDesignTokens.radiusMedium(context)),
          border: Border.all(
            color: AppDesignTokens.primaryAction(context).withOpacity(0.3),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.info_outline,
              color: AppDesignTokens.primaryAction(context),
              size: 20,
            ),
            SizedBox(width: AppDesignTokens.spacing8),
            Expanded(
              child: Text(
                '奖金税收说明：\n'
                '• 年终奖按全年一次性奖金税率计算\n'
                '• 十三薪按全年一次性奖金税率计算\n'
                '• 其他奖金按领取当月税率计算',
                style: AppDesignTokens.caption(context).copyWith(
                  color: AppDesignTokens.primaryAction(context),
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
    print('📝 Editing bonus: ${bonus.name} with quarterlyPaymentMonths: ${bonus.quarterlyPaymentMonths}');
    final updatedBonus =
        await BonusDialogManager.showEditDialog(context, bonus);
    if (updatedBonus != null) {
      print('✅ Updated bonus: ${updatedBonus.name} with quarterlyPaymentMonths: ${updatedBonus.quarterlyPaymentMonths}');
      setState(() {
        final index = _tempBonuses.indexWhere((b) => b.id == bonus.id);
        if (index != -1) {
          _tempBonuses[index] = updatedBonus;
          print('✅ Bonus updated in _tempBonuses at index $index');
        } else {
          print('❌ Bonus not found in _tempBonuses');
        }
      });
      widget.onBonusesChanged(List.from(_tempBonuses));
      print('✅ onBonusesChanged called with ${_tempBonuses.length} bonuses');
    } else {
      print('❌ No updated bonus returned from dialog');
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
