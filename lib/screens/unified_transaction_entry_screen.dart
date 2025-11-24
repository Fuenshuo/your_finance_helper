import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:your_finance_flutter/core/models/parsed_transaction.dart';
import 'package:your_finance_flutter/core/models/transaction.dart';
import 'package:your_finance_flutter/core/providers/account_provider.dart';
import 'package:your_finance_flutter/core/providers/budget_provider.dart';
import 'package:your_finance_flutter/core/providers/transaction_provider.dart';
import 'package:your_finance_flutter/core/services/ai/natural_language_transaction_service.dart';
import 'package:your_finance_flutter/core/services/user_income_profile_service.dart';
import 'package:your_finance_flutter/core/theme/app_design_tokens.dart';
import 'package:your_finance_flutter/core/theme/app_theme.dart';
import 'package:your_finance_flutter/core/widgets/app_card.dart';
import 'package:your_finance_flutter/core/widgets/app_primary_button.dart';
import 'package:your_finance_flutter/core/widgets/app_text_field.dart';

/// 统一记账入口页面
/// AI自动识别收支类型，零认知负担
class UnifiedTransactionEntryScreen extends StatefulWidget {
  const UnifiedTransactionEntryScreen({super.key});

  @override
  State<UnifiedTransactionEntryScreen> createState() =>
      _UnifiedTransactionEntryScreenState();
}

class _UnifiedTransactionEntryScreenState
    extends State<UnifiedTransactionEntryScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _inputController = TextEditingController();
  late final Future<NaturalLanguageTransactionService> _nlServiceFuture;

  bool _isLoading = false;
  TransactionParseResult? _parseResult;
  int _placeholderIndex = 0;
  late AnimationController _placeholderAnimationController;

  // Placeholder轮播问句
  static const List<String> _placeholders = [
    '刚发工资了？',
    '又买奶茶啦？',
    '朋友转你钱了？',
    '今天花了多少？',
  ];

  @override
  void initState() {
    super.initState();
    _nlServiceFuture = NaturalLanguageTransactionService.getInstance();
    
    _placeholderAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _placeholderAnimationController.addListener(() {
      if (_placeholderAnimationController.isCompleted) {
        setState(() {
          _placeholderIndex = (_placeholderIndex + 1) % _placeholders.length;
        });
        _placeholderAnimationController.reset();
        _placeholderAnimationController.forward();
      }
    });
    _placeholderAnimationController.forward();
  }

  @override
  void dispose() {
    _inputController.dispose();
    _placeholderAnimationController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final input = _inputController.text.trim();
    if (input.isEmpty) return;

    setState(() {
      _isLoading = true;
      _parseResult = null;
    });

    try {
      // 获取上下文数据
      final transactionProvider = context.read<TransactionProvider>();
      final accountProvider = context.read<AccountProvider>();
      final budgetProvider = context.read<BudgetProvider>();

      final accounts = accountProvider.accounts;
      final budgets = budgetProvider.envelopeBudgets;
      final userHistory = transactionProvider.transactions.take(20).toList();

      // 获取服务实例
      final nlService = await _nlServiceFuture;

      // 解析交易
      final result = await nlService.parseTransaction(
        input: input,
        userHistory: userHistory,
        accounts: accounts,
        budgets: budgets,
      );

      setState(() {
        _parseResult = result;
        _isLoading = false;
      });

      // 根据action路由
      _handleAction(result);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('解析失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleAction(TransactionParseResult result) {
    switch (result.action) {
      case 'auto_save':
        _handleAutoSave(result.parsed);
        break;
      case 'quick_confirm':
        _showQuickConfirm(result.parsed);
        break;
      case 'clarify':
        _showClarifyDialog(result.parsed);
        break;
      case 'transfer_confirm':
        _showTransferConfirm(result.parsed);
        break;
    }
  }

  Future<void> _handleAutoSave(ParsedTransaction parsed) async {
    // 保存交易
    final transaction = parsed.toTransaction();
    if (transaction != null) {
      try {
        final transactionProvider = context.read<TransactionProvider>();
        await transactionProvider.addTransaction(transaction);

        // 更新用户画像
        final profileService = await UserIncomeProfileService.getInstance();
        await profileService.updateFromTransaction(transaction);

        // 显示Toast
        if (mounted) {
          HapticFeedback.lightImpact();
          _showToast(parsed);
        }

        // 清空输入
        _inputController.clear();
        setState(() {
          _parseResult = null;
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('保存失败: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('解析结果无效，无法保存'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _showToast(ParsedTransaction parsed) {
    final isIncome = parsed.type == TransactionType.income;
    final emoji = isIncome ? '🎉' : '✅';
    final message = isIncome
        ? '${emoji} ${parsed.category?.displayName ?? "收入"}到账 ¥${_formatAmount(parsed.amount ?? 0)}！'
        : '${emoji} 已记录：${parsed.description ?? parsed.category?.displayName ?? "支出"} ¥${_formatAmount(parsed.amount ?? 0)}';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Expanded(child: Text(message)),
            Text(
              '(点击可修改 ↗️)',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        backgroundColor: isIncome ? Colors.green : Colors.blue,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: '修改',
          textColor: Colors.white,
          onPressed: () {
            _showQuickEditDialog(parsed);
          },
        ),
      ),
    );
  }

  void _showQuickConfirm(ParsedTransaction parsed) {
    showModalBottomSheet<void>(
      context: context,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _QuickConfirmBottomSheet(
        parsed: parsed,
        onConfirm: (category) async {
          Navigator.pop(context);
          final updatedParsed = parsed.copyWith(category: category);
          await _handleAutoSave(updatedParsed);
        },
        onOther: () {
          Navigator.pop(context);
          _showClarifyDialog(parsed);
        },
      ),
    );
  }

  void _showClarifyDialog(ParsedTransaction parsed) {
    showDialog<void>(
      context: context,
      builder: (context) => _ClarifyDialog(
        parsed: parsed,
        onSave: (updatedParsed) async {
          Navigator.pop(context);
          await _handleAutoSave(updatedParsed);
        },
      ),
    );
  }

  void _showTransferConfirm(ParsedTransaction parsed) {
    showDialog<void>(
      context: context,
      builder: (context) => _TransferConfirmDialog(
        parsed: parsed,
        onConfirm: (direction) async {
          Navigator.pop(context);
          // 根据方向更新类型
          TransactionType? newType;
          if (direction == 'received') {
            newType = TransactionType.income;
          } else if (direction == 'sent') {
            newType = TransactionType.expense;
          }
          // transfer保持原样

          final updatedParsed = parsed.copyWith(type: newType);
          await _handleAutoSave(updatedParsed);

          // 更新转账方向偏好
          final profileService = await UserIncomeProfileService.getInstance();
          await profileService.updateTransferDirectionPreference(direction);
        },
      ),
    );
  }

  void _showQuickEditDialog(ParsedTransaction parsed) {
    // TODO: 实现快速编辑对话框
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('快速编辑功能开发中...')),
    );
  }

  String _formatAmount(double amount) {
    return amount.toStringAsFixed(amount.truncateToDouble() == amount ? 0 : 2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('统一记账入口'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: context.primaryBackground,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppDesignTokens.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 状态栏
            AppCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        '💰 总资产',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.secondaryText,
                        ),
                      ),
                      Text(
                        '¥XXX,XXX',
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        '📊 本月收入',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.secondaryText,
                        ),
                      ),
                      Text(
                        '¥XX,XXX',
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        '💸 支出',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.secondaryText,
                        ),
                      ),
                      Text(
                        '¥X,XXX',
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: AppDesignTokens.spacing24),

            // 统一输入框
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTextField(
                    controller: _inputController,
                    hintText: _placeholders[_placeholderIndex],
                    onFieldSubmitted: (_) => _handleSubmit(),
                    enabled: !_isLoading,
                  ),
                  SizedBox(height: AppDesignTokens.spacing16),
                  Row(
                    children: [
                      Expanded(
                        child: AppPrimaryButton(
                          label: _isLoading ? '处理中...' : '记一笔',
                          onPressed: _isLoading ? null : _handleSubmit,
                          isLoading: _isLoading,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: AppDesignTokens.spacing16),

            // 多模态入口
            Row(
              children: [
                Expanded(
                  child: _buildMultimodalButton(
                    icon: Icons.camera_alt_outlined,
                    label: '拍照',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('拍照功能开发中...')),
                      );
                    },
                  ),
                ),
                SizedBox(width: AppDesignTokens.spacing8),
                Expanded(
                  child: _buildMultimodalButton(
                    icon: Icons.mic_outlined,
                    label: '语音',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('语音功能开发中...')),
                      );
                    },
                  ),
                ),
                SizedBox(width: AppDesignTokens.spacing8),
                Expanded(
                  child: _buildMultimodalButton(
                    icon: Icons.paste_outlined,
                    label: '粘贴',
                    onPressed: () async {
                      final clipboardData =
                          await Clipboard.getData(Clipboard.kTextPlain);
                      if (clipboardData?.text != null) {
                        _inputController.text = clipboardData!.text!;
                      }
                    },
                  ),
                ),
              ],
            ),

            // 解析结果展示（调试用）
            if (_parseResult != null) ...[
              SizedBox(height: AppDesignTokens.spacing24),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '解析结果（调试）',
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: AppDesignTokens.spacing8),
                    Text('类型: ${_parseResult!.parsed.type?.name}'),
                    Text('分类: ${_parseResult!.parsed.category?.displayName}'),
                    Text('金额: ¥${_formatAmount(_parseResult!.parsed.amount ?? 0)}'),
                    Text('置信度: ${(_parseResult!.parsed.confidence * 100).toStringAsFixed(0)}%'),
                    Text('动作: ${_parseResult!.action}'),
                    if (_parseResult!.parsed.uncertainty != null)
                      Text('不确定性: ${_parseResult!.parsed.uncertainty}'),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMultimodalButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(
          vertical: AppDesignTokens.spacing12,
        ),
      ),
    );
  }
}

/// 快速确认底部弹窗
class _QuickConfirmBottomSheet extends StatelessWidget {
  const _QuickConfirmBottomSheet({
    required this.parsed,
    required this.onConfirm,
    required this.onOther,
  });

  final ParsedTransaction parsed;
  final void Function(TransactionCategory) onConfirm;
  final VoidCallback onOther;

  @override
  Widget build(BuildContext context) {
    final isIncome = parsed.type == TransactionType.income;
    final amount = parsed.amount ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: EdgeInsets.all(AppDesignTokens.spacing16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 关闭按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isIncome
                    ? '💰 刚收到 ¥${_formatAmount(amount)}，这是什么收入？'
                    : '💸 花了 ¥${_formatAmount(amount)}，这是什么支出？',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          SizedBox(height: AppDesignTokens.spacing16),
          // 场景化标签
          Wrap(
            spacing: AppDesignTokens.spacing8,
            runSpacing: AppDesignTokens.spacing8,
            children: [
              if (isIncome) ...[
                _buildCategoryButton(
                  context,
                  '我的工资',
                  TransactionCategory.salary,
                  onConfirm,
                ),
                _buildCategoryButton(
                  context,
                  '年终奖',
                  TransactionCategory.bonus,
                  onConfirm,
                ),
                _buildCategoryButton(
                  context,
                  '朋友转账',
                  TransactionCategory.gift,
                  onConfirm,
                ),
              ] else ...[
                _buildCategoryButton(
                  context,
                  '打车',
                  TransactionCategory.transport,
                  onConfirm,
                ),
                _buildCategoryButton(
                  context,
                  '吃饭',
                  TransactionCategory.food,
                  onConfirm,
                ),
                _buildCategoryButton(
                  context,
                  '购物',
                  TransactionCategory.shopping,
                  onConfirm,
                ),
              ],
              OutlinedButton(
                onPressed: onOther,
                child: const Text('其他'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryButton(
    BuildContext context,
    String label,
    TransactionCategory category,
    void Function(TransactionCategory) onTap,
  ) {
    return ElevatedButton(
      onPressed: () => onTap(category),
      child: Text(label),
    );
  }

  String _formatAmount(double amount) {
    return amount.toStringAsFixed(amount.truncateToDouble() == amount ? 0 : 2);
  }
}

/// 降级补全对话框
class _ClarifyDialog extends StatefulWidget {
  const _ClarifyDialog({
    required this.parsed,
    required this.onSave,
  });

  final ParsedTransaction parsed;
  final void Function(ParsedTransaction) onSave;

  @override
  State<_ClarifyDialog> createState() => _ClarifyDialogState();
}

class _ClarifyDialogState extends State<_ClarifyDialog> {
  final TextEditingController _amountController = TextEditingController();
  TransactionCategory? _selectedCategory;
  TransactionType? _selectedType;

  @override
  void initState() {
    super.initState();
    _amountController.text =
        widget.parsed.amount?.toStringAsFixed(0) ?? '';
    _selectedCategory = widget.parsed.category;
    _selectedType = widget.parsed.type;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.parsed.type == TransactionType.income
          ? '💰 发工资啦！多少钱？'
          : '💸 这笔钱是什么？'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _amountController,
            decoration: const InputDecoration(
              labelText: '金额',
              prefixText: '¥',
            ),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: AppDesignTokens.spacing16),
          DropdownButtonFormField<TransactionType>(
            value: _selectedType,
            decoration: const InputDecoration(labelText: '类型'),
            items: TransactionType.values.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(type.displayName),
              );
            }).toList(),
            onChanged: (value) => setState(() => _selectedType = value),
          ),
          SizedBox(height: AppDesignTokens.spacing16),
          DropdownButtonFormField<TransactionCategory>(
            value: _selectedCategory,
            decoration: const InputDecoration(labelText: '分类'),
            items: TransactionCategory.values
                .where((cat) => _selectedType == null ||
                    (_selectedType == TransactionType.income &&
                        cat.isIncome) ||
                    (_selectedType == TransactionType.expense &&
                        cat.isExpense))
                .map((cat) {
              return DropdownMenuItem(
                value: cat,
                child: Text(cat.displayName),
              );
            }).toList(),
            onChanged: (value) => setState(() => _selectedCategory = value),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: () {
            final amount = double.tryParse(_amountController.text);
            if (amount != null && _selectedCategory != null) {
              widget.onSave(
                widget.parsed.copyWith(
                  amount: amount,
                  category: _selectedCategory,
                  type: _selectedType,
                ),
              );
            }
          },
          child: const Text('保存'),
        ),
      ],
    );
  }
}

/// 转账确认对话框
class _TransferConfirmDialog extends StatelessWidget {
  const _TransferConfirmDialog({
    required this.parsed,
    required this.onConfirm,
  });

  final ParsedTransaction parsed;
  final void Function(String) onConfirm;

  @override
  Widget build(BuildContext context) {
    final amount = parsed.amount ?? 0;

    return AlertDialog(
      title: const Text('🔄 这笔 ¥ 是？'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '¥${_formatAmount(amount)}',
            style: context.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppDesignTokens.spacing16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => onConfirm('sent'),
              child: const Text('我转给朋友'),
            ),
          ),
          SizedBox(height: AppDesignTokens.spacing8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => onConfirm('received'),
              child: const Text('朋友转给我'),
            ),
          ),
          SizedBox(height: AppDesignTokens.spacing8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => onConfirm('internal'),
              child: const Text('银行卡间转账'),
            ),
          ),
          SizedBox(height: AppDesignTokens.spacing8),
          Text(
            '💡 银行卡转账不计入预算统计',
            style: context.textTheme.bodySmall?.copyWith(
              color: context.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  String _formatAmount(double amount) {
    return amount.toStringAsFixed(amount.truncateToDouble() == amount ? 0 : 2);
  }
}

