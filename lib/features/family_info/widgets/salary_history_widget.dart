import 'package:flutter/material.dart';
import 'package:your_finance_flutter/core/theme/app_design_tokens.dart';
import 'package:your_finance_flutter/core/utils/salary_form_validators.dart';
import 'package:your_finance_flutter/core/widgets/amount_input_field.dart';
import 'package:your_finance_flutter/core/widgets/app_animations.dart';
import 'package:your_finance_flutter/core/widgets/app_card.dart';
import 'package:your_finance_flutter/core/widgets/composite/input_with_action_button.dart';

class SalaryHistoryWidget extends StatefulWidget {
  const SalaryHistoryWidget({
    required this.basicSalaryController,
    required this.salaryHistory,
    required this.onHistoryChanged,
    super.key,
  });
  final TextEditingController basicSalaryController;
  final Map<DateTime, double> salaryHistory;
  final Function(Map<DateTime, double>) onHistoryChanged;

  @override
  State<SalaryHistoryWidget> createState() => _SalaryHistoryWidgetState();
}

class _SalaryHistoryWidgetState extends State<SalaryHistoryWidget> {
  late Map<DateTime, double> _tempHistory;

  @override
  void initState() {
    super.initState();
    _tempHistory = Map.from(widget.salaryHistory);
  }

  @override
  Widget build(BuildContext context) => AppAnimations.animatedListItem(
        index: 1,
        child: AppCard(
          child: Padding(
            padding: EdgeInsets.all(AppDesignTokens.spacing16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InputWithActionButton(
                  controller: widget.basicSalaryController,
                  labelText: '基本工资',
                  hintText: '每月基本工资',
                  prefixIcon: Icon(
                    Icons.account_balance_wallet,
                    color: AppDesignTokens.successColor(context),
                  ),
                  validator: SalaryFormValidators.validateBasicSalary,
                  keyboardType: TextInputType.number,
                  actionButton: IconButton(
                    onPressed: () => _showSalaryHistoryDialog(context),
                    icon: Icon(
                      Icons.history,
                      color: AppDesignTokens.primaryAction(context),
                    ),
                    tooltip: '工资历史',
                    style: IconButton.styleFrom(
                      backgroundColor: AppDesignTokens.primaryAction(context).withOpacity(0.1),
                      padding: const EdgeInsets.all(12),
                    ),
                  ),
                ),
                if (_tempHistory.isNotEmpty) ...[
                  SizedBox(height: AppDesignTokens.spacing8),
                  Container(
                    padding: EdgeInsets.all(AppDesignTokens.spacing8),
                    decoration: BoxDecoration(
                      color: AppDesignTokens.primaryAction(context).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppDesignTokens.radiusMedium(context)),
                      border: Border.all(
                        color: AppDesignTokens.primaryAction(context).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppDesignTokens.primaryAction(context),
                          size: 16,
                        ),
                        SizedBox(width: AppDesignTokens.spacing8),
                        Expanded(
                          child: Text(
                            '已记录 ${_tempHistory.length} 次工资调整',
                            style: AppDesignTokens.caption(context).copyWith(
                              color: AppDesignTokens.primaryAction(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );

  void _showSalaryHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('工资历史管理'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '记录工资的变化历史，系统会自动根据生效时间计算相应的收入。',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),
                SizedBox(height: AppDesignTokens.spacing16),

                // 添加新记录按钮
                ElevatedButton.icon(
                  onPressed: () => _showAddSalaryChangeDialog(
                    context,
                    _tempHistory,
                    setState,
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('添加工资调整'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
                SizedBox(height: AppDesignTokens.spacing16),

                // 显示工资历史记录
                if (_tempHistory.isEmpty)
                  Container(
                    padding: EdgeInsets.all(AppDesignTokens.spacing16),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text('暂无工资历史记录'),
                    ),
                  )
                else
                  Column(
                    children: (_tempHistory.entries.toList()
                          ..sort((a, b) => b.key.compareTo(a.key))) // 按时间倒序
                        .map(
                          (entry) => _buildSalaryHistoryItem(
                            entry,
                            _tempHistory,
                            setState,
                          ),
                        )
                        .toList(),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                widget.onHistoryChanged(Map.from(_tempHistory));
                Navigator.of(context).pop();
              },
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalaryHistoryItem(
    MapEntry<DateTime, double> entry,
    Map<DateTime, double> history,
    StateSetter setState,
  ) =>
      Container(
        margin: EdgeInsets.only(bottom: AppDesignTokens.spacing8),
        padding: EdgeInsets.all(AppDesignTokens.spacing12),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¥${entry.value.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                  ),
                  Text(
                    '生效日期：${_formatDate(entry.key)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => _showEditSalaryChangeDialog(
                context,
                entry,
                history,
                setState,
              ),
              icon: const Icon(Icons.edit, size: 16),
              tooltip: '编辑',
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  history.remove(entry.key);
                });
              },
              icon: const Icon(Icons.delete, size: 16, color: Colors.red),
              tooltip: '删除',
            ),
          ],
        ),
      );

  void _showAddSalaryChangeDialog(
    BuildContext context,
    Map<DateTime, double> history,
    StateSetter setState,
  ) {
    var selectedDate = DateTime.now();
    var newSalary = double.tryParse(widget.basicSalaryController.text) ?? 0;

    // 如果这是第一次添加工资调整，自动创建初始工资记录
    if (history.isEmpty) {
      final currentYear = DateTime.now().year;
      final initialSalary =
          double.tryParse(widget.basicSalaryController.text) ?? 0;
      if (initialSalary > 0) {
        history[DateTime(currentYear)] = initialSalary;
      }
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setInnerState) => AlertDialog(
          title: const Text('添加工资调整'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 生效日期选择
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    setInnerState(() => selectedDate = picked);
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: '生效日期',
                  ),
                  child: Text(_formatDate(selectedDate)),
                ),
              ),
              SizedBox(height: AppDesignTokens.spacing16),

              // 新工资输入
              TextField(
                decoration: const InputDecoration(
                  labelText: '新工资金额',
                  hintText: '请输入调整后的工资',
                ),
                keyboardType: TextInputType.number,
                controller: TextEditingController(text: newSalary.toString()),
                onChanged: (value) => newSalary = double.tryParse(value) ?? 0,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                if (newSalary > 0) {
                  setState(() {
                    history[selectedDate] = newSalary;
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text('添加'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditSalaryChangeDialog(
    BuildContext context,
    MapEntry<DateTime, double> entry,
    Map<DateTime, double> history,
    StateSetter setState,
  ) {
    var selectedDate = entry.key;
    var newSalary = entry.value;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setInnerState) => AlertDialog(
          title: const Text('编辑工资调整'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 生效日期选择
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    setInnerState(() => selectedDate = picked);
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: '生效日期',
                  ),
                  child: Text(_formatDate(selectedDate)),
                ),
              ),
              SizedBox(height: AppDesignTokens.spacing16),

              // 新工资输入
              TextField(
                decoration: const InputDecoration(
                  labelText: '工资金额',
                  hintText: '请输入工资金额',
                ),
                keyboardType: TextInputType.number,
                controller: TextEditingController(text: newSalary.toString()),
                onChanged: (value) => newSalary = double.tryParse(value) ?? 0,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                if (newSalary > 0) {
                  setState(() {
                    if (selectedDate != entry.key) {
                      history.remove(entry.key);
                    }
                    history[selectedDate] = newSalary;
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
