import 'package:flutter/material.dart';
import 'package:your_finance_flutter/models/bonus_item.dart';
import 'package:your_finance_flutter/theme/app_theme.dart';
import 'package:your_finance_flutter/widgets/app_animations.dart';
import 'package:your_finance_flutter/widgets/app_card.dart';

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

  // 季度奖金状态
  DateTime _quarterlyStartDate = DateTime.now();
  int _quarterlyDurationYears = 5;
  final TextEditingController _durationController = TextEditingController();
  bool _quarterlySettingsInitialized = false;

  // 年份和季度选择状态
  int _selectedYear = DateTime.now().year;
  int _selectedQuarterMonth = 1; // 1, 4, 7, 10

  @override
  void initState() {
    super.initState();
    _tempBonuses = List.from(widget.bonuses);
    _initializeQuarterlySettings();
  }

  void _initializeQuarterlySettings() {
    // 只在第一次调用时进行初始化
    if (!_quarterlySettingsInitialized) {
      final now = DateTime.now();
      _quarterlyStartDate = _getNextQuarterlyDate(now);

      // 确保初始化时的年份在下拉列表范围内（从前年开始到未来8年）
      final currentYear = now.year;
      final oldYear = _selectedYear;
      _selectedYear = (_quarterlyStartDate.year >= currentYear - 2 &&
              _quarterlyStartDate.year <= currentYear + 8)
          ? _quarterlyStartDate.year
          : currentYear;

      // 确保_selectedQuarterMonth是有效的季度月份
      final quarterlyMonths = [1, 4, 7, 10];
      final oldMonth = _selectedQuarterMonth;
      _selectedQuarterMonth =
          quarterlyMonths.contains(_quarterlyStartDate.month)
              ? _quarterlyStartDate.month
              : 1; // 默认选择1月

      _quarterlyDurationYears = 5;
      _durationController.text = _quarterlyDurationYears.toString();
      _durationController.selection = TextSelection.fromPosition(
        TextPosition(offset: _durationController.text.length),
      );
      _quarterlySettingsInitialized = true;

      // 调试日志
      debugPrint('🚀 初始化季度设置:');
      debugPrint('  当前时间: $now');
      debugPrint('  计算的开始日期: $_quarterlyStartDate');
      debugPrint('  年份: $oldYear -> $_selectedYear');
      debugPrint('  季度月份: $oldMonth -> $_selectedQuarterMonth');
    }
  }

  // 根据选择的年份和季度更新开始日期
  void _updateQuarterlyStartDate() {
    final oldDate = _quarterlyStartDate;
    _quarterlyStartDate = DateTime(_selectedYear, _selectedQuarterMonth, 15);
    _quarterlySettingsInitialized = true;

    // 调试日志
    debugPrint('🎯 _updateQuarterlyStartDate:');
    debugPrint('  年份: $_selectedYear');
    debugPrint('  季度月份: $_selectedQuarterMonth');
    debugPrint('  旧日期: $oldDate');
    debugPrint('  新日期: $_quarterlyStartDate');
  }

  @override
  void dispose() {
    _durationController.dispose();
    super.dispose();
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '奖金和福利',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showAddBonusDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('添加奖金'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.primaryAction,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: context.spacing16),

                // 显示奖金项目列表
                if (_tempBonuses.isEmpty)
                  Container(
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
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.grey,
                                ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Column(
                    children: _tempBonuses.map(_buildBonusItem).toList(),
                  ),

                // 奖金税收说明
                if (_tempBonuses.isNotEmpty) ...[
                  SizedBox(height: context.spacing16),
                  Container(
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
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.blue.shade700,
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

  Widget _buildBonusItem(BonusItem bonus) => Container(
        key: ValueKey(bonus.id), // 添加Key确保列表更新正确
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
                      onPressed: () => _showEditBonusDialog(context, bonus),
                      icon: const Icon(Icons.edit, size: 16),
                      tooltip: '编辑',
                    ),
                    IconButton(
                      onPressed: () => _showDeleteBonusDialog(context, bonus),
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
      case BonusType.performanceBonus:
        return Colors.blue;
      case BonusType.projectBonus:
        return Colors.orange;
      case BonusType.holidayBonus:
        return Colors.pink;
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
      case BonusType.performanceBonus:
        return Icons.trending_up;
      case BonusType.projectBonus:
        return Icons.work;
      case BonusType.holidayBonus:
        return Icons.cake;
      case BonusType.other:
        return Icons.star;
    }
  }

  void _showAddBonusDialog(BuildContext context) {
    _showBonusDialog(context, null);
  }

  void _showEditBonusDialog(BuildContext context, BonusItem bonus) {
    _showBonusDialog(context, bonus);
  }

  void _showBonusDialog(BuildContext context, BonusItem? bonus) {
    // 临时变量
    var name = bonus?.name ?? '';
    var type = bonus?.type ?? BonusType.other;
    var amount = bonus?.amount ?? 0;
    var frequency = bonus?.frequency ?? BonusFrequency.oneTime;
    var startDate = bonus?.startDate ?? DateTime.now();
    var endDate = bonus?.endDate;
    var description = bonus?.description ?? '';


    // 如果编辑的是季度奖金，确保频率设置为每季度
    if (bonus != null && type == BonusType.quarterlyBonus) {
      frequency = BonusFrequency.quarterly;
      // 初始化季度奖金的状态变量
      _quarterlyStartDate = bonus.startDate;
      _selectedYear = bonus.startDate.year; // 同步类级别状态
      _selectedQuarterMonth = bonus.startDate.month; // 同步类级别状态
      // 如果有结束日期，计算持续年数
      if (bonus.endDate != null) {
        _quarterlyDurationYears = bonus.endDate!.year - bonus.startDate.year;
        if (_quarterlyDurationYears < 1) _quarterlyDurationYears = 1;
      } else {
        _quarterlyDurationYears = 5; // 默认5年
      }
      _durationController.text = _quarterlyDurationYears.toString();
    }

    final nameController = TextEditingController(text: name);
    final amountController = TextEditingController(text: amount.toString());
    final descriptionController = TextEditingController(text: description);

    showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(bonus == null ? '添加奖金项目' : '编辑奖金项目'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 奖金名称
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: '奖金名称',
                    hintText: '如：年终奖、绩效奖金等',
                  ),
                  onChanged: (value) => name = value,
                ),
                SizedBox(height: context.spacing16),

                // 奖金类型
                DropdownButtonFormField<BonusType>(
                  value: type,
                  decoration: const InputDecoration(
                    labelText: '奖金类型',
                  ),
                  items: BonusType.values
                      .map(
                        (type) => DropdownMenuItem(
                          value: type,
                          child: Text(type.typeDisplayName),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        type = value;
                        // 如果选择季度奖金类型，自动设置生效周期为每季度
                        if (type == BonusType.quarterlyBonus) {
                          frequency = BonusFrequency.quarterly;
                        }
                      });
                    }
                  },
                ),
                SizedBox(height: context.spacing16),

                // 奖金金额
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(
                    labelText: '奖金金额',
                    hintText: '请输入金额',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => amount = double.tryParse(value) ?? 0,
                ),
                SizedBox(height: context.spacing16),

                // 生效周期
                if (type == BonusType.quarterlyBonus) ...[
                  // 季度奖金类型时，固定显示每季度周期
                  TextField(
                    controller: TextEditingController(text: '每季度（1、4、7、10月）'),
                    decoration: const InputDecoration(
                      labelText: '生效周期',
                      filled: true,
                      fillColor: Color(0xFFF5F5F5),
                    ),
                    readOnly: true,
                  ),
                ] else ...[
                  // 其他奖金类型时，允许选择生效周期
                  DropdownButtonFormField<BonusFrequency>(
                    value: frequency,
                    decoration: const InputDecoration(
                      labelText: '生效周期',
                    ),
                    items: BonusFrequency.values
                        .map(
                          (freq) => DropdownMenuItem(
                            value: freq,
                            child: Text(
                              freq == BonusFrequency.oneTime
                                  ? '一次性'
                                  : freq == BonusFrequency.monthly
                                      ? '每月'
                                      : freq == BonusFrequency.quarterly
                                          ? '每季度（1、4、7、10月）'
                                          : freq == BonusFrequency.semiAnnual
                                              ? '每半年'
                                              : '每年',
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => frequency = value);
                      }
                    },
                  ),
                ],
                SizedBox(height: context.spacing16),

                // 季度奖金的简化输入界面
                if (frequency == BonusFrequency.quarterly) ...[
                  _buildQuarterlyBonusInput(amount),
                ] else ...[
                  // 其他奖金类型的开始日期输入
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: startDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        setState(() => startDate = picked);
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: '开始日期',
                      ),
                      child: Text(_formatDate(startDate)),
                    ),
                  ),
                  SizedBox(height: context.spacing16),

                  // 结束日期（可选）
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: endDate ?? startDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        setState(() => endDate = picked);
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: '结束日期（可选）',
                        hintText: '留空表示持续有效',
                      ),
                      child: Text(
                        endDate != null ? _formatDate(endDate!) : '无结束日期',
                      ),
                    ),
                  ),
                ],
                SizedBox(height: context.spacing16),

                // 描述
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: '描述（可选）',
                    hintText: '奖金相关说明',
                  ),
                  maxLines: 2,
                  onChanged: (value) => description = value,
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
                if (name.isNotEmpty && amount > 0) {
                  // 对于季度奖金，使用类级别的状态变量
                  final actualStartDate = frequency == BonusFrequency.quarterly
                      ? _quarterlyStartDate
                      : startDate;
                  final actualEndDate = frequency == BonusFrequency.quarterly
                      ? DateTime(
                          _quarterlyStartDate.year + _quarterlyDurationYears,
                          _quarterlyStartDate.month,
                          _quarterlyStartDate.day,
                        )
                      : endDate;

                  final newBonus = bonus?.copyWith(
                        name: name,
                        type: type,
                        amount: amount,
                        frequency: frequency,
                        startDate: actualStartDate,
                        endDate: actualEndDate,
                        description: description,
                      ) ??
                      BonusItem.create(
                        name: name,
                        type: type,
                        amount: amount,
                        frequency: frequency,
                        startDate: actualStartDate,
                        endDate: actualEndDate,
                        description: description,
                      );

                  setState(() {
                    if (bonus != null) {
                      // 编辑现有奖金
                      final index =
                          _tempBonuses.indexWhere((b) => b.id == bonus.id);
                      if (index != -1) {
                        _tempBonuses[index] = newBonus;
                      }
                    } else {
                      // 添加新奖金
                      _tempBonuses.add(newBonus);
                    }
                  });

                  widget.onBonusesChanged(List.from(_tempBonuses));
                  Navigator.of(context).pop();
                }
              },
              child: Text(bonus == null ? '添加' : '保存'),
            ),
          ],
        ),
      );
    },
  }

  void _showDeleteBonusDialog(BuildContext context, BonusItem bonus) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除奖金项目'),
        content: Text('确定要删除奖金项目"${bonus.name}"吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _tempBonuses.removeWhere((b) => b.id == bonus.id);
              });
              widget.onBonusesChanged(List.from(_tempBonuses));
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  // 构建季度奖金的简化输入界面
  Widget _buildQuarterlyBonusInput(double amount) {
    // 计算季度发放月份：1、4、7、10月
    final quarterlyMonths = [1, 4, 7, 10];

    // 使用类级别的状态变量 - 确保selected状态正确

    // 计算支付日期
    final paymentDates = _calculateQuarterlyPaymentDates(
      _quarterlyStartDate,
      _quarterlyDurationYears,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 季度发放说明
        Container(
          padding: EdgeInsets.all(context.spacing8),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.blue.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.blue, size: 16),
              SizedBox(width: context.spacing8),
              Expanded(
                child: Text(
                  '季度奖金每年1、4、7、10月发放四次',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.blue.shade700,
                        fontSize: 12,
                      ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: context.spacing16),

        // 开始年份选择
        Text(
          '开始年份',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        SizedBox(height: context.spacing8),
        DropdownButtonFormField<int>(
          value: _selectedYear,
          decoration: const InputDecoration(
            labelText: '选择年份',
            border: OutlineInputBorder(),
          ),
          items: List.generate(11, (index) {
            final year = DateTime.now().year + index - 2; // 从前年到未来8年
            return DropdownMenuItem(
              value: year,
              child: Text('$year年'),
            );
          }),
          onChanged: (value) {
            if (value != null) {
              debugPrint('📅 年份选择: $value (原值: $_selectedYear)');
              setState(() {
                _selectedYear = value;
                _updateQuarterlyStartDate();
              });
              // 移除持续年数输入框的焦点
              FocusScope.of(context).unfocus();
            }
          },
        ),
        SizedBox(height: context.spacing16),

        // 开始季度选择
        Text(
          '开始季度',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        SizedBox(height: context.spacing8),
        Wrap(
          spacing: context.spacing8,
          runSpacing: context.spacing8,
          children: quarterlyMonths.map(
            (month) {
                  debugPrint(
                      '🔄 构建季度选择ChoiceChip $month月, 当前选择: $_selectedQuarterMonth月');
              final isSelected = _selectedQuarterMonth == month;
              if (isSelected) {
                debugPrint(
                    '✅ ChoiceChip $month月 被选中 (当前选择: $_selectedQuarterMonth)');
              }
              return ChoiceChip(
                label: Text('$month月'),
                selected: isSelected,
                onSelected: (selected) {
                  debugPrint(
                      '🏷️ 季度选择: $month月, selected=$selected (当前选择: $_selectedQuarterMonth)');
                  if (selected) {
                    setState(() {
                      _selectedQuarterMonth = month;
                      _updateQuarterlyStartDate();
                    });
                    // 移除持续年数输入框的焦点
                    FocusScope.of(context).unfocus();
                  }
                },
              );
            },
          ).toList(),
        ),
        SizedBox(height: context.spacing16),

        // 计算出的开始日期（隐藏，因为用户通过年份+季度已经选择了）
        // 这个日期会自动传递给奖金项目，无需用户关心
        SizedBox(height: context.spacing16),

        // 持续年数输入
        Text(
          '持续年数',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        SizedBox(height: context.spacing8),
        TextField(
          decoration: const InputDecoration(
            labelText: '持续年数',
            hintText: '请输入持续年数（如：4）',
            suffixText: '年',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          controller: _durationController,
          onChanged: (value) {
            final years = int.tryParse(value) ?? _quarterlyDurationYears;
            if (years > 0 && years <= 50 && value.isNotEmpty) {
              // 限制在1-50年之间
              setState(() {
                _quarterlyDurationYears = years;
              });
            }
          },
          onSubmitted: (value) {
            // 提交时验证输入并失去焦点
            final years = int.tryParse(value) ?? _quarterlyDurationYears;
            if (years <= 0 || years > 50 || value.isEmpty) {
              setState(() {
                _durationController.text = _quarterlyDurationYears.toString();
              });
            }
            FocusScope.of(context).unfocus();
          },
        ),
        SizedBox(height: context.spacing16),

        // 发放预览
        Text(
          '发放预览（前10次）',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        SizedBox(height: context.spacing8),
        Container(
          padding: EdgeInsets.all(context.spacing12),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '共${paymentDates.length}次发放，总额：¥${(amount * paymentDates.length).toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
              ),
              SizedBox(height: context.spacing8),
              Wrap(
                spacing: context.spacing8,
                runSpacing: context.spacing8,
                children: paymentDates
                    .take(10)
                    .map(
                      (date) => Chip(
                        label: Text(
                          '${date.year}年${date.month}月',
                          style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor: Colors.green.withOpacity(0.2),
                      ),
                    )
                    .toList(),
              ),
              if (paymentDates.length > 10)
                Text(
                  '... 还有${paymentDates.length - 10}次发放',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // 获取下一个季度发放日期
  DateTime _getNextQuarterlyDate(DateTime fromDate) {
    final quarterlyMonths = [1, 4, 7, 10];
    final currentMonth = fromDate.month;

    // 找到最近的季度月
    for (final month in quarterlyMonths) {
      if (month >= currentMonth) {
        return DateTime(fromDate.year, month, 15);
      }
    }

    // 如果当前月份已经过了最后一个季度月，返回下一年的第一个季度月
    return DateTime(fromDate.year + 1, 1, 15);
  }

  // 计算季度奖金发放日期列表
  List<DateTime> _calculateQuarterlyPaymentDates(
    DateTime startDate,
    int durationYears,
  ) {
    final dates = <DateTime>[];
    final quarterlyMonths = [1, 4, 7, 10];

    for (var year = 0; year < durationYears; year++) {
      for (final month in quarterlyMonths) {
        final paymentDate = DateTime(startDate.year + year, month, 15);

        // 确保日期不早于开始日期
        if (paymentDate.isAtSameMomentAs(startDate) ||
            paymentDate.isAfter(startDate)) {
          dates.add(paymentDate);
        }
      }
    }

    return dates;
  }

  String _formatDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
