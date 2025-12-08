import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:your_finance_flutter/core/animations/ios_animation_system.dart';
import 'package:your_finance_flutter/core/models/account.dart';
import 'package:your_finance_flutter/core/models/expense_plan.dart';
import 'package:your_finance_flutter/core/providers/account_provider.dart';
import 'package:your_finance_flutter/core/providers/expense_plan_provider.dart';
import 'package:your_finance_flutter/core/theme/app_theme.dart';
import 'package:your_finance_flutter/core/widgets/app_card.dart';
import 'package:your_finance_flutter/features/financial_planning/screens/budget_management_screen.dart';
import 'package:your_finance_flutter/features/financial_planning/screens/mortgage_calculator_screen.dart';

/// 创建/编辑支出计划页面
class CreateExpensePlanScreen extends StatefulWidget {
  const CreateExpensePlanScreen({
    super.key,
    this.editPlan,
  });
  final ExpensePlan? editPlan;

  @override
  State<CreateExpensePlanScreen> createState() =>
      _CreateExpensePlanScreenState();
}

class _CreateExpensePlanScreenState extends State<CreateExpensePlanScreen> {
  final _formKey = GlobalKey<FormState>();
  late final IOSAnimationSystem _animationSystem;
  String _planName = '';
  String _description = '';
  double _amount = 0.0;
  ExpensePlanType _planType = ExpensePlanType.periodic;
  ExpenseFrequency _frequency = ExpenseFrequency.monthly;
  String? _selectedAccountId; // 支出账户ID（扣款账户）
  String? _selectedLoanAccountId; // 贷款账户ID（收款账户，用于还款）
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

  @override
  void initState() {
    super.initState();

    // ===== v1.1.0 初始化企业级动效系统 =====
    _animationSystem = IOSAnimationSystem();

    // 注册支出计划表单专用动效曲线
    IOSAnimationSystem.registerCustomCurve(
      'expense-form-focus',
      Curves.easeInOutCubic,
    );
    IOSAnimationSystem.registerCustomCurve(
      'expense-validation-error',
      Curves.elasticOut,
    );
    IOSAnimationSystem.registerCustomCurve(
      'expense-success-feedback',
      Curves.elasticOut,
    );

    // 如果是编辑模式，加载现有数据
    if (widget.editPlan != null) {
      _loadEditData();
    }
  }

  /// 加载编辑数据
  void _loadEditData() {
    final plan = widget.editPlan!;
    _planName = plan.name;
    _description = plan.description ?? '';
    _amount = plan.amount;
    _planType = plan.type;
    _frequency = plan.frequency;
    _selectedAccountId = plan.walletId;
    _selectedLoanAccountId = plan.loanAccountId;
    _categoryId = plan.categoryId;
    _startDate = plan.startDate;
    _endDate = plan.endDate;
  }

  /// 创建支出计划
  Future<void> _createExpensePlan() async {
    if (!_formKey.currentState!.validate()) return;

    // 重要：调用save()确保表单数据被保存到变量中
    _formKey.currentState?.save();

    if (_selectedAccountId == null || _selectedAccountId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择支出账户')),
      );
      return;
    }

    try {
      final expensePlanProvider = context.read<ExpensePlanProvider>();

      if (widget.editPlan != null) {
        // 编辑模式：更新现有计划
        final updatedPlan = widget.editPlan!.copyWith(
          name: _planName,
          description: _description,
          type: _planType,
          amount: _amount,
          frequency: _frequency,
          walletId: _selectedAccountId,
          categoryId: _categoryId,
          loanAccountId: _selectedLoanAccountId,
          startDate: _startDate,
          endDate: _endDate,
          updateDate: DateTime.now(),
        );

        await expensePlanProvider.updateExpensePlan(updatedPlan);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('支出计划修改成功')),
          );
          Navigator.of(context).pop(updatedPlan);
        }
      } else {
        // 创建模式：创建新计划
        final expensePlan = ExpensePlan.create(
          name: _planName,
          description: _description,
          type: _planType,
          amount: _amount,
          frequency: _frequency,
          walletId: _selectedAccountId!,
          categoryId: _categoryId,
          loanAccountId: _selectedLoanAccountId,
          startDate: _startDate,
          endDate: _endDate,
        );

        await expensePlanProvider.addExpensePlan(expensePlan);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('支出计划创建成功')),
          );
          Navigator.of(context).pop(expensePlan);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e')),
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
            widget.editPlan != null ? '编辑支出计划' : '创建支出计划',
            style: context.textTheme.headlineMedium,
          ),
          centerTitle: true,
          actions: [
            TextButton(
              onPressed: _createExpensePlan,
              child: Text(
                widget.editPlan != null ? '保存' : '创建',
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
                        initialValue: _amount == 0.0 ? '' : _amount.toString(),
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
                        onChanged: (value) {
                          _amount = double.tryParse(value ?? '0') ?? 0.0;
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

                      // 支出账户
                      Consumer<AccountProvider>(
                        builder: (context, accountProvider, child) {
                          final accounts = accountProvider.accounts
                              .where(
                                (account) => account.type.isAsset,
                              ) // 只显示资产账户（可用于支出）
                              .toList();

                          return DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: '支出账户',
                              border: OutlineInputBorder(),
                            ),
                            initialValue: _selectedAccountId,
                            hint: const Text('选择支出账户'),
                            items: accounts
                                .map(
                                  (account) => DropdownMenuItem(
                                    value: account.id,
                                    child: Text(
                                      '${account.name} (${account.type.displayName})',
                                    ),
                                  ),
                                )
                                .toList(),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '请选择支出账户';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              setState(() {
                                _selectedAccountId = value;
                              });
                            },
                          );
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
                          '如果这是贷款还款，请选择对应的贷款账户',
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.secondaryText,
                          ),
                        ),
                        SizedBox(height: context.spacing16),
                        // 贷款账户选择器
                        Consumer<AccountProvider>(
                          builder: (context, accountProvider, child) {
                            final loanAccounts = accountProvider.accounts
                                .where(
                                  (account) => account.type == AccountType.loan,
                                )
                                .toList();

                            return DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: '关联贷款账户（可选）',
                                border: OutlineInputBorder(),
                                hintText: '选择要还款的贷款账户',
                              ),
                              initialValue: _selectedLoanAccountId,
                              items: [
                                const DropdownMenuItem<String>(
                                  child: Text('无关联贷款'),
                                ),
                                ...loanAccounts.map(
                                  (account) => DropdownMenuItem(
                                    value: account.id,
                                    child: Text(
                                      '${account.name} (${account.loanType?.displayName ?? '未知类型'})',
                                    ),
                                  ),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedLoanAccountId = value;
                                });
                              },
                            );
                          },
                        ),
                        SizedBox(height: context.spacing16),
                        Text(
                          '或者使用房贷计算器自动创建还款计划',
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
          walletId: _selectedAccountId ?? '',
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

  @override
  void dispose() {
    _animationSystem.dispose();
    super.dispose();
  }
}
