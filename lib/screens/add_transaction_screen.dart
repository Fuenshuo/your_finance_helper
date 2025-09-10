import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:your_finance_flutter/models/account.dart';
import 'package:your_finance_flutter/models/budget.dart';
import 'package:your_finance_flutter/models/transaction.dart';
import 'package:your_finance_flutter/providers/account_provider.dart';
import 'package:your_finance_flutter/providers/budget_provider.dart';
import 'package:your_finance_flutter/providers/transaction_provider.dart';
import 'package:your_finance_flutter/theme/app_theme.dart';
import 'package:your_finance_flutter/widgets/app_animations.dart';
import 'package:your_finance_flutter/widgets/app_card.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({
    super.key,
    this.initialType,
    this.editingTransaction,
  });
  final TransactionType? initialType;
  final Transaction? editingTransaction;

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  TransactionType _selectedType = TransactionType.expense;
  TransactionCategory _selectedCategory = TransactionCategory.otherExpense;
  String? _selectedSubCategory;
  String? _selectedFromAccountId;
  String? _selectedToAccountId;
  String? _selectedEnvelopeBudgetId;
  DateTime _selectedDate = DateTime.now();
  bool _isRecurring = false;
  bool _isDraft = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialType != null) {
      _selectedType = widget.initialType!;
    }
    if (widget.editingTransaction != null) {
      _loadTransactionData();
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _loadTransactionData() {
    final transaction = widget.editingTransaction!;
    _descriptionController.text = transaction.description;
    _amountController.text = transaction.amount.toString();
    _notesController.text = transaction.notes ?? '';
    _selectedType = transaction.type;
    _selectedCategory = transaction.category;
    _selectedSubCategory = transaction.subCategory;
    _selectedFromAccountId = transaction.fromAccountId;
    _selectedToAccountId = transaction.toAccountId;
    _selectedEnvelopeBudgetId = transaction.envelopeBudgetId;
    _selectedDate = transaction.date;
    _isRecurring = transaction.isRecurring;
    _isDraft = transaction.status == TransactionStatus.draft;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: context.primaryBackground,
        appBar: AppBar(
          title: Text(widget.editingTransaction != null ? '编辑交易' : '添加交易'),
          backgroundColor: Colors.white,
          elevation: 0,
          actions: [
            if (widget.editingTransaction == null)
              TextButton(
                onPressed: _saveAsDraft,
                child: const Text('保存草稿'),
              ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(context.spacing16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 交易类型选择
                _buildTransactionTypeSection(),
                SizedBox(height: context.spacing16),

                // 基本信息
                _buildBasicInfoSection(),
                SizedBox(height: context.spacing16),

                // 账户选择
                _buildAccountSection(),
                SizedBox(height: context.spacing16),

                // 预算关联
                if (_selectedType != TransactionType.transfer)
                  _buildBudgetSection(),
                if (_selectedType != TransactionType.transfer)
                  SizedBox(height: context.spacing16),

                // 其他选项
                _buildOtherOptionsSection(),
                SizedBox(height: context.spacing24),

                // 保存按钮
                _buildSaveButton(),
              ],
            ),
          ),
        ),
      );

  // 交易类型选择
  Widget _buildTransactionTypeSection() => AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '交易类型',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: context.spacing12),
            Row(
              children: TransactionType.values.map((type) {
                final isSelected = _selectedType == type;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: context.spacing4),
                    child: InkWell(
                      onTap: () => setState(() => _selectedType = type),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: context.spacing12,
                          horizontal: context.spacing8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? _getTransactionTypeColor(type).withOpacity(0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? _getTransactionTypeColor(type)
                                : Colors.grey.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              _getTransactionTypeIcon(type),
                              color: isSelected
                                  ? _getTransactionTypeColor(type)
                                  : Colors.grey,
                              size: 24,
                            ),
                            SizedBox(height: context.spacing4),
                            Text(
                              type.displayName,
                              style: TextStyle(
                                color: isSelected
                                    ? _getTransactionTypeColor(type)
                                    : Colors.grey,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      );

  // 基本信息
  Widget _buildBasicInfoSection() => AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '基本信息',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: context.spacing16),

            // 描述
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: '描述',
                hintText: '请输入交易描述',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '请输入交易描述';
                }
                return null;
              },
            ),
            SizedBox(height: context.spacing16),

            // 金额
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: '金额',
                hintText: '0.00',
                border: OutlineInputBorder(),
                prefixText: '¥ ',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '请输入金额';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return '请输入有效的金额';
                }
                return null;
              },
            ),
            SizedBox(height: context.spacing16),

            // 分类选择
            _buildCategorySelector(),
            SizedBox(height: context.spacing16),

            // 日期选择
            InkWell(
              onTap: _selectDate,
              child: Container(
                padding: EdgeInsets.all(context.spacing12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 20),
                    SizedBox(width: context.spacing12),
                    Text(
                      DateFormat('yyyy-MM-dd').format(_selectedDate),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Spacer(),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
            SizedBox(height: context.spacing16),

            // 备注
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: '备注',
                hintText: '可选',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      );

  // 分类选择器
  Widget _buildCategorySelector() {
    final categories = _getAvailableCategories();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('分类',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        SizedBox(height: context.spacing8),
        InkWell(
          onTap: () => _showCategoryPicker(categories),
          child: Container(
            padding: EdgeInsets.all(context.spacing12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  _getCategoryIcon(_selectedCategory),
                  size: 20,
                  color: _getTransactionTypeColor(_selectedType),
                ),
                SizedBox(width: context.spacing12),
                Text(
                  _selectedCategory.displayName,
                  style: const TextStyle(fontSize: 16),
                ),
                const Spacer(),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 账户选择
  Widget _buildAccountSection() => Consumer<AccountProvider>(
        builder: (context, accountProvider, child) {
          final accounts = accountProvider.accounts;

          return AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedType == TransactionType.transfer ? '转账账户' : '账户',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(height: context.spacing16),

                // 来源账户
                _buildAccountSelector(
                  '来源账户',
                  _selectedFromAccountId,
                  accounts,
                  (accountId) =>
                      setState(() => _selectedFromAccountId = accountId),
                ),

                if (_selectedType == TransactionType.transfer) ...[
                  SizedBox(height: context.spacing16),
                  _buildAccountSelector(
                    '目标账户',
                    _selectedToAccountId,
                    accounts
                        .where((a) => a.id != _selectedFromAccountId)
                        .toList(),
                    (accountId) =>
                        setState(() => _selectedToAccountId = accountId),
                  ),
                ],
              ],
            ),
          );
        },
      );

  // 账户选择器
  Widget _buildAccountSelector(
    String title,
    String? selectedAccountId,
    List<Account> accounts,
    Function(String?) onChanged,
  ) {
    final selectedAccount = accounts.firstWhere(
      (a) => a.id == selectedAccountId,
      orElse: () => accounts.isNotEmpty
          ? accounts.first
          : Account(
              name: '请选择账户',
              type: AccountType.cash,
            ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        SizedBox(height: context.spacing8),
        InkWell(
          onTap: () => _showAccountPicker(accounts, onChanged),
          child: Container(
            padding: EdgeInsets.all(context.spacing12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  _getAccountTypeIcon(selectedAccount.type),
                  size: 20,
                  color: context.primaryAction,
                ),
                SizedBox(width: context.spacing12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedAccount.name,
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        '余额: ${context.formatAmount(selectedAccount.balance)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: context.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 预算关联
  Widget _buildBudgetSection() => Consumer<BudgetProvider>(
        builder: (context, budgetProvider, child) {
          final envelopeBudgets = budgetProvider.envelopeBudgets;

          return AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '预算关联',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(height: context.spacing12),
                Text(
                  '选择要关联的信封预算（可选）',
                  style: TextStyle(
                    color: context.secondaryText,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: context.spacing16),
                InkWell(
                  onTap: () => _showBudgetPicker(envelopeBudgets),
                  child: Container(
                    padding: EdgeInsets.all(context.spacing12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.account_balance_wallet, size: 20),
                        SizedBox(width: context.spacing12),
                        Expanded(
                          child: Text(
                            _selectedEnvelopeBudgetId != null
                                ? envelopeBudgets
                                    .firstWhere((b) =>
                                        b.id == _selectedEnvelopeBudgetId)
                                    .name
                                : '选择预算（可选）',
                            style: TextStyle(
                              fontSize: 16,
                              color: _selectedEnvelopeBudgetId != null
                                  ? context.primaryText
                                  : context.secondaryText,
                            ),
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );

  // 其他选项
  Widget _buildOtherOptionsSection() => AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '其他选项',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: context.spacing16),
            SwitchListTile(
              title: const Text('周期性交易'),
              subtitle: const Text('设置定期重复的交易'),
              value: _isRecurring,
              onChanged: (value) => setState(() => _isRecurring = value),
            ),
            if (widget.editingTransaction == null)
              SwitchListTile(
                title: const Text('保存为草稿'),
                subtitle: const Text('稍后确认此交易'),
                value: _isDraft,
                onChanged: (value) => setState(() => _isDraft = value),
              ),
          ],
        ),
      );

  // 保存按钮
  Widget _buildSaveButton() => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _saveTransaction,
          style: ElevatedButton.styleFrom(
            backgroundColor: context.primaryAction,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: context.spacing16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            widget.editingTransaction != null
                ? '更新交易'
                : (_isDraft ? '保存草稿' : '保存交易'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );

  // 获取可用分类
  List<TransactionCategory> _getAvailableCategories() {
    switch (_selectedType) {
      case TransactionType.income:
        return TransactionCategory.values.where((c) => c.isIncome).toList();
      case TransactionType.expense:
        return TransactionCategory.values.where((c) => c.isExpense).toList();
      case TransactionType.transfer:
        return [TransactionCategory.otherExpense]; // 转账通常不需要分类
    }
  }

  // 获取交易类型颜色
  Color _getTransactionTypeColor(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return context.successColor;
      case TransactionType.expense:
        return context.errorColor;
      case TransactionType.transfer:
        return context.primaryAction;
    }
  }

  // 获取交易类型图标
  IconData _getTransactionTypeIcon(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return Icons.trending_up;
      case TransactionType.expense:
        return Icons.trending_down;
      case TransactionType.transfer:
        return Icons.swap_horiz;
    }
  }

  // 获取分类图标
  IconData _getCategoryIcon(TransactionCategory category) {
    switch (category) {
      case TransactionCategory.food:
        return Icons.restaurant_outlined;
      case TransactionCategory.transport:
        return Icons.directions_car_outlined;
      case TransactionCategory.shopping:
        return Icons.shopping_bag_outlined;
      case TransactionCategory.entertainment:
        return Icons.movie_outlined;
      case TransactionCategory.healthcare:
        return Icons.local_hospital_outlined;
      case TransactionCategory.education:
        return Icons.school_outlined;
      case TransactionCategory.housing:
        return Icons.home_outlined;
      case TransactionCategory.utilities:
        return Icons.electrical_services_outlined;
      case TransactionCategory.insurance:
        return Icons.security_outlined;
      case TransactionCategory.investment:
        return Icons.trending_up_outlined;
      case TransactionCategory.salary:
        return Icons.work_outlined;
      case TransactionCategory.bonus:
        return Icons.card_giftcard_outlined;
      case TransactionCategory.freelance:
        return Icons.work_outline;
      case TransactionCategory.otherIncome:
        return Icons.attach_money_outlined;
      case TransactionCategory.otherExpense:
        return Icons.receipt_outlined;
      case TransactionCategory.gift:
        return Icons.card_giftcard_outlined;
    }
  }

  // 获取账户类型图标
  IconData _getAccountTypeIcon(AccountType type) {
    switch (type) {
      case AccountType.cash:
        return Icons.account_balance_wallet;
      case AccountType.bank:
        return Icons.account_balance;
      case AccountType.creditCard:
        return Icons.credit_card;
      case AccountType.investment:
        return Icons.trending_up;
      case AccountType.loan:
        return Icons.account_balance_wallet;
      case AccountType.asset:
        return Icons.home;
      case AccountType.liability:
        return Icons.credit_card;
    }
  }

  // 选择日期
  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  // 显示分类选择器
  void _showCategoryPicker(List<TransactionCategory> categories) {
    AppAnimations.showAppModalBottomSheet(
      context: context,
      child: Container(
        padding: EdgeInsets.all(context.spacing24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '选择分类',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: context.spacing16),
            ...categories.map(
              (category) => ListTile(
                leading: Icon(
                  _getCategoryIcon(category),
                  color: _getTransactionTypeColor(_selectedType),
                ),
                title: Text(category.displayName),
                onTap: () {
                  setState(() => _selectedCategory = category);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 显示账户选择器
  void _showAccountPicker(List<Account> accounts, Function(String?) onChanged) {
    AppAnimations.showAppModalBottomSheet(
      context: context,
      child: Container(
        padding: EdgeInsets.all(context.spacing24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '选择账户',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: context.spacing16),
            ...accounts.map(
              (account) => ListTile(
                leading: Icon(
                  _getAccountTypeIcon(account.type),
                  color: context.primaryAction,
                ),
                title: Text(account.name),
                subtitle: Text('余额: ${context.formatAmount(account.balance)}'),
                onTap: () {
                  onChanged(account.id);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 显示预算选择器
  void _showBudgetPicker(List<EnvelopeBudget> budgets) {
    AppAnimations.showAppModalBottomSheet(
      context: context,
      child: Container(
        padding: EdgeInsets.all(context.spacing24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '选择预算',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: context.spacing16),
            ListTile(
              leading: const Icon(Icons.clear),
              title: const Text('不关联预算'),
              onTap: () {
                setState(() => _selectedEnvelopeBudgetId = null);
                Navigator.pop(context);
              },
            ),
            ...budgets.map(
              (budget) => ListTile(
                leading: const Icon(Icons.account_balance_wallet),
                title: Text(budget.name),
                subtitle:
                    Text('预算: ${context.formatAmount(budget.allocatedAmount)}'),
                onTap: () {
                  setState(() => _selectedEnvelopeBudgetId = budget.id);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 保存为草稿
  void _saveAsDraft() {
    if (_formKey.currentState!.validate()) {
      _isDraft = true;
      _saveTransaction();
    }
  }

  // 保存交易
  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedFromAccountId == null) {
      // 静默验证，不显示提示框
      return;
    }

    if (_selectedType == TransactionType.transfer &&
        _selectedToAccountId == null) {
      // 静默验证，不显示提示框
      return;
    }

    final amount = double.parse(_amountController.text);
    final transaction = Transaction(
      id: widget.editingTransaction?.id,
      description: _descriptionController.text.trim(),
      amount: amount,
      type: _selectedType,
      category: _selectedCategory,
      subCategory: _selectedSubCategory,
      fromAccountId: _selectedFromAccountId!,
      toAccountId: _selectedToAccountId,
      envelopeBudgetId: _selectedEnvelopeBudgetId,
      date: _selectedDate,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      status: _isDraft ? TransactionStatus.draft : TransactionStatus.confirmed,
      isRecurring: _isRecurring,
    );

    try {
      final transactionProvider = context.read<TransactionProvider>();

      if (widget.editingTransaction != null) {
        await transactionProvider.updateTransaction(transaction);
      } else {
        if (_isDraft) {
          await transactionProvider.addDraftTransaction(transaction);
        } else {
          await transactionProvider.addTransaction(transaction);
        }
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      // 静默处理错误，不显示提示框
    }
  }
}
