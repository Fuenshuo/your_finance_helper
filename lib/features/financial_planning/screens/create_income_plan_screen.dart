import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:your_finance_flutter/core/models/budget.dart';
import 'package:your_finance_flutter/core/models/income_plan.dart';
import 'package:your_finance_flutter/core/providers/budget_provider.dart';
import 'package:your_finance_flutter/core/providers/income_plan_provider.dart';
import 'package:your_finance_flutter/core/theme/app_theme.dart';
import 'package:your_finance_flutter/core/widgets/app_card.dart';
import 'package:your_finance_flutter/features/family_info/screens/salary_income_setup_screen.dart';

/// 创建收入计划页面
class CreateIncomePlanScreen extends StatefulWidget {
  const CreateIncomePlanScreen({super.key});

  @override
  State<CreateIncomePlanScreen> createState() => _CreateIncomePlanScreenState();
}

class _CreateIncomePlanScreenState extends State<CreateIncomePlanScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedTemplate = 'ordinary'; // 'ordinary', 'detailed', or 'salary'
  String _planName = '';
  double _amount = 0.0;
  String _frequency = 'monthly';
  String _selectedWallet = '';
  DateTime _startDate = DateTime.now();
  SalaryIncome? _selectedSalary; // 选择的工资收入

  final List<String> _frequencies = [
    'daily',
    'weekly',
    'monthly',
    'quarterly',
    'yearly',
  ];
  final List<String> _wallets = ['工资卡', '储蓄卡', '投资账户'];

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: context.primaryBackground,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            '创建收入计划',
            style: context.textTheme.headlineMedium,
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(context.responsiveSpacing16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 计划类型选择
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🎯 计划模板',
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: context.spacing16),
                      Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildTemplateOption(
                                  context,
                                  icon: Icons.monetization_on,
                                  title: '普通收入',
                                  subtitle: '一次性或定期收入',
                                  selected: _selectedTemplate == 'ordinary',
                                  onTap: () {
                                    setState(() {
                                      _selectedTemplate = 'ordinary';
                                      _selectedSalary = null;
                                    });
                                  },
                                ),
                              ),
                              SizedBox(width: context.spacing12),
                              Expanded(
                                child: _buildTemplateOption(
                                  context,
                                  icon: Icons.work,
                                  title: '详细工资',
                                  subtitle: '包含五险一金等',
                                  selected: _selectedTemplate == 'detailed',
                                  onTap: () {
                                    // 导航到工资收入设置页面
                                    Navigator.of(context)
                                        .push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const SalaryIncomeSetupScreen(),
                                      ),
                                    )
                                        .then((result) {
                                      // 如果用户完成了工资设置，返回这里
                                      if (result != null && result is Map) {
                                        // 处理工资设置结果
                                        _handleSalarySetupResult(result);
                                      }
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: context.spacing12),
                          _buildTemplateOption(
                            context,
                            icon: Icons.account_balance_wallet,
                            title: '从工资创建',
                            subtitle: '使用已设置的工资',
                            selected: _selectedTemplate == 'salary',
                            onTap: () => _selectSalaryIncome(context),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: context.spacing16),

                // 基本信息
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '📝 基本信息',
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: context.spacing16),

                      // 计划名称
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: '计划名称',
                          hintText: '如：月薪收入、奖金收入',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '请输入计划名称';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _planName = value ?? '';
                        },
                      ),

                      SizedBox(height: context.spacing16),

                      // 金额
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: '收入金额',
                          hintText: '请输入收入金额',
                          border: OutlineInputBorder(),
                          prefixText: '¥',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '请输入收入金额';
                          }
                          final amount = double.tryParse(value);
                          if (amount == null || amount <= 0) {
                            return '请输入有效的金额';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _amount = double.tryParse(value ?? '0') ?? 0.0;
                        },
                      ),

                      SizedBox(height: context.spacing16),

                      // 频率
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: '收入频率',
                          border: OutlineInputBorder(),
                        ),
                        value: _frequency,
                        items: _frequencies
                            .map(
                              (frequency) => DropdownMenuItem(
                                value: frequency,
                                child:
                                    Text(_getFrequencyDisplayName(frequency)),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _frequency = value ?? 'monthly';
                          });
                        },
                      ),

                      SizedBox(height: context.spacing16),

                      // 目标钱包
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: '目标钱包',
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedWallet.isEmpty ? null : _selectedWallet,
                        hint: const Text('选择收入存入的钱包'),
                        items: _wallets
                            .map(
                              (wallet) => DropdownMenuItem(
                                value: wallet,
                                child: Text(wallet),
                              ),
                            )
                            .toList(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '请选择目标钱包';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            _selectedWallet = value ?? '';
                          });
                        },
                      ),
                    ],
                  ),
                ),

                SizedBox(height: context.spacing16),

                // 高级设置
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '⚙️ 高级设置',
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: context.spacing16),

                      // 开始日期
                      InkWell(
                        onTap: _selectStartDate,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: '开始日期',
                            border: OutlineInputBorder(),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${_startDate.year}-${_startDate.month.toString().padLeft(2, '0')}-${_startDate.day.toString().padLeft(2, '0')}',
                              ),
                              Icon(
                                Icons.calendar_today,
                                color: context.secondaryText,
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: context.spacing16),

                      // 自动执行开关
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '自动执行',
                                style: context.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: context.spacing4),
                              Text(
                                '到日期自动记录收入',
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: context.secondaryText,
                                ),
                              ),
                            ],
                          ),
                          Switch(
                            value: true,
                            onChanged: (value) {
                              // TODO: 实现自动执行开关
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: context.spacing32),

                // 操作按钮
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            vertical: context.responsiveSpacing12,
                          ),
                        ),
                        child: const Text('取消'),
                      ),
                    ),
                    SizedBox(width: context.spacing16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _selectedTemplate == 'salary'
                            ? _createFromSalary
                            : _savePlan,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            vertical: context.responsiveSpacing12,
                          ),
                        ),
                        child: const Text('创建计划'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildTemplateOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool selected,
    required VoidCallback onTap,
  }) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(context.responsiveSpacing12),
        child: Container(
          padding: EdgeInsets.all(context.responsiveSpacing16),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFF4CAF50).withOpacity(0.1)
                : context.surfaceColor,
            borderRadius: BorderRadius.circular(context.responsiveSpacing12),
            border: Border.all(
              color: selected ? const Color(0xFF4CAF50) : context.dividerColor,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color:
                    selected ? const Color(0xFF4CAF50) : context.secondaryText,
                size: 32,
              ),
              SizedBox(height: context.spacing8),
              Text(
                title,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color:
                      selected ? const Color(0xFF4CAF50) : context.primaryText,
                ),
              ),
              SizedBox(height: context.spacing4),
              Text(
                subtitle,
                style: context.textTheme.bodySmall?.copyWith(
                  color: selected
                      ? const Color(0xFF4CAF50)
                      : context.secondaryText,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );

  String _getFrequencyDisplayName(String frequency) {
    switch (frequency) {
      case 'daily':
        return '每日';
      case 'weekly':
        return '每周';
      case 'monthly':
        return '每月';
      case 'quarterly':
        return '每季度';
      case 'yearly':
        return '每年';
      default:
        return frequency;
    }
  }

  Future<void> _selectStartDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );

    if (pickedDate != null) {
      setState(() {
        _startDate = pickedDate;
      });
    }
  }

  void _savePlan() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      // 创建收入计划对象
      final incomePlan = IncomePlan(
        id: const Uuid().v4(),
        name: _planName,
        amount: _amount,
        frequency: _getIncomeFrequencyFromString(_frequency),
        walletId: _selectedWallet, // TODO: 从钱包列表中获取实际的钱包ID
        startDate: _startDate,
        description: '通过财务计划创建的收入计划',
        category: _selectedTemplate == 'detailed' ? '工资收入' : '其他收入',
        creationDate: DateTime.now(),
        updateDate: DateTime.now(),
        salaryIncomeId: _selectedTemplate == 'detailed'
            ? 'salary_income_id'
            : null, // TODO: 获取实际的工资收入ID
      );

      // 保存到Provider
      final incomePlanProvider = context.read<IncomePlanProvider>();
      incomePlanProvider.addIncomePlan(incomePlan);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('收入计划 "$_planName" 创建成功！'),
          backgroundColor: const Color(0xFF4CAF50),
        ),
      );

      Navigator.of(context).pop();
    }
  }

  IncomeFrequency _getIncomeFrequencyFromString(String frequency) {
    switch (frequency) {
      case 'daily':
        return IncomeFrequency.daily;
      case 'weekly':
        return IncomeFrequency.weekly;
      case 'monthly':
        return IncomeFrequency.monthly;
      case 'quarterly':
        return IncomeFrequency.quarterly;
      case 'yearly':
        return IncomeFrequency.yearly;
      default:
        return IncomeFrequency.monthly;
    }
  }

  /// 选择工资收入
  Future<void> _selectSalaryIncome(BuildContext context) async {
    final budgetProvider = context.read<BudgetProvider>();
    final salaryIncomes = budgetProvider.salaryIncomes;

    if (salaryIncomes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('没有找到已设置的工资收入，请先设置工资')),
      );
      return;
    }

    final selectedSalary = await showDialog<SalaryIncome>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择工资收入'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: salaryIncomes.length,
            itemBuilder: (context, index) {
              final salary = salaryIncomes[index];
              final hasPlan = context
                  .read<IncomePlanProvider>()
                  .hasIncomePlanForSalary(salary.id);

              return ListTile(
                title: Text(salary.name),
                subtitle: Text('月薪: ¥${salary.netIncome.toStringAsFixed(0)}'),
                trailing: hasPlan
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : null,
                onTap: () => Navigator.of(context).pop(salary),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
        ],
      ),
    );

    if (selectedSalary != null) {
      setState(() {
        _selectedTemplate = 'salary';
        _selectedSalary = selectedSalary;
        _planName = selectedSalary.name;
        _amount = selectedSalary.netIncome;
        _frequency = 'monthly';
      });
    }
  }

  /// 处理工资设置结果
  void _handleSalarySetupResult(Map<dynamic, dynamic> result) {
    // 这里可以处理从工资设置页面返回的结果
    // 暂时保持为空，将来可以扩展
  }

  /// 从工资创建收入计划
  Future<void> _createFromSalary() async {
    if (_selectedSalary == null || _selectedWallet.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择工资和钱包')),
      );
      return;
    }

    try {
      await context.read<IncomePlanProvider>().createIncomePlanFromSalary(
            _selectedSalary!,
            _selectedWallet,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('成功从工资创建收入计划')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('创建失败: $e')),
        );
      }
    }
  }
}
