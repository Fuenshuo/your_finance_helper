import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:your_finance_flutter/core/models/expense_plan.dart';
import 'package:your_finance_flutter/core/providers/expense_plan_provider.dart';
import 'package:your_finance_flutter/core/theme/app_theme.dart';
import 'package:your_finance_flutter/core/widgets/app_card.dart';
import 'package:your_finance_flutter/features/financial_planning/screens/budget_management_screen.dart';
import 'package:your_finance_flutter/features/financial_planning/screens/mortgage_calculator_screen.dart';

/// 创建支出计划页面
class CreateExpensePlanScreen extends StatefulWidget {
  const CreateExpensePlanScreen({super.key});

  @override
  State<CreateExpensePlanScreen> createState() =>
      _CreateExpensePlanScreenState();
}

class _CreateExpensePlanScreenState extends State<CreateExpensePlanScreen> {
  final _formKey = GlobalKey<FormState>();
  String _planName = '';
  String _description = '';
  double _amount = 0.0;
  ExpensePlanType _planType = ExpensePlanType.periodic;
  ExpenseFrequency _frequency = ExpenseFrequency.monthly;
  String _selectedWallet = '';
  String? _categoryId;
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;

  // For budget plan frequency selection
  String _budgetFrequency = 'monthly';

  final List<String> _categories = [
    '餐饮',
    '交通',
    '购物',
    '娱乐',
    '医疗',
    '教育',
    '住房',
    '通讯',
    '其他',
  ];

  final List<String> _wallets = ['工资卡', '储蓄卡', '信用卡'];

  /// 创建支出计划
  Future<void> _createExpensePlan() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedWallet.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择钱包')),
      );
      return;
    }

    try {
      final expensePlan = ExpensePlan.create(
        name: _planName,
        description: _description,
        type: _planType,
        amount: _amount,
        frequency: _frequency,
        walletId: _selectedWallet,
        categoryId: _categoryId,
        startDate: _startDate,
        endDate: _endDate,
      );

      await context.read<ExpensePlanProvider>().addExpensePlan(expensePlan);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('支出计划创建成功')),
        );
        Navigator.of(context).pop(expensePlan);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('创建失败: $e')),
        );
      }
    }
  }

  /// 导航到预算管理页面
  void _navigateToBudgetManagement() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const BudgetManagementScreen(),
      ),
    );
  }

  /// 导航到房贷计算器
  void _navigateToMortgageCalculator() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const MortgageCalculatorScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: context.primaryBackground,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            '创建支出计划',
            style: context.textTheme.headlineMedium,
          ),
          centerTitle: true,
          actions: [
            TextButton(
              onPressed: _createExpensePlan,
              child: Text(
                '创建',
                style: TextStyle(
                  color: context.primaryAction,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
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
                        '🎯 计划类型',
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: context.spacing16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildPlanTypeOption(
                              context,
                              icon: Icons.schedule,
                              title: '周期性支出',
                              subtitle: '定期固定支出',
                              selected: _planType == ExpensePlanType.periodic,
                              onTap: () => setState(
                                () => _planType = ExpensePlanType.periodic,
                              ),
                            ),
                          ),
                          SizedBox(width: context.spacing12),
                          Expanded(
                            child: _buildPlanTypeOption(
                              context,
                              icon: Icons.account_balance_wallet,
                              title: '预算计划',
                              subtitle: '约束型支出上限',
                              selected: _planType == ExpensePlanType.budget,
                              onTap: () => setState(
                                () => _planType = ExpensePlanType.budget,
                              ),
                            ),
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
                        decoration: InputDecoration(
                          labelText: _planType == ExpensePlanType.budget
                              ? '预算名称'
                              : '支出项目',
                          hintText: _planType == ExpensePlanType.budget
                              ? '如：餐饮预算、娱乐预算'
                              : '如：房租、水电费',
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '请输入${_planType == ExpensePlanType.budget ? '预算名称' : '支出项目'}';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _planName = value ?? '';
                        },
                      ),

                      SizedBox(height: context.spacing16),

                      // 描述（可选）
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: '描述（可选）',
                          hintText: '添加详细描述',
                          border: OutlineInputBorder(),
                        ),
                        onSaved: (value) {
                          _description = value ?? '';
                        },
                      ),

                      SizedBox(height: context.spacing16),

                      // 金额
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: _planType == ExpensePlanType.budget
                              ? '预算金额'
                              : '支出金额',
                          hintText: _planType == ExpensePlanType.budget
                              ? '设置每月预算上限'
                              : '设置每月支出金额',
                          border: const OutlineInputBorder(),
                          prefixText: '¥',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '请输入金额';
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

                      if (_planType == ExpensePlanType.periodic) ...[
                        SizedBox(height: context.spacing16),

                        // 支出频率
                        DropdownButtonFormField<ExpenseFrequency>(
                          decoration: const InputDecoration(
                            labelText: '支出频率',
                            border: OutlineInputBorder(),
                          ),
                          initialValue: _frequency,
                          items: ExpenseFrequency.values
                              .map(
                                (frequency) => DropdownMenuItem(
                                  value: frequency,
                                  child: Text(frequency.displayName),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _frequency = value);
                            }
                          },
                        ),
                      ],

                      SizedBox(height: context.spacing16),

                      // 支付钱包
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: '支付钱包',
                          border: OutlineInputBorder(),
                        ),
                        initialValue:
                            _selectedWallet.isEmpty ? null : _selectedWallet,
                        hint: const Text('选择支出使用的钱包'),
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
                            return '请选择支付钱包';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            _selectedWallet = value ?? '';
                          });
                        },
                      ),

                      SizedBox(height: context.spacing16),

                      // 支出分类
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: '支出分类（可选）',
                          border: OutlineInputBorder(),
                        ),
                        hint: const Text('选择支出分类'),
                        initialValue: _categoryId,
                        items: _categories
                            .map(
                              (category) => DropdownMenuItem(
                                value: category,
                                child: Text(category),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _categoryId = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),

                if (_planType == 'budget') ...[
                  SizedBox(height: context.spacing16),

                  // 预算设置
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '🎯 预算设置',
                          style: context.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: context.spacing16),

                        // 预算周期
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: '预算周期',
                            border: OutlineInputBorder(),
                          ),
                          initialValue: _budgetFrequency,
                          items: ['weekly', 'monthly', 'quarterly']
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
                              _budgetFrequency = value ?? 'monthly';
                            });
                          },
                        ),

                        SizedBox(height: context.spacing16),

                        // 预算提醒
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '预算提醒',
                                  style: context.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: context.spacing4),
                                Text(
                                  '超出预算时发送提醒',
                                  style: context.textTheme.bodySmall?.copyWith(
                                    color: context.secondaryText,
                                  ),
                                ),
                              ],
                            ),
                            Switch(
                              value: true,
                              onChanged: (value) {
                                // TODO: 实现预算提醒开关
                              },
                            ),
                          ],
                        ),

                        SizedBox(height: context.spacing16),

                        // 预算类型说明
                        Container(
                          padding: EdgeInsets.all(context.responsiveSpacing12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF9800).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(
                              context.responsiveSpacing8,
                            ),
                            border: Border.all(
                              color: const Color(0xFFFF9800).withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                color: Color(0xFFFF9800),
                                size: 20,
                              ),
                              SizedBox(width: context.spacing8),
                              Expanded(
                                child: Text(
                                  '预算计划不会自动生成交易，而是作为消费时的校验规则。当实际支出接近预算上限时，系统会发出提醒。',
                                  style: context.textTheme.bodySmall?.copyWith(
                                    color: const Color(0xFFFF9800),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  SizedBox(height: context.spacing16),

                  // 周期性支出设置
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '⚙️ 支出设置',
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
                                  '到日期自动记录支出',
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
                ],

                SizedBox(height: context.spacing24),

                // 系统集成选项
                if (_planType == ExpensePlanType.budget) ...[
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '🔗 系统集成',
                          style: context.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: context.spacing16),
                        Text(
                          '您可以从现有的预算管理系统中导入预算设置',
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.secondaryText,
                          ),
                        ),
                        SizedBox(height: context.spacing16),
                        OutlinedButton.icon(
                          onPressed: _navigateToBudgetManagement,
                          icon: const Icon(Icons.link),
                          label: const Text('从预算管理导入'),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              vertical: context.responsiveSpacing12,
                              horizontal: context.responsiveSpacing16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: context.spacing16),
                ] else if (_planType == ExpensePlanType.periodic) ...[
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '🏠 贷款集成',
                          style: context.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: context.spacing16),
                        Text(
                          '如果这是房贷还款，您可以使用房贷计算器自动创建还款计划',
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.secondaryText,
                          ),
                        ),
                        SizedBox(height: context.spacing16),
                        OutlinedButton.icon(
                          onPressed: _navigateToMortgageCalculator,
                          icon: const Icon(Icons.home_work),
                          label: const Text('使用房贷计算器'),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              vertical: context.responsiveSpacing12,
                              horizontal: context.responsiveSpacing16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: context.spacing16),
                ],

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
                        onPressed: _createExpensePlan,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF44336),
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

  Widget _buildPlanTypeOption(
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
                ? const Color(0xFFF44336).withOpacity(0.1)
                : context.surfaceColor,
            borderRadius: BorderRadius.circular(context.responsiveSpacing12),
            border: Border.all(
              color: selected ? const Color(0xFFF44336) : context.dividerColor,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color:
                    selected ? const Color(0xFFF44336) : context.secondaryText,
                size: 32,
              ),
              SizedBox(height: context.spacing8),
              Text(
                title,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color:
                      selected ? const Color(0xFFF44336) : context.primaryText,
                ),
              ),
              SizedBox(height: context.spacing4),
              Text(
                subtitle,
                style: context.textTheme.bodySmall?.copyWith(
                  color: selected
                      ? const Color(0xFFF44336)
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

  Future<void> _savePlan() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      try {
        // 创建支出计划对象
        final expensePlan = ExpensePlan(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: _planName,
          type: _planType == 'budget'
              ? ExpensePlanType.budget
              : ExpensePlanType.periodic,
          amount: _amount,
          frequency: _frequency,
          walletId: _selectedWallet,
          startDate: _startDate,
          description: _description.isEmpty ? '' : _description,
          categoryId: _categoryId,
        );

        // 保存到Provider
        final expensePlanProvider = context.read<ExpensePlanProvider>();
        await expensePlanProvider.addExpensePlan(expensePlan);

        final planTypeText = _planType == 'budget' ? '预算' : '支出';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$planTypeText计划 "$_planName" 创建成功！'),
            backgroundColor: const Color(0xFFF44336),
          ),
        );

        if (mounted) {
          Navigator.of(context).pop(true); // 返回成功标志
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('保存失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
