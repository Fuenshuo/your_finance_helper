import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:your_finance_flutter/core/animations/ios_animation_system.dart';
import 'package:your_finance_flutter/core/utils/logger.dart';
import 'package:your_finance_flutter/core/models/account.dart';
import 'package:your_finance_flutter/core/models/budget.dart';
import 'package:your_finance_flutter/core/models/expense_plan.dart';
import 'package:your_finance_flutter/core/models/transaction.dart';
import 'package:your_finance_flutter/core/providers/account_provider.dart';
import 'package:your_finance_flutter/core/providers/budget_provider.dart';
import 'package:your_finance_flutter/core/providers/expense_plan_provider.dart';
import 'package:your_finance_flutter/core/providers/transaction_provider.dart';
import 'package:your_finance_flutter/core/theme/app_theme.dart';
import 'package:your_finance_flutter/core/utils/unified_notifications.dart';
import 'package:your_finance_flutter/core/widgets/app_card.dart';
import 'package:your_finance_flutter/core/constants/app_icons.dart';
import 'package:your_finance_flutter/core/models/parsed_transaction.dart';
import 'package:your_finance_flutter/core/services/ai/category_recommendation_service.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({
    super.key,
    this.initialType,
    this.editingTransaction,
    this.initialAccountId,
    this.parsedTransaction,
    this.imagePath,
  });
  final TransactionType? initialType;
  final Transaction? editingTransaction;
  final String? initialAccountId;
  final ParsedTransaction? parsedTransaction;
  final String? imagePath;

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  late final IOSAnimationSystem _animationSystem;

  TransactionType _selectedType = TransactionType.expense;
  TransactionCategory _selectedCategory = TransactionCategory.otherExpense;
  String? _selectedSubCategory;
  String? _selectedAccountId; // 收入/支出使用这个，统一账户选择
  String? _selectedFromAccountId; // 转账的来源账户
  String? _selectedToAccountId; // 转账的目标账户
  String? _selectedEnvelopeBudgetId;
  String? _selectedExpensePlanId; // 关联的支出计划ID
  DateTime _selectedDate = DateTime.now();
  bool _isRecurring = false;
  bool _isDraft = false;
  String? _transactionImagePath; // 交易关联的图片路径（用于发票识别）

  // AI分类推荐相关
  CategoryRecommendation? _categoryRecommendation;
  bool _isRecommendingCategory = false;
  Timer? _recommendationTimer;
  String? _lastRequestedDescription; // 记录最后一次请求的描述，避免重复请求

  @override
  void initState() {
    super.initState();

    // ===== v1.1.0 初始化企业级动效系统 =====
    _animationSystem = IOSAnimationSystem();

    // 注册表单动效专用曲线
    IOSAnimationSystem.registerCustomCurve('form-field-focus', Curves.easeInOutCubic);
    IOSAnimationSystem.registerCustomCurve('validation-error', Curves.elasticOut);
    IOSAnimationSystem.registerCustomCurve('success-feedback', Curves.elasticOut);

    if (widget.initialType != null) {
      _selectedType = widget.initialType!;
    }
    if (widget.initialAccountId != null) {
      // 根据交易类型设置相应的账户ID
      if (_selectedType == TransactionType.transfer) {
        _selectedFromAccountId = widget.initialAccountId;
      } else {
        _selectedAccountId = widget.initialAccountId;
      }
    }
    if (widget.editingTransaction != null) {
      _loadTransactionData();
    }
    
    // 如果有AI解析结果，填充表单
    if (widget.parsedTransaction != null) {
      _handleParsedTransaction(widget.parsedTransaction!);
      if (widget.imagePath != null) {
        _transactionImagePath = widget.imagePath;
      }
    }
  }

  /// 处理AI解析结果
  void _handleParsedTransaction(ParsedTransaction parsed) {
    setState(() {
      // 填充描述
      if (parsed.description != null && parsed.description!.isNotEmpty) {
        _descriptionController.text = parsed.description!;
      }

      // 填充金额
      if (parsed.amount != null && parsed.amount! > 0) {
        _amountController.text = parsed.amount!.toStringAsFixed(2);
      }

      // 填充交易类型
      if (parsed.type != null) {
        _selectedType = parsed.type!;
      }

      // 填充分类
      if (parsed.category != null) {
        _selectedCategory = parsed.category!;
      }

      // 填充子分类
      if (parsed.subCategory != null) {
        _selectedSubCategory = parsed.subCategory;
      }

      // 填充账户
      if (parsed.accountId != null) {
        if (_selectedType == TransactionType.transfer) {
          // 转账类型需要特殊处理
          _selectedFromAccountId = parsed.accountId;
        } else {
          _selectedAccountId = parsed.accountId;
        }
      }

      // 填充预算
      if (parsed.envelopeBudgetId != null) {
        _selectedEnvelopeBudgetId = parsed.envelopeBudgetId;
      }

      // 填充日期
      if (parsed.date != null) {
        _selectedDate = parsed.date!;
      }

      // 填充备注
      if (parsed.notes != null && parsed.notes!.isNotEmpty) {
        _notesController.text = parsed.notes!;
      }
    });
  }


  @override
  void dispose() {
    _recommendationTimer?.cancel();
    _animationSystem.dispose();
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
    _selectedType = transaction.type ?? TransactionType.income;
    _selectedCategory = transaction.category;
    _selectedSubCategory = transaction.subCategory;
    // 根据交易类型设置账户
    if (_selectedType == TransactionType.transfer) {
      _selectedFromAccountId = transaction.fromAccountId;
      _selectedToAccountId = transaction.toAccountId;
    } else {
      _selectedAccountId = transaction.fromAccountId ?? transaction.toAccountId;
    }
    _selectedEnvelopeBudgetId = transaction.envelopeBudgetId;
    _selectedExpensePlanId = transaction.expensePlanId;
    _selectedDate = transaction.date;
    _isRecurring = transaction.isRecurring;
    _isDraft = transaction.status == TransactionStatus.draft;

    // 验证类型和分类的一致性
    final availableCategories = _getAvailableCategories();
    if (!availableCategories.contains(_selectedCategory)) {
      // 如果当前分类在新类型中不可用，选择合适的默认分类
      _selectedCategory = _getDefaultCategoryForType(_selectedType);
    }
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

                // 支出计划关联
                if (_selectedType == TransactionType.expense)
                  _buildExpensePlanSection(),
                if (_selectedType == TransactionType.expense)
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
                      onTap: () => _onTransactionTypeChanged(type),
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
              onChanged: (value) => _onDescriptionChanged(value),
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

            // AI分类推荐显示
            if (_categoryRecommendation != null || _isRecommendingCategory)
              _buildCategoryRecommendation(),

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

  /// 描述输入变化处理（带防抖和请求去重）
  void _onDescriptionChanged(String value) {
    // 取消之前的定时器
    _recommendationTimer?.cancel();

    final trimmedValue = value.trim();

    // 如果描述太短，清除推荐
    if (trimmedValue.isEmpty || trimmedValue.length < 3) {
      setState(() {
        _categoryRecommendation = null;
        _isRecommendingCategory = false;
        _lastRequestedDescription = null;
      });
      return;
    }

    // 如果和上次请求的描述相同，不重复请求
    if (trimmedValue == _lastRequestedDescription) {
      return;
    }

    // 设置防抖定时器（400ms，平衡响应速度和请求频率）
    _recommendationTimer = Timer(const Duration(milliseconds: 400), () {
      // 再次检查描述是否仍然有效且与当前输入一致
      if (mounted && _descriptionController.text.trim() == trimmedValue) {
        _recommendCategory(trimmedValue);
      }
    });
  }

  /// 推荐分类
  Future<void> _recommendCategory(String description) async {
    if (description.isEmpty) return;

    // 检查描述是否仍然有效（用户可能已经继续输入了）
    if (!mounted || _descriptionController.text.trim() != description) {
      return;
    }

    // 记录本次请求的描述，避免重复请求
    _lastRequestedDescription = description;

    setState(() {
      _isRecommendingCategory = true;
      _categoryRecommendation = null;
    });

    try {
      final service = await CategoryRecommendationService.getInstance();
      final transactionProvider =
          Provider.of<TransactionProvider>(context, listen: false);
      final transactions = transactionProvider.transactions;

      final recommendation = await service.recommendCategory(
        description: description,
        userHistory: transactions.take(50).toList(),
        transactionType: _selectedType,
      );

      // 再次检查：如果用户已经继续输入，忽略这次结果
      if (!mounted || _descriptionController.text.trim() != description) {
        return;
      }

      if (mounted) {
        setState(() {
          _categoryRecommendation = recommendation;
          _isRecommendingCategory = false;

          // 如果置信度>0.5，自动选中推荐分类
          if (recommendation.confidence > 0.5) {
            _selectedCategory = recommendation.category;
            if (recommendation.subCategory != null) {
              _selectedSubCategory = recommendation.subCategory;
            }
          }
        });

        // 显示推荐提示（只在置信度足够高时显示）
        if (recommendation.confidence > 0.5) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'AI推荐分类: ${recommendation.category.displayName}${recommendation.subCategory != null ? ' - ${recommendation.subCategory}' : ''}',
              ),
              duration: const Duration(seconds: 2),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      print(
        '[AddTransactionScreen._recommendCategory] ❌ 分类推荐失败: $e',
      );
      if (mounted) {
        // 只有在描述仍然匹配时才清除加载状态
        if (_descriptionController.text.trim() == description) {
          setState(() {
            _isRecommendingCategory = false;
          });
        }
      }
    }
  }

  /// 构建分类推荐显示
  Widget _buildCategoryRecommendation() {
    return Container(
      margin: EdgeInsets.only(bottom: context.spacing12),
      padding: EdgeInsets.all(context.spacing12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.blue.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: _isRecommendingCategory
          ? Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                ),
                SizedBox(width: context.spacing8),
                Text(
                  'AI正在推荐分类...',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            )
          : _categoryRecommendation != null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          size: 16,
                          color: Colors.blue[700],
                        ),
                        SizedBox(width: context.spacing4),
                        Text(
                          'AI推荐',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '置信度: ${(_categoryRecommendation!.confidence * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[600],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: context.spacing4),
                    Text(
                      '分类: ${_categoryRecommendation!.category.displayName}${_categoryRecommendation!.subCategory != null ? ' - ${_categoryRecommendation!.subCategory}' : ''}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue[900],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (_categoryRecommendation!.reason != null) ...[
                      SizedBox(height: context.spacing4),
                      Text(
                        _categoryRecommendation!.reason!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ],
                )
              : const SizedBox.shrink(),
    );
  }

  // 分类选择器
  Widget _buildCategorySelector() {
    final categories = _getAvailableCategories();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '分类',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: context.spacing8),
        InkWell(
          onTap: () => _showCategoryPicker(categories),
          child: Container(
            padding: EdgeInsets.all(context.spacing12),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.02),
              border: Border.all(color: Colors.grey.withOpacity(0.4)),
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
                  _selectedCategory == TransactionCategory.otherExpense
                      ? '请选择分类'
                      : _selectedCategory.displayName,
                  style: TextStyle(
                    fontSize: 16,
                    color: _selectedCategory == TransactionCategory.otherExpense
                        ? Colors.grey.shade500
                        : Colors.black,
                    fontStyle:
                        _selectedCategory == TransactionCategory.otherExpense
                            ? FontStyle.italic
                            : FontStyle.normal,
                  ),
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
                // 只在非转账模式下显示section title
                if (_selectedType != TransactionType.transfer) ...[
                  Text(
                    _getAccountSectionTitle(),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  SizedBox(height: context.spacing16),
                ],

                // 账户选择器
                _buildAccountSelector(
                  _getAccountSelectorTitle(_selectedType, true),
                  _selectedType == TransactionType.transfer
                      ? _selectedFromAccountId
                      : _selectedAccountId,
                  accounts,
                  (accountId) => setState(() {
                    if (_selectedType == TransactionType.transfer) {
                      _selectedFromAccountId = accountId;
                    } else {
                      _selectedAccountId = accountId;
                    }
                  }),
                ),

                if (_selectedType == TransactionType.transfer) ...[
                  SizedBox(height: context.spacing16),
                  _buildAccountSelector(
                    _getAccountSelectorTitle(_selectedType, false),
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
    final selectedAccount = selectedAccountId != null
        ? accounts.firstWhere(
            (a) => a.id == selectedAccountId,
            orElse: () => Account(
              name: '账户不存在',
              type: AccountType.cash,
            ),
          )
        : Account(
            name: '请选择账户',
            type: AccountType.cash,
          );

    // 计算实时余额
    final realBalance = selectedAccountId != null
        ? context.read<AccountProvider>().getAccountBalance(
              selectedAccountId,
              context.read<TransactionProvider>().transactions,
            )
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: context.spacing8),
        InkWell(
          onTap: () => _showAccountPicker(accounts, onChanged),
          child: Container(
            padding: EdgeInsets.all(context.spacing12),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.02),
              border: Border.all(color: Colors.grey.withOpacity(0.4)),
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
                        style: TextStyle(
                          fontSize: 16,
                          color: selectedAccountId == null
                              ? Colors.grey.shade500
                              : Colors.black,
                          fontStyle: selectedAccountId == null
                              ? FontStyle.italic
                              : FontStyle.normal,
                        ),
                      ),
                      Text(
                        '余额: ${context.formatAmount(realBalance)}',
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
                      color: Colors.grey.withOpacity(0.02),
                      border: Border.all(color: Colors.grey.withOpacity(0.4)),
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
                                    .firstWhere(
                                      (b) => b.id == _selectedEnvelopeBudgetId,
                                    )
                                    .name
                                : '选择预算（可选）',
                            style: TextStyle(
                              fontSize: 16,
                              color: _selectedEnvelopeBudgetId == null
                                  ? Colors.grey.shade500
                                  : Colors.black,
                              fontStyle: _selectedEnvelopeBudgetId == null
                                  ? FontStyle.italic
                                  : FontStyle.normal,
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

  // 支出计划关联
  Widget _buildExpensePlanSection() => Consumer<ExpensePlanProvider>(
        builder: (context, expensePlanProvider, child) {
          final expensePlans = expensePlanProvider.activeExpensePlans;

          return AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '支出计划关联',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(height: context.spacing12),
                Text(
                  '选择要关联的支出计划，如定期还款计划（可选）',
                  style: TextStyle(
                    color: context.secondaryText,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: context.spacing16),
                InkWell(
                  onTap: expensePlans.isEmpty
                      ? null
                      : () => _showExpensePlanPicker(expensePlans),
                  child: Container(
                    padding: EdgeInsets.all(context.spacing12),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.02),
                      border: Border.all(color: Colors.grey.withOpacity(0.4)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 20,
                          color: expensePlans.isEmpty
                              ? Colors.grey.shade400
                              : null,
                        ),
                        SizedBox(width: context.spacing12),
                        Expanded(
                          child: Text(
                            _selectedExpensePlanId != null
                                ? expensePlans
                                    .firstWhere(
                                      (p) => p.id == _selectedExpensePlanId,
                                    )
                                    .name
                                : expensePlans.isEmpty
                                    ? '暂无支出计划'
                                    : '选择支出计划（可选）',
                            style: TextStyle(
                              fontSize: 16,
                              color: _selectedExpensePlanId != null
                                  ? Colors.black
                                  : expensePlans.isEmpty
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade500,
                              fontStyle: _selectedExpensePlanId == null &&
                                      expensePlans.isNotEmpty
                                  ? FontStyle.italic
                                  : FontStyle.normal,
                            ),
                          ),
                        ),
                        if (expensePlans.isNotEmpty)
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

  // 交易类型改变处理
  void _onTransactionTypeChanged(TransactionType newType) {
    setState(() {
      final oldType = _selectedType;
      _selectedType = newType;

      // 如果交易类型改变，检查当前分类是否仍然有效
      if (oldType != newType) {
        final availableCategories = _getAvailableCategories();
        if (!availableCategories.contains(_selectedCategory)) {
          // 当前分类在新类型中不可用，选择合适的默认分类
          _selectedCategory = _getDefaultCategoryForType(newType);
        }
      }
    });
  }

  // 获取指定交易类型的默认分类
  TransactionCategory _getDefaultCategoryForType(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return TransactionCategory.salary; // 收入默认选择工资
      case TransactionType.expense:
        return TransactionCategory.food; // 支出默认选择餐饮
      case TransactionType.transfer:
        return TransactionCategory.otherExpense; // 转账使用其他支出
    }
  }

  // 获取账户区域标题
  String _getAccountSectionTitle() {
    switch (_selectedType) {
      case TransactionType.income:
        return '目标账户'; // 收入进入账户
      case TransactionType.expense:
        return '来源账户'; // 支出从账户出去
      case TransactionType.transfer:
        return '账户选择'; // 转账涉及两个账户
    }
  }

  // 获取账户选择器标题
  String _getAccountSelectorTitle(TransactionType type, bool isFromAccount) {
    switch (type) {
      case TransactionType.income:
        return '目标账户'; // 收入的目标账户
      case TransactionType.expense:
        return '来源账户'; // 支出的来源账户
      case TransactionType.transfer:
        return isFromAccount ? '来源账户' : '目标账户'; // 转账的来源和目标
    }
  }

  // 更新账户余额
  // 账户余额现在通过交易历史实时计算，不需要手动更新
  Future<void> _updateAccountBalances(
    Transaction transaction,
    BuildContext context,
  ) async {
    Logger.debug('✅ 交易已记录，账户余额将基于所有交易历史实时计算');
    Logger.debug('🔄 交易类型: ${transaction.type}, 金额: ${transaction.amount}');
    Logger.debug(
      '📊 账户IDs: from=${transaction.fromAccountId}, to=${transaction.toAccountId}',
    );

    // 不再需要手动更新账户余额
    // 余额通过AccountProvider.getAccountBalance()方法实时计算
    // 这样确保了数据一致性和完整的审计追踪
  }

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
    return AppIcons.getTransactionTypeIcon(type);
  }

  // 获取分类图标
  IconData _getCategoryIcon(TransactionCategory category) {
    return AppIcons.getCategoryIcon(category);
  }

  // 获取账户类型图标
  IconData _getAccountTypeIcon(AccountType type) {
    switch (type) {
      case AccountType.loan:
        return Icons.account_balance_wallet;
      case AccountType.asset:
        return Icons.home;
      case AccountType.liability:
        return Icons.credit_card;
      default:
        return AppIcons.getAccountIcon(type);
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
    _animationSystem.showIOSModal(
      context: context,
      builder: (context) => Container(
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
    _animationSystem.showIOSModal(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(context.spacing24),
        child: SingleChildScrollView(
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
                (account) => Consumer<TransactionProvider>(
                  builder: (context, transactionProvider, child) {
                    final accountProvider = context.read<AccountProvider>();
                    final realBalance = accountProvider.getAccountBalance(
                      account.id,
                      transactionProvider.transactions,
                    );
                    return ListTile(
                      leading: Icon(
                        _getAccountTypeIcon(account.type),
                        color: context.primaryAction,
                      ),
                      title: Text(account.name),
                      subtitle: Text('余额: ${context.formatAmount(realBalance)}'),
                      onTap: () {
                        onChanged(account.id);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 显示预算选择器
  void _showBudgetPicker(List<EnvelopeBudget> budgets) {
    _animationSystem.showIOSModal(
      context: context,
      builder: (context) => Container(
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

  // 显示支出计划选择器
  void _showExpensePlanPicker(List<ExpensePlan> expensePlans) {
    _animationSystem.showIOSModal(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(context.spacing24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '选择支出计划',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: context.spacing16),
            ListTile(
              leading: const Icon(Icons.clear),
              title: const Text('不关联支出计划'),
              onTap: () {
                setState(() => _selectedExpensePlanId = null);
                Navigator.pop(context);
              },
            ),
            ...expensePlans.map(
              (plan) => ListTile(
                leading: Icon(
                  plan.type == ExpensePlanType.periodic
                      ? Icons.repeat
                      : Icons.account_balance_wallet,
                ),
                title: Text(plan.name),
                subtitle: Text(
                  '金额: ${context.formatAmount(plan.amount)} | ${plan.frequency.displayName}',
                ),
                onTap: () {
                  setState(() => _selectedExpensePlanId = plan.id);
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
    Logger.debug('🔄 开始保存交易');
    Logger.debug('📝 交易类型: $_selectedType');
    Logger.debug('📝 来源账户ID: $_selectedFromAccountId');
    Logger.debug('📝 目标账户ID: $_selectedToAccountId');
    Logger.debug('📝 金额: ${_amountController.text}');
    Logger.debug('📝 描述: ${_descriptionController.text}');

    if (!_formKey.currentState!.validate()) {
      Logger.debug('❌ 表单验证失败');
      return;
    }

    // 根据交易类型校验账户选择
    switch (_selectedType) {
      case TransactionType.income:
        if (_selectedAccountId == null) {
          Logger.debug('❌ 收入未选择目标账户');
          unifiedNotifications.showError(context, '请选择目标账户');
          return;
        }

      case TransactionType.expense:
        if (_selectedAccountId == null) {
          Logger.debug('❌ 支出未选择来源账户');
          unifiedNotifications.showError(context, '请选择来源账户');
          return;
        }

      case TransactionType.transfer:
        if (_selectedFromAccountId == null) {
          Logger.debug('❌ 转账未选择来源账户');
          unifiedNotifications.showError(context, '请选择来源账户');
          return;
        }
        if (_selectedToAccountId == null) {
          Logger.debug('❌ 转账未选择目标账户');
          unifiedNotifications.showError(context, '请选择目标账户');
          return;
        }
        // 转账不能在同一账户间进行
        if (_selectedFromAccountId == _selectedToAccountId) {
          Logger.debug('❌ 转账来源和目标账户不能相同');
          unifiedNotifications.showError(context, '来源账户和目标账户不能相同');
          return;
        }
    }

    final amount = double.parse(_amountController.text);
    Logger.debug('🎯 创建交易: type=$_selectedType, name=${_selectedType.name}');
    final transaction = Transaction(
      id: widget.editingTransaction?.id,
      description: _descriptionController.text.trim(),
      amount: amount,
      type: _selectedType,
      category: _selectedCategory,
      subCategory: _selectedSubCategory,
      fromAccountId: _selectedType == TransactionType.expense ||
              _selectedType == TransactionType.transfer
          ? (_selectedType == TransactionType.transfer
              ? _selectedFromAccountId
              : _selectedAccountId)
          : null,
      toAccountId: _selectedType == TransactionType.income ||
              _selectedType == TransactionType.transfer
          ? (_selectedType == TransactionType.transfer
              ? _selectedToAccountId
              : _selectedAccountId)
          : null,
      envelopeBudgetId: _selectedEnvelopeBudgetId,
      expensePlanId: _selectedExpensePlanId,
      date: _selectedDate,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      status: _isDraft ? TransactionStatus.draft : TransactionStatus.confirmed,
      isRecurring: _isRecurring,
      imagePath: _transactionImagePath,
    );
    Logger.debug('✅ 交易创建完成: ${transaction.toJson()}');

    try {
      final transactionProvider = context.read<TransactionProvider>();

      if (widget.editingTransaction != null) {
        await transactionProvider.updateTransaction(transaction);
      } else {
        if (_isDraft) {
          await transactionProvider.addDraftTransaction(transaction);
        } else {
          await transactionProvider.addTransaction(transaction);

          // 更新账户余额
          await _updateAccountBalances(transaction, context);
        }
      }

      if (mounted) {
        // 给AccountDetailScreen一些时间来检测交易变化和触发动画
        await Future.delayed(const Duration(milliseconds: 200));
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      // 静默处理错误，不显示提示框
    }
  }
}
