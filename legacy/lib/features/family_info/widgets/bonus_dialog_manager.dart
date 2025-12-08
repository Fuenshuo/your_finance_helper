import 'package:flutter/material.dart';
import 'package:your_finance_flutter/core/models/bonus_item.dart';
import 'package:your_finance_flutter/core/services/storage_service.dart';
import 'package:your_finance_flutter/core/theme/app_theme.dart';
import 'package:your_finance_flutter/core/utils/logger.dart';
import 'package:your_finance_flutter/features/family_info/widgets/quarterly_bonus_calculator.dart';

/// Simplified manager class for bonus-related dialogs
class BonusDialogManager {
  /// Show dialog to add a new bonus
  static Future<BonusItem?> showAddDialog(BuildContext context) async =>
      _showBonusDialog(context, null);

  static Future<BonusItem?> showEditDialog(
    BuildContext context,
    BonusItem bonus,
  ) async {
    Logger.debug(
        '📝 showEditDialog called with bonus: ${bonus.name} and quarterlyPaymentMonths: ${bonus.quarterlyPaymentMonths}');
    final result = await _showBonusDialog(context, bonus);
    if (result != null) {
      Logger.debug(
          '✅ showEditDialog returning bonus: ${result.name} with quarterlyPaymentMonths: ${result.quarterlyPaymentMonths}');
    } else {
      Logger.debug('❌ showEditDialog returning null');
    }
    return result;
  }

  /// Show delete confirmation dialog
  static Future<bool> showDeleteDialog(
    BuildContext context,
    BonusItem bonus,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除奖金"${bonus.name}"吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Get user's basic salary for thirteenth salary and double pay bonus
  static Future<double?> _getBasicSalary() async {
    try {
      Logger.debug('[BonusDialogManager._getBasicSalary] 💼 开始获取基本工资');
      final storageService = await StorageService.getInstance();
      final salaryIncomes = await storageService.loadSalaryIncomes();
      Logger.debug(
          '[BonusDialogManager._getBasicSalary] 📊 加载到工资收入记录: ${salaryIncomes.length} 条');

      if (salaryIncomes.isNotEmpty) {
        final basicSalary = salaryIncomes.first.basicSalary;
        Logger.debug('[BonusDialogManager._getBasicSalary] 💰 找到基本工资: ¥$basicSalary');
        Logger.debug(
            '[BonusDialogManager._getBasicSalary] 📝 工资收入详情: ${salaryIncomes.first.name}');

        if (basicSalary > 0) {
          Logger.debug(
              '[BonusDialogManager._getBasicSalary] ✅ 返回有效基本工资: ¥$basicSalary');
          return basicSalary;
        } else {
          Logger.warning(
              '[BonusDialogManager._getBasicSalary] ⚠️ 基本工资为0或null: $basicSalary');
          return null;
        }
      } else {
        Logger.warning('[BonusDialogManager._getBasicSalary] ❌ 未找到任何工资收入记录');
      }
    } catch (e) {
      Logger.error('[BonusDialogManager._getBasicSalary] 💥 获取基本工资出错: $e');
      // Ignore errors and return null
    }
    Logger.debug('[BonusDialogManager._getBasicSalary] 🚫 返回null');
    return null;
  }

  /// Get user's basic salary for a specific month (for thirteenth salary)
  /// Supports month-specific salaries based on salary history
  static Future<double?> _getBasicSalaryForMonth(int month) async {
    try {
      final storageService = await StorageService.getInstance();
      final salaryIncomes = await storageService.loadSalaryIncomes();

      if (salaryIncomes.isNotEmpty) {
        final salaryIncome = salaryIncomes.first;

        // Check if there's salary history for the specific month
        if (salaryIncome.salaryHistory != null &&
            salaryIncome.salaryHistory!.isNotEmpty) {
          // Find the most recent salary change that applies to this month
          final currentYear = DateTime.now().year;
          final targetDate = DateTime(currentYear, month);

          // Sort salary history by date (most recent first)
          final sortedHistory = salaryIncome.salaryHistory!.entries.toList()
            ..sort((a, b) => b.key.compareTo(a.key));

          for (final entry in sortedHistory) {
            try {
              // entry.key is already a DateTime object
              final historyDate = entry.key;
              final historySalary = entry.value;

              // If the history date is before or equal to target date, use this salary
              if (historyDate.isBefore(targetDate) ||
                  historyDate.isAtSameMomentAs(targetDate)) {
                if (historySalary > 0) {
                  return historySalary;
                }
              }
            } catch (e) {
              // Ignore processing errors and continue
              continue;
            }
          }
        }

        // Fallback to current basic salary if no history found
        return salaryIncome.basicSalary;
      }
    } catch (e) {
      // Ignore errors and return null
    }
    return null;
  }

  static Future<BonusItem?> _showBonusDialog(
    BuildContext context,
    BonusItem? bonus,
  ) async {
    Logger.debug(
        '📝 _showBonusDialog called with bonus: ${bonus?.name} and quarterlyPaymentMonths: ${bonus?.quarterlyPaymentMonths}');
    final type = bonus?.type ?? BonusType.quarterlyBonus;
    final name = bonus?.name ??
        (type == BonusType.thirteenthSalary
            ? '${DateTime.now().year}十三薪'
            : type == BonusType.doublePayBonus
                ? '${DateTime.now().year}双薪'
                : type == BonusType.yearEndBonus
                    ? '${DateTime.now().year}年终奖'
                    : type == BonusType.quarterlyBonus
                        ? '${DateTime.now().year}季度奖金'
                        : type == BonusType.other
                            ? '${DateTime.now().year}其他奖金'
                            : '');
    final amount = bonus?.amount ?? 0.0;
    final frequency = bonus?.frequency ?? BonusFrequency.quarterly;

    // Date related state
    final quarterlyStartDate = bonus?.startDate ?? DateTime.now();
    final quarterlyPaymentCount =
        bonus?.paymentCount ?? 4; // Default to 4 quarters
    final endDate = bonus?.endDate;

    // Thirteenth salary and year-end bonus specific state
    final thirteenthSalaryMonth = bonus?.thirteenthSalaryMonth ??
        (bonus?.type == BonusType.thirteenthSalary
            ? (bonus?.startDate.month ?? 1)
            : null) ??
        1; // 从BonusItem读取或默认
    final yearEndBonusMonth =
        bonus?.startDate.month ?? 12; // Default to December

    // 新增：授予日期和归属日期
    final awardDate = bonus?.awardDate ?? DateTime.now(); // 默认为当前日期
    final attributionDate = bonus?.attributionDate ?? awardDate; // 默认与授予日期相同

    return showDialog<BonusItem>(
      context: context,
      builder: (dialogContext) => _BonusDialog(
        bonus: bonus,
        type: type,
        name: name,
        amount: amount,
        frequency: frequency,
        quarterlyStartDate: quarterlyStartDate,
        quarterlyPaymentCount: quarterlyPaymentCount,
        endDate: endDate,
        thirteenthSalaryMonth: thirteenthSalaryMonth,
        yearEndBonusMonth: yearEndBonusMonth,
        awardDate: awardDate, // 授予日期
        attributionDate: attributionDate, // 归属日期
      ),
    );
  }
}

class _BonusDialog extends StatefulWidget {
  // 归属日期

  const _BonusDialog({
    required this.bonus,
    required this.type,
    required this.name,
    required this.amount,
    required this.frequency,
    required this.quarterlyStartDate,
    required this.quarterlyPaymentCount,
    required this.endDate,
    required this.thirteenthSalaryMonth,
    required this.yearEndBonusMonth,
    required this.awardDate, // 授予日期
    required this.attributionDate, // 归属日期
  });
  final BonusItem? bonus;
  final BonusType type;
  final String name;
  final double amount;
  final BonusFrequency frequency;
  final DateTime quarterlyStartDate;
  final int quarterlyPaymentCount;
  final DateTime? endDate;
  final int thirteenthSalaryMonth;
  final int yearEndBonusMonth;
  final DateTime awardDate; // 授予日期
  final DateTime attributionDate;

  @override
  _BonusDialogState createState() => _BonusDialogState();
}

class _BonusDialogState extends State<_BonusDialog> {
  late BonusType _type;
  late String _name;
  late double _amount;
  late BonusFrequency _frequency;
  late DateTime _quarterlyStartDate;
  late int _quarterlyPaymentCount;
  late DateTime? _endDate;
  late int _thirteenthSalaryMonth;
  late int _yearEndBonusMonth;
  late DateTime _awardDate; // 授予日期
  late DateTime _attributionDate; // 归属日期

  // Quarterly payment months state
  late List<int> _quarterlyPaymentMonths;

  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // 创建金额输入控制器
  late TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    Logger.debug('📝 _BonusDialog initState called');

    // Initialize state variables from widget properties
    _type = widget.type;
    _name = widget.name;
    _amount = widget.amount;
    _frequency = widget.frequency;
    _quarterlyStartDate = widget.quarterlyStartDate;
    _quarterlyPaymentCount = widget.quarterlyPaymentCount;
    _endDate = widget.endDate;
    _thirteenthSalaryMonth = widget.thirteenthSalaryMonth;
    _yearEndBonusMonth = widget.yearEndBonusMonth;
    _awardDate = widget.awardDate; // 授予日期
    _attributionDate = widget.attributionDate; // 归属日期

    // Initialize quarterly payment months - use the initial value from widget but allow it to be modified
    _quarterlyPaymentMonths = widget.bonus?.quarterlyPaymentMonths != null
        ? List<int>.from(widget.bonus!.quarterlyPaymentMonths!)
        : (widget.type == BonusType.quarterlyBonus
            ? <int>[] // 新增时默认为空，让用户自己选择
            : <int>[]);

    Logger.debug('📝 Initial quarterlyPaymentMonths: $_quarterlyPaymentMonths');

    // Initialize amount controller
    _amountController = TextEditingController(
      text: _amount > 0 ? _amount.toString() : '',
    );

    // 初始化时为十三薪自动填充调薪历史金额
    if (_type == BonusType.thirteenthSalary && widget.bonus != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        BonusDialogManager._getBasicSalaryForMonth(_thirteenthSalaryMonth)
            .then((monthlySalary) {
          if (monthlySalary != null && monthlySalary > 0) {
            // 获取原始基本工资
            BonusDialogManager._getBasicSalary().then((basicSalary) {
              final isOriginalBasicSalary =
                  basicSalary != null && _amount == basicSalary;
              final isCurrentMonthSalary = monthlySalary == _amount;

              // 如果金额是原始基本工资或与当前月工资相同，则更新为调薪历史金额
              if (isOriginalBasicSalary ||
                  isCurrentMonthSalary ||
                  _amount == widget.bonus!.amount) {
                _updateAmount(monthlySalary);
              }
            });
          }
        });
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  // 创建更新金额的函数
  void _updateAmount(double newAmount) {
    setState(() {
      _amount = newAmount;
      _amountController.text = newAmount.toString();
    });
  }

  // 创建更新发放次数的函数
  void _updatePaymentCount(int newCount) {
    setState(() {
      _quarterlyPaymentCount = newCount;
    });
  }

  // 创建更新季度月份状态的函数 - 确保总是更新正确的状态
  void _updateQuarterlyMonths(List<int> newMonths) {
    Logger.debug('🔄 updateQuarterlyMonths called with: $newMonths');
    Logger.debug('📊 Current state before update: $_quarterlyPaymentMonths');
    setState(() {
      _quarterlyPaymentMonths = List<int>.from(newMonths); // 创建新列表确保状态更新被检测到
    });
    Logger.debug('✅ Updated state: $_quarterlyPaymentMonths');
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(widget.bonus == null ? '添加奖金' : '编辑奖金'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bonus name
                TextFormField(
                  initialValue: _name,
                  decoration: const InputDecoration(
                    labelText: '奖金名称',
                    hintText: '如：年终奖、绩效奖金等',
                    contentPadding: EdgeInsets.only(
                      top: 20,
                      bottom: 12,
                      left: 12,
                      right: 12,
                    ),
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? '请输入奖金名称' : null,
                  onChanged: (value) => setState(() => _name = value),
                ),
                const SizedBox(height: 16),

                // Bonus type
                DropdownButtonFormField<BonusType>(
                  initialValue: _type,
                  decoration: const InputDecoration(
                    labelText: '奖金类型',
                  ),
                  items: BonusType.values
                      .map(
                        (bonusType) => DropdownMenuItem(
                          value: bonusType,
                          child: Text(bonusType.typeDisplayName),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _type = value;
                        // Reset state when switching between bonus types
                        if (_type == BonusType.quarterlyBonus) {
                          // 自动设置季度奖金名称
                          _name = '${DateTime.now().year}季度奖金';
                          _quarterlyPaymentCount = _quarterlyPaymentCount > 0
                              ? _quarterlyPaymentCount
                              : 4;
                          // 确保季度月份为空，让用户自己选择
                          if (_quarterlyPaymentMonths.isEmpty) {
                            _quarterlyPaymentMonths = [];
                          }
                        } else if (_type == BonusType.other) {
                          // 自动设置其他奖金名称
                          _name = '${DateTime.now().year}其他奖金';
                        } else if (_type == BonusType.thirteenthSalary) {
                          _thirteenthSalaryMonth = 12;
                          // 自动设置十三薪名称
                          _name = '${DateTime.now().year}十三薪';
                          // 为十三薪设置默认金额（基本工资）- 总是尝试设置，除非用户明确设置了其他金额
                          BonusDialogManager._getBasicSalary()
                              .then((defaultAmount) {
                            if (defaultAmount != null && defaultAmount > 0) {
                              // 如果金额为0或等于当前基本工资，则自动设置为基本工资
                              if (_amount == 0.0 || _amount == defaultAmount) {
                                setState(() => _amount = defaultAmount);
                              }
                            }
                          }).catchError((error) {
                            // Ignore errors
                          });
                        } else if (_type == BonusType.doublePayBonus) {
                          // 自动设置双薪名称
                          _name = '${DateTime.now().year}双薪';
                          // 为回奖金设置默认金额（基本工资）
                          BonusDialogManager._getBasicSalary()
                              .then((defaultAmount) {
                            if (defaultAmount != null &&
                                defaultAmount > 0 &&
                                _amount == 0.0) {
                              setState(() => _amount = defaultAmount);
                            }
                          });
                        } else if (_type == BonusType.yearEndBonus) {
                          // 自动设置年终奖名称
                          _name = '${DateTime.now().year}年终奖';
                          _yearEndBonusMonth = 12;
                        } else {
                          _endDate = null;
                        }
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Bonus amount (show for all bonus types)
                if (_type != BonusType.yearEndBonus)
                  Column(
                    children: [
                      // 奖金金额说明
                      Container(
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _type == BonusType.thirteenthSalary ||
                                  _type == BonusType.doublePayBonus
                              ? '💡 金额设置：系统已自动填入您的基本工资，您可以修改为实际金额'
                              : '💡 奖金年度总额：请输入全年奖金总金额，系统会根据发放频率和当前日期自动计算已发放金额',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      TextFormField(
                        controller: _amountController,
                        decoration: InputDecoration(
                          labelText: _type == BonusType.thirteenthSalary ||
                                  _type == BonusType.doublePayBonus
                              ? '金额'
                              : '奖金年度总额',
                          hintText: _type == BonusType.thirteenthSalary ||
                                  _type == BonusType.doublePayBonus
                              ? '请输入金额'
                              : '请输入奖金年度总额',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return _type == BonusType.thirteenthSalary ||
                                    _type == BonusType.doublePayBonus
                                ? '请输入金额'
                                : '请输入奖金年度总额';
                          }
                          final numValue = double.tryParse(value!);
                          if (numValue == null || numValue <= 0) {
                            return '请输入有效的金额';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          final numValue = double.tryParse(value);
                          if (numValue != null) {
                            setState(() => _amount = numValue);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),

                if (_type == BonusType.quarterlyBonus) ...[
                  // Ultra-simplified quarterly bonus month selection
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      // Award date selection (授予日期)
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _awardDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) {
                            setState(() {
                              _awardDate = picked;
                              // 自动填充归属日期为授予日期
                              _attributionDate = picked;
                            });
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: '授予日期',
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            '${_awardDate.year}年${_awardDate.month}月${_awardDate.day}日',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Attribution date selection (归属日期)
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _attributionDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) {
                            setState(() => _attributionDate = picked);
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: '归属日期',
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            '${_attributionDate.year}年${_attributionDate.month}月${_attributionDate.day}日',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Selected months display with clear button
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _quarterlyPaymentMonths.isEmpty
                                  ? '请选择发放月份（最多4个）'
                                  : '已选择: ${_quarterlyPaymentMonths.map((m) => '$m月').join(', ')}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          if (_quarterlyPaymentMonths.isNotEmpty)
                            TextButton(
                              onPressed: () {
                                Logger.debug(
                                    '🗑️ Clear button clicked, clearing all months');
                                _updateQuarterlyMonths([]);
                              },
                              child: const Text('清空'),
                            ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Simple month grid using Wrap - no rendering issues
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: List.generate(12, (index) {
                          final month = index + 1;
                          final isSelected =
                              _quarterlyPaymentMonths.contains(month);

                          return SizedBox(
                            width: 60, // Fixed width for consistent layout
                            child: TextButton(
                              onPressed: () {
                                Logger.debug(
                                    '📝 Month button clicked: $month月, currently selected: $isSelected');
                                final currentMonths =
                                    List<int>.from(_quarterlyPaymentMonths);
                                if (isSelected) {
                                  // Remove selected month
                                  currentMonths.remove(month);
                                  Logger.debug(
                                      '📝 Removing month $month月, new list: $currentMonths');
                                } else if (currentMonths.length < 4) {
                                  // Add new month
                                  currentMonths.add(month);
                                  currentMonths.sort();
                                  Logger.debug(
                                      '📝 Adding month $month月, new list: $currentMonths');
                                }
                                _updateQuarterlyMonths(currentMonths);
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: isSelected
                                    ? Colors.blue
                                    : Colors.grey.shade200,
                                foregroundColor:
                                    isSelected ? Colors.white : Colors.black87,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text('$month月'),
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 8),

                      // Simple counter
                      Text(
                        '${_quarterlyPaymentMonths.length}/4 个月份',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),

                      if (_quarterlyPaymentMonths.isEmpty) ...[
                        const SizedBox(height: 8),
                        const Text(
                          '请至少选择一个发放月份',
                          style: TextStyle(fontSize: 12, color: Colors.orange),
                        ),
                      ],
                    ],
                  ),
                ] else if (_type == BonusType.thirteenthSalary)
                  // Thirteenth salary month selection
                  Column(
                    children: [
                      const SizedBox(height: 16),

                      // Award date selection (授予日期)
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _awardDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) {
                            setState(() {
                              _awardDate = picked;
                              // 自动填充归属日期为授予日期
                              _attributionDate = picked;
                            });
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: '授予日期',
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            '${_awardDate.year}年${_awardDate.month}月${_awardDate.day}日',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Attribution date selection (归属日期)
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _attributionDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) {
                            setState(() => _attributionDate = picked);
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: '归属日期',
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            '${_attributionDate.year}年${_attributionDate.month}月${_attributionDate.day}日',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Month selection for thirteenth salary
                      DropdownButtonFormField<int>(
                        initialValue: _thirteenthSalaryMonth,
                        decoration: const InputDecoration(
                          labelText: '发放月份',
                          hintText: '选择十三薪发放月份',
                        ),
                        items: List.generate(12, (index) {
                          final month = index + 1;
                          return DropdownMenuItem(
                            value: month,
                            child: Text('$month月'),
                          );
                        }),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _thirteenthSalaryMonth = value);
                            // 如果金额为空，尝试自动获取对应月份的基本工资
                            if (_amount == 0.0) {
                              BonusDialogManager._getBasicSalaryForMonth(value)
                                  .then((basicSalary) {
                                if (basicSalary != null && basicSalary > 0) {
                                  setState(() => _amount = basicSalary);
                                }
                              }).catchError((error) {
                                // Ignore errors
                              });
                            }

                            // 为十三薪月份选择时更新金额（支持调薪）
                            if (_type == BonusType.thirteenthSalary) {
                              BonusDialogManager._getBasicSalaryForMonth(
                                      _thirteenthSalaryMonth)
                                  .then((monthlySalary) {
                                if (monthlySalary != null &&
                                    monthlySalary > 0) {
                                  // 总是更新金额，除非用户明确设置为不同的值
                                  // 这样可以支持调薪情况下的自动更新
                                  BonusDialogManager._getBasicSalary()
                                      .then((basicSalary) {
                                    final isOriginalBasicSalary =
                                        basicSalary != null &&
                                            _amount == basicSalary;
                                    final isDifferentFromMonthly =
                                        _amount != monthlySalary;

                                    if (_amount == 0.0 ||
                                        isOriginalBasicSalary ||
                                        !isDifferentFromMonthly) {
                                      _updateAmount(monthlySalary);
                                    }
                                  }).catchError((error) {
                                    // Ignore errors
                                  });
                                }
                              }).catchError((error) {
                                // Ignore errors
                              });
                            }
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      // Info text for thirteenth salary
                      Container(
                        padding: EdgeInsets.all(context.spacing8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: Colors.blue.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: Colors.blue,
                              size: 16,
                            ),
                            SizedBox(width: context.spacing8),
                            Expanded(
                              child: Text(
                                '十三薪金额将自动设置为您的月工资总额',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Colors.blue.shade700,
                                      fontSize: 12,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                else if (_type == BonusType.yearEndBonus)
                  // Year-end bonus month selection and amount input
                  Column(
                    children: [
                      const SizedBox(height: 16),

                      // Award date selection (授予日期)
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _awardDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) {
                            setState(() {
                              _awardDate = picked;
                              // 自动填充归属日期为授予日期
                              _attributionDate = picked;
                            });
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: '授予日期',
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            '${_awardDate.year}年${_awardDate.month}月${_awardDate.day}日',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Attribution date selection (归属日期)
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _attributionDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) {
                            setState(() => _attributionDate = picked);
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: '归属日期',
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            '${_attributionDate.year}年${_attributionDate.month}月${_attributionDate.day}日',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Amount input for year-end bonus
                      TextFormField(
                        initialValue: _amount > 0 ? _amount.toString() : '',
                        decoration: const InputDecoration(
                          labelText: '年终奖年度总额',
                          hintText: '请输入年终奖年度总额',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value?.isEmpty ?? true) return '请输入年终奖年度总额';
                          final numValue = double.tryParse(value!);
                          if (numValue == null || numValue <= 0) {
                            return '请输入有效的金额';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          final numValue = double.tryParse(value);
                          if (numValue != null) {
                            setState(() => _amount = numValue);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      // Month selection for year-end bonus
                      DropdownButtonFormField<int>(
                        initialValue: _yearEndBonusMonth,
                        decoration: const InputDecoration(
                          labelText: '发放月份',
                          hintText: '选择年终奖发放月份',
                        ),
                        items: List.generate(12, (index) {
                          final month = index + 1;
                          return DropdownMenuItem(
                            value: month,
                            child: Text('$month月'),
                          );
                        }),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _yearEndBonusMonth = value);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      // Info text for year-end bonus
                      Container(
                        padding: EdgeInsets.all(context.spacing8),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: Colors.orange.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star_outline,
                              color: Colors.orange,
                              size: 16,
                            ),
                            SizedBox(width: context.spacing8),
                            Expanded(
                              child: Text(
                                '年终奖单独计税，与工资分开计算个人所得税',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Colors.orange.shade700,
                                      fontSize: 12,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                else
                  // Regular bonus date inputs
                  Column(
                    children: [
                      const SizedBox(height: 16),
                      // Award date selection (授予日期)
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _awardDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) {
                            setState(() {
                              _awardDate = picked;
                              // 自动填充归属日期为授予日期
                              _attributionDate = picked;
                            });
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: '授予日期',
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            '${_awardDate.year}年${_awardDate.month}月${_awardDate.day}日',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Attribution date selection (归属日期)
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _attributionDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) {
                            setState(() => _attributionDate = picked);
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: '归属日期',
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            '${_attributionDate.year}年${_attributionDate.month}月${_attributionDate.day}日',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Start date selection
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _quarterlyStartDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) {
                            setState(() => _quarterlyStartDate = picked);
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: '开始日期',
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            '${_quarterlyStartDate.year}年${_quarterlyStartDate.month}月${_quarterlyStartDate.day}日',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // End date selection (optional)
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _endDate ?? _quarterlyStartDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) {
                            setState(() => _endDate = picked);
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: '结束日期（可选）',
                            hintText: '留空表示一次性发放',
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            _endDate != null
                                ? '${_endDate!.year}年${_endDate!.month}月${_endDate!.day}日'
                                : '无结束日期',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ),
                    ],
                  ),

                // Payment count input (show for quarterly bonus)
                if (_type == BonusType.quarterlyBonus)
                  Column(
                    children: [
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: _quarterlyPaymentCount > 0
                            ? _quarterlyPaymentCount.toString()
                            : '',
                        decoration: const InputDecoration(
                          labelText: '发放次数',
                          hintText: '请输入发放次数 (如: 4, 8, 12)',
                          border: OutlineInputBorder(),
                          suffixText: '次',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return '请输入发放次数';
                          }
                          final numValue = int.tryParse(value!);
                          if (numValue == null || numValue <= 0) {
                            return '请输入有效的发放次数';
                          }
                          if (numValue > 30) {
                            return '发放次数不能超过30次';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          final numValue = int.tryParse(value);
                          if (numValue != null && numValue > 0) {
                            _updatePaymentCount(numValue);
                          }
                        },
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState?.validate() ?? false) {
                Logger.debug('✅ Form validation passed');
                // Validate quarterly bonus payment months
                if (_type == BonusType.quarterlyBonus &&
                    _quarterlyPaymentMonths.isEmpty) {
                  Logger.debug('❌ Quarterly payment months validation failed');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('请至少选择一个季度奖金发放月份'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                Logger.debug('✅ Quarterly payment months validation passed');

                // Handle thirteenth salary and double pay bonus special cases
                if (_type == BonusType.thirteenthSalary ||
                    _type == BonusType.doublePayBonus) {
                  final basicSalary =
                      await BonusDialogManager._getBasicSalary();
                  if (basicSalary == null) {
                    // Show error if basic salary not found
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('未找到基本工资设置，请先设置工资信息'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  // For thirteenth salary and double pay bonus, use basic salary if not set
                  if (_amount == 0.0) {
                    _amount = basicSalary;
                  }
                }

                Logger.debug(
                    '📝 Creating bonus with quarterlyPaymentMonths: $_quarterlyPaymentMonths');

                final newBonus = BonusItem(
                  id: widget.bonus?.id ??
                      DateTime.now().millisecondsSinceEpoch.toString(),
                  name: _name,
                  type: _type,
                  amount: _amount,
                  frequency: _type == BonusType.thirteenthSalary
                      ? BonusFrequency.oneTime // Thirteenth salary is one-time
                      : _type == BonusType.doublePayBonus
                          ? BonusFrequency
                              .oneTime // Double pay bonus is one-time
                          : _type == BonusType.yearEndBonus
                              ? BonusFrequency
                                  .oneTime // Year-end bonus is one-time
                              : _frequency,
                  paymentCount: _type == BonusType.quarterlyBonus
                      ? _quarterlyPaymentCount
                      : _type == BonusType.thirteenthSalary
                          ? 1 // Thirteenth salary is once a year
                          : _type == BonusType.doublePayBonus
                              ? 1 // Double pay bonus is once a year
                              : _type == BonusType.yearEndBonus
                                  ? 1 // Year-end bonus is once a year
                                  : 1, // Default
                  startDate: _type == BonusType.thirteenthSalary
                      ? DateTime(
                          DateTime.now().year,
                          _thirteenthSalaryMonth,
                          15,
                        ) // Set to selected month
                      : _type == BonusType.doublePayBonus
                          ? DateTime(
                              DateTime.now().year,
                              12, // Double pay bonus typically at year end
                              15,
                            ) // Set to December
                          : _type == BonusType.yearEndBonus
                              ? DateTime(
                                  DateTime.now().year,
                                  _yearEndBonusMonth,
                                  15,
                                ) // Set to selected month
                              : _quarterlyStartDate,
                  creationDate: widget.bonus?.creationDate ?? DateTime.now(),
                  updateDate: DateTime.now(),
                  quarterlyPaymentMonths: _type == BonusType.quarterlyBonus
                      ? List<int>.from(
                          _quarterlyPaymentMonths) // Create a new list to avoid reference issues
                      : null,
                  thirteenthSalaryMonth: _type == BonusType.thirteenthSalary
                      ? _thirteenthSalaryMonth
                      : null,
                  awardDate: _awardDate, // 授予日期
                  attributionDate: _attributionDate, // 归属日期
                  endDate: _type == BonusType.quarterlyBonus
                      ? QuarterlyBonusCalculator.calculateEndDate(
                          _quarterlyStartDate,
                          _quarterlyPaymentCount,
                        )
                      : _type == BonusType.thirteenthSalary ||
                              _type == BonusType.yearEndBonus
                          ? null // One-time bonuses don't have end dates
                          : _endDate,
                );

                Logger.debug(
                    '✅ Bonus created successfully with quarterlyPaymentMonths: ${newBonus.quarterlyPaymentMonths}');
                Navigator.of(context).pop(newBonus);
              } else {
                Logger.debug('❌ Form validation failed');
              }
            },
            child: const Text('保存'),
          ),
        ],
      );
}
