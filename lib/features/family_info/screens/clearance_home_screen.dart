import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart' as provider;
import 'package:your_finance_flutter/core/models/account.dart';
import 'package:your_finance_flutter/core/models/clearance_entry.dart';
import 'package:your_finance_flutter/core/providers/account_provider.dart';
import 'package:your_finance_flutter/core/providers/transaction_provider.dart';
import 'package:your_finance_flutter/core/services/clearance_service.dart';
import 'package:your_finance_flutter/core/theme/app_theme.dart';
import 'package:your_finance_flutter/core/theme/responsive_text_styles.dart';
import 'package:your_finance_flutter/core/utils/logger.dart';
import 'package:your_finance_flutter/core/widgets/app_card.dart';
import 'package:your_finance_flutter/core/widgets/glass_notification.dart';
import 'package:your_finance_flutter/features/family_info/screens/period_difference_analysis_screen.dart';
import 'package:your_finance_flutter/features/family_info/screens/period_summary_screen.dart';

class ClearanceHomeScreen extends ConsumerStatefulWidget {
  const ClearanceHomeScreen({super.key});

  @override
  ConsumerState<ClearanceHomeScreen> createState() =>
      _ClearanceHomeScreenState();
}

class _ClearanceHomeScreenState extends ConsumerState<ClearanceHomeScreen> {
  final PeriodClearanceService _clearanceService = PeriodClearanceService();
  final TextEditingController _sessionNameController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  DateTime? _startDate; // 开始日期（从上期清账自动获取）
  DateTime? _endDate; // 结束日期（默认为当前时间）

  List<PeriodClearanceSession> _sessions = [];
  PeriodClearanceSession? _currentSession;
  bool _isLoading = false;

  // 余额录入相关状态
  List<Account> _wallets = [];
  final Map<String, TextEditingController> _startBalanceControllers = {};
  final Map<String, TextEditingController> _endBalanceControllers = {};
  bool _isInputtingBalances = false;
  bool _hasLoadedPreviousBalances = false;

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  @override
  void dispose() {
    _sessionNameController.dispose();
    _notesController.dispose();
    for (final controller in _startBalanceControllers.values) {
      controller.dispose();
    }
    for (final controller in _endBalanceControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _initializeService() async {
    await _clearanceService.initialize();
    await _loadSessions();
    await _loadWallets();

    // 确保 TransactionProvider 已初始化（用于计算余额）
    try {
      final transactionProvider =
          provider.Provider.of<TransactionProvider>(context, listen: false);
      if (transactionProvider.transactions.isEmpty &&
          !transactionProvider.isLoading) {
        print(
          '[ClearanceHomeScreen._initializeService] 📊 初始化 TransactionProvider',
        );
        await transactionProvider.initialize();
      }
    } catch (e) {
      print(
        '[ClearanceHomeScreen._initializeService] ⚠️ TransactionProvider 初始化失败: $e',
      );
    }

    _loadDateRange(); // 加载日期范围
  }

  /// 加载日期范围：开始日期从上期清账获取，结束日期默认为当前时间
  void _loadDateRange() {
    // 查找上期已完成的清账会话
    final completedSessions = _sessions.where((s) => s.isCompleted).toList();

    if (completedSessions.isNotEmpty) {
      // 按结束日期倒序排列，取最新的
      completedSessions.sort((a, b) => b.endDate.compareTo(a.endDate));
      final latestSession = completedSessions.first;

      // 开始日期 = 上期清账的结束日期
      _startDate = latestSession.endDate;

      // 生成会话名称
      _generateSessionName();
    } else {
      // 第一次清账，开始日期为空（显示"第一次清账"）
      _startDate = null;
      _sessionNameController.text = '第一次清账';
    }

    // 结束日期默认为当前时间
    _endDate = DateTime.now();

    setState(() {});
  }

  Future<void> _loadWallets() async {
    try {
      print('[ClearanceHomeScreen._loadWallets] 📊 开始加载钱包列表');
      final accountProvider =
          provider.Provider.of<AccountProvider>(context, listen: false);

      // 确保 AccountProvider 已初始化
      if (accountProvider.accounts.isEmpty && !accountProvider.isLoading) {
        print(
          '[ClearanceHomeScreen._loadWallets] ⚠️ AccountProvider 未初始化，开始初始化',
        );
        await accountProvider.initialize();
      }

      // 等待加载完成
      if (accountProvider.isLoading) {
        print(
          '[ClearanceHomeScreen._loadWallets] ⏳ 等待 AccountProvider 加载完成...',
        );
        // 简单等待，实际项目中可以使用 FutureBuilder 或监听器
        await Future<void>.delayed(const Duration(milliseconds: 500));
      }

      final wallets = accountProvider.activeAccounts;
      print('[ClearanceHomeScreen._loadWallets] ✅ 加载到 ${wallets.length} 个活跃钱包');

      setState(() {
        _wallets = wallets;

        // 为每个钱包创建控制器
        for (final wallet in _wallets) {
          if (!_startBalanceControllers.containsKey(wallet.id)) {
            _startBalanceControllers[wallet.id] = TextEditingController();
          }
          if (!_endBalanceControllers.containsKey(wallet.id)) {
            _endBalanceControllers[wallet.id] = TextEditingController();
          }
        }
      });

      // 记录每个钱包的余额
      for (final wallet in _wallets) {
        // 尝试从交易记录计算余额（如果 TransactionProvider 可用）
        try {
          final transactionProvider =
              provider.Provider.of<TransactionProvider>(context, listen: false);
          final transactions = transactionProvider.transactions;
          final accountProvider =
              provider.Provider.of<AccountProvider>(context, listen: false);
          final calculatedBalance =
              accountProvider.getAccountBalance(wallet.id, transactions);
          print(
            '[ClearanceHomeScreen._loadWallets] 💰 钱包: ${wallet.name}, ID: ${wallet.id}, 余额(从交易计算): $calculatedBalance, 余额(模型字段): ${wallet.balance}',
          );
        } catch (e) {
          print(
            '[ClearanceHomeScreen._loadWallets] 💰 钱包: ${wallet.name}, ID: ${wallet.id}, 余额(模型字段): ${wallet.balance}',
          );
        }
      }

      if (_wallets.isEmpty) {
        print('[ClearanceHomeScreen._loadWallets] ⚠️ 钱包列表为空！');
      }
    } catch (e, stackTrace) {
      print('[ClearanceHomeScreen._loadWallets] ❌ 加载钱包失败: $e');
      print('[ClearanceHomeScreen._loadWallets] 堆栈: $stackTrace');
    }
  }

  Future<void> _loadPreviousBalances() async {
    if (_hasLoadedPreviousBalances || _currentSession == null) return;

    print('[ClearanceHomeScreen._loadPreviousBalances] 📊 开始加载期初余额');

    // 确保钱包列表已加载
    if (_wallets.isEmpty) {
      print('[ClearanceHomeScreen._loadPreviousBalances] ⚠️ 钱包列表为空，尝试重新加载');
      await _loadWallets();
    }

    if (_wallets.isEmpty) {
      print('[ClearanceHomeScreen._loadPreviousBalances] ⚠️ 钱包列表仍然为空，无法加载期初余额');
      setState(() => _hasLoadedPreviousBalances = true);
      return;
    }

    try {
      // 获取 AccountProvider 和 TransactionProvider
      final accountProvider =
          provider.Provider.of<AccountProvider>(context, listen: false);
      final transactionProvider =
          provider.Provider.of<TransactionProvider>(context, listen: false);

      // 确保 TransactionProvider 已初始化
      if (transactionProvider.transactions.isEmpty &&
          !transactionProvider.isLoading) {
        print(
          '[ClearanceHomeScreen._loadPreviousBalances] ⚠️ TransactionProvider 未初始化，开始初始化',
        );
        await transactionProvider.initialize();
      }

      // 优先查找上期清账会话（如果有）
      final allSessions = await _clearanceService.getPeriodClearanceSessions();
      final previousSessions = allSessions
          .where(
            (s) =>
                s.isCompleted && s.endDate.isBefore(_currentSession!.startDate),
          )
          .toList();

      if (previousSessions.isNotEmpty) {
        // 按结束日期倒序排列，取最新的
        previousSessions.sort((a, b) => b.endDate.compareTo(a.endDate));
        final latestSession = previousSessions.first;

        print(
          '[ClearanceHomeScreen._loadPreviousBalances] 📊 找到上期清账会话: ${latestSession.name}',
        );

        // 填充期初余额（使用上期的期末余额）
        for (final endBalance in latestSession.endBalances) {
          final controller = _startBalanceControllers[endBalance.walletId];
          if (controller != null) {
            controller.text = endBalance.balance.toStringAsFixed(2);
            print(
              '[ClearanceHomeScreen._loadPreviousBalances] ✅ 钱包 ${endBalance.walletName} 期初余额: ${endBalance.balance}',
            );
          }
        }

        setState(() => _hasLoadedPreviousBalances = true);
        print('[ClearanceHomeScreen._loadPreviousBalances] ✅ 已加载上期余额数据');
      } else {
        // 如果没有上期清账，从交易记录计算当前余额作为期初余额
        print(
          '[ClearanceHomeScreen._loadPreviousBalances] 📊 第一次清账，从交易记录计算期初余额',
        );
        var loadedCount = 0;
        final transactions = transactionProvider.transactions;

        for (final wallet in _wallets) {
          final controller = _startBalanceControllers[wallet.id];
          if (controller != null) {
            // 使用 getAccountBalance 方法从交易记录计算余额
            final balance =
                accountProvider.getAccountBalance(wallet.id, transactions);
            controller.text = balance.toStringAsFixed(2);
            print(
              '[ClearanceHomeScreen._loadPreviousBalances] ✅ 钱包 ${wallet.name} (ID: ${wallet.id}) 期初余额: $balance (从交易记录计算)',
            );
            if (balance != 0) {
              loadedCount++;
            }
          } else {
            print(
              '[ClearanceHomeScreen._loadPreviousBalances] ⚠️ 钱包 ${wallet.name} (ID: ${wallet.id}) 没有对应的控制器',
            );
          }
        }

        setState(() => _hasLoadedPreviousBalances = true);
        print(
          '[ClearanceHomeScreen._loadPreviousBalances] ✅ 已从交易记录计算期初余额，共${_wallets.length}个钱包，$loadedCount个有余额',
        );

        if (loadedCount == 0) {
          print(
            '[ClearanceHomeScreen._loadPreviousBalances] ⚠️ 所有钱包余额都为0，可能是没有交易记录',
          );
        }
      }
    } catch (e, stackTrace) {
      print('[ClearanceHomeScreen._loadPreviousBalances] ❌ 加载期初余额失败: $e');
      print('[ClearanceHomeScreen._loadPreviousBalances] 堆栈: $stackTrace');
      // 如果出错，也尝试从交易记录计算
      try {
        final accountProvider =
            provider.Provider.of<AccountProvider>(context, listen: false);
        final transactionProvider =
            provider.Provider.of<TransactionProvider>(context, listen: false);
        final transactions = transactionProvider.transactions;

        for (final wallet in _wallets) {
          final controller = _startBalanceControllers[wallet.id];
          if (controller != null) {
            final balance =
                accountProvider.getAccountBalance(wallet.id, transactions);
            controller.text = balance.toStringAsFixed(2);
          }
        }
        setState(() => _hasLoadedPreviousBalances = true);
        print(
          '[ClearanceHomeScreen._loadPreviousBalances] ✅ 从交易记录计算期初余额（错误恢复）',
        );
      } catch (e2) {
        print(
          '[ClearanceHomeScreen._loadPreviousBalances] ❌ 从交易记录计算期初余额也失败: $e2',
        );
      }
    }
  }

  Future<void> _loadSessions() async {
    setState(() => _isLoading = true);
    try {
      _sessions = await _clearanceService.getPeriodClearanceSessions();
      _currentSession =
          await _clearanceService.getLatestPeriodClearanceSession();
      // 加载完成后更新日期范围
      _loadDateRange();
    } catch (e) {
      Logger.debug('加载清账会话失败: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _generateSessionName() {
    if (_startDate == null || _endDate == null) {
      _sessionNameController.text = '第一次清账';
      return;
    }

    final startStr = DateFormat('yyyy-MM-dd').format(_startDate!);
    final endStr = DateFormat('yyyy-MM-dd').format(_endDate!);

    // 如果开始和结束日期在同一个月，显示为"2024年1月清账"
    if (_startDate!.year == _endDate!.year &&
        _startDate!.month == _endDate!.month) {
      _sessionNameController.text = '${_endDate!.year}年${_endDate!.month}月清账';
    } else {
      // 否则显示日期范围
      _sessionNameController.text = '$startStr 至 $endStr 清账';
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: context.primaryBackground,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text('周期清账', style: context.responsiveHeadlineMedium),
          centerTitle: true,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: EdgeInsets.all(context.responsiveSpacing16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 如果正在录入余额，显示余额录入表单
                    if (_isInputtingBalances && _currentSession != null) ...[
                      _buildBalanceInputSection(),
                    ] else ...[
                      // 当前进行中的清账会话
                      if (_currentSession != null &&
                          !_currentSession!.isCompleted) ...[
                        _buildCurrentSessionCard(),
                        SizedBox(height: context.responsiveSpacing16),
                      ],

                      // 开始新清账
                      _buildNewClearanceCard(),
                      SizedBox(height: context.responsiveSpacing16),

                      // 清账历史
                      _buildHistoryCard(),
                    ],
                  ],
                ),
              ),
      );

  // 当前进行中的清账会话卡片
  Widget _buildCurrentSessionCard() {
    if (_currentSession == null) return const SizedBox.shrink();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '进行中的清账',
                style: context.responsiveHeadlineMedium.copyWith(
                  color: Colors.blue,
                ),
              ),
              _buildStatusBadge(_currentSession!.status),
            ],
          ),
          SizedBox(height: context.responsiveSpacing8),
          Text(
            _currentSession!.name,
            style: context.responsiveBodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: context.responsiveSpacing4),
          Text(
            _currentSession!.periodDescription,
            style: context.responsiveBodyMedium.copyWith(
              color: Colors.grey,
            ),
          ),
          SizedBox(height: context.responsiveSpacing12),

          // 进度信息
          if (_currentSession!.status ==
              ClearanceSessionStatus.differenceAnalysis) ...[
            Row(
              children: [
                Expanded(
                  child: _buildProgressItem(
                    '总差额',
                    context.formatAmount(_currentSession!.totalDifference),
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildProgressItem(
                    '已解释',
                    context.formatAmount(_currentSession!.totalExplainedAmount),
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildProgressItem(
                    '剩余',
                    context.formatAmount(_currentSession!.totalRemainingAmount),
                    Colors.orange,
                  ),
                ),
              ],
            ),
            SizedBox(height: context.responsiveSpacing12),
            LinearProgressIndicator(
              value: _currentSession!.explanationRate,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                _currentSession!.explanationRate == 1.0
                    ? Colors.green
                    : Colors.blue,
              ),
            ),
            SizedBox(height: context.responsiveSpacing8),
          ],

          // 操作按钮
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _continueCurrentSession,
              child: Text(_getCurrentSessionButtonText()),
            ),
          ),
        ],
      ),
    );
  }

  // 开始新清账卡片
  Widget _buildNewClearanceCard() => AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '开始新的清账',
              style: context.responsiveHeadlineMedium,
            ),
            SizedBox(height: context.responsiveSpacing16),

            // 日期选择
            Row(
              children: [
                Expanded(
                  child: _buildDateSelector(
                    '开始日期',
                    _startDate,
                    (date) {
                      setState(() {
                        _startDate = date;
                        _generateSessionName();
                      });
                    },
                    isFirstClearance: _startDate == null,
                  ),
                ),
                SizedBox(width: context.responsiveSpacing8),
                Expanded(
                  child: _buildDateSelector(
                    '结束日期',
                    _endDate,
                    (date) {
                      setState(() {
                        _endDate = date;
                        _generateSessionName();
                      });
                    },
                  ),
                ),
              ],
            ),

            SizedBox(height: context.responsiveSpacing16),

            // 会话名称
            TextField(
              controller: _sessionNameController,
              decoration: InputDecoration(
                labelText: '清账会话名称',
                hintText: '例如：2024年1月清账',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            SizedBox(height: context.responsiveSpacing16),

            // 开始按钮
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed:
                    _canStartNewSession() ? _startNewClearanceSession : null,
                icon: const Icon(Icons.play_arrow),
                label: const Text('开始清账'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.all(context.responsiveSpacing12),
                ),
              ),
            ),
          ],
        ),
      );

  // 清账历史卡片
  Widget _buildHistoryCard() => AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '清账历史',
              style: context.responsiveHeadlineMedium,
            ),
            SizedBox(height: context.responsiveSpacing16),
            if (_sessions.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(context.responsiveSpacing24),
                  child: Text(
                    '暂无清账记录',
                    style: context.responsiveBodyMedium.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _sessions.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  color: Colors.grey[300],
                ),
                itemBuilder: (context, index) {
                  final session = _sessions[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      session.name,
                      style: context.responsiveBodyLarge,
                    ),
                    subtitle: Text(
                      '${session.periodDescription} • ${session.status.displayName}',
                      style: context.responsiveBodySmall.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 未完成的会话显示删除按钮
                        if (!session.isCompleted)
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                              size: 20,
                            ),
                            onPressed: () => _deleteSession(session),
                            tooltip: '删除',
                          ),
                        if (session.isCompleted)
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 20,
                          )
                        else
                          const Icon(
                            Icons.pending,
                            color: Colors.orange,
                            size: 20,
                          ),
                        const Icon(Icons.chevron_right, color: Colors.grey),
                      ],
                    ),
                    onTap: () => _viewSessionDetail(session),
                  );
                },
              ),
          ],
        ),
      );

  // 辅助UI组件
  Widget _buildStatusBadge(ClearanceSessionStatus status) {
    Color color;
    IconData icon;

    switch (status) {
      case ClearanceSessionStatus.balanceInput:
        color = Colors.orange;
        icon = Icons.edit;
      case ClearanceSessionStatus.differenceAnalysis:
        color = Colors.blue;
        icon = Icons.analytics;
      case ClearanceSessionStatus.completed:
        color = Colors.green;
        icon = Icons.check_circle;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.responsiveSpacing8,
        vertical: context.responsiveSpacing4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          SizedBox(width: context.responsiveSpacing4),
          Text(
            status.displayName,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressItem(String label, String value, Color color) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: context.responsiveBodySmall.copyWith(
              color: Colors.grey,
            ),
          ),
          SizedBox(height: context.responsiveSpacing2),
          Text(
            value,
            style: context.responsiveBodyMedium.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );

  Widget _buildDateSelector(
    String label,
    DateTime? date,
    void Function(DateTime) onDateSelected, {
    bool isFirstClearance = false,
  }) =>
      InkWell(
        onTap: () async {
          final selectedDate = await showDatePicker(
            context: context,
            initialDate: date ?? DateTime.now(),
            firstDate: DateTime.now()
                .subtract(const Duration(days: 365 * 10)), // 允许选择过去10年
            lastDate: DateTime.now().add(const Duration(days: 365)),
          );
          if (selectedDate != null) {
            onDateSelected(selectedDate);
          }
        },
        child: Container(
          padding: EdgeInsets.all(context.responsiveSpacing12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: context.responsiveBodySmall.copyWith(
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: context.responsiveSpacing4),
              Text(
                isFirstClearance && date == null
                    ? '第一次清账'
                    : date != null
                        ? DateFormat('yyyy-MM-dd').format(date)
                        : '请选择日期',
                style: context.responsiveBodyMedium.copyWith(
                  color: isFirstClearance && date == null ? Colors.blue : null,
                  fontWeight:
                      isFirstClearance && date == null ? FontWeight.w600 : null,
                ),
              ),
            ],
          ),
        ),
      );

  // 业务逻辑方法
  String _getCurrentSessionButtonText() {
    if (_currentSession == null) return '';

    switch (_currentSession!.status) {
      case ClearanceSessionStatus.balanceInput:
        return '录入余额';
      case ClearanceSessionStatus.differenceAnalysis:
        return '分解差额';
      case ClearanceSessionStatus.completed:
        return '查看总结';
    }
  }

  bool _canStartNewSession() {
    if (_sessionNameController.text.trim().isEmpty) return false;
    // 结束日期必须存在（开始日期可以为空，表示第一次清账）
    return _endDate != null;
  }

  // 事件处理方法
  Future<void> _startNewClearanceSession() async {
    if (!_canStartNewSession()) return;

    setState(() => _isLoading = true);

    try {
      // 如果没有开始日期，使用结束日期作为开始日期（第一次清账）
      final startDate = _startDate ?? _endDate!;

      final session = await _clearanceService.startPeriodClearance(
        sessionName: _sessionNameController.text.trim(),
        periodType: PeriodType.custom, // 统一使用自定义类型
        startDate: startDate,
        endDate: _endDate!,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
      );

      Logger.debug('清账会话已创建: ${session.name}');

      print(
        '[ClearanceHomeScreen._startNewClearanceSession] ✅ 清账会话已创建: ${session.name}',
      );
      print(
        '[ClearanceHomeScreen._startNewClearanceSession] 📅 开始日期: ${session.startDate}, 结束日期: ${session.endDate}',
      );

      // 确保钱包列表已加载
      if (_wallets.isEmpty) {
        print('[ClearanceHomeScreen._startNewClearanceSession] ⚠️ 钱包列表为空，开始加载');
        await _loadWallets();
      }

      print(
        '[ClearanceHomeScreen._startNewClearanceSession] 📊 当前钱包数量: ${_wallets.length}',
      );

      // 更新当前会话并显示余额录入表单
      setState(() {
        _currentSession = session;
        _isInputtingBalances = true;
        _hasLoadedPreviousBalances = false;
      });

      // 加载上期余额
      print('[ClearanceHomeScreen._startNewClearanceSession] 📊 开始加载期初余额');
      await _loadPreviousBalances();

      // 刷新会话列表
      await _loadSessions();
    } catch (e) {
      Logger.debug('创建清账会话失败: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('创建清账会话失败: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _continueCurrentSession() async {
    if (_currentSession == null) return;

    switch (_currentSession!.status) {
      case ClearanceSessionStatus.balanceInput:
        // 显示余额录入表单
        setState(() {
          _isInputtingBalances = true;
          _hasLoadedPreviousBalances = false;
        });
        await _loadPreviousBalances();
      case ClearanceSessionStatus.differenceAnalysis:
        await _navigateToDifferenceAnalysis(_currentSession!);
      case ClearanceSessionStatus.completed:
        await _navigateToSummary(_currentSession!);
    }
  }

  void _viewSessionDetail(PeriodClearanceSession session) {
    if (session.isCompleted) {
      _navigateToSummary(session);
    } else {
      _continueCurrentSession();
    }
  }

  /// 删除清账会话
  Future<void> _deleteSession(PeriodClearanceSession session) async {
    // 显示确认对话框
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除清账会话"${session.name}"吗？\n\n此操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      await _clearanceService.deletePeriodClearanceSession(session.id);

      // 如果删除的是当前会话，清空当前会话
      if (_currentSession?.id == session.id) {
        setState(() {
          _currentSession = null;
          _isInputtingBalances = false;
        });
      }

      // 刷新会话列表和日期范围
      await _loadSessions();

      if (mounted) {
        GlassNotification.show(
          context,
          message: '清账会话已删除',
          icon: Icons.check_circle,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      Logger.debug('删除清账会话失败: $e');
      if (mounted) {
        GlassNotification.show(
          context,
          message: '删除失败: $e',
          icon: Icons.error_outline,
          backgroundColor: Colors.red.withOpacity(0.2),
          textColor: Colors.red,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // 余额录入相关方法
  Future<void> _submitBalances() async {
    if (!_canSubmitBalances()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请填写所有钱包的期末余额')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 构建期初余额快照
      final startBalances = <WalletBalanceSnapshot>[];
      for (final wallet in _wallets) {
        final controller = _startBalanceControllers[wallet.id]!;
        final balance = double.parse(controller.text.trim());
        startBalances.add(
          WalletBalanceSnapshot(
            walletId: wallet.id,
            walletName: wallet.name,
            balance: balance,
            recordTime: _currentSession!.startDate,
          ),
        );
      }

      // 保存期初余额
      await _clearanceService.inputStartBalances(
        sessionId: _currentSession!.id,
        startBalances: startBalances,
      );

      // 构建期末余额快照
      final endBalances = <WalletBalanceSnapshot>[];
      for (final wallet in _wallets) {
        final controller = _endBalanceControllers[wallet.id]!;
        final balance = double.parse(controller.text.trim());
        endBalances.add(
          WalletBalanceSnapshot(
            walletId: wallet.id,
            walletName: wallet.name,
            balance: balance,
            recordTime: _currentSession!.endDate,
          ),
        );
      }

      // 保存期末余额并计算差额
      final updatedSession =
          await _clearanceService.inputEndBalancesAndCalculateDifferences(
        sessionId: _currentSession!.id,
        endBalances: endBalances,
      );

      Logger.debug('余额录入完成，已计算差额');

      // 更新当前会话
      setState(() {
        _currentSession = updatedSession;
        _isInputtingBalances = false;
      });

      // 刷新会话列表
      await _loadSessions();

      // 跳转到差额分解页面
      await _navigateToDifferenceAnalysis(updatedSession);
    } catch (e) {
      Logger.debug('提交余额失败: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('提交失败: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  bool _canSubmitBalances() {
    if (_currentSession == null) {
      print('[ClearanceHomeScreen._canSubmitBalances] ❌ 当前会话为空');
      return false;
    }

    if (_wallets.isEmpty) {
      print('[ClearanceHomeScreen._canSubmitBalances] ❌ 钱包列表为空');
      return false;
    }

    // 检查所有钱包是否都填写了期末余额（期初余额已自动填充）
    for (final wallet in _wallets) {
      final startController = _startBalanceControllers[wallet.id];
      final endController = _endBalanceControllers[wallet.id];

      if (startController == null || endController == null) {
        print(
          '[ClearanceHomeScreen._canSubmitBalances] ❌ 钱包 ${wallet.name} 缺少控制器',
        );
        return false;
      }

      final startText = startController.text.trim();
      final endText = endController.text.trim();

      // 期初余额应该已经自动填充，如果为空说明加载失败
      if (startText.isEmpty) {
        print(
          '[ClearanceHomeScreen._canSubmitBalances] ❌ 钱包 ${wallet.name} 期初余额为空',
        );
        return false;
      }

      // 期末余额必须由用户填写
      if (endText.isEmpty) {
        print(
          '[ClearanceHomeScreen._canSubmitBalances] ❌ 钱包 ${wallet.name} 期末余额为空',
        );
        return false;
      }

      // 验证是否为有效数字
      final startBalance = double.tryParse(startText);
      final endBalance = double.tryParse(endText);

      if (startBalance == null) {
        print(
          '[ClearanceHomeScreen._canSubmitBalances] ❌ 钱包 ${wallet.name} 期初余额无效: "$startText"',
        );
        return false;
      }

      if (endBalance == null) {
        print(
          '[ClearanceHomeScreen._canSubmitBalances] ❌ 钱包 ${wallet.name} 期末余额无效: "$endText"',
        );
        return false;
      }

      print(
        '[ClearanceHomeScreen._canSubmitBalances] ✅ 钱包 ${wallet.name}: 期初=$startBalance, 期末=$endBalance',
      );
    }

    print('[ClearanceHomeScreen._canSubmitBalances] ✅ 所有钱包验证通过，可以提交');
    return true;
  }

  void _cancelBalanceInput() {
    setState(() {
      _isInputtingBalances = false;
      // 清空余额输入
      for (final controller in _startBalanceControllers.values) {
        controller.clear();
      }
      for (final controller in _endBalanceControllers.values) {
        controller.clear();
      }
    });
  }

  Future<void> _navigateToDifferenceAnalysis(
    PeriodClearanceSession session,
  ) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => PeriodDifferenceAnalysisScreen(session: session),
      ),
    );

    if (result ?? false) {
      await _loadSessions(); // 刷新数据
    }
  }

  Future<void> _navigateToSummary(PeriodClearanceSession session) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (context) => PeriodSummaryScreen(session: session),
      ),
    );
  }

  // 余额录入表单UI组件
  Widget _buildBalanceInputSection() {
    if (_currentSession == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 会话信息卡片
        _buildSessionInfoCard(),
        SizedBox(height: context.responsiveSpacing16),

        // 提示信息
        _buildBalanceHintCard(),
        SizedBox(height: context.responsiveSpacing16),

        // 余额录入表单
        _buildBalanceInputForm(),
        SizedBox(height: context.responsiveSpacing16),

        // 操作按钮
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _cancelBalanceInput,
                child: const Text('取消'),
              ),
            ),
            SizedBox(width: context.responsiveSpacing12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: _canSubmitBalances() ? _submitBalances : null,
                icon: const Icon(Icons.check),
                label: const Text('确认并计算差额'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.all(context.responsiveSpacing12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSessionInfoCard() {
    if (_currentSession == null) return const SizedBox.shrink();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _currentSession!.name,
            style: context.responsiveHeadlineMedium,
          ),
          SizedBox(height: context.responsiveSpacing8),
          Text(
            _currentSession!.periodDescription,
            style: context.responsiveBodyMedium.copyWith(
              color: Colors.grey,
            ),
          ),
          SizedBox(height: context.responsiveSpacing4),
          Text(
            '期初日期: ${DateFormat('yyyy-MM-dd').format(_currentSession!.startDate)}',
            style: context.responsiveBodySmall.copyWith(
              color: Colors.grey,
            ),
          ),
          SizedBox(height: context.responsiveSpacing2),
          Text(
            '期末日期: ${DateFormat('yyyy-MM-dd').format(_currentSession!.endDate)}',
            style: context.responsiveBodySmall.copyWith(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceHintCard() => AppCard(
        child: Row(
          children: [
            const Icon(
              Icons.info_outline,
              color: Colors.blue,
              size: 24,
            ),
            SizedBox(width: context.responsiveSpacing12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '录入说明',
                    style: context.responsiveBodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: context.responsiveSpacing4),
                  Text(
                    '期初余额：自动从账户获取（或上期期末余额）\n期末余额：请输入当前实际余额',
                    style: context.responsiveBodySmall.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _buildBalanceInputForm() {
    if (_wallets.isEmpty) {
      return AppCard(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(context.responsiveSpacing24),
            child: Column(
              children: [
                Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                SizedBox(height: context.responsiveSpacing16),
                Text(
                  '暂无活跃钱包',
                  style: context.responsiveHeadlineMedium.copyWith(
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: context.responsiveSpacing8),
                Text(
                  '请先在账户管理中创建钱包',
                  style: context.responsiveBodyMedium.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '钱包余额录入',
            style: context.responsiveHeadlineMedium,
          ),
          SizedBox(height: context.responsiveSpacing16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _wallets.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: Colors.grey[300],
            ),
            itemBuilder: (context, index) {
              final wallet = _wallets[index];
              return _buildWalletBalanceInput(wallet);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWalletBalanceInput(Account wallet) {
    final startController = _startBalanceControllers[wallet.id];
    final endController = _endBalanceControllers[wallet.id];

    if (startController == null || endController == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.responsiveSpacing12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 钱包名称
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _getAccountColor(wallet.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getAccountIcon(wallet.type),
                  color: _getAccountColor(wallet.type),
                  size: 18,
                ),
              ),
              SizedBox(width: context.responsiveSpacing8),
              Expanded(
                child: Text(
                  wallet.name,
                  style: context.responsiveBodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: context.responsiveSpacing12),

          // 期初余额（自动获取，只读）
          TextField(
            controller: startController,
            readOnly: true,
            decoration: InputDecoration(
              labelText: '期初余额',
              prefixText: '¥ ',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              helperText: '自动从账户获取（或上期期末余额）',
              filled: true,
              fillColor: Colors.grey[100],
            ),
          ),

          SizedBox(height: context.responsiveSpacing12),

          // 期末余额输入
          TextField(
            controller: endController,
            onChanged: (value) {
              // 输入时实时更新按钮状态
              setState(() {});
            },
            decoration: InputDecoration(
              labelText: '期末余额',
              hintText: '请输入期末余额',
              prefixText: '¥ ',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              helperText: '当前实际余额',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ],
      ),
    );
  }

  Color _getAccountColor(AccountType type) {
    if (type.isAsset) return Colors.green;
    if (type.isLiability) return Colors.red;
    return Colors.blue;
  }

  IconData _getAccountIcon(AccountType type) {
    switch (type) {
      case AccountType.cash:
        return Icons.money;
      case AccountType.bank:
        return Icons.account_balance;
      case AccountType.creditCard:
        return Icons.credit_card;
      case AccountType.investment:
        return Icons.trending_up;
      case AccountType.loan:
        return Icons.account_balance_wallet;
      default:
        return Icons.account_balance_wallet;
    }
  }
}
