import 'package:flutter/material.dart';
import 'package:your_finance_flutter/core/models/bonus_item.dart';
import 'package:your_finance_flutter/core/services/storage_service.dart';
import 'package:your_finance_flutter/core/theme/app_theme.dart';
import 'package:your_finance_flutter/features/family_info/widgets/quarterly_bonus_calculator.dart';
import 'package:your_finance_flutter/features/transaction_flow/widgets/payment_timeline_widget.dart';

/// Simplified manager class for bonus-related dialogs
class BonusDialogManager {
  /// Show dialog to add a new bonus
  static Future<BonusItem?> showAddDialog(BuildContext context) async =>
      _showBonusDialog(context, null);

  /// Show dialog to edit an existing bonus
  static Future<BonusItem?> showEditDialog(
    BuildContext context,
    BonusItem bonus,
  ) async =>
      _showBonusDialog(context, bonus);

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
      final storageService = await StorageService.getInstance();
      final salaryIncomes = await storageService.loadSalaryIncomes();

      if (salaryIncomes.isNotEmpty) {
        // Return only basic salary for thirteenth salary and double pay bonus
        return salaryIncomes.first.basicSalary;
      }
    } catch (e) {
      // Ignore errors and return null
    }
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
    final formKey = GlobalKey<FormState>();
    var type = bonus?.type ?? BonusType.quarterlyBonus;
    var name = bonus?.name ??
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
    var amount = bonus?.amount ?? 0.0;
    final frequency = bonus?.frequency ?? BonusFrequency.quarterly;

    // Date related state
    var quarterlyStartDate = bonus?.startDate ?? DateTime.now();
    var quarterlyPaymentCount =
        bonus?.paymentCount ?? 4; // Default to 4 quarters
    var endDate = bonus?.endDate;

    // Thirteenth salary and year-end bonus specific state
    var thirteenthSalaryMonth = bonus?.thirteenthSalaryMonth ??
        bonus?.startDate.month ??
        12; // 从BonusItem读取或默认
    var yearEndBonusMonth = bonus?.startDate.month ?? 12; // Default to December

    return showDialog<BonusItem>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          // Quarterly payment months state
          final quarterlyPaymentMonths = bonus?.quarterlyPaymentMonths ??
              (type == BonusType.quarterlyBonus ? [3, 6, 9, 12] : <int>[]);

          // 创建金额输入控制器
          final amountController = TextEditingController(
            text: amount > 0 ? amount.toString() : '',
          );

          // 创建更新金额的函数
          void updateAmount(double newAmount) {
            setState(() {
              amount = newAmount;
              amountController.text = newAmount.toString();
            });
          }

          // 初始化时为十三薪自动填充调薪历史金额
          if (type == BonusType.thirteenthSalary && bonus != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _getBasicSalaryForMonth(thirteenthSalaryMonth)
                  .then((monthlySalary) {
                if (monthlySalary != null && monthlySalary > 0) {
                  // 获取原始基本工资
                  _getBasicSalary().then((basicSalary) {
                    final isOriginalBasicSalary =
                        basicSalary != null && amount == basicSalary;
                    final isCurrentMonthSalary = monthlySalary == amount;

                    // 如果金额是原始基本工资或与当前月工资相同，则更新为调薪历史金额
                    if (isOriginalBasicSalary ||
                        isCurrentMonthSalary ||
                        amount == bonus.amount) {
                      updateAmount(monthlySalary);
                    }
                  });
                }
              });
            });
          }

          return AlertDialog(
            title: Text(bonus == null ? '添加奖金' : '编辑奖金'),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bonus name
                    TextFormField(
                      initialValue: name,
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
                      onChanged: (value) => name = value,
                    ),
                    const SizedBox(height: 16),

                    // Bonus type
                    DropdownButtonFormField<BonusType>(
                      initialValue: type,
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
                            type = value;
                            // Reset state when switching between bonus types
                            if (type == BonusType.quarterlyBonus) {
                              quarterlyPaymentCount = 4;
                            } else if (type == BonusType.thirteenthSalary) {
                              thirteenthSalaryMonth = 12;
                              // 为十三薪设置默认金额（基本工资）- 总是尝试设置，除非用户明确设置了其他金额
                              _getBasicSalary().then((defaultAmount) {
                                if (defaultAmount != null &&
                                    defaultAmount > 0) {
                                  // 如果金额为0或等于当前基本工资，则自动设置为基本工资
                                  if (amount == 0.0 ||
                                      amount == defaultAmount) {
                                    setState(() => amount = defaultAmount);
                                  }
                                }
                              }).catchError((error) {
                                // Ignore errors
                              });
                            } else if (type == BonusType.doublePayBonus) {
                              // 为回奖金设置默认金额（基本工资）
                              _getBasicSalary().then((defaultAmount) {
                                if (defaultAmount != null &&
                                    defaultAmount > 0 &&
                                    amount == 0.0) {
                                  setState(() => amount = defaultAmount);
                                }
                              });
                            } else if (type == BonusType.yearEndBonus) {
                              yearEndBonusMonth = 12;
                            } else {
                              endDate = null;
                            }
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Bonus amount (show for all bonus types)
                    if (type != BonusType.yearEndBonus)
                      Column(
                        children: [
                          // 奖金金额说明
                          Container(
                            padding: const EdgeInsets.all(8),
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              type == BonusType.thirteenthSalary ||
                                      type == BonusType.doublePayBonus
                                  ? '💡 金额设置：系统已自动填入您的基本工资，您可以修改为实际金额'
                                  : '💡 奖金年度总额：请输入全年奖金总金额，系统会根据发放频率和当前日期自动计算已发放金额',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          TextFormField(
                            controller: amountController,
                            decoration: InputDecoration(
                              labelText: type == BonusType.thirteenthSalary ||
                                      type == BonusType.doublePayBonus
                                  ? '金额'
                                  : '奖金年度总额',
                              hintText: type == BonusType.thirteenthSalary ||
                                      type == BonusType.doublePayBonus
                                  ? '请输入金额'
                                  : '请输入奖金年度总额',
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return type == BonusType.thirteenthSalary ||
                                        type == BonusType.doublePayBonus
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
                                amount = numValue;
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),

                    if (type == BonusType.quarterlyBonus) ...[
                      // Simple quarterly bonus configuration
                      const SizedBox(height: 16),
                      const Text('季度奖金配置',
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      Text('发放月份: ${quarterlyPaymentMonths.join(", ")}月'),
                    ] else if (type == BonusType.thirteenthSalary)
                      // Thirteenth salary month selection
                      Column(
                        children: [
                          const SizedBox(height: 16),
                          // Month selection for thirteenth salary
                          DropdownButtonFormField<int>(
                            initialValue: thirteenthSalaryMonth,
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
                                thirteenthSalaryMonth = value;
                                setState(() {});
                                // 如果金额为空，尝试自动获取对应月份的基本工资
                                if (amount == 0.0) {
                                  _getBasicSalaryForMonth(value)
                                      .then((basicSalary) {
                                    if (basicSalary != null &&
                                        basicSalary > 0) {
                                      setState(() => amount = basicSalary);
                                    }
                                  }).catchError((error) {
                                    // Ignore errors
                                  });
                                }

                                // 为十三薪月份选择时更新金额（支持调薪）
                                if (type == BonusType.thirteenthSalary) {
                                  _getBasicSalaryForMonth(thirteenthSalaryMonth)
                                      .then((monthlySalary) {
                                    if (monthlySalary != null &&
                                        monthlySalary > 0) {
                                      // 总是更新金额，除非用户明确设置为不同的值
                                      // 这样可以支持调薪情况下的自动更新
                                      _getBasicSalary().then((basicSalary) {
                                        final isOriginalBasicSalary =
                                            basicSalary != null &&
                                                amount == basicSalary;
                                        final isDifferentFromMonthly =
                                            amount != monthlySalary;

                                        if (amount == 0.0 ||
                                            isOriginalBasicSalary ||
                                            !isDifferentFromMonthly) {
                                          updateAmount(monthlySalary);
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
                                color: Colors.blue.withOpacity(0.3),
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
                    else if (type == BonusType.yearEndBonus)
                      // Year-end bonus month selection and amount input
                      Column(
                        children: [
                          const SizedBox(height: 16),
                          // Amount input for year-end bonus
                          TextFormField(
                            initialValue: amount > 0 ? amount.toString() : '',
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
                                amount = numValue;
                                setState(() {});
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          // Month selection for year-end bonus
                          DropdownButtonFormField<int>(
                            initialValue: yearEndBonusMonth,
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
                                yearEndBonusMonth = value;
                                setState(() {});
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          // Info text for year-end bonus
                          Container(
                            padding: EdgeInsets.all(context.spacing8),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: Colors.orange.withOpacity(0.3),
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
                          // Start date selection
                          InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: quarterlyStartDate,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2030),
                              );
                              if (picked != null) {
                                quarterlyStartDate = picked;
                                setState(() {});
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: '开始日期',
                                border: OutlineInputBorder(),
                              ),
                              child: Text(
                                '${quarterlyStartDate.year}年${quarterlyStartDate.month}月${quarterlyStartDate.day}日',
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
                                initialDate: endDate ?? quarterlyStartDate,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2030),
                              );
                              if (picked != null) {
                                endDate = picked;
                                setState(() {});
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: '结束日期（可选）',
                                hintText: '留空表示一次性发放',
                                border: OutlineInputBorder(),
                              ),
                              child: Text(
                                endDate != null
                                    ? '${endDate!.year}年${endDate!.month}月${endDate!.day}日'
                                    : '无结束日期',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
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
                  if (formKey.currentState?.validate() ?? false) {
                    // Handle thirteenth salary and double pay bonus special cases
                    if (type == BonusType.thirteenthSalary ||
                        type == BonusType.doublePayBonus) {
                      final basicSalary = await _getBasicSalary();
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
                      if (amount == 0.0) {
                        amount = basicSalary;
                      }
                    }

                    final newBonus = BonusItem(
                      id: bonus?.id ??
                          DateTime.now().millisecondsSinceEpoch.toString(),
                      name: name,
                      type: type,
                      amount: amount,
                      frequency: type == BonusType.thirteenthSalary
                          ? BonusFrequency
                              .oneTime // Thirteenth salary is one-time
                          : type == BonusType.doublePayBonus
                              ? BonusFrequency
                                  .oneTime // Double pay bonus is one-time
                              : type == BonusType.yearEndBonus
                                  ? BonusFrequency
                                      .oneTime // Year-end bonus is one-time
                                  : frequency,
                      paymentCount: type == BonusType.quarterlyBonus
                          ? quarterlyPaymentCount
                          : type == BonusType.thirteenthSalary
                              ? 1 // Thirteenth salary is once a year
                              : type == BonusType.doublePayBonus
                                  ? 1 // Double pay bonus is once a year
                                  : type == BonusType.yearEndBonus
                                      ? 1 // Year-end bonus is once a year
                                      : 1, // Default
                      startDate: type == BonusType.thirteenthSalary
                          ? DateTime(
                              DateTime.now().year,
                              thirteenthSalaryMonth,
                              15,
                            ) // Set to selected month
                          : type == BonusType.doublePayBonus
                              ? DateTime(
                                  DateTime.now().year,
                                  12, // Double pay bonus typically at year end
                                  15,
                                ) // Set to December
                              : type == BonusType.yearEndBonus
                                  ? DateTime(
                                      DateTime.now().year,
                                      yearEndBonusMonth,
                                      15,
                                    ) // Set to selected month
                                  : quarterlyStartDate,
                      creationDate: bonus?.creationDate ?? DateTime.now(),
                      updateDate: DateTime.now(),
                      quarterlyPaymentMonths: type == BonusType.quarterlyBonus
                          ? quarterlyPaymentMonths
                          : null,
                      thirteenthSalaryMonth: type == BonusType.thirteenthSalary
                          ? thirteenthSalaryMonth
                          : null,
                      endDate: type == BonusType.quarterlyBonus
                          ? QuarterlyBonusCalculator.calculateEndDate(
                              quarterlyStartDate,
                              quarterlyPaymentCount,
                            )
                          : type == BonusType.thirteenthSalary ||
                                  type == BonusType.yearEndBonus
                              ? null // One-time bonuses don't have end dates
                              : endDate,
                    );

                    Navigator.of(context).pop(newBonus);
                  }
                },
                child: const Text('保存'),
              ),
            ],
          );
        },
      ),
    );
  }

  static Widget _buildQuarterlyBonusInputWithBonus(
    BuildContext context,
    DateTime quarterlyStartDate,
    int quarterlyPaymentCount,
    double amount,
    BonusItem? bonus,
    Function(DateTime) onStartDateChanged,
    Function(int) onPaymentCountChanged,
  ) {
    // Calculate quarterly payment dates with bonus-specific months
    final quarterlyMonths = bonus?.quarterlyPaymentMonths ?? [3, 6, 9, 12];
    final paymentDates =
        QuarterlyBonusCalculator.calculatePaymentDatesFromCountWithMonths(
      quarterlyStartDate,
      quarterlyPaymentCount,
      quarterlyMonths,
    );

    final amountPerPayment =
        quarterlyPaymentCount > 0 ? (amount / quarterlyPaymentCount) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Quarterly payment schedule
        const Text(
          '发放计划：',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '总金额: ¥${amount.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                '发放次数: $quarterlyPaymentCount 次',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              if (paymentDates.isNotEmpty) ...[
                const SizedBox(height: 8),
                ...paymentDates.take(5).map(
                      (date) => Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(
                          '${date.year}年${date.month}月${date.day}日 - ¥${amountPerPayment.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                if (paymentDates.length > 5)
                  Text(
                    '... 还有 ${paymentDates.length - 5} 次发放',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 16),
      ],
    );
  }

  static Widget _buildQuarterlyBonusInput(
    BuildContext context,
    DateTime quarterlyStartDate,
    int quarterlyPaymentCount,
    double amount,
    Function(DateTime) onStartDateChanged,
    Function(int) onPaymentCountChanged,
  ) {
    // Calculate quarterly payment dates (fallback to old behavior)
    final paymentDates =
        QuarterlyBonusCalculator.calculatePaymentDatesFromCount(
      quarterlyStartDate,
      quarterlyPaymentCount,
    );

    final amountPerPayment =
        quarterlyPaymentCount > 0 ? (amount / quarterlyPaymentCount) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        // Start year-month selection
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: quarterlyStartDate,
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
            );
            if (picked != null) {
              onStartDateChanged(picked);
            }
          },
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: '开始年月',
              border: OutlineInputBorder(),
            ),
            child: Text(
              '${quarterlyStartDate.year}年${quarterlyStartDate.month}月',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
        const SizedBox(height: 16),

        const SizedBox(height: 16),

        // Payment count selection
        Row(
          children: [
            const Text('发放次数：'),
            const SizedBox(width: 8),
            Expanded(
              child: Wrap(
                spacing: 8,
                children: [4, 8, 12, 16]
                    .map(
                      (count) => ChoiceChip(
                        label: Text('$count次'),
                        selected: quarterlyPaymentCount == count,
                        onSelected: (selected) {
                          if (selected) {
                            onPaymentCountChanged(count);
                          }
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Payment preview - Timeline
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
              // Summary info
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '共$quarterlyPaymentCount次发放',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                  ),
                  SizedBox(height: context.spacing4),
                  Text(
                    '每次发放：¥${amountPerPayment.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.green.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  SizedBox(height: context.spacing4),
                  Text(
                    '总金额：¥${amount.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                ],
              ),
              SizedBox(height: context.spacing12),

              // Simple timeline widget
              PaymentTimelineWidget(
                paymentDates: paymentDates,
                amountPerPayment: amountPerPayment,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
