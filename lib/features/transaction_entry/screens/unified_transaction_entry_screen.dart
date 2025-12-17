import 'dart:async';
import 'dart:collection';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:your_finance_flutter/core/models/account.dart';
import 'package:your_finance_flutter/core/models/flux_view_state.dart';
import 'package:your_finance_flutter/core/models/insights_drawer_state.dart';
import 'package:your_finance_flutter/core/models/parsed_transaction.dart';
import 'package:your_finance_flutter/core/models/transaction.dart';
import 'package:your_finance_flutter/core/providers/account_provider.dart';
import 'package:your_finance_flutter/core/providers/budget_provider.dart';
import 'package:your_finance_flutter/core/providers/flux_providers.dart';
import 'package:your_finance_flutter/core/providers/stream_insights_flag_provider.dart';
import 'package:your_finance_flutter/core/providers/theme_provider.dart';
import 'package:your_finance_flutter/core/providers/theme_style_provider.dart';
import 'package:your_finance_flutter/core/providers/transaction_provider.dart';
import 'package:your_finance_flutter/core/services/ai/natural_language_transaction_service.dart';
import 'package:your_finance_flutter/core/services/user_income_profile_service.dart';
import 'package:your_finance_flutter/core/theme/app_design_tokens.dart';
import 'package:your_finance_flutter/core/theme/app_theme.dart' hide AppTheme;
import 'package:your_finance_flutter/core/utils/logger.dart';
import 'package:your_finance_flutter/core/utils/performance_monitor.dart';
import 'package:your_finance_flutter/core/widgets/app_primary_button.dart';
import 'package:your_finance_flutter/core/widgets/app_selection_controls.dart';
import 'package:your_finance_flutter/core/widgets/app_shimmer.dart';
import 'package:your_finance_flutter/features/insights/services/stream_insights_analysis_service.dart';

const _timeframeControlKey = Key('unified_timeframe_segmented_control');
const _timelineViewKey = Key('unified_timeline_view');
const _insightsViewKey = Key('unified_insights_view');
const _insightsNavChipKey = Key('unified_insights_nav_chip');
const _inputDockKey = Key('unified_input_dock');
const _timelineGroupListKey = Key('unified_timeline_group_list');
const _draftCardKey = Key('unified_draft_card');
const bool _enableTimelineMorph = false;
const Duration _paneSwitchAnimationBudget = Duration(milliseconds: 420);
const Duration _drawerAnimationBudget = Duration(milliseconds: 520);
const String _paneSwitchOperationName =
    'UnifiedTransactionEntryScreen.pane_switch';
const String _drawerExpandOperationName =
    'UnifiedTransactionEntryScreen.drawer_expand';
const String _drawerCollapseOperationName =
    'UnifiedTransactionEntryScreen.drawer_collapse';

/// 统一记账入口页面
/// AI自动识别收支类型，零认知负担
class UnifiedTransactionEntryScreen extends ConsumerStatefulWidget {
  const UnifiedTransactionEntryScreen({
    super.key,
    this.initialDraft,
  });

  final ParsedTransaction? initialDraft;

  @override
  ConsumerState<UnifiedTransactionEntryScreen> createState() =>
      _UnifiedTransactionEntryScreenState();
}

class _UnifiedTransactionEntryScreenState
    extends ConsumerState<UnifiedTransactionEntryScreen>
    with TickerProviderStateMixin {
  final TextEditingController _inputController = TextEditingController();
  late final Future<NaturalLanguageTransactionService> _nlServiceFuture;

  bool _isLoading = false;
  final int _placeholderIndex = 0;
  ParsedTransaction? _draftTransaction;
  DateTime? _draftDate;
  String? _draftAccountId;
  String? _draftAccountName;
  late final AnimationController _draftMergeController;
  late final AnimationController _inputCollapseController;
  late final AnimationController _rainbowRotationController;
  late final AnimationController _confirmGlowController;
  late final AnimationController _dayCardHighlightController;
  late AnimationController _toastController;
  final ScrollController _scrollController = ScrollController();
  Timer? _insightsAnalysisTimer;
  bool _isConfirmingDraft = false;
  final NumberFormat _currencyFormatter =
      NumberFormat.currency(locale: 'zh_CN', symbol: '¥');
  final Map<String, GlobalKey> _dateKeys = {};
  final Map<String, GlobalKey> _groupCardKeys = {};
  bool _isScrollScheduled = false;
  String? _pendingScrollDayKey;
  String? _highlightedDayKey;
  String? _recentTransactionId;
  int _pendingScrollAttempts = 0;
  int _draftAnimationSeed = 0;
  GlobalKey<SliverAnimatedListState> _listKey =
      GlobalKey<SliverAnimatedListState>();
  List<_TimelineGroup> _currentGroups = [];
  List<_TimelineGroup> _dayGroups = [];
  List<_TimelineGroup> _weekGroups = [];
  List<_TimelineGroup> _monthGroups = [];
  bool _didBootstrapGroups = false;
  bool _isMorphing = false;
  bool _isScrubbing = false;
  String _scrubLabel = '';
  String _lastScrubLabel = '';
  double _scrubPosition = 0.0;
  TransactionProvider? _transactionProvider;
  bool _didRequestThemeStyleInit = false;
  Timer? _toastTimer;
  String _toastMessage = '';
  bool _isToastError = false;
  _MonthBreakdownTab _monthBreakdownTab = _MonthBreakdownTab.expense;
  late final ProviderSubscription<FluxViewState> _viewStateSubscription;
  ProviderSubscription<StreamInsightsFlagProvider>? _flagSubscription;
  ProviderSubscription<InsightsDrawerState>? _drawerSubscription;
  final Map<String, Timer> _operationTimers = <String, Timer>{};

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
    print('[UnifiedTransactionEntryScreen.initState] 🎯 页面初始化开始');

    _nlServiceFuture = NaturalLanguageTransactionService.getInstance();
    final initialDraft = widget.initialDraft;
    if (initialDraft != null) {
      _draftTransaction = initialDraft;
      _draftDate = initialDraft.date ?? DateTime.now();
      _draftAccountId = initialDraft.accountId;
      _draftAccountName = initialDraft.accountName;
    }

    // 记录初始状态
    print(
      '[UnifiedTransactionEntryScreen.initState] 📊 草稿状态: ${_draftTransaction != null ? "有草稿" : "无草稿"}',
    );

    _viewStateSubscription = ref.listenManual<FluxViewState>(
      fluxViewStateProvider,
      (previous, next) {
        if (previous?.timeframe != next.timeframe) {
          _handleTimeframeChanged(previous?.timeframe, next.timeframe);
        }
      },
    );
    _flagSubscription = ref.listenManual<StreamInsightsFlagProvider>(
      streamInsightsFlagStateProvider,
      (previous, next) => _syncFlagState(next.isEnabled),
    );
    _drawerSubscription = ref.listenManual<InsightsDrawerState>(
      insightsDrawerControllerProvider,
      _handleDrawerStateChanged,
    );
    _syncFlagState(ref.read(streamInsightsFlagStateProvider).isEnabled);

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
      duration: const Duration(seconds: 1),
    );
    _confirmGlowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
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
          if (!_isLoading && _draftTransaction == null) {
            _rainbowRotationController.stop();
          }
        }
      });

    _toastController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..addStatusListener((status) {
        if (status == AnimationStatus.dismissed && mounted) {
          setState(() {
            _toastMessage = '';
          });
        }
      });
  }

  List<_TimelineGroup> _groupsByTimeframe(FluxTimeframe timeframe) {
    switch (timeframe) {
      case FluxTimeframe.day:
        return _dayGroups;
      case FluxTimeframe.week:
        return _weekGroups;
      case FluxTimeframe.month:
        return _monthGroups;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = context.read<TransactionProvider>();

    if (_transactionProvider != provider) {
      _transactionProvider?.removeListener(_handleTransactionsUpdated);
      _transactionProvider = provider;
      _transactionProvider?.addListener(_handleTransactionsUpdated);
      _handleTransactionsUpdated();
    }
    if (!_didRequestThemeStyleInit) {
      _didRequestThemeStyleInit = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<ThemeStyleProvider>().initialize();
        }
      });
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    _draftMergeController.dispose();
    _inputCollapseController.dispose();
    _rainbowRotationController.dispose();
    _confirmGlowController.dispose();
    _dayCardHighlightController.dispose();
    _toastController.dispose();
    _toastTimer?.cancel();
    _scrollController.dispose();
    _transactionProvider?.removeListener(_handleTransactionsUpdated);
    _viewStateSubscription.close();
    _flagSubscription?.close();
    _drawerSubscription?.close();
    _insightsAnalysisTimer?.cancel();
    _cancelOperationTimers();
    super.dispose();
  }

  void _syncFlagState(bool isEnabled) {
    ref.read(fluxViewStateProvider.notifier).syncFlag(isEnabled: isEnabled);
    if (!isEnabled) {
      ref
          .read(insightsDrawerControllerProvider.notifier)
          .collapseNow(reason: 'flag_disabled');
    }
  }

  Future<void> _handleSubmit() async {
    final input = _inputController.text.trim();
    if (input.isEmpty) return;

    setState(() {
      _isLoading = true;
    });
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
        _showToast('解析失败: $e', isError: true);
      }
    }
  }

  void _applyDraftResult(TransactionParseResult result) {
    final parsed = result.parsed;
    if (!parsed.isValid) {
      final guidance = _guidanceFromNextStuff(
        parsed,
        '请输入更完整的描述，例如 “星巴克 35”',
      );
      _showToast(guidance, isError: true);
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
      _draftAnimationSeed++;
    });
    HapticFeedback.mediumImpact();
    _inputCollapseController.reverse();
    if (!_rainbowRotationController.isAnimating) {
      _rainbowRotationController.repeat();
    }
    _inputController.clear();
    FocusScope.of(context).unfocus();
  }

  void _handleTransactionsUpdated() {
    if (!mounted) return;

    final transactions = _transactionProvider?.transactions ?? [];

    if (transactions.isEmpty) {
      setState(() {
        _didBootstrapGroups = true;
        _currentGroups = [];
      });
      return;
    }

    final newDayGroups = _groupTransactionsByDay(transactions);
    final newWeekGroups = _groupTransactionsByWeek(transactions);
    final newMonthGroups = _groupTransactionsByMonth(transactions);

    final dayChanged = !_groupListsEqual(_dayGroups, newDayGroups);
    final weekChanged = !_groupListsEqual(_weekGroups, newWeekGroups);
    final monthChanged = !_groupListsEqual(_monthGroups, newMonthGroups);

    if (!dayChanged && !weekChanged && !monthChanged && _didBootstrapGroups) {
      return;
    }
    setState(() {
      _dayGroups = newDayGroups;
      _weekGroups = newWeekGroups;
      _monthGroups = newMonthGroups;
      if (!_isMorphing) {
        final currentTimeframe = ref.read(fluxViewStateProvider).timeframe;
        final target = _groupsByTimeframe(currentTimeframe);
        _currentGroups = List<_TimelineGroup>.from(target);
        _listKey = GlobalKey<SliverAnimatedListState>();
        _groupCardKeys.clear();
        _dateKeys.clear();
      }
      _didBootstrapGroups = true;
    });
  }

  void _handleTimeframeChanged(
    FluxTimeframe? previous,
    FluxTimeframe current,
  ) {
    if (!_didBootstrapGroups) {
      return;
    }
    final targetGroups = _groupsByTimeframe(current);
    if (_currentGroups.isEmpty || previous == null) {
      setState(() {
        _currentGroups = List<_TimelineGroup>.from(targetGroups);
        _listKey = GlobalKey<SliverAnimatedListState>();
        _isMorphing = false;
      });
      return;
    }
    if (targetGroups.isEmpty) {
      setState(() {
        _currentGroups.clear();
        _listKey = GlobalKey<SliverAnimatedListState>();
        _isMorphing = false;
      });
      return;
    }
    if (!_enableTimelineMorph) {
      setState(() {
        _currentGroups = List<_TimelineGroup>.from(targetGroups);
        _listKey = GlobalKey<SliverAnimatedListState>();
        _isMorphing = false;
      });
      return;
    }
    if (_isMorphing) return;
    setState(() {
      _isMorphing = true;
    });
    _performMorphTransition(targetGroups);
  }

  void _handleDrawerStateChanged(
    InsightsDrawerState? previous,
    InsightsDrawerState next,
  ) {
    final wasExpanded = previous?.isExpanded ?? false;
    final isExpanded = next.isExpanded;
    if (wasExpanded == isExpanded) {
      return;
    }
    final operationName =
        isExpanded ? _drawerExpandOperationName : _drawerCollapseOperationName;
    _scheduleOperationMeasurement(operationName, _drawerAnimationBudget);
  }

  void _scheduleOperationMeasurement(
    String operationName,
    Duration animationBudget,
  ) {
    _operationTimers.remove(operationName)?.cancel();
    PerformanceMonitor.endOperation(operationName);
    PerformanceMonitor.startOperation(operationName);
    _operationTimers[operationName] = Timer(animationBudget, () {
      PerformanceMonitor.endOperation(operationName);
      _operationTimers.remove(operationName);
    });
  }

  void _cancelOperationTimers() {
    for (final timer in _operationTimers.values) {
      timer.cancel();
    }
    _operationTimers.clear();
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

        if (ref.read(streamInsightsFlagStateProvider).isEnabled) {
          _triggerInsightsAnalysis(transaction);
        }

        // 清空输入
        _inputController.clear();
      } catch (e) {
        if (mounted) {
          _showToast('保存失败: $e', isError: true);
        }
      }
    } else {
      final guidance = _guidanceFromNextStuff(
        parsed,
        '解析结果无效，无法保存',
      );
      if (mounted) {
        _showToast(guidance, isError: true);
      }
    }
  }

  void _triggerInsightsAnalysis(Transaction transaction) {
    _insightsAnalysisTimer?.cancel();
    _insightsAnalysisTimer = Timer(const Duration(milliseconds: 350), () {
      unawaited(_runInsightsAnalysis(transaction));
    });
  }

  Future<void> _runInsightsAnalysis(Transaction transaction) async {
    final flagProvider = ref.read(streamInsightsFlagStateProvider);
    final flagEnabled = flagProvider.isEnabled;
    if (!flagEnabled) {
      return;
    }

    try {
      final service = await StreamInsightsAnalysisService.getInstance();
      final viewState = ref.read(fluxViewStateProvider);
      final summary = await service.requestAnalysis(
        transactionIds: <String>[transaction.id],
        timeframe: viewState.timeframe,
        pane: viewState.pane,
        flagEnabled: flagEnabled,
      );

      if (!mounted) {
        return;
      }

      final drawerController =
          ref.read(insightsDrawerControllerProvider.notifier);
      final deferDuration = _drawerDeferDuration();
      drawerController.handleAnalysisSummary(
        summaryText: summary.topRecommendation.isNotEmpty
            ? summary.topRecommendation
            : _buildDrawerSummary(transaction),
        improvementDelta:
            summary.improvementsFound <= 0 ? 1 : summary.improvementsFound,
        collapseAfter: const Duration(seconds: 6),
        deferExpansionBy: deferDuration == Duration.zero ? null : deferDuration,
      );

      PerformanceMonitor.logAnalysisSummaryTelemetry(
        summary: summary,
        pane: viewState.pane,
        timeframe: viewState.timeframe,
        flagEnabled: flagEnabled,
      );
    } catch (error) {
      Logger.warning(
        'StreamInsightsAnalysis',
        '分析请求失败：$error',
      );
    }
  }

  Duration _drawerDeferDuration() {
    if (_rainbowRotationController.isAnimating) {
      return const Duration(milliseconds: 900);
    }
    if (_inputCollapseController.isAnimating ||
        _inputCollapseController.value > 0) {
      return const Duration(milliseconds: 600);
    }
    return Duration.zero;
  }

  String _buildDrawerSummary(Transaction transaction) {
    final description = transaction.description.trim();
    final amount = transaction.amount;
    final buffer = StringBuffer('分析完成');
    if (description.isNotEmpty) {
      buffer.write('：$description');
    }
    buffer.write(' · ${_currencyFormatter.format(amount)}');
    buffer.write('，查看洞察获取建议');
    return buffer.toString();
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
          final contentOpacity = (1 - collapseValue * 1.2).clamp(0.0, 1.0);
          final bottomPadding = MediaQuery.of(context).padding.bottom + 12;
          final sendButtonSize = lerpDouble(44, 52, collapseValue)!;
          final ignoreTextInput = collapseValue > 0.85 || _isLoading;
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final textColor = context.fluxPrimaryText;
          final textFieldStyle = context.textTheme.bodyMedium?.copyWith(
                fontSize: 16,
                color: textColor,
                height: 1.3,
              ) ??
              TextStyle(
                fontSize: 16,
                color: textColor,
                height: 1.3,
              );
          final hintColor =
              context.fluxSecondaryText.withValues(alpha: isDark ? 0.75 : 0.6);
          final inputFillColor = AppDesignTokens.inputFill(context);

          return Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: IgnorePointer(
              ignoring: ignoreTextInput,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: contentOpacity,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        context.fluxPageBackground.withValues(alpha: 0),
                        context.fluxPageBackground.withValues(alpha: 0.9),
                      ],
                      stops: const [0.0, 0.3],
                    ),
                  ),
                  padding: EdgeInsets.fromLTRB(16, 10, 16, bottomPadding),
                  child: Container(
                    key: _inputDockKey,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: context.fluxSurface,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _inputController,
                            enabled: !_isLoading,
                            onSubmitted: (_) => _handleSubmit(),
                            textAlignVertical: TextAlignVertical.center,
                            style: textFieldStyle,
                            cursorColor: context.fluxPrimaryAction,
                            decoration: InputDecoration(
                              hintText: _placeholders[_placeholderIndex],
                              hintStyle: textFieldStyle.copyWith(
                                color: hintColor,
                              ),
                              filled: true,
                              fillColor: inputFillColor,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const Gap(8),
                        SizedBox(
                          width: sendButtonSize,
                          height: sendButtonSize,
                          child: _RainbowSendButton(
                            key: const ValueKey('rainbow-send-button'),
                            isLoading: _isLoading,
                            collapseProgress: collapseValue,
                            rotationValue: _rainbowRotationController.value,
                            onPressed: _isLoading ? null : _handleSubmit,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );

  Widget _buildToastOverlay(BuildContext context) => AnimatedBuilder(
        animation: _toastController,
        builder: (context, child) {
          final progress = _toastController.value;
          if ((_toastMessage.isEmpty && progress == 0.0) ||
              (progress == 0.0 && !_toastController.isAnimating)) {
            return const SizedBox.shrink();
          }
          final opacity = Curves.easeOutCubic.transform(progress);
          if (opacity <= 0) {
            return const SizedBox.shrink();
          }
          final slide = Curves.easeOutBack.transform(progress);
          final viewInsets = MediaQuery.of(context).padding;
          final bottomPadding =
              kBottomNavigationBarHeight + viewInsets.bottom + 100;

          return Positioned(
            left: 0,
            right: 0,
            bottom: bottomPadding,
            child: IgnorePointer(
              child: Opacity(
                opacity: opacity,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - slide)),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C1C1E).withValues(alpha: 0.96),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isToastError
                                ? Icons.error_rounded
                                : Icons.check_circle_rounded,
                            color: _isToastError
                                ? const Color(0xFFFF453A)
                                : const Color(0xFF32D74B),
                            size: 18,
                          ),
                          const Gap(10),
                          Flexible(
                            child: Text(
                              _toastMessage,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.none,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
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
        duration: const Duration(milliseconds: 280),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: _draftTransaction == null
            ? const SizedBox.shrink()
            : _buildLiquidDraftCard(context, accounts),
      );

  Widget _buildLiquidDraftCard(
    BuildContext context,
    List<Account> accounts,
  ) {
    final haloWrappedCard = AnimatedBuilder(
      animation: Listenable.merge([
        _rainbowRotationController,
        _inputCollapseController,
      ]),
      builder: (context, child) {
        final haloIntensity = (!_isLoading && _draftTransaction != null)
            ? Curves.easeOutExpo.transform(
                (1 - _inputCollapseController.value).clamp(0.0, 1.0),
              )
            : 0.0;
        if (haloIntensity <= 0) {
          return child!;
        }
        return _RainbowGlowBorder(
          borderRadius: 24,
          borderWidth: haloIntensity,
          intensity: haloIntensity,
          rotation: _rainbowRotationController.value * 2 * math.pi,
          child: child!,
        );
      },
      child: _buildDraftCardContent(context, accounts),
    );

    final draftCard = AnimatedBuilder(
      animation: _draftMergeController,
      builder: (context, child) {
        final mergeValue = _draftMergeController.value.clamp(0.0, 1.0);
        final opacity = (1 - mergeValue).clamp(0.0, 1.0);
        final lift = -60 * mergeValue;
        final scale = 1 - mergeValue * 0.12;
        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(0, lift),
            child: Transform.scale(
              scale: scale,
              alignment: Alignment.bottomRight,
              child: child,
            ),
          ),
        );
      },
      child: haloWrappedCard,
    );

    return draftCard
        .animate(
          key: ValueKey('draft-card-$_draftAnimationSeed'),
        )
        .scaleXY(
          begin: 0.2,
          end: 1,
          duration: 800.ms,
          curve: Curves.elasticOut,
          alignment: Alignment.bottomRight,
        )
        .moveY(
          begin: 50,
          end: 0,
          duration: 520.ms,
          curve: Curves.easeOutQuart,
        )
        .fadeIn(duration: 240.ms)
        .shimmer(
          duration: 1.seconds,
          color: Colors.white.withValues(alpha: 0.5),
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
        ? context.fluxNegativeAmount
        : isIncome
            ? context.fluxPositiveAmount
            : context.fluxPrimaryText;
    final title = draft.category?.displayName ?? draft.description ?? '未分类';
    var subtitle = draft.notes ?? '';
    if (subtitle.isEmpty) {
      if (draft.description != null && draft.description != title) {
        subtitle = draft.description!;
      } else {
        subtitle = 'AI帮你整理的草稿';
      }
    }

    return Container(
      key: _draftCardKey,
      decoration: BoxDecoration(
        color: context.fluxSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: context.fluxPrimaryAction.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: context.fluxPrimaryAction.withValues(alpha: 0.15),
            blurRadius: 40,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TweenAnimationBuilder<double>(
                  key: ValueKey('draft-amount-$_draftAnimationSeed'),
                  tween: Tween<double>(begin: 0, end: amount.abs()),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutExpo,
                  builder: (context, value, child) => Text(
                    '$sign${_currencyFormatter.format(value)}',
                    style: GoogleFonts.ibmPlexMono(
                      textStyle: context.textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: amountColor,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ),
              ),
              _buildCancelButton(context),
              const Gap(12),
              _buildConfirmButton(context),
            ],
          ),
          const Gap(16),
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: context.fluxPageBackground,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  _categoryIcon(
                    draft.category ?? TransactionCategory.otherExpense,
                  ),
                  color: context.fluxPrimaryText,
                ),
              ),
              const Gap(12),
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
                    const Gap(4),
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
          const Gap(16),
          Row(
            children: [
              _buildDateChip(context),
              const Gap(8),
              _buildAccountChip(context, accounts),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCancelButton(BuildContext context) {
    final isDisabled = _isConfirmingDraft;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isDisabled ? 0.0 : 1.0,
      child: IgnorePointer(
        ignoring: isDisabled,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: context.fluxSurface,
            shape: BoxShape.circle,
            border: Border.all(
              color: context.fluxSecondaryText.withValues(alpha: 0.2),
            ),
          ),
          child: IconButton(
            tooltip: '取消',
            splashRadius: 24,
            onPressed: _handleCancelDraft,
            icon: Icon(
              PhosphorIcons.x(),
              size: 20,
              color: context.fluxSecondaryText,
            ),
          ),
        ),
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
                        color: context.fluxPrimaryAction
                            .withValues(alpha: 0.4 * (1 - glow)),
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
          backgroundColor: context.fluxPrimaryAction,
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
          color: AppDesignTokens.inputFill(context),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: context.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: context.fluxPrimaryText,
              ) ??
              TextStyle(
                fontWeight: FontWeight.w600,
                color: context.fluxPrimaryText,
              ),
        ),
      );

  String get _dateChipLabel {
    final date = _draftDate ?? DateTime.now();
    final today = DateTime.now();
    if (_isSameDay(date, today)) {
      return '🕒 今天';
    }
    if (_isSameDay(date, today.subtract(const Duration(days: 1)))) {
      return '🕒 昨天';
    }
    return '🕒 ${DateFormat('M月d日').format(date)}';
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

  void _handleCancelDraft() {
    setState(() {
      _draftTransaction = null;
      _isConfirmingDraft = false;
    });
    _draftMergeController.reset();
    if (!_isLoading) {
      _rainbowRotationController.stop();
    }
    _inputCollapseController.reverse();
  }

  Future<void> _confirmDraftTransaction() async {
    final draft = _draftTransaction;
    if (draft == null || _isConfirmingDraft) return;
    if (!draft.isValid) {
      final guidance = _guidanceFromNextStuff(
        draft,
        '请完善金额和描述后再确认',
      );
      _showToast(guidance, isError: true);
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
    List<_TimelineGroup> groups,
    bool isLoading,
  ) {
    if (isLoading && !_didBootstrapGroups) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
          child: Column(
            children: List.generate(
              3,
              (index) => Padding(
                padding: EdgeInsets.only(bottom: index == 2 ? 0 : 16),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: context.fluxSurface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppShimmer.text(width: 120, height: 18),
                      const Gap(16),
                      ...List.generate(
                        3,
                        (rowIndex) => Padding(
                          padding: EdgeInsets.only(
                            bottom: rowIndex == 2 ? 0 : 16,
                          ),
                          child: Row(
                            children: [
                              AppShimmer.circle(size: 42),
                              const Gap(12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AppShimmer.text(
                                      height: 14,
                                    ),
                                    const Gap(8),
                                    AppShimmer.text(
                                      width: 120,
                                      height: 12,
                                    ),
                                  ],
                                ),
                              ),
                              const Gap(12),
                              AppShimmer.text(
                                width: 60,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (groups.isEmpty) {
      return SliverToBoxAdapter(child: _buildEmptyState(context));
    }

    return KeyedSubtree(
      key: _timelineGroupListKey,
      child: SliverAnimatedList(
        key: _listKey,
        initialItemCount: groups.length,
        itemBuilder: (context, index, animation) {
          final group = groups[index];
          final card = _buildGroupCard(context, group);

          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutBack,
              ),
              child: card,
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimelineView(
    BuildContext context,
    EdgeInsets viewInsets,
    double scrollBottomPadding,
    bool isLoading,
    List<_TimelineGroup> groupedTransactions, {
    double headerOffset = 60,
  }) =>
      KeyedSubtree(
        key: _timelineViewKey,
        child: CustomScrollView(
          key: const PageStorageKey<String>('unified_timeline_scroll'),
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                16,
                viewInsets.top + headerOffset,
                16,
                scrollBottomPadding,
              ),
              sliver: _buildTimelineSliver(
                context,
                groupedTransactions,
                isLoading,
              ),
            ),
          ],
        ),
      );

  Widget _buildInsightsView(
    BuildContext context,
    EdgeInsets viewInsets,
    double scrollBottomPadding,
  ) =>
      KeyedSubtree(
        key: _insightsViewKey,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            viewInsets.top + 60,
            16,
            scrollBottomPadding,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: context.fluxSurface,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color:
                    context.fluxPrimaryAction.withAlpha((255 * 0.12).round()),
              ),
              boxShadow: [
                AppDesignTokens.primaryShadow(context),
              ],
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: context.fluxPrimaryAction
                            .withAlpha((255 * 0.1).round()),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        PhosphorIcons.sparkle(),
                        size: 28,
                        color: context.fluxPrimaryAction,
                      ),
                    ),
                    const Gap(16),
                    Text(
                      'Flux Insights',
                      style: context.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.fluxPrimaryText,
                      ),
                    ),
                    const Gap(8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'AI 分析将在这里展示你的消费与收入洞察。T014 将接入抽屉交互与实时摘要。',
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.fluxSecondaryText,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const Gap(16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: context.fluxPrimaryAction
                            .withAlpha((255 * 0.08).round()),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '敬请期待 👀',
                        style: context.textTheme.labelLarge?.copyWith(
                          color: context.fluxPrimaryAction,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

  Widget _buildHeader(
    BuildContext context,
    EdgeInsets viewInsets,
    FluxViewState viewState,
  ) =>
      Positioned(
        top: viewInsets.top + 12,
        left: 16,
        right: 16,
        child: Row(
          children: [
            Expanded(
              child: _buildTimeframeControl(context, viewState.timeframe),
            ),
            const SizedBox(width: 12),
            _buildInsightsNavChip(context, viewState),
          ],
        ),
      );

  Widget _buildInsightsDrawerOverlay(
    BuildContext context,
    EdgeInsets viewInsets,
  ) {
    final flagEnabled = ref.watch(streamInsightsFlagStateProvider).isEnabled;
    if (!flagEnabled) {
      return const SizedBox.shrink();
    }
    final drawerState = ref.watch(insightsDrawerControllerProvider);
    if (!drawerState.isVisible) {
      return const SizedBox.shrink();
    }
    final controller = ref.read(insightsDrawerControllerProvider.notifier);
    return Positioned(
      left: 16,
      right: 16,
      top: viewInsets.top + 72,
      child: _InsightsDrawer(
        state: drawerState,
        onExpand: () => controller.setExpanded(true),
        onMinimize: () => controller.setExpanded(false),
        onClose: () => controller.collapseNow(reason: 'manual_close'),
      ),
    );
  }

  Widget _buildTimeframeControl(
    BuildContext context,
    FluxTimeframe timeframe,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.white.withValues(alpha: 0.5);

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          key: _timeframeControlKey,
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderColor),
            boxShadow: [
              AppDesignTokens.primaryShadow(context),
            ],
          ),
          child: AppSegmentedControl<FluxTimeframe>(
            groupValue: timeframe,
            onValueChanged: (value) {
              if (value == null) return;
              _setTimeframe(value);
            },
            children: const {
              FluxTimeframe.day: Text('Day'),
              FluxTimeframe.week: Text('Week'),
              FluxTimeframe.month: Text('Month'),
            },
          ),
        ),
      ),
    );
  }

  Widget _buildInsightsNavChip(
    BuildContext context,
    FluxViewState viewState,
  ) {
    final isActive = viewState.isShowingInsights;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : Colors.black.withValues(alpha: 0.05);
    final label = isActive ? 'Timeline' : 'Insights';
    final icon = isActive ? PhosphorIcons.arrowLeft() : PhosphorIcons.sparkle();

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: _insightsNavChipKey,
          onTap: () =>
              _setPane(isActive ? FluxPane.timeline : FluxPane.insights),
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: borderColor),
              boxShadow: [
                AppDesignTokens.primaryShadow(context),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: isActive
                      ? context.fluxPrimaryAction
                      : context.fluxSecondaryText,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: context.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ) ??
                      TextStyle(
                        fontWeight: FontWeight.w600,
                        color: context.fluxPrimaryText,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThemeSettingsButton(
    BuildContext context,
    EdgeInsets viewInsets,
    ThemeMode currentMode,
    ThemeStyleProvider themeStyleProvider,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final capsuleColor = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : context.fluxSurface.withValues(alpha: 0.65);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.2)
        : context.fluxSecondaryText.withValues(alpha: 0.25);
    final shadowColor = isDark
        ? Colors.black.withValues(alpha: 0.45)
        : Colors.black.withValues(alpha: 0.05);
    final iconColor = isDark ? Colors.white : context.fluxPrimaryAction;

    return Positioned(
      top: viewInsets.top + 12,
      right: 16,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: capsuleColor,
              shape: BoxShape.circle,
              border: Border.all(color: borderColor),
              boxShadow: [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              iconSize: 20,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: PhosphorIcon(
                _themeModeIcon(currentMode),
                color: iconColor,
              ),
              tooltip:
                  '主题：${themeStyleProvider.getThemeDisplayName(themeStyleProvider.currentTheme)} · 金额：${themeStyleProvider.getMoneyThemeDisplayName(themeStyleProvider.currentMoneyTheme)} · ${_themeModeTitle(currentMode)}',
              onPressed: () =>
                  _showThemeSettingsSheet(context, themeStyleProvider),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showThemeSettingsSheet(
    BuildContext context,
    ThemeStyleProvider themeStyleProvider,
  ) async {
    final themeProvider = context.read<ThemeProvider>();

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            decoration: BoxDecoration(
              color: context.fluxSurface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 30,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: Row(
                        children: [
                          Text(
                            '主题设置',
                            style: context.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            width: 36,
                            height: 4,
                            decoration: BoxDecoration(
                              color: context.fluxSecondaryText
                                  .withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '金额主题',
                          style: context.textTheme.labelMedium?.copyWith(
                            color: context.fluxSecondaryText
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    ),
                    ...MoneyTheme.values.map((moneyTheme) {
                      final isSelected =
                          themeStyleProvider.currentMoneyTheme == moneyTheme;
                      return ListTile(
                        leading: Icon(
                          PhosphorIcons.wallet(),
                          color: isSelected
                              ? context.fluxPrimaryAction
                              : context.fluxSecondaryText,
                        ),
                        title: Text(
                          themeStyleProvider
                              .getMoneyThemeDisplayName(moneyTheme),
                          style: context.textTheme.titleSmall?.copyWith(
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          _moneyThemeDescription(moneyTheme),
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.fluxSecondaryText
                                .withValues(alpha: 0.6),
                          ),
                        ),
                        trailing: isSelected
                            ? PhosphorIcon(
                                PhosphorIcons.checkCircle(),
                                color: context.fluxPrimaryAction,
                              )
                            : null,
                        onTap: () {
                          themeStyleProvider.setMoneyTheme(moneyTheme);
                          Navigator.of(sheetContext).pop();
                        },
                      );
                    }),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '显示模式',
                          style: context.textTheme.labelMedium?.copyWith(
                            color: context.fluxSecondaryText
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    ),
                    ...ThemeMode.values.map((mode) {
                      final isSelected = themeProvider.themeMode == mode;
                      return ListTile(
                        leading: PhosphorIcon(
                          _themeModeIcon(mode),
                          color: isSelected
                              ? context.fluxPrimaryAction
                              : context.fluxSecondaryText,
                        ),
                        title: Text(
                          _themeModeTitle(mode),
                          style: context.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          _themeModeDescription(mode),
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.fluxSecondaryText
                                .withValues(alpha: 0.6),
                          ),
                        ),
                        trailing: isSelected
                            ? PhosphorIcon(
                                PhosphorIcons.checkCircle(),
                                color: context.fluxPrimaryAction,
                              )
                            : null,
                        onTap: () {
                          themeProvider.setThemeMode(mode);
                          Navigator.of(sheetContext).pop();
                        },
                      );
                    }),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScrubber(List<_TimelineGroup> groups) {
    if (groups.isEmpty) {
      return const SizedBox.shrink();
    }
    final mediaQuery = MediaQuery.of(context);
    final topSafe = mediaQuery.padding.top + 12;
    final bottomSafe =
        kBottomNavigationBarHeight + mediaQuery.padding.bottom + 160;
    final availableHeight = (mediaQuery.size.height - topSafe - bottomSafe)
        .clamp(1.0, mediaQuery.size.height);
    final bubbleTop = (topSafe + availableHeight * _scrubPosition)
        .clamp(topSafe, mediaQuery.size.height - bottomSafe);

    return Positioned.fill(
      child: Stack(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onVerticalDragStart: (details) {
                setState(() {
                  _isScrubbing = true;
                });
                _handleScrubberDrag(details.globalPosition.dy, groups);
              },
              onVerticalDragUpdate: (details) =>
                  _handleScrubberDrag(details.globalPosition.dy, groups),
              onVerticalDragEnd: _endScrubbing,
              onVerticalDragCancel: _endScrubbing,
              child: Container(
                width: 44,
                margin: EdgeInsets.only(
                  top: topSafe,
                  bottom: bottomSafe,
                  right: 4,
                ),
                alignment: Alignment.centerRight,
                child: Container(
                  width: 6,
                  decoration: BoxDecoration(
                    color: _isScrubbing
                        ? Colors.black.withValues(alpha: 0.18)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
          ),
          if (_isScrubbing && _scrubLabel.isNotEmpty)
            Positioned(
              top: bubbleTop - 24,
              right: 56,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 120),
                opacity: _isScrubbing ? 1 : 0,
                child: _ScrubBubble(label: _scrubLabel),
              ),
            ),
        ],
      ),
    );
  }

  void _handleScrubberDrag(double globalDy, List<_TimelineGroup> groups) {
    if (groups.isEmpty || !_scrollController.hasClients) {
      return;
    }
    final mediaQuery = MediaQuery.of(context);
    final topSafe = mediaQuery.padding.top + 12;
    final bottomSafe =
        kBottomNavigationBarHeight + mediaQuery.padding.bottom + 160;
    final availableHeight = (mediaQuery.size.height - topSafe - bottomSafe)
        .clamp(1.0, mediaQuery.size.height);
    final clampedDy = (globalDy - topSafe).clamp(0.0, availableHeight);
    final relative = (clampedDy / availableHeight).clamp(0.0, 1.0);
    final position = _scrollController.position;
    final targetOffset = position.maxScrollExtent * relative;
    position.jumpTo(targetOffset);
    final index =
        (relative * (groups.length - 1)).round().clamp(0, groups.length - 1);
    final group = groups[index];
    final label = switch (group.timeframe) {
      FluxTimeframe.day => _formatDayLabel(group.startDate),
      FluxTimeframe.week => _formatWeekRange(group.startDate, group.endDate),
      FluxTimeframe.month => _formatMonthLabel(group.startDate),
    };
    if (_lastScrubLabel != label) {
      HapticFeedback.selectionClick();
      _lastScrubLabel = label;
    }
    setState(() {
      _scrubLabel = label;
      _scrubPosition = relative;
    });
  }

  void _endScrubbing([_]) {
    if (!_isScrubbing) return;
    setState(() {
      _isScrubbing = false;
      _scrubLabel = '';
      _lastScrubLabel = '';
    });
  }

  Widget _buildGroupCard(BuildContext context, _TimelineGroup group) {
    final groupKey = group.uniqueKey;
    final cardKey = _groupCardKeys.putIfAbsent(
      groupKey,
      () => GlobalObjectKey(groupKey),
    );
    for (final date in group.representedDates) {
      _dateKeys[_dayKeyFromDate(date)] = cardKey;
    }

    final isHighlighted = _highlightedDayKey != null &&
        group.representedDates
            .any((date) => _dayKeyFromDate(date) == _highlightedDayKey);

    final card = switch (group.timeframe) {
      FluxTimeframe.day => _buildDayCard(
          context,
          group as _TransactionDayGroup,
          cardKey,
          _formatDayLabel(group.startDate),
        ),
      FluxTimeframe.week => _buildWeekTrendCard(
          context,
          group as _TransactionWeekGroup,
          cardKey,
        ),
      FluxTimeframe.month => _buildMonthSummaryCard(
          context,
          group as _TransactionMonthGroup,
          cardKey,
          _formatMonthLabel(group.startDate),
        ),
    };

    if (!isHighlighted || group.timeframe != FluxTimeframe.day) {
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
          borderWidth: intensity,
          intensity: intensity,
          rotation: _rainbowRotationController.value * 2 * math.pi,
          child: child!,
        );
      },
      child: card,
    );
  }

  Widget _buildDayCard(
    BuildContext context,
    _TransactionDayGroup group,
    Key cardKey,
    String headerLabel,
  ) {
    double totalIncome = 0;
    double totalExpense = 0;
    for (final transaction in group.transactions) {
      final amount = transaction.amount.abs();
      if (_isIncome(transaction)) {
        totalIncome += amount;
      } else if (_isExpense(transaction)) {
        totalExpense += amount;
      }
    }
    final netCashflow = totalIncome - totalExpense;
    final totalFlow = totalIncome + totalExpense;
    final incomeRatio = totalFlow == 0 ? 0.5 : totalIncome / totalFlow;

    return AnimatedSize(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOutCubic,
      child: Container(
        key: cardKey,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: context.fluxSurface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 30,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      headerLabel,
                      style: context.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: context.fluxSecondaryText,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      '${group.transactions.length} 笔记录',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.fluxSecondaryText.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '净现金流',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.fluxSecondaryText.withValues(alpha: 0.6),
                      ),
                    ),
                    const Gap(4),
                    Text(
                      _formatSignedAmount(netCashflow),
                      style: context.textTheme.titleMedium?.copyWith(
                        color: netCashflow >= 0
                            ? context.fluxPositiveAmount
                            : context.fluxNegativeAmount,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Gap(16),
            Row(
              children: [
                _buildSummaryPill(
                  context,
                  label: '收入',
                  amount: totalIncome,
                  color: context.fluxPositiveAmount,
                ),
                const Gap(12),
                _buildSummaryPill(
                  context,
                  label: '支出',
                  amount: totalExpense,
                  color: context.fluxNegativeAmount,
                ),
              ],
            ),
            const Gap(12),
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                return Stack(
                  children: [
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: context.fluxSurface.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 350),
                      height: 8,
                      width: width * incomeRatio,
                      decoration: BoxDecoration(
                        color:
                            context.fluxPositiveAmount.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ],
                );
              },
            ),
            const Gap(20),
            ...List.generate(group.transactions.length, (index) {
              final transaction = group.transactions[index];
              final isLast = index == group.transactions.length - 1;
              return Column(
                children: [
                  _buildTransactionRow(
                    context,
                    transaction,
                    transaction.id == _recentTransactionId,
                  ),
                  if (!isLast) const Gap(8),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekTrendCard(
    BuildContext context,
    _TransactionWeekGroup group,
    Key cardKey,
  ) {
    final headerLabel = _formatWeekRange(group.startDate, group.endDate);
    final trendPoints = _computeWeekTrendPoints(group);
    final maxAmount = trendPoints
        .map((point) => math.max(point.income, point.expense))
        .fold<double>(0, math.max);
    final netCashflow = trendPoints.fold<double>(
      0,
      (previousValue, point) => previousValue + point.income - point.expense,
    );
    const maxSectionHeight = 56.0;
    final labelHeight = (context.textTheme.bodySmall?.fontSize ?? 14) + 12;
    final chartHeight = (maxSectionHeight * 2) + 32 + labelHeight;
    final netColor = netCashflow >= 0
        ? context.fluxPositiveAmount
        : context.fluxNegativeAmount;

    return AnimatedSize(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOutCubic,
      child: Container(
        key: cardKey,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: context.fluxSurface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 30,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      headerLabel,
                      style: context.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: context.fluxSecondaryText,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      '7天收入 / 支出趋势',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.fluxSecondaryText.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '净现金流',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.fluxSecondaryText.withValues(alpha: 0.6),
                      ),
                    ),
                    const Gap(4),
                    Text(
                      _formatSignedAmount(netCashflow),
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: netColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Gap(20),
            SizedBox(
              height: chartHeight,
              child: Row(
                children: [
                  for (final point in trendPoints) ...[
                    Expanded(
                      child: Column(
                        children: [
                          SizedBox(
                            height: maxSectionHeight,
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: _buildTrendBarSegment(
                                context,
                                height: maxAmount == 0
                                    ? 0
                                    : maxSectionHeight *
                                        (point.income / maxAmount),
                                color: context.fluxPositiveAmount,
                              ),
                            ),
                          ),
                          Container(
                            height: 2,
                            width: 16,
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            decoration: BoxDecoration(
                              color: context.fluxSecondaryText
                                  .withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          SizedBox(
                            height: maxSectionHeight,
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: _buildTrendBarSegment(
                                context,
                                height: maxAmount == 0
                                    ? 0
                                    : maxSectionHeight *
                                        (point.expense / maxAmount),
                                color: context.fluxNegativeAmount,
                              ),
                            ),
                          ),
                          const Gap(8),
                          Text(
                            point.shortLabel,
                            style: context.textTheme.bodySmall?.copyWith(
                              fontWeight: point.isToday
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: point.isToday
                                  ? context.fluxPrimaryAction
                                  : context.fluxSecondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (point != trendPoints.last) const Gap(4),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_DailyTrendPoint> _computeWeekTrendPoints(
    _TransactionWeekGroup group,
  ) {
    final points = <_DailyTrendPoint>[];
    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);
    for (var date = group.startDate;
        !date.isAfter(group.endDate);
        date = date.add(const Duration(days: 1))) {
      double income = 0;
      double expense = 0;
      for (final transaction in group.transactions) {
        if (_isSameDay(transaction.date, date)) {
          final amount = transaction.amount.abs();
          if (_isIncome(transaction)) {
            income += amount;
          } else if (_isExpense(transaction)) {
            expense += amount;
          }
        }
      }
      points.add(
        _DailyTrendPoint(
          date: date,
          income: income,
          expense: expense,
          shortLabel: _weekdayAbbreviation(date),
          isToday: _isSameDay(date, normalizedToday),
        ),
      );
    }
    return points;
  }

  Widget _buildTrendBarSegment(
    BuildContext context, {
    required double height,
    required Color color,
  }) {
    if (height <= 2) {
      return Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.3),
          shape: BoxShape.circle,
        ),
      );
    }
    return Container(
      width: 10,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }

  Widget _buildMonthSummaryCard(
    BuildContext context,
    _TransactionMonthGroup group,
    Key cardKey,
    String headerLabel,
  ) {
    final netCashflow = group.totalIncome - group.totalExpense;
    final netColor = netCashflow >= 0
        ? context.fluxPositiveAmount
        : context.fluxNegativeAmount;
    final incomeColor = context.fluxPositiveAmount;
    final expenseColor = context.fluxNegativeAmount;
    final incomeCategories = group.categorySummaries
        .where((summary) => summary.type == TransactionType.income)
        .toList();
    final expenseCategories = group.categorySummaries
        .where((summary) => summary.type == TransactionType.expense)
        .toList();
    final maxIncomeAmount =
        incomeCategories.isEmpty ? 1.0 : incomeCategories.first.amount;
    final maxExpenseAmount =
        expenseCategories.isEmpty ? 1.0 : expenseCategories.first.amount;
    final mutedTextColor = context.fluxSecondaryText.withValues(alpha: 0.6);

    return AnimatedSize(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOutCubic,
      child: Container(
        key: cardKey,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: context.fluxSurface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 30,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      headerLabel,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: context.fluxSecondaryText,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      '${group.transactions.length} 笔记录',
                      style: context.textTheme.bodySmall
                          ?.copyWith(color: mutedTextColor),
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '净现金流',
                      style: context.textTheme.bodySmall
                          ?.copyWith(color: mutedTextColor),
                    ),
                    const Gap(4),
                    Text(
                      _formatSignedAmount(netCashflow),
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: netColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Gap(16),
            Row(
              children: [
                _buildSummaryPill(
                  context,
                  label: '本月收入',
                  amount: group.totalIncome,
                  color: incomeColor,
                ),
                const Gap(12),
                _buildSummaryPill(
                  context,
                  label: '本月支出',
                  amount: group.totalExpense,
                  color: expenseColor,
                ),
              ],
            ),
            const Gap(20),
            const Gap(12),
            AppSegmentedControl<_MonthBreakdownTab>(
              groupValue: _monthBreakdownTab,
              onValueChanged: (value) {
                if (value == null) return;
                setState(() => _monthBreakdownTab = value);
              },
              children: const {
                _MonthBreakdownTab.expense: Text('支出构成'),
                _MonthBreakdownTab.income: Text('收入来源'),
              },
            ),
            const Gap(16),
            _buildCategoryColumn(
              context,
              title: _monthBreakdownTab == _MonthBreakdownTab.expense
                  ? '支出类别 TOP5'
                  : '收入来源 TOP5',
              summaries: (_monthBreakdownTab == _MonthBreakdownTab.expense
                      ? expenseCategories
                      : incomeCategories)
                  .take(8)
                  .toList(),
              maxAmount: _monthBreakdownTab == _MonthBreakdownTab.expense
                  ? maxExpenseAmount
                  : maxIncomeAmount,
              color: _monthBreakdownTab == _MonthBreakdownTab.expense
                  ? expenseColor
                  : incomeColor,
              emptyPlaceholder: _monthBreakdownTab == _MonthBreakdownTab.expense
                  ? '暂无支出记录'
                  : '暂无收入记录',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryPill(
    BuildContext context, {
    required String label,
    required double amount,
    required Color color,
  }) =>
      Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: color.withValues(
              alpha:
                  Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.08,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: context.textTheme.bodySmall?.copyWith(
                  color: color.withValues(
                    alpha: Theme.of(context).brightness == Brightness.dark
                        ? 0.9
                        : 0.7,
                  ),
                ),
              ),
              const Gap(6),
              Text(
                _currencyFormatter.format(amount),
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildCategoryColumn(
    BuildContext context, {
    required String title,
    required List<_CategorySummary> summaries,
    required double maxAmount,
    required Color color,
    required String emptyPlaceholder,
  }) {
    final labelStyle = context.textTheme.bodySmall?.copyWith(
      color: context.fluxSecondaryText.withValues(alpha: 0.7),
      fontWeight: FontWeight.w600,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: labelStyle),
        const Gap(10),
        if (summaries.isEmpty)
          Text(
            emptyPlaceholder,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.fluxSecondaryText.withValues(alpha: 0.5),
            ),
          )
        else
          ...summaries.map(
            (summary) => _buildCategorySummaryRow(
              context,
              summary,
              maxAmount,
              color,
            ),
          ),
      ],
    );
  }

  Widget _buildCategorySummaryRow(
    BuildContext context,
    _CategorySummary summary,
    double maxAmount,
    Color barColor,
  ) {
    final progress =
        maxAmount == 0 ? 0.0 : (summary.amount / maxAmount).clamp(0.0, 1.0);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bubbleColor = barColor.withValues(alpha: isDark ? 0.25 : 0.12);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: bubbleColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: PhosphorIcon(
                    _categoryIcon(summary.category),
                    color: barColor,
                    size: 18,
                  ),
                ),
              ),
              const Gap(10),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        summary.category.displayName,
                        style: context.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: context.fluxPrimaryText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Gap(12),
                    Text(
                      _currencyFormatter.format(summary.amount),
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: barColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(4),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: isDark
                  ? Colors.white.withValues(alpha: 0.15)
                  : context.fluxSurface.withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
        ],
      ),
    );
  }

  String _formatSignedAmount(double value) {
    final formatted = _currencyFormatter.format(value.abs());
    if (value == 0) return formatted;
    return value > 0 ? '+$formatted' : '-$formatted';
  }

  void _setTimeframe(FluxTimeframe timeframe) {
    if (_isMorphing) return;
    ref.read(fluxViewStateProvider.notifier).setTimeframe(timeframe);
  }

  void _setPane(
    FluxPane pane, {
    String source = 'header_chip',
  }) {
    final currentState = ref.read(fluxViewStateProvider);
    if (currentState.pane == pane) {
      return;
    }
    _scheduleOperationMeasurement(
      _paneSwitchOperationName,
      _paneSwitchAnimationBudget,
    );
    ref.read(fluxViewStateProvider.notifier).setPane(pane);
    final flagEnabled = ref.read(streamInsightsFlagStateProvider).isEnabled;
    PerformanceMonitor.logViewToggleTelemetry(
      pane: pane,
      timeframe: currentState.timeframe,
      flagEnabled: flagEnabled,
      metadata: <String, Object?>{'source': source},
    );
  }

  void _performMorphTransition(List<_TimelineGroup> targetGroups) {
    final listState = _listKey.currentState;
    if (listState == null) {
      setState(() {
        _currentGroups = List<_TimelineGroup>.from(targetGroups);
        _listKey = GlobalKey<SliverAnimatedListState>();
        _isMorphing = false;
      });
      return;
    }

    if (targetGroups.isEmpty) {
      setState(() {
        _currentGroups.clear();
        _isMorphing = false;
      });
      return;
    }

    final now = DateTime.now();
    var anchorIndex =
        _currentGroups.indexWhere((group) => group.containsDate(now));
    if (anchorIndex == -1 && _currentGroups.isNotEmpty) {
      anchorIndex = 0;
    }
    final anchorGroup = _findAnchorGroup(targetGroups, now);
    final anchorKey = anchorGroup.uniqueKey;
    final targetAnchorIndex =
        targetGroups.indexWhere((group) => group.uniqueKey == anchorKey);

    setState(() {
      if (_currentGroups.isEmpty) {
        _currentGroups.add(anchorGroup);
        listState.insertItem(
          0,
          duration: const Duration(milliseconds: 260),
        );
        anchorIndex = 0;
      } else if (anchorIndex >= 0 && anchorIndex < _currentGroups.length) {
        _currentGroups[anchorIndex] = anchorGroup;
      }
    });

    for (var i = _currentGroups.length - 1; i >= 0; i--) {
      if (i == anchorIndex &&
          _currentGroups[i].uniqueKey == anchorGroup.uniqueKey) {
        continue;
      }
      final removedGroup = _currentGroups.removeAt(i);
      listState.removeItem(
        i,
        (context, animation) => FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              ),
            ),
            child: _buildGroupCard(context, removedGroup),
          ),
        ),
        duration: const Duration(milliseconds: 200),
      );
    }

    final before = <_TimelineGroup>[];
    final after = <_TimelineGroup>[];
    for (var i = 0; i < targetGroups.length; i++) {
      final group = targetGroups[i];
      if (group.uniqueKey == anchorKey) continue;
      if (targetAnchorIndex != -1 && i < targetAnchorIndex) {
        before.add(group);
      } else {
        after.add(group);
      }
    }

    for (var i = before.length - 1; i >= 0; i--) {
      final group = before[i];
      final insertIndex = anchorIndex.clamp(0, _currentGroups.length);
      _currentGroups.insert(insertIndex, group);
      listState.insertItem(
        insertIndex,
      );
    }

    anchorIndex += before.length;

    var insertIndex = anchorIndex + 1;
    for (final group in after) {
      final effectiveIndex = insertIndex.clamp(0, _currentGroups.length);
      _currentGroups.insert(effectiveIndex, group);
      listState.insertItem(
        effectiveIndex,
      );
      insertIndex++;
    }

    setState(() {
      _isMorphing = false;
    });
  }

  Widget _buildTransactionRow(
    BuildContext context,
    Transaction transaction,
    bool isNewlyInserted,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconBackground = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : context.fluxPrimaryAction.withValues(alpha: 0.1);
    final iconColor = isDark ? Colors.white : context.fluxPrimaryAction;
    final isExpense = _isExpense(transaction);
    final isIncome = _isIncome(transaction);
    final amountColor = isExpense
        ? context.fluxNegativeAmount
        : isIncome
            ? context.fluxPositiveAmount
            : context.fluxPrimaryText;
    final sign = isExpense
        ? '-'
        : isIncome
            ? '+'
            : '';
    final formattedAmount = _currencyFormatter.format(transaction.amount.abs());
    final title = transaction.category.displayName;
    final subtitle = (transaction.notes?.trim().isNotEmpty ?? false)
        ? transaction.notes!.trim()
        : transaction.description;

    final content = Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBackground,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: PhosphorIcon(
                _categoryIcon(transaction.category),
                color: iconColor,
                size: 22,
              ),
            ),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.fluxPrimaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textScaler: const TextScaler.linear(0.9),
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.fluxSecondaryText,
                  ),
                ),
              ],
            ),
          ),
          const Gap(12),
          Text(
            '$sign$formattedAmount',
            style: GoogleFonts.ibmPlexMono(
              textStyle: context.textTheme.titleMedium?.copyWith(
                color: amountColor,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );

    final slidable = Slidable(
      key: ValueKey(transaction.id),
      startActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.25,
        children: [
          CustomSlidableAction(
            onPressed: (_) => _handleEditTransaction(transaction),
            backgroundColor: Colors.transparent,
            child: _buildFloatingSlidableButton(
              color: context.fluxPrimaryAction,
              icon: PhosphorIcons.pencilSimple(),
            ),
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.25,
        children: [
          CustomSlidableAction(
            onPressed: (_) => _confirmDeleteTransaction(transaction),
            backgroundColor: Colors.transparent,
            child: _buildFloatingSlidableButton(
              color: context.fluxNegativeAmount,
              icon: PhosphorIcons.trash(),
            ),
          ),
        ],
      ),
      child: content,
    );

    if (!isNewlyInserted) {
      return slidable;
    }

    return TweenAnimationBuilder<double>(
      key: ValueKey('txn-${transaction.id}-highlight'),
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 540),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        final overlayColor = Color.lerp(
          context.fluxPrimaryAction.withValues(alpha: 0.18),
          Colors.transparent,
          value,
        )!;
        return Container(
          decoration: overlayColor == Colors.transparent
              ? null
              : BoxDecoration(
                  color: overlayColor,
                  borderRadius: BorderRadius.circular(16),
                ),
          padding: overlayColor == Colors.transparent
              ? EdgeInsets.zero
              : const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: child,
        );
      },
      child: slidable
          .animate(
            key: ValueKey('txn-${transaction.id}-entry'),
          )
          .slideY(
            begin: -0.5,
            end: 0,
            duration: 360.ms,
            curve: Curves.easeOutCubic,
          )
          .fadeIn(
            duration: 260.ms,
            curve: Curves.easeOut,
          ),
    );
  }

  Future<void> _confirmDeleteTransaction(Transaction transaction) async {
    HapticFeedback.lightImpact();
    final shouldDelete = await showCupertinoDialog<bool>(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('删除交易'),
            content: const Text('确定要删除这条记录吗？此操作不可撤销。'),
            actions: [
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('取消'),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('删除'),
              ),
            ],
          ),
        ) ??
        false;

    if (!shouldDelete) return;

    await context.read<TransactionProvider>().deleteTransaction(transaction.id);
  }

  void _handleEditTransaction(Transaction transaction) {
    // TODO: Navigate to edit flow when ready.
    print('Edit todo for transaction ${transaction.id}');
  }

  Widget _buildFloatingSlidableButton({
    required Color color,
    required IconData icon,
  }) =>
      Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.25),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: PhosphorIcon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        ),
      );

  Widget _buildEmptyState(BuildContext context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: context.fluxSurface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
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
              color: context.fluxSecondaryText,
            ),
            const Gap(12),
            Text(
              '暂无记录',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Gap(4),
            Text(
              '开始记录，看看今日现金流。',
              style: context.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );

  List<_TimelineGroup> _groupTransactionsByDay(
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

  List<_TimelineGroup> _groupTransactionsByWeek(
    List<Transaction> transactions,
  ) {
    final confirmed = transactions
        .where(
          (transaction) => transaction.status == TransactionStatus.confirmed,
        )
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    final Map<DateTime, List<Transaction>> grouped = LinkedHashMap(
      equals: (a, b) =>
          a.year == b.year && a.month == b.month && a.day == b.day,
      hashCode: (date) => date.year * 10000 + date.month * 100 + date.day,
    );
    final order = <DateTime>[];

    for (final transaction in confirmed) {
      final weekStart = _startOfIsoWeek(transaction.date);
      final key = DateTime(weekStart.year, weekStart.month, weekStart.day);
      if (!grouped.containsKey(key)) {
        order.add(key);
        grouped[key] = [];
      }
      grouped[key]!.add(transaction);
    }

    return order
        .map(
          (start) => _TransactionWeekGroup(
            startDate: start,
            endDate: _endOfIsoWeek(start),
            transactions: grouped[start] ?? [],
          ),
        )
        .toList();
  }

  List<_TimelineGroup> _groupTransactionsByMonth(
    List<Transaction> transactions,
  ) {
    final confirmed = transactions
        .where(
          (transaction) => transaction.status == TransactionStatus.confirmed,
        )
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    final Map<DateTime, List<Transaction>> grouped = LinkedHashMap(
      equals: (a, b) => a.year == b.year && a.month == b.month,
      hashCode: (date) => date.year * 100 + date.month,
    );
    final order = <DateTime>[];

    for (final transaction in confirmed) {
      final monthStart =
          DateTime(transaction.date.year, transaction.date.month);
      if (!grouped.containsKey(monthStart)) {
        order.add(monthStart);
        grouped[monthStart] = [];
      }
      grouped[monthStart]!.add(transaction);
    }

    return order.map((monthStart) {
      final transactionsInMonth = grouped[monthStart] ?? [];
      double totalIncome = 0;
      double totalExpense = 0;
      final incomeTotals = <TransactionCategory, double>{};
      final expenseTotals = <TransactionCategory, double>{};

      for (final transaction in transactionsInMonth) {
        final amount = transaction.amount.abs();
        if (_isIncome(transaction)) {
          totalIncome += amount;
          incomeTotals.update(
            transaction.category,
            (value) => value + amount,
            ifAbsent: () => amount,
          );
        } else if (_isExpense(transaction)) {
          totalExpense += amount;
          expenseTotals.update(
            transaction.category,
            (value) => value + amount,
            ifAbsent: () => amount,
          );
        }
      }

      final summaries = incomeTotals.entries
          .map(
            (entry) => _CategorySummary(
              category: entry.key,
              amount: entry.value,
              type: TransactionType.income,
            ),
          )
          .followedBy(
            expenseTotals.entries.map(
              (entry) => _CategorySummary(
                category: entry.key,
                amount: entry.value,
                type: TransactionType.expense,
              ),
            ),
          )
          .toList()
        ..sort((a, b) => b.amount.compareTo(a.amount));

      final monthEnd =
          DateTime(monthStart.year, monthStart.month + 1, 0, 23, 59, 59);

      return _TransactionMonthGroup(
        startDate: monthStart,
        endDate: monthEnd,
        transactions: transactionsInMonth,
        totalIncome: totalIncome,
        totalExpense: totalExpense,
        categorySummaries: summaries,
      );
    }).toList();
  }

  bool _groupListsEqual(
    List<_TimelineGroup> previous,
    List<_TimelineGroup> next,
  ) {
    if (identical(previous, next)) {
      return true;
    }
    if (previous.length != next.length) {
      return false;
    }
    for (var i = 0; i < previous.length; i++) {
      if (previous[i].uniqueKey != next[i].uniqueKey ||
          previous[i].transactions.length != next[i].transactions.length) {
        return false;
      }
    }
    return true;
  }

  DateTime _startOfIsoWeek(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    final difference = normalized.weekday - DateTime.monday;
    return normalized.subtract(Duration(days: difference));
  }

  DateTime _endOfIsoWeek(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    final difference = DateTime.sunday - normalized.weekday;
    return normalized.add(Duration(days: difference));
  }

  _TimelineGroup _findAnchorGroup(
    List<_TimelineGroup> groups,
    DateTime target,
  ) {
    for (final group in groups) {
      if (group.containsDate(target)) {
        return group;
      }
    }
    return groups.first;
  }

  void _scheduleScrollToHighlightedCard() {
    if (_pendingScrollDayKey == null || _isScrollScheduled) {
      return;
    }
    _isScrollScheduled = true;
    _pendingScrollAttempts = 0;
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _runScrollToHighlighted());
  }

  void _runScrollToHighlighted() {
    final dayKey = _pendingScrollDayKey;
    if (dayKey == null) {
      _isScrollScheduled = false;
      return;
    }
    final key = _dateKeys[dayKey];
    final context = key?.currentContext;
    if (context == null) {
      if (_pendingScrollAttempts >= 5) {
        _isScrollScheduled = false;
        return;
      }
      _pendingScrollAttempts++;
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
      _pendingScrollAttempts = 0;
    });
  }

  String _dayKeyFromDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  String _formatDayLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (_isSameDay(date, today)) {
      return '今天';
    }
    if (_isSameDay(date, yesterday)) {
      return '昨天';
    }

    return DateFormat('M月d日').format(date);
  }

  String _formatWeekRange(DateTime start, DateTime end) =>
      '${DateFormat('MM.dd').format(start)} - ${DateFormat('MM.dd').format(end)}';

  String _formatMonthLabel(DateTime date) =>
      DateFormat('yyyy年 M月').format(date);

  String _weekdayAbbreviation(DateTime date) {
    switch (date.weekday) {
      case DateTime.monday:
        return 'M';
      case DateTime.tuesday:
        return 'T';
      case DateTime.wednesday:
        return 'W';
      case DateTime.thursday:
        return 'T';
      case DateTime.friday:
        return 'F';
      case DateTime.saturday:
        return 'S';
      case DateTime.sunday:
        return 'S';
      default:
        return '';
    }
  }

  String _themeModeTitle(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return '浅色模式';
      case ThemeMode.dark:
        return '深色模式';
      case ThemeMode.system:
        return '跟随系统';
    }
  }

  String _themeModeDescription(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return '明亮背景，适合白天使用';
      case ThemeMode.dark:
        return '降低眩光，夜间更舒适';
      case ThemeMode.system:
        return '根据系统设置自动切换';
    }
  }

  String _moneyThemeDescription(MoneyTheme theme) => switch (theme) {
        MoneyTheme.fluxBlue => 'Flux 蓝调：收入蓝、支出红、对比最强',
        MoneyTheme.forestEmerald => '森绿调：自然系收入绿、支出赤，适合极简预算',
        MoneyTheme.graphiteMono => '石墨调：黑白灰+渐层，适合夜间与审计场景',
      };

  IconData _themeModeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return PhosphorIcons.sun();
      case ThemeMode.dark:
        return PhosphorIcons.moon();
      case ThemeMode.system:
        return PhosphorIcons.monitor();
    }
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
        return PhosphorIcons.coffee();
      case TransactionCategory.transport:
        return PhosphorIcons.carSimple();
      case TransactionCategory.shopping:
        return PhosphorIcons.shoppingBag();
      case TransactionCategory.entertainment:
        return PhosphorIcons.popcorn();
      case TransactionCategory.healthcare:
        return PhosphorIcons.firstAidKit();
      case TransactionCategory.education:
        return PhosphorIcons.bookBookmark();
      case TransactionCategory.housing:
        return PhosphorIcons.house();
      case TransactionCategory.utilities:
        return PhosphorIcons.plug();
      case TransactionCategory.insurance:
        return PhosphorIcons.shieldCheck();
      case TransactionCategory.salary:
        return PhosphorIcons.wallet();
      case TransactionCategory.bonus:
        return PhosphorIcons.gift();
      case TransactionCategory.investment:
        return PhosphorIcons.trendUp();
      case TransactionCategory.freelance:
        return PhosphorIcons.briefcase();
      case TransactionCategory.gift:
        return PhosphorIcons.seal();
      case TransactionCategory.otherIncome:
        return PhosphorIcons.sparkle();
      case TransactionCategory.otherExpense:
        return PhosphorIcons.dotsThreeCircle();
    }
  }

  @override
  Widget build(BuildContext context) => PerformanceMonitor.monitorBuild(
        'UnifiedTransactionEntryScreen',
        () => _buildUnifiedContent(context),
      );

  Widget _buildUnifiedContent(BuildContext context) {
    final transactionProvider = context.watch<TransactionProvider>();
    final accountsProvider = context.watch<AccountProvider>();
    final themeMode = context.watch<ThemeProvider>().themeMode;
    final themeStyleProvider = context.watch<ThemeStyleProvider>();
    final fluxViewState = ref.watch(fluxViewStateProvider);
    final flagEnabled = ref.watch(streamInsightsFlagStateProvider).isEnabled;
    final groupedTransactions = _currentGroups;
    _scheduleScrollToHighlightedCard();
    final viewInsets = MediaQuery.of(context).padding;
    final dockBottom = kBottomNavigationBarHeight + viewInsets.bottom + 8;
    final cardBottom = dockBottom + 150;
    final scrollBottomPadding = dockBottom + 260;

    if (!flagEnabled) {
      final legacyTimelineView = _buildTimelineView(
        context,
        viewInsets,
        scrollBottomPadding,
        transactionProvider.isLoading,
        groupedTransactions,
        headerOffset: 24,
      );
      return _buildLegacyStreamLayout(
        context: context,
        timelineView: legacyTimelineView,
        viewInsets: viewInsets,
        themeMode: themeMode,
        themeStyleProvider: themeStyleProvider,
        accountsProvider: accountsProvider,
        cardBottom: cardBottom,
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            fit: StackFit.expand,
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: fluxViewState.isShowingInsights
                      ? _buildInsightsView(
                          context,
                          viewInsets,
                          scrollBottomPadding,
                        )
                      : _buildTimelineView(
                          context,
                          viewInsets,
                          scrollBottomPadding,
                          transactionProvider.isLoading,
                          groupedTransactions,
                        ),
                ),
              ),
              _buildHeader(context, viewInsets, fluxViewState),
              _buildInsightsDrawerOverlay(context, viewInsets),
              _buildThemeSettingsButton(
                context,
                viewInsets,
                themeMode,
                themeStyleProvider,
              ),
              if (!fluxViewState.isShowingInsights)
                _buildScrubber(groupedTransactions),
              Positioned(
                left: 16,
                right: 16,
                bottom: cardBottom,
                child: _buildDraftCard(
                  context,
                  accountsProvider.accounts,
                ),
              ),
              _buildInputDock(context),
              _buildToastOverlay(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegacyStreamLayout({
    required BuildContext context,
    required Widget timelineView,
    required EdgeInsets viewInsets,
    required ThemeMode themeMode,
    required ThemeStyleProvider themeStyleProvider,
    required AccountProvider accountsProvider,
    required double cardBottom,
  }) =>
      AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Stack(
              fit: StackFit.expand,
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(child: timelineView),
                _buildThemeSettingsButton(
                  context,
                  viewInsets,
                  themeMode,
                  themeStyleProvider,
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
                _buildInputDock(context),
                _buildToastOverlay(context),
              ],
            ),
          ),
        ),
      );

  void _showToast(String message, {bool isError = false}) {
    _toastTimer?.cancel();
    setState(() {
      _toastMessage = message;
      _isToastError = isError;
    });
    _toastController.forward(from: 0);
    HapticFeedback.lightImpact();
    _toastTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        _toastController.reverse();
      }
    });
  }

  String _guidanceFromNextStuff(
    ParsedTransaction parsed,
    String fallback,
  ) {
    final raw = parsed.nextStuff;
    if (raw == null || raw.trim().isEmpty) {
      return fallback;
    }
    final sanitized = _sanitizeNextStuff(raw);
    if (sanitized.isEmpty) {
      return fallback;
    }
    return sanitized;
  }

  String _sanitizeNextStuff(String nextStuff) {
    var cleaned = nextStuff.trim();
    final technicalPatterns = [
      RegExp('你是一个.*?记账助手', caseSensitive: false),
      RegExp('不要使用.*?敬语', caseSensitive: false),
      RegExp('语气要像.*?', caseSensitive: false),
      RegExp('保持.*?松弛感', caseSensitive: false),
      RegExp('优先级.*?', caseSensitive: false),
      RegExp('如果.*?缺失.*?', caseSensitive: false),
      RegExp('引导语.*?', caseSensitive: false),
      RegExp('简洁.*?自然.*?', caseSensitive: false),
      RegExp('不超过.*?字', caseSensitive: false),
      RegExp('#.*?', caseSensitive: false),
      RegExp('<.*?>', caseSensitive: false),
      RegExp(r'\{.*?\}', caseSensitive: false),
    ];
    for (final pattern in technicalPatterns) {
      cleaned = cleaned.replaceAll(pattern, '').trim();
    }
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (cleaned.length > 18) {
      cleaned = cleaned.substring(0, 18);
    }
    return cleaned;
  }
}

class _ScrubBubble extends StatelessWidget {
  const _ScrubBubble({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: context.textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ) ??
              const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
        ),
      );
}

abstract class _TimelineGroup {
  const _TimelineGroup({
    required this.startDate,
    required this.endDate,
    required this.transactions,
  });

  final DateTime startDate;
  final DateTime endDate;
  final List<Transaction> transactions;

  FluxTimeframe get timeframe;

  Iterable<DateTime> get representedDates;

  String get uniqueKey =>
      '${timeframe.name}-${startDate.microsecondsSinceEpoch}-${endDate.microsecondsSinceEpoch}';

  bool containsDate(DateTime date) =>
      !date.isBefore(startDate) && !date.isAfter(endDate);
}

class _TransactionDayGroup extends _TimelineGroup {
  _TransactionDayGroup({
    required DateTime date,
    required super.transactions,
  }) : super(
          startDate: date,
          endDate: date,
        );

  @override
  FluxTimeframe get timeframe => FluxTimeframe.day;

  @override
  Iterable<DateTime> get representedDates => [startDate];
}

class _TransactionWeekGroup extends _TimelineGroup {
  _TransactionWeekGroup({
    required super.startDate,
    required super.endDate,
    required super.transactions,
  });

  @override
  FluxTimeframe get timeframe => FluxTimeframe.week;

  @override
  Iterable<DateTime> get representedDates {
    final totalDays = endDate.difference(startDate).inDays;
    return List<DateTime>.generate(
      totalDays + 1,
      (index) => startDate.add(Duration(days: index)),
    );
  }
}

class _TransactionMonthGroup extends _TimelineGroup {
  _TransactionMonthGroup({
    required super.startDate,
    required super.endDate,
    required super.transactions,
    required this.totalIncome,
    required this.totalExpense,
    required this.categorySummaries,
  });

  final double totalIncome;
  final double totalExpense;
  final List<_CategorySummary> categorySummaries;

  @override
  FluxTimeframe get timeframe => FluxTimeframe.month;

  @override
  Iterable<DateTime> get representedDates => [startDate];
}

class _CategorySummary {
  const _CategorySummary({
    required this.category,
    required this.amount,
    required this.type,
  });

  final TransactionCategory category;
  final double amount;
  final TransactionType type;
}

enum _MonthBreakdownTab { expense, income }

class _DailyTrendPoint {
  const _DailyTrendPoint({
    required this.date,
    required this.income,
    required this.expense,
    required this.shortLabel,
    required this.isToday,
  });

  final DateTime date;
  final double income;
  final double expense;
  final String shortLabel;
  final bool isToday;
}

enum _DateMenuAction { today, yesterday, pick }

class _InsightsDrawer extends StatelessWidget {
  const _InsightsDrawer({
    required this.state,
    required this.onExpand,
    required this.onMinimize,
    required this.onClose,
  });

  final InsightsDrawerState state;
  final VoidCallback onExpand;
  final VoidCallback onMinimize;
  final VoidCallback onClose;

  bool get _isExpanded => state.isExpanded && state.hasMessage;

  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: _isExpanded
            ? _buildExpanded(context)
            : Align(
                alignment: Alignment.topRight,
                child: _buildCollapsed(context),
              ),
      );

  Widget _buildCollapsed(BuildContext context) {
    final hasBadge = state.improvementCount > 0;
    return GestureDetector(
      key: const ValueKey('insights_drawer_collapsed'),
      onTap: onExpand,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: context.fluxSurface,
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            AppDesignTokens.primaryShadow(context),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              PhosphorIcons.sparkle(),
              color: context.fluxPrimaryAction,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              '洞察准备就绪',
              style: context.textTheme.labelLarge?.copyWith(
                color: context.fluxPrimaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (hasBadge) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color:
                      context.fluxPrimaryAction.withAlpha((255 * 0.15).round()),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '+${state.improvementCount}',
                  style: context.textTheme.labelSmall?.copyWith(
                    color: context.fluxPrimaryAction,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExpanded(BuildContext context) {
    final subtitleStyle = context.textTheme.bodyMedium?.copyWith(
      color: context.fluxSecondaryText,
      height: 1.4,
    );

    return Container(
      key: const ValueKey('insights_drawer_expanded'),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: context.fluxSurface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: context.fluxPrimaryAction.withAlpha((255 * 0.12).round()),
        ),
        boxShadow: [
          AppDesignTokens.primaryShadow(context),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color:
                      context.fluxPrimaryAction.withAlpha((255 * 0.12).round()),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  PhosphorIcons.sparkle(),
                  color: context.fluxPrimaryAction,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'AI 洞察',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                tooltip: '折叠',
                icon: const Icon(Icons.expand_less),
                onPressed: onMinimize,
              ),
              IconButton(
                tooltip: '关闭',
                icon: const Icon(Icons.close),
                onPressed: onClose,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            state.message ?? '洞察已准备就绪',
            style: context.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: context.fluxPrimaryText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '共发现 ${state.improvementCount} 条可行动建议',
            style: subtitleStyle,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: AppPrimaryButton(
              label: '查看洞察',
              onPressed: onExpand,
            ),
          ),
        ],
      ),
    );
  }
}

class _RainbowSendButton extends StatelessWidget {
  const _RainbowSendButton({
    required this.isLoading,
    required this.collapseProgress,
    required this.rotationValue,
    required this.onPressed,
    super.key,
  });

  final bool isLoading;
  final double collapseProgress;
  final double rotationValue;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final clampedProgress = collapseProgress.clamp(0.0, 1.0);
    // Keep the border visible throughout loading so the painter can render the halo.
    final borderReveal =
        isLoading ? 1.0 : ((clampedProgress - 0.75) / 0.25).clamp(0.0, 1.0);
    final baseIntensity = isLoading ? 0.6 : 0.0;
    final intensity = (baseIntensity + borderReveal * 0.8).clamp(0.0, 1.0);
    return _RainbowGlowBorder(
      borderRadius: 999,
      borderWidth: borderReveal,
      intensity: intensity,
      rotation: rotationValue * 2 * math.pi,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          backgroundColor: context.fluxPrimaryAction,
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
              : const Icon(
                  Icons.arrow_upward_rounded,
                  size: 24,
                ),
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
    if (intensity <= 0 || borderWidth <= 0) {
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
    final visibility = borderWidth.clamp(0.0, 1.0);
    if (intensity <= 0 || visibility <= 0) {
      return;
    }
    final rect = Offset.zero & size;
    final activeIntensity = (intensity * visibility).clamp(0.0, 1.0);
    final gradient = SweepGradient(
      colors: [
        const Color(0xFF2F80ED),
        const Color(0xFF8E2DE2),
        const Color(0xFFF562A7),
        const Color(0xFFFFA751),
        const Color(0xFF2F80ED),
      ].map((color) => color.withValues(alpha: activeIntensity)).toList(),
      stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
      transform: GradientRotation(rotation),
    );
    final stroke = lerpDouble(4.0, 10.0, visibility)!;
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt
      ..maskFilter = MaskFilter.blur(BlurStyle.outer, 2.4 * activeIntensity);
    final rrect = RRect.fromRectAndRadius(
      rect.deflate(stroke / 2),
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

extension _FluxColorContext on BuildContext {
  Color get fluxSurface => AppDesignTokens.surface(this);
  Color get fluxPrimaryAction => AppDesignTokens.primaryAction(this);
  Color get fluxPrimaryText => AppDesignTokens.primaryText(this);
  Color get fluxSecondaryText => AppDesignTokens.secondaryText(this);
  Color get fluxPositiveAmount => AppDesignTokens.amountPositiveColor(this);
  Color get fluxNegativeAmount => AppDesignTokens.amountNegativeColor(this);
  Color get fluxPageBackground => AppDesignTokens.pageBackground(this);
}
