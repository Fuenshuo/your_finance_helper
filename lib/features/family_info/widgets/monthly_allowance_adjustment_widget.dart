import 'package:flutter/material.dart';
import 'package:your_finance_flutter/core/models/budget.dart';
import 'package:your_finance_flutter/core/theme/app_theme.dart';
import 'package:your_finance_flutter/core/widgets/amount_input_field.dart';
import 'package:your_finance_flutter/core/widgets/app_animations.dart';
import 'package:your_finance_flutter/core/widgets/app_card.dart';

class MonthlyAllowanceAdjustmentWidget extends StatefulWidget {
  const MonthlyAllowanceAdjustmentWidget({
    required this.defaultAllowances,
    required this.monthlyAllowances,
    required this.onAllowancesChanged,
    super.key,
  });

  final AllowanceRecord defaultAllowances;
  final Map<int, AllowanceRecord> monthlyAllowances;
  final void Function(Map<int, AllowanceRecord>) onAllowancesChanged;

  @override
  State<MonthlyAllowanceAdjustmentWidget> createState() =>
      _MonthlyAllowanceAdjustmentWidgetState();
}

class _MonthlyAllowanceAdjustmentWidgetState
    extends State<MonthlyAllowanceAdjustmentWidget> {
  late Map<int, AllowanceRecord> _tempAllowances;

  @override
  void initState() {
    super.initState();
    _tempAllowances = Map.from(widget.monthlyAllowances);
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
                // 标题和说明
                Text(
                  '月度津贴调整',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(height: context.spacing8),
                Text(
                  '您可以为每个月份设置不同的津贴金额，未设置的月份将使用默认值。',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.secondaryText,
                      ),
                ),
                SizedBox(height: context.spacing16),

                // 快捷操作按钮
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _applyDefaultToAll,
                        icon: const Icon(Icons.copy, size: 16),
                        label: const Text('应用默认值'),
                      ),
                    ),
                    SizedBox(width: context.spacing8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _clearAll,
                        icon: const Icon(Icons.clear, size: 16),
                        label: const Text('全部清零'),
                      ),
                    ),
                    SizedBox(width: context.spacing8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _distributeEvenly,
                        icon: const Icon(Icons.calculate, size: 16),
                        label: const Text('平均分配'),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: context.spacing16),

                // 月份津贴调整表格
                _buildMonthlyAllowanceTable(),
              ],
            ),
          ),
        ),
      );

  Widget _buildMonthlyAllowanceTable() => Container(
        decoration: BoxDecoration(
          border: Border.all(color: context.dividerColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            // 表头
            Container(
              padding: EdgeInsets.all(context.spacing12),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: const Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      '月份',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      '住房补贴',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      '餐补',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      '交通补贴',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      '其他补贴',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      '小计',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            // 月份行
            ...List.generate(12, (index) {
              final month = index + 1;
              final allowanceRecord =
                  _tempAllowances[month] ?? widget.defaultAllowances;
              return _buildMonthlyAllowanceRow(month, allowanceRecord);
            }),
          ],
        ),
      );

  Widget _buildMonthlyAllowanceRow(
    int month,
    AllowanceRecord allowanceRecord,
  ) =>
      Container(
        padding: EdgeInsets.all(context.spacing8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: context.dividerColor,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            // 月份
            Expanded(
              flex: 2,
              child: Text(
                '$month月',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            // 住房补贴
            Expanded(
              flex: 3,
              child: _buildAllowanceField(
                month,
                'housing',
                allowanceRecord.housingAllowance,
                (value) => _updateAllowance(month, housing: value),
              ),
            ),
            // 餐补
            Expanded(
              flex: 3,
              child: _buildAllowanceField(
                month,
                'meal',
                allowanceRecord.mealAllowance,
                (value) => _updateAllowance(month, meal: value),
              ),
            ),
            // 交通补贴
            Expanded(
              flex: 3,
              child: _buildAllowanceField(
                month,
                'transportation',
                allowanceRecord.transportationAllowance,
                (value) => _updateAllowance(month, transportation: value),
              ),
            ),
            // 其他补贴
            Expanded(
              flex: 3,
              child: _buildAllowanceField(
                month,
                'other',
                allowanceRecord.otherAllowance,
                (value) => _updateAllowance(month, other: value),
              ),
            ),
            // 小计
            Expanded(
              flex: 3,
              child: Text(
                '¥${allowanceRecord.totalAllowance.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      );

  Widget _buildAllowanceField(
    int month,
    String type,
    double value,
    void Function(double) onChanged,
  ) {
    final controller = TextEditingController(text: value.toString());

    return AmountInputField(
      controller: controller,
      onChanged: (value) {
        final numericValue = double.tryParse(value) ?? 0.0;
        onChanged(numericValue);
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
    );
  }

  void _updateAllowance(
    int month, {
    double? housing,
    double? meal,
    double? transportation,
    double? other,
  }) {
    final currentRecord = _tempAllowances[month] ?? widget.defaultAllowances;
    final newRecord = AllowanceRecord(
      housingAllowance: housing ?? currentRecord.housingAllowance,
      mealAllowance: meal ?? currentRecord.mealAllowance,
      transportationAllowance:
          transportation ?? currentRecord.transportationAllowance,
      otherAllowance: other ?? currentRecord.otherAllowance,
    );

    // 如果新记录与默认记录相同，则移除记录以节省空间
    if (newRecord.housingAllowance ==
            widget.defaultAllowances.housingAllowance &&
        newRecord.mealAllowance == widget.defaultAllowances.mealAllowance &&
        newRecord.transportationAllowance ==
            widget.defaultAllowances.transportationAllowance &&
        newRecord.otherAllowance == widget.defaultAllowances.otherAllowance) {
      setState(() {
        _tempAllowances.remove(month);
      });
    } else {
      setState(() {
        _tempAllowances[month] = newRecord;
      });
    }

    // 通知父组件津贴记录已更改
    widget.onAllowancesChanged(Map.from(_tempAllowances));
  }

  // 应用默认值到所有月份
  void _applyDefaultToAll() {
    setState(() {
      _tempAllowances.clear();
      for (var i = 1; i <= 12; i++) {
        _tempAllowances[i] = widget.defaultAllowances;
      }
    });
    widget.onAllowancesChanged(Map.from(_tempAllowances));
  }

  // 清空所有月份的津贴设置
  void _clearAll() {
    setState(() {
      _tempAllowances.clear();
    });
    widget.onAllowancesChanged(Map.from(_tempAllowances));
  }

  // 平均分配津贴（根据默认津贴总额平均分配）
  void _distributeEvenly() {
    final totalHousing = widget.defaultAllowances.housingAllowance * 12;
    final totalMeal = widget.defaultAllowances.mealAllowance * 12;
    final totalTransportation =
        widget.defaultAllowances.transportationAllowance * 12;
    final totalOther = widget.defaultAllowances.otherAllowance * 12;

    final monthlyHousing = totalHousing / 12;
    final monthlyMeal = totalMeal / 12;
    final monthlyTransportation = totalTransportation / 12;
    final monthlyOther = totalOther / 12;

    setState(() {
      _tempAllowances.clear();
      for (var i = 1; i <= 12; i++) {
        _tempAllowances[i] = AllowanceRecord(
          housingAllowance: monthlyHousing,
          mealAllowance: monthlyMeal,
          transportationAllowance: monthlyTransportation,
          otherAllowance: monthlyOther,
        );
      }
    });
    widget.onAllowancesChanged(Map.from(_tempAllowances));
  }
}
