import 'dart:collection';
import 'dart:math' as math;
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
    extends State<UnifiedTransactionEntryScreen> with TickerProviderStateMixin {
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
  late final AnimationController _inputCollapseController;
  late final AnimationController _rainbowRotationController;
  late final AnimationController _draftCardRevealController;
  late final AnimationController _confirmGlowController;
  late final AnimationController _dayCardHighlightController;
  late final AnimationController _insertionController;
  final ScrollController _scrollController = ScrollController();
  bool _isConfirmingDraft = false;
  final NumberFormat _currencyFormatter =
      NumberFormat.currency(locale: 'zh_CN', symbol: '¥');
  final Map<String, GlobalKey> _dayCardKeys = {};
  bool _isScrollScheduled = false;
  String? _pendingScrollDayKey;
  String? _highlightedDayKey;
  String? _recentTransactionId;

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
    _inputCollapseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _rainbowRotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _draftCardRevealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 720),
    );
    _confirmGlowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _insertionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _dayCardHighlightController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          Future<void>.delayed(const Duration(milliseconds: 350), () {
            if (mounted &&
                _dayCardHighlightController.status ==
                    AnimationStatus.completed) {
              _dayCardHighlightController.reverse();
            }
          });
        }
        if (status == AnimationStatus.dismissed && mounted) {
          setState(() {
            _highlightedDayKey = null;
            _recentTransactionId = null;
          });
          _insertionController.reset();
          if (!_isLoading && _draftTransaction == null) {
            _rainbowRotationController.stop();
          }
        }
      });

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
    _inputCollapseController.dispose();
    _rainbowRotationController.dispose();
    _draftCardRevealController.dispose();
    _confirmGlowController.dispose();
    _insertionController.dispose();
    _dayCardHighlightController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final input = _inputController.text.trim();
    if (input.isEmpty) return;

    setState(() {
      _isLoading = true;
    });
    _inputCollapseController.forward(from: 0);
    if (!_rainbowRotationController.isAnimating) {
      _rainbowRotationController.repeat();
    }

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
      _inputCollapseController.reverse();
      if (_draftTransaction == null) {
        _rainbowRotationController.stop();
      }
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
      _inputCollapseController.reverse();
      _rainbowRotationController.stop();
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
    _inputCollapseController.reverse();
    _draftCardRevealController.forward(from: 0);
    if (!_rainbowRotationController.isAnimating) {
      _rainbowRotationController.repeat();
    }
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

        final dayKey = _dayKeyFromDate(transaction.date);
        setState(() {
          _pendingScrollDayKey = dayKey;
          _highlightedDayKey = dayKey;
          _recentTransactionId = transaction.id;
        });
        _insertionController.forward(from: 0);
        if (!_rainbowRotationController.isAnimating) {
          _rainbowRotationController.repeat();
        }
        _dayCardHighlightController.forward(from: 0);
        _scheduleScrollToHighlightedCard();

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

  Widget _buildInputDock(BuildContext context) => AnimatedBuilder(
        animation: Listenable.merge([
          _inputCollapseController,
          _rainbowRotationController,
        ]),
        builder: (context, child) {
          final collapseValue = Curves.easeInOutCubic.transform(
            _inputCollapseController.value,
          );
          final availableWidth = MediaQuery.of(context).size.width - 32;
          final dockWidth = lerpDouble(availableWidth, 78, collapseValue)!;
          final dockRadius = lerpDouble(24, dockWidth / 2, collapseValue)!;
          var horizontalPadding = 20 - (18 * collapseValue);
          if (horizontalPadding < 2) {
            horizontalPadding = 2;
          } else if (horizontalPadding > 20) {
            horizontalPadding = 20;
          }
          final verticalPadding = 20 - 6 * collapseValue;
          return SafeArea(
            top: false,
            child: Align(
              alignment: collapseValue > 0.2
                  ? Alignment.bottomRight
                  : Alignment.center,
              child: SizedBox(
                width: dockWidth,
                child: Container(
                  decoration: BoxDecoration(
                    color: context.surfaceWhite,
                    borderRadius: BorderRadius.circular(dockRadius),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withOpacity(0.08 + 0.12 * collapseValue),
                        blurRadius: 30,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    verticalPadding,
                    horizontalPadding,
                    16,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: 1 - collapseValue,
                        child: collapseValue >= 0.95
                            ? const SizedBox.shrink()
                            : Text(
                                '记一笔',
                                style: context.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                      SizedBox(height: collapseValue >= 0.95 ? 0 : 12),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final sendButtonSize =
                              lerpDouble(56, 74, collapseValue)!;
                          final gap = collapseValue >= 0.95 ? 0.0 : 12.0;
                          final inputWidth =
                              (constraints.maxWidth - sendButtonSize - gap)
                                  .clamp(0.0, double.infinity);
                          final animatedInputWidth =
                              inputWidth * (1 - collapseValue);
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (animatedInputWidth > 4)
                                SizedBox(
                                  width: animatedInputWidth,
                                  child: Opacity(
                                    opacity: 1 - collapseValue,
                                    child: TextField(
                                      controller: _inputController,
                                      enabled: !_isLoading,
                                      onSubmitted: (_) => _handleSubmit(),
                                      decoration: InputDecoration(
                                        hintText:
                                            _placeholders[_placeholderIndex],
                                        filled: true,
                                        fillColor: const Color(0xFFF2F2F7),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          borderSide: BorderSide.none,
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              if (animatedInputWidth > 4) SizedBox(width: gap),
                              SizedBox(
                                height: sendButtonSize,
                                width: sendButtonSize,
                                child: _RainbowSendButton(
                                  isLoading: _isLoading,
                                  collapseProgress: collapseValue,
                                  rotationValue:
                                      _rainbowRotationController.value,
                                  onPressed: _isLoading ? null : _handleSubmit,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );

  Widget _buildDraftCard(
    BuildContext context,
    List<Account> accounts,
  ) =>
      AnimatedSwitcher(
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
                animation: Listenable.merge([
                  _draftMergeController,
                  _draftCardRevealController,
                  _rainbowRotationController,
                ]),
                builder: (context, child) {
                  final mergeValue = _draftMergeController.value;
                  final revealValue = _draftCardRevealController.value;
                  final intensity = (1 - mergeValue) *
                      Curves.easeOutExpo.transform(revealValue.clamp(0.0, 1.0));
                  final transformed = Opacity(
                    opacity: 1 - mergeValue,
                    child: Transform.translate(
                      offset: Offset(0, -60 * mergeValue),
                      child: Transform.scale(
                        scale: 1 - mergeValue * 0.2,
                        child: child,
                      ),
                    ),
                  );
                  return _RainbowGlowBorder(
                    borderRadius: 24,
                    borderWidth: 1.5 + intensity * 1.5,
                    intensity: intensity,
                    rotation: _rainbowRotationController.value * 2 * math.pi,
                    child: transformed,
                  );
                },
                child: _buildDraftCardContent(context, accounts),
              ),
      );

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
                    draft.category ?? TransactionCategory.otherExpense,
                  ),
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
    return AnimatedBuilder(
      animation: _confirmGlowController,
      builder: (context, child) {
        final glow = Curves.easeOutQuad.transform(
          _confirmGlowController.value.clamp(0.0, 1.0),
        );
        return Transform.scale(
          scale: 1 + glow * 0.08,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: glow > 0
                  ? [
                      BoxShadow(
                        color:
                            context.primaryAction.withOpacity(0.4 * (1 - glow)),
                        blurRadius: 30,
                        spreadRadius: 6,
                      ),
                    ]
                  : const [],
            ),
            child: child,
          ),
        );
      },
      child: ElevatedButton(
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
      ),
    );
  }

  Widget _buildDateChip(BuildContext context) =>
      PopupMenuButton<_DateMenuAction>(
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

  Widget _buildAccountChip(
    BuildContext context,
    List<Account> accounts,
  ) =>
      PopupMenuButton<String?>(
        tooltip: '选择账户',
        onSelected: (value) => _handleAccountSelection(value, accounts),
        itemBuilder: (context) => [
          const PopupMenuItem<String?>(
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
      case _DateMenuAction.yesterday:
        newDate = DateTime.now().subtract(const Duration(days: 1));
      case _DateMenuAction.pick:
        final picked = await showDatePicker(
          context: context,
          initialDate: _draftDate ?? DateTime.now(),
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        newDate = picked;
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

    _confirmGlowController.forward(from: 0);
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
      _rainbowRotationController.stop();
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
    final dayKey = _dayKeyFromDate(group.date);
    final cardKey =
        _dayCardKeys.putIfAbsent(dayKey, () => GlobalObjectKey(dayKey));
    final isHighlighted = _highlightedDayKey == dayKey;

    final Widget card = Container(
      key: cardKey,
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
            final isLast = index == group.transactions.length - 1;
            final row = _buildTransactionRow(
              context,
              transaction,
              transaction.id == _recentTransactionId,
            );
            if (isLast) {
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

    if (!isHighlighted) {
      return card;
    }

    return AnimatedBuilder(
      animation: Listenable.merge([
        _dayCardHighlightController,
        _rainbowRotationController,
      ]),
      builder: (context, child) {
        final intensity = Curves.easeOutExpo.transform(
          _dayCardHighlightController.value.clamp(0.0, 1.0),
        );
        return _RainbowGlowBorder(
          borderRadius: 20,
          borderWidth: 1.2 + intensity * 1.2,
          intensity: intensity,
          rotation: _rainbowRotationController.value * 2 * math.pi,
          child: child!,
        );
      },
      child: card,
    );
  }

  Widget _buildTransactionRow(
    BuildContext context,
    Transaction transaction,
    bool isNewlyInserted,
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

    final row = Row(
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

    if (!isNewlyInserted) {
      return row;
    }

    final entryAnimation = CurvedAnimation(
      parent: _insertionController,
      curve: Curves.easeOutCubic,
    );

    return SizeTransition(
      sizeFactor: entryAnimation,
      axisAlignment: -1,
      child: TweenAnimationBuilder<double>(
        key: ValueKey('txn-${transaction.id}'),
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          final overlayColor = Color.lerp(
            context.primaryAction.withOpacity(0.15),
            Colors.transparent,
            value,
          )!;
          return Container(
            decoration: BoxDecoration(
              color: overlayColor,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: overlayColor == Colors.transparent
                ? EdgeInsets.zero
                : const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Transform.translate(
              offset: Offset(0, (1 - value) * -12),
              child: Opacity(opacity: value, child: child),
            ),
          );
        },
        child: row,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) => Container(
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

  List<_TransactionDayGroup> _groupTransactions(
    List<Transaction> transactions,
  ) {
    final confirmed = transactions
        .where(
          (transaction) => transaction.status == TransactionStatus.confirmed,
        )
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    final grouped = LinkedHashMap<DateTime, List<Transaction>>(
      equals: _isSameDay,
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

  void _scheduleScrollToHighlightedCard() {
    if (_pendingScrollDayKey == null || _isScrollScheduled) {
      return;
    }
    _isScrollScheduled = true;
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _runScrollToHighlighted());
  }

  void _runScrollToHighlighted() {
    final dayKey = _pendingScrollDayKey;
    if (dayKey == null) {
      _isScrollScheduled = false;
      return;
    }
    final key = _dayCardKeys[dayKey];
    final context = key?.currentContext;
    if (context == null) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _runScrollToHighlighted());
      return;
    }
    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeInOutCubic,
      alignment: 0.1,
    ).whenComplete(() {
      _pendingScrollDayKey = null;
      _isScrollScheduled = false;
    });
  }

  String _dayKeyFromDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

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
    _scheduleScrollToHighlightedCard();
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
              controller: _scrollController,
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

class _RainbowSendButton extends StatelessWidget {
  const _RainbowSendButton({
    required this.isLoading,
    required this.collapseProgress,
    required this.rotationValue,
    required this.onPressed,
  });

  final bool isLoading;
  final double collapseProgress;
  final double rotationValue;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final baseIntensity = isLoading ? 0.6 : 0.25;
    final intensity = (baseIntensity + collapseProgress * 0.75).clamp(0.0, 1.0);
    return _RainbowGlowBorder(
      borderRadius: 999,
      borderWidth: 1.2 + collapseProgress * 1.2,
      intensity: intensity,
      rotation: rotationValue * 2 * math.pi,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          backgroundColor: context.primaryAction,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.zero,
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.arrow_upward_rounded),
        ),
      ),
    );
  }
}

class _RainbowGlowBorder extends StatelessWidget {
  const _RainbowGlowBorder({
    required this.child,
    required this.borderRadius,
    required this.borderWidth,
    required this.intensity,
    required this.rotation,
  });

  final Widget child;
  final double borderRadius;
  final double borderWidth;
  final double intensity;
  final double rotation;

  @override
  Widget build(BuildContext context) {
    if (intensity <= 0) {
      return child;
    }
    return CustomPaint(
      foregroundPainter: _RainbowBorderPainter(
        rotation: rotation,
        intensity: intensity,
        borderWidth: borderWidth,
        radius: borderRadius,
      ),
      child: child,
    );
  }
}

class _RainbowBorderPainter extends CustomPainter {
  const _RainbowBorderPainter({
    required this.rotation,
    required this.intensity,
    required this.borderWidth,
    required this.radius,
  });

  final double rotation;
  final double intensity;
  final double borderWidth;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    if (intensity <= 0) {
      return;
    }
    final rect = Offset.zero & size;
    final gradient = SweepGradient(
      startAngle: rotation,
      endAngle: rotation + 2 * math.pi,
      colors: [
        const Color(0xFF2F80ED),
        const Color(0xFF8E2DE2),
        const Color(0xFFF562A7),
        const Color(0xFFFFA751),
        const Color(0xFF2F80ED),
      ].map((color) => color.withOpacity(intensity)).toList(),
    );
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..maskFilter = MaskFilter.blur(BlurStyle.outer, 4 * intensity);
    final rrect = RRect.fromRectAndRadius(
      rect.deflate(borderWidth / 2),
      Radius.circular(radius),
    );
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _RainbowBorderPainter oldDelegate) =>
      rotation != oldDelegate.rotation ||
      intensity != oldDelegate.intensity ||
      borderWidth != oldDelegate.borderWidth ||
      radius != oldDelegate.radius;
}
