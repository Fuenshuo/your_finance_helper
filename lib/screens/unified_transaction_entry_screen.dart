import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
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
    'Tell me about a transaction...',
    '试试：刚才打车花了35',
    '工资到账了吗？',
    '把昨晚的外卖也记一下吧',
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

      final result = await nlService.parseTransaction(
        input: input,
        userHistory: userHistory,
        accounts: accounts,
        budgets: budgets,
      );

      setState(() {
        _isLoading = false;
      });
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
      default:
        setState(() {
          _parseResult = result;
        });
    }
  }

  Future<void> _handleAutoSave(ParsedTransaction parsed) async {
    // 保存交易
    final transaction = parsed.toTransaction();
    if (transaction != null) {
      try {
        final normalizedTransaction = transaction.copyWith(
          date: _resolveTransactionDate(parsed.date),
        );
        final transactionProvider = context.read<TransactionProvider>();
        await transactionProvider.addTransaction(normalizedTransaction);

        // 更新用户画像
        final profileService = await UserIncomeProfileService.getInstance();
        await profileService.updateFromTransaction(normalizedTransaction);

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
              '继续聊天吧',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        backgroundColor: isIncome ? Colors.green : Colors.blue,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatAmount(double amount) {
    return amount.toStringAsFixed(amount.truncateToDouble() == amount ? 0 : 2);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: context.primaryBackground,
      body: Column(
        children: [
          _buildCompactHeader(context),
          Expanded(child: _buildTimelineFeed(context)),
          AnimatedPadding(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            padding: EdgeInsets.only(bottom: bottomInset),
            child: _buildAiCommandDock(context),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactHeader(BuildContext context) {
    final accounts = context.watch<AccountProvider>().accounts;
    final transactions = context.watch<TransactionProvider>().transactions;

    final totalAssets = accounts.fold<double>(
      0,
      (sum, account) => sum + account.balance,
    );

    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month);
    double monthlyExpense = 0;
    for (final transaction in transactions) {
      if (transaction.date.isBefore(monthStart)) continue;
      final type = transaction.type ??
          (transaction.category.isIncome
              ? TransactionType.income
              : TransactionType.expense);
      if (type == TransactionType.expense) {
        monthlyExpense += transaction.amount;
      }
    }

    return SafeArea(
      bottom: false,
      child: Container(
        height: 72,
        padding: EdgeInsets.symmetric(horizontal: AppDesignTokens.spacing16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _HeaderMetric(
              label: '本月支出',
              value: '¥${_formatAmount(monthlyExpense)}',
            ),
            Container(
              width: 1,
              height: 32,
              color: Colors.grey.shade200,
            ),
            _HeaderMetric(
              label: '总资产',
              value: '¥${_formatAmount(totalAssets)}',
              alignment: CrossAxisAlignment.end,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineFeed(BuildContext context) {
    final transactionProvider = context.watch<TransactionProvider>();
    final transactions = transactionProvider.transactions.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    final grouped = _groupTransactionsByDate(transactions);

    final hasDraft = _parseResult != null;

    if (grouped.isEmpty && !hasDraft) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppDesignTokens.spacing24),
          child: Text(
            '还没有记录。告诉我“刚才咖啡花了28”，我就能把它记在账本里。',
            textAlign: TextAlign.center,
            style: context.textTheme.bodyLarge?.copyWith(
              color: context.secondaryText,
            ),
          ),
        ),
      );
    }

    final sections = <_TimelineSection>[];
    if (hasDraft) {
      final draft = _parseResult;
      if (draft != null) {
        sections.add(_TimelineSection.draft(draft));
      }
    }
    sections.addAll(grouped);

    final timelineSections = sections.where((s) => !s.isDraft).toList();

    final timeline = ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        AppDesignTokens.spacing16,
        AppDesignTokens.spacing12,
        AppDesignTokens.spacing16,
        hasDraft ? 200 : 140,
      ),
      itemCount: timelineSections.length,
      itemBuilder: (context, index) {
        final section = timelineSections[index];
        return _buildTimelineSection(context, section);
      },
    );

    return Stack(
      children: [
        Positioned.fill(child: timeline),
        if (hasDraft && sections.first.isDraft && sections.first.draft != null)
          Positioned(
            left: AppDesignTokens.spacing16,
            right: AppDesignTokens.spacing16,
            bottom: AppDesignTokens.spacing16,
            child: _buildFloatingDraftCard(context, sections.first.draft!),
          ),
      ],
    );
  }

  List<_TimelineSection> _groupTransactionsByDate(
    List<Transaction> transactions,
  ) {
    final sections = <_TimelineSection>[];
    DateTime? currentDate;
    List<Transaction> currentItems = [];

    void addSection() {
      final dateForSection = currentDate;
      if (dateForSection != null && currentItems.isNotEmpty) {
        sections.add(
          _TimelineSection(
            date: dateForSection,
            transactions: List<Transaction>.unmodifiable(currentItems),
          ),
        );
        currentItems = [];
      }
    }

    for (final transaction in transactions) {
      final date = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );
      if (currentDate == null || date != currentDate) {
        addSection();
        currentDate = date;
      }
      currentItems.add(transaction);
    }
    addSection();
    return sections;
  }

  Widget _buildTimelineSection(
    BuildContext context,
    _TimelineSection section,
  ) {
    final dateLabel = _formatDateLabel(section.date ?? DateTime.now());

    return Padding(
      padding: EdgeInsets.only(bottom: AppDesignTokens.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: AppDesignTokens.spacing4,
            ),
            child: Text(
              dateLabel,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: EdgeInsets.symmetric(
              horizontal: AppDesignTokens.spacing16,
              vertical: AppDesignTokens.spacing8,
            ),
            child: Column(
              children: section.transactions
                  .map(
                    (transaction) => _buildTimelineRow(
                      context,
                      transaction,
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineRow(BuildContext context, Transaction transaction) {
    final type = transaction.type ??
        (transaction.category.isIncome
            ? TransactionType.income
            : TransactionType.expense);
    final isIncome = type == TransactionType.income;
    final amountColor = isIncome ? Colors.green : Colors.redAccent;
    final description = transaction.description;
    final subtitle =
        transaction.notes?.isNotEmpty == true ? transaction.notes : description;
    final formattedAmount =
        '${isIncome ? '+' : '-'}¥${_formatAmount(transaction.amount)}';

    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppDesignTokens.spacing8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.grey.shade100,
            child: Icon(
              _categoryIcon(transaction.category),
              color: Colors.grey.shade600,
              size: 22,
            ),
          ),
          SizedBox(width: AppDesignTokens.spacing16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.category.displayName,
                  style: context.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: AppDesignTokens.spacing4),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.secondaryText,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            formattedAmount,
            style: context.textTheme.titleLarge?.copyWith(
              color: amountColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingDraftCard(
    BuildContext context,
    TransactionParseResult result,
  ) {
    final parsed = result.parsed;
    final isIncome = parsed.type == TransactionType.income;
    final amountColor = isIncome ? Colors.green : Colors.redAccent;
    final amount = _formatAmount(parsed.amount ?? 0);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(AppDesignTokens.spacing16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '待确认 · ${parsed.category?.displayName ?? "未分类"}',
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppDesignTokens.spacing8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.grey.shade100,
                  child: Icon(
                    _categoryIcon(parsed.category),
                    size: 28,
                    color: Colors.grey.shade700,
                  ),
                ),
                SizedBox(width: AppDesignTokens.spacing16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${isIncome ? '+' : '-'}¥$amount',
                        style: context.textTheme.displaySmall?.copyWith(
                          color: amountColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (parsed.description?.isNotEmpty ?? false)
                        Padding(
                          padding: EdgeInsets.only(
                            top: AppDesignTokens.spacing4,
                          ),
                          child: Text(
                            parsed.description!,
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.secondaryText,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: AppDesignTokens.spacing16),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed:
                        _isLoading ? null : () => _handleAutoSave(parsed),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('确认入账'),
                  ),
                ),
                SizedBox(width: AppDesignTokens.spacing8),
                IconButton(
                  onPressed: () => setState(() => _parseResult = null),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _categoryIcon(TransactionCategory? category) {
    switch (category) {
      case TransactionCategory.food:
        return Icons.restaurant;
      case TransactionCategory.transport:
        return Icons.directions_bus;
      case TransactionCategory.shopping:
        return Icons.shopping_bag;
      case TransactionCategory.salary:
        return Icons.work;
      case TransactionCategory.bonus:
        return Icons.card_giftcard;
      case TransactionCategory.entertainment:
        return Icons.movie;
      case TransactionCategory.healthcare:
        return Icons.health_and_safety;
      case TransactionCategory.education:
        return Icons.school;
      case TransactionCategory.housing:
        return Icons.home;
      case TransactionCategory.utilities:
        return Icons.lightbulb;
      case TransactionCategory.insurance:
        return Icons.shield;
      default:
        return Icons.receipt_long;
    }
  }

  Widget _buildAiCommandDock(BuildContext context) {
    final iconColor = context.secondaryText;

    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppDesignTokens.spacing12,
          vertical: AppDesignTokens.spacing8,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: () => _showWipSnackbar(context, '拍照'),
              splashRadius: 22,
              icon: Icon(Icons.camera_alt_outlined, color: iconColor),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDesignTokens.spacing12,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(26),
                ),
                child: TextField(
                  controller: _inputController,
                  onSubmitted: (_) => _handleSubmit(),
                  enabled: !_isLoading,
                  minLines: 1,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: _placeholders[_placeholderIndex],
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: () => _showWipSnackbar(context, '语音'),
              splashRadius: 22,
              icon: Icon(Icons.mic_none_outlined, color: iconColor),
            ),
            _buildSendButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSendButton(BuildContext context) {
    final Color primary = AppDesignTokens.primaryAction(context);
    return Container(
      margin: EdgeInsets.only(left: AppDesignTokens.spacing8),
      child: SizedBox(
        width: 48,
        height: 48,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _handleSubmit,
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: EdgeInsets.zero,
            backgroundColor: primary,
            elevation: 0,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                ),
        ),
      ),
    );
  }

  void _showWipSnackbar(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature 功能开发中...')),
    );
  }
}

class _HeaderMetric extends StatelessWidget {
  const _HeaderMetric({
    required this.label,
    required this.value,
    this.alignment = CrossAxisAlignment.start,
  });

  final String label;
  final String value;
  final CrossAxisAlignment alignment;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignment,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.secondaryText,
          ),
        ),
        SizedBox(height: AppDesignTokens.spacing4),
        Text(
          value,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _TimelineSection {
  const _TimelineSection({
    required this.date,
    required this.transactions,
  })  : draft = null,
        isDraft = false;

  const _TimelineSection.draft(this.draft)
      : date = null,
        transactions = const [],
        isDraft = true;

  final DateTime? date;
  final List<Transaction> transactions;
  final TransactionParseResult? draft;
  final bool isDraft;
}

DateTime _resolveTransactionDate(DateTime? parsedDate) {
  final now = DateTime.now();
  if (parsedDate == null) return now;
  final isMidnight = parsedDate.hour == 0 &&
      parsedDate.minute == 0 &&
      parsedDate.second == 0 &&
      parsedDate.millisecond == 0 &&
      parsedDate.microsecond == 0;
  if (!isMidnight) return parsedDate;
  return DateTime(
    parsedDate.year,
    parsedDate.month,
    parsedDate.day,
    now.hour,
    now.minute,
    now.second,
    now.millisecond,
    now.microsecond,
  );
}

String _formatDateLabel(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final target = DateTime(date.year, date.month, date.day);

  if (target == today) {
    return '今天';
  }
  if (target == yesterday) {
    return '昨天';
  }
  if (target.year == today.year) {
    return DateFormat('M月d日').format(date);
  }
  return DateFormat('yyyy年M月d日').format(date);
}
