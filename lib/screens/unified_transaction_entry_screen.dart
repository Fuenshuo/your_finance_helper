import 'dart:collection';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:your_finance_flutter/core/models/account.dart';
import 'package:your_finance_flutter/core/models/parsed_transaction.dart';
import 'package:your_finance_flutter/core/models/transaction.dart';
import 'package:your_finance_flutter/core/providers/account_provider.dart';
import 'package:your_finance_flutter/core/providers/budget_provider.dart';
import 'package:your_finance_flutter/core/providers/transaction_provider.dart';
import 'package:your_finance_flutter/core/services/ai/natural_language_transaction_service.dart';
import 'package:your_finance_flutter/core/services/user_income_profile_service.dart';
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
  int _placeholderIndex = 0;
  late AnimationController _placeholderAnimationController;
  ParsedTransaction? _draftTransaction;
  DateTime? _draftDate;
  String? _draftAccountId;
  String? _draftAccountName;
  late final AnimationController _draftMergeController;
  bool _isConfirmingDraft = false;
  final NumberFormat _currencyFormatter =
      NumberFormat.currency(locale: 'zh_CN', symbol: '¥');

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

    _draftMergeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

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
    _draftMergeController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final input = _inputController.text.trim();
    if (input.isEmpty) return;

    setState(() {
      _isLoading = true;
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
        _isLoading = false;
      });

      _applyDraftResult(result);
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

  void _applyDraftResult(TransactionParseResult result) {
    final parsed = result.parsed;
    if (!parsed.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请输入更完整的描述，例如 “星巴克 35”'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _draftTransaction = parsed;
      _draftDate = parsed.date ?? DateTime.now();
      _draftAccountId = parsed.accountId;
      _draftAccountName = parsed.accountName;
      _isConfirmingDraft = false;
      _draftMergeController.reset();
    });
    _inputController.clear();
    FocusScope.of(context).unfocus();
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
        }

        // 清空输入
        _inputController.clear();
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

  Widget _buildInputDock(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: context.surfaceWhite,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 30,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '记一笔',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    enabled: !_isLoading,
                    onSubmitted: (_) => _handleSubmit(),
                    decoration: InputDecoration(
                      hintText: _placeholders[_placeholderIndex],
                      filled: true,
                      fillColor: const Color(0xFFF2F2F7),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: _isLoading ? null : _handleSubmit,
                    child: _isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.arrow_upward_rounded),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDraftCard(
    BuildContext context,
    List<Account> accounts,
  ) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 420),
      transitionBuilder: (child, animation) {
        final curved =
            CurvedAnimation(parent: animation, curve: Curves.easeOutBack);
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1).animate(curved),
            child: child,
          ),
        );
      },
      child: _draftTransaction == null
          ? const SizedBox.shrink()
          : AnimatedBuilder(
              animation: _draftMergeController,
              builder: (context, child) {
                final value = _draftMergeController.value;
                return Opacity(
                  opacity: 1 - value,
                  child: Transform.translate(
                    offset: Offset(0, -60 * value),
                    child: Transform.scale(
                      scale: 1 - value * 0.15,
                      child: child,
                    ),
                  ),
                );
              },
              child: _buildDraftCardContent(context, accounts),
            ),
    );
  }

  Widget _buildDraftCardContent(
    BuildContext context,
    List<Account> accounts,
  ) {
    final draft = _draftTransaction!;
    final isExpense = _isParsedExpense(draft);
    final isIncome = _isParsedIncome(draft);
    final amount = draft.amount ?? 0;
    final sign = isExpense
        ? '-'
        : isIncome
            ? '+'
            : '';
    final amountColor = isExpense
        ? context.expenseRed
        : isIncome
            ? context.incomeGreen
            : context.textPrimary;
    final title = draft.category?.displayName ?? draft.description ?? '未分类';
    final subtitle = draft.description ?? draft.notes ?? '——';

    return Container(
      decoration: BoxDecoration(
        color: context.surfaceWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  '$sign${_currencyFormatter.format(amount.abs())}',
                  style: context.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: amountColor,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              _buildConfirmButton(context),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: context.primaryBackground,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  _categoryIcon(
                      draft.category ?? TransactionCategory.otherExpense),
                  color: context.primaryText,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildDateChip(context),
              const SizedBox(width: 8),
              _buildAccountChip(context, accounts),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    final canConfirm =
        (_draftTransaction?.isValid ?? false) && !_isConfirmingDraft;
    return ElevatedButton(
      onPressed: canConfirm ? _confirmDraftTransaction : null,
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        minimumSize: const Size(56, 56),
        backgroundColor: context.primaryAction,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      child: _isConfirmingDraft
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Icon(Icons.check_rounded),
    );
  }

  Widget _buildDateChip(BuildContext context) {
    return PopupMenuButton<_DateMenuAction>(
      tooltip: '选择日期',
      onSelected: _handleDateMenuSelection,
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: _DateMenuAction.today,
          child: Text('今天'),
        ),
        PopupMenuItem(
          value: _DateMenuAction.yesterday,
          child: Text('昨天'),
        ),
        PopupMenuItem(
          value: _DateMenuAction.pick,
          child: Text('选择日期...'),
        ),
      ],
      child: _buildChipSurface(label: _dateChipLabel),
    );
  }

  Widget _buildAccountChip(
    BuildContext context,
    List<Account> accounts,
  ) {
    return PopupMenuButton<String?>(
      tooltip: '选择账户',
      onSelected: (value) => _handleAccountSelection(value, accounts),
      itemBuilder: (context) => [
        const PopupMenuItem<String?>(
          value: null,
          child: Text('默认账户'),
        ),
        ...accounts.map(
          (account) => PopupMenuItem<String?>(
            value: account.id,
            child: Text(account.name),
          ),
        ),
      ],
      child: _buildChipSurface(label: _accountChipLabel(accounts)),
    );
  }

  Widget _buildChipSurface({required String label}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F7),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: context.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      );

  String get _dateChipLabel {
    final date = _draftDate ?? DateTime.now();
    final today = DateTime.now();
    if (_isSameDay(date, today)) {
      return '🕒 Today';
    }
    if (_isSameDay(date, today.subtract(const Duration(days: 1)))) {
      return '🕒 Yesterday';
    }
    return '🕒 ${DateFormat('MMM d').format(date)}';
  }

  String _accountChipLabel(List<Account> accounts) {
    if (_draftAccountName != null && _draftAccountName!.isNotEmpty) {
      return '💳 ${_draftAccountName!}';
    }
    if (_draftAccountId != null) {
      Account? match;
      for (final account in accounts) {
        if (account.id == _draftAccountId) {
          match = account;
          break;
        }
      }
      if (match != null) {
        return '💳 ${match.name}';
      }
    }
    return '💳 Default';
  }

  Future<void> _handleDateMenuSelection(_DateMenuAction action) async {
    DateTime? newDate;
    switch (action) {
      case _DateMenuAction.today:
        newDate = DateTime.now();
        break;
      case _DateMenuAction.yesterday:
        newDate = DateTime.now().subtract(const Duration(days: 1));
        break;
      case _DateMenuAction.pick:
        final picked = await showDatePicker(
          context: context,
          initialDate: _draftDate ?? DateTime.now(),
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        newDate = picked;
        break;
    }
    if (newDate != null) {
      setState(() {
        _draftDate = DateTime(
          newDate!.year,
          newDate.month,
          newDate.day,
        );
      });
    }
  }

  void _handleAccountSelection(String? value, List<Account> accounts) {
    if (value == null) {
      setState(() {
        _draftAccountId = null;
        _draftAccountName = 'Default';
      });
      return;
    }

    Account? selected;
    for (final account in accounts) {
      if (account.id == value) {
        selected = account;
        break;
      }
    }

    setState(() {
      _draftAccountId = value;
      _draftAccountName = selected?.name ?? 'Default';
    });
  }

  Future<void> _confirmDraftTransaction() async {
    final draft = _draftTransaction;
    if (draft == null || _isConfirmingDraft) return;
    if (!draft.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请完善金额和描述后再确认'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isConfirmingDraft = true;
    });

    try {
      await _draftMergeController.forward();
      final updatedDraft = draft.copyWith(
        date: _draftDate,
        accountId: _draftAccountId ?? draft.accountId,
        accountName: _draftAccountName ?? draft.accountName,
      );
      await _handleAutoSave(updatedDraft);
      if (!mounted) return;
      setState(() {
        _draftTransaction = null;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isConfirmingDraft = false;
        });
      }
      _draftMergeController.reset();
    }
  }

  bool _isParsedExpense(ParsedTransaction parsed) {
    if (parsed.type != null) {
      return parsed.type == TransactionType.expense;
    }
    return true;
  }

  bool _isParsedIncome(ParsedTransaction parsed) {
    if (parsed.type != null) {
      return parsed.type == TransactionType.income;
    }
    return false;
  }

  Widget _buildTimelineSliver(
    BuildContext context,
    List<_TransactionDayGroup> groups,
    bool isLoading,
  ) {
    if (isLoading) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 48),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (groups.isEmpty) {
      return SliverToBoxAdapter(child: _buildEmptyState(context));
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => _buildDayCard(context, groups[index]),
        childCount: groups.length,
      ),
    );
  }

  Widget _buildDayCard(BuildContext context, _TransactionDayGroup group) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 30,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                _formatDayLabel(group.date),
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${group.transactions.length} 笔',
                style: context.textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...List.generate(group.transactions.length, (index) {
            final transaction = group.transactions[index];
            final row = _buildTransactionRow(context, transaction);
            if (index == group.transactions.length - 1) {
              return row;
            }
            return Column(
              children: [
                row,
                const SizedBox(height: 12),
                Divider(color: context.dividerColor.withOpacity(0.3)),
                const SizedBox(height: 12),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTransactionRow(
    BuildContext context,
    Transaction transaction,
  ) {
    final isExpense = _isExpense(transaction);
    final isIncome = _isIncome(transaction);
    final amountColor = isExpense
        ? context.expenseRed
        : isIncome
            ? context.incomeGreen
            : context.textPrimary;
    final sign = isExpense
        ? '-'
        : isIncome
            ? '+'
            : '';
    final formattedAmount = _currencyFormatter.format(transaction.amount.abs());

    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: context.primaryBackground,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            _categoryIcon(transaction.category),
            color: context.primaryText,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            transaction.description,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: context.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '$sign$formattedAmount',
          style: context.textTheme.titleMedium?.copyWith(
            color: amountColor,
            fontFeatures: const [FontFeature.tabularFigures()],
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 24,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.stars_rounded,
            size: 48,
            color: context.secondaryText,
          ),
          const SizedBox(height: 12),
          Text(
            '暂无记录',
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '随手记一笔，看看今日现金流。',
            style: context.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<_TransactionDayGroup> _groupTransactions(
    List<Transaction> transactions,
  ) {
    final confirmed = transactions
        .where(
            (transaction) => transaction.status == TransactionStatus.confirmed)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    final grouped = LinkedHashMap<DateTime, List<Transaction>>(
      equals: (a, b) => _isSameDay(a, b),
      hashCode: (date) => date.year * 10000 + date.month * 100 + date.day,
    );

    for (final transaction in confirmed) {
      final dayKey = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );
      grouped.putIfAbsent(dayKey, () => []).add(transaction);
    }

    return grouped.entries
        .map(
          (entry) => _TransactionDayGroup(
            date: entry.key,
            transactions: entry.value,
          ),
        )
        .toList();
  }

  String _formatDayLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (_isSameDay(date, today)) {
      return 'Today';
    }
    if (_isSameDay(date, yesterday)) {
      return 'Yesterday';
    }

    return DateFormat('MMM d, yyyy').format(date);
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isExpense(Transaction transaction) {
    if (transaction.type != null) {
      return transaction.type == TransactionType.expense;
    }
    if (transaction.flow != null) {
      return transaction.flow == TransactionFlow.walletToExternal ||
          transaction.flow == TransactionFlow.walletToAsset;
    }
    return false;
  }

  bool _isIncome(Transaction transaction) {
    if (transaction.type != null) {
      return transaction.type == TransactionType.income;
    }
    if (transaction.flow != null) {
      return transaction.flow == TransactionFlow.externalToWallet ||
          transaction.flow == TransactionFlow.assetToWallet;
    }
    return false;
  }

  IconData _categoryIcon(TransactionCategory category) {
    switch (category) {
      case TransactionCategory.food:
        return Icons.restaurant;
      case TransactionCategory.transport:
        return Icons.directions_bus_outlined;
      case TransactionCategory.shopping:
        return Icons.shopping_bag_outlined;
      case TransactionCategory.entertainment:
        return Icons.movie_outlined;
      case TransactionCategory.healthcare:
        return Icons.health_and_safety_outlined;
      case TransactionCategory.education:
        return Icons.menu_book_outlined;
      case TransactionCategory.housing:
        return Icons.house_outlined;
      case TransactionCategory.utilities:
        return Icons.lightbulb_outline;
      case TransactionCategory.insurance:
        return Icons.verified_user_outlined;
      case TransactionCategory.salary:
        return Icons.workspace_premium_outlined;
      case TransactionCategory.bonus:
        return Icons.card_giftcard_outlined;
      case TransactionCategory.investment:
        return Icons.trending_up_outlined;
      case TransactionCategory.freelance:
        return Icons.work_outline;
      case TransactionCategory.gift:
        return Icons.cake_outlined;
      case TransactionCategory.otherIncome:
      case TransactionCategory.otherExpense:
        return Icons.category_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = context.watch<TransactionProvider>();
    final accountsProvider = context.watch<AccountProvider>();
    final groupedTransactions = _groupTransactions(
      transactionProvider.transactions,
    );
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final dockBottom = kBottomNavigationBarHeight + bottomInset + 8;
    final cardBottom = dockBottom + 150;
    final scrollBottomPadding = dockBottom + 260;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: context.primaryBackground,
        body: Stack(
          clipBehavior: Clip.none,
          children: [
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Smart Timeline',
                          style: context.textTheme.displayMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '每一天的现金流都在这里。',
                          style: context.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, scrollBottomPadding),
                  sliver: _buildTimelineSliver(
                    context,
                    groupedTransactions,
                    transactionProvider.isLoading,
                  ),
                ),
              ],
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: cardBottom,
              child: _buildDraftCard(
                context,
                accountsProvider.accounts,
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: dockBottom,
              child: _buildInputDock(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionDayGroup {
  const _TransactionDayGroup({
    required this.date,
    required this.transactions,
  });

  final DateTime date;
  final List<Transaction> transactions;
}

enum _DateMenuAction { today, yesterday, pick }
