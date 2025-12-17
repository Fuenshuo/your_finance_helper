import 'package:your_finance_flutter/core/models/clearance_entry.dart';
import 'package:your_finance_flutter/core/models/transaction.dart';
import 'package:your_finance_flutter/core/services/storage_service.dart';
import 'package:your_finance_flutter/core/utils/logger.dart';

class PeriodClearanceService {
  late final StorageService _storageService;

  Future<void> initialize() async {
    _storageService = await StorageService.getInstance();
  }

  /// 开始周期清账：创建新的清账会话
  Future<PeriodClearanceSession> startPeriodClearance({
    required String sessionName,
    required PeriodType periodType,
    required DateTime startDate,
    required DateTime endDate,
    String? notes,
  }) async {
    Logger.debug('🔄 开始周期清账: $sessionName');

    final session = PeriodClearanceSession(
      name: sessionName,
      periodType: periodType,
      startDate: startDate,
      endDate: endDate,
      notes: notes,
    );

    await _savePeriodClearanceSession(session);
    Logger.debug('✅ 周期清账会话已创建: ${session.id}');
    return session;
  }

  /// 录入期初余额
  Future<PeriodClearanceSession> inputStartBalances({
    required String sessionId,
    required List<WalletBalanceSnapshot> startBalances,
  }) async {
    final session = await _loadPeriodClearanceSession(sessionId);
    if (session == null) {
      throw Exception('清账会话不存在: $sessionId');
    }

    final updatedSession = session.copyWith(
      startBalances: startBalances,
      updateDate: DateTime.now(),
    );

    await _savePeriodClearanceSession(updatedSession);
    Logger.debug('📝 已录入期初余额: ${startBalances.length}个钱包');
    return updatedSession;
  }

  /// 录入期末余额并计算差额
  Future<PeriodClearanceSession> inputEndBalancesAndCalculateDifferences({
    required String sessionId,
    required List<WalletBalanceSnapshot> endBalances,
  }) async {
    final session = await _loadPeriodClearanceSession(sessionId);
    if (session == null) {
      throw Exception('清账会话不存在: $sessionId');
    }

    // 计算各钱包差额
    final walletDifferences = <WalletDifference>[];
    for (final endBalance in endBalances) {
      final startBalance = session.startBalances.firstWhere(
        (s) => s.walletId == endBalance.walletId,
        orElse: () => WalletBalanceSnapshot(
          walletId: endBalance.walletId,
          walletName: endBalance.walletName,
          balance: 0.0,
          recordTime: session.startDate,
        ),
      );

      final difference = WalletDifference(
        walletId: endBalance.walletId,
        walletName: endBalance.walletName,
        startBalance: startBalance.balance,
        endBalance: endBalance.balance,
        explainedAmount: 0.0, // 初始时未解释任何金额
      );

      walletDifferences.add(difference);
    }

    final updatedSession = session.copyWith(
      endBalances: endBalances,
      walletDifferences: walletDifferences,
      status: ClearanceSessionStatus.differenceAnalysis,
      updateDate: DateTime.now(),
    );

    await _savePeriodClearanceSession(updatedSession);
    Logger.debug(
      '📊 已计算差额: 总差额 ¥${updatedSession.totalDifference.toStringAsFixed(2)}',
    );
    return updatedSession;
  }

  /// 添加手动交易记录
  Future<PeriodClearanceSession> addManualTransaction({
    required String sessionId,
    required ManualTransaction transaction,
  }) async {
    final session = await _loadPeriodClearanceSession(sessionId);
    if (session == null) {
      throw Exception('清账会话不存在: $sessionId');
    }

    // 添加交易到列表
    final updatedTransactions = [...session.manualTransactions, transaction];

    // 重新计算钱包差额中的已解释金额
    final updatedWalletDifferences =
        session.walletDifferences.map((walletDiff) {
      // 计算该钱包相关的手动交易总额
      final walletTransactions = updatedTransactions.where(
        (t) => t.walletId == walletDiff.walletId,
      );

      final explainedAmount = walletTransactions.fold<double>(
        0.0,
        (sum, t) => sum + (t.category.isIncome ? t.amount : -t.amount),
      );

      return walletDiff.copyWith(explainedAmount: explainedAmount);
    }).toList();

    final updatedSession = session.copyWith(
      manualTransactions: updatedTransactions,
      walletDifferences: updatedWalletDifferences,
      updateDate: DateTime.now(),
    );

    await _savePeriodClearanceSession(updatedSession);
    Logger.debug(
      '➕ 已添加手动交易: ${transaction.description} ¥${transaction.amount}',
    );
    return updatedSession;
  }

  /// 删除手动交易记录
  Future<PeriodClearanceSession> removeManualTransaction({
    required String sessionId,
    required String transactionId,
  }) async {
    final session = await _loadPeriodClearanceSession(sessionId);
    if (session == null) {
      throw Exception('清账会话不存在: $sessionId');
    }

    // 从列表中移除交易
    final updatedTransactions =
        session.manualTransactions.where((t) => t.id != transactionId).toList();

    // 重新计算钱包差额中的已解释金额
    final updatedWalletDifferences =
        session.walletDifferences.map((walletDiff) {
      final walletTransactions = updatedTransactions.where(
        (t) => t.walletId == walletDiff.walletId,
      );

      final explainedAmount = walletTransactions.fold<double>(
        0.0,
        (sum, t) => sum + (t.category.isIncome ? t.amount : -t.amount),
      );

      return walletDiff.copyWith(explainedAmount: explainedAmount);
    }).toList();

    final updatedSession = session.copyWith(
      manualTransactions: updatedTransactions,
      walletDifferences: updatedWalletDifferences,
      updateDate: DateTime.now(),
    );

    await _savePeriodClearanceSession(updatedSession);
    Logger.debug('➖ 已删除手动交易: $transactionId');
    return updatedSession;
  }

  /// 将剩余差额归为"其他"类别
  Future<PeriodClearanceSession> processRemainingDifference({
    required String sessionId,
    required String walletId,
    required String categoryName, // "其他收入" 或 "其他支出"
  }) async {
    final session = await _loadPeriodClearanceSession(sessionId);
    if (session == null) {
      throw Exception('清账会话不存在: $sessionId');
    }

    final walletDiff = session.walletDifferences.firstWhere(
      (w) => w.walletId == walletId,
      orElse: () => throw Exception('钱包不存在: $walletId'),
    );

    if (!walletDiff.hasRemainingDifference) {
      Logger.debug('钱包 ${walletDiff.walletName} 无剩余差额需要处理');
      return session;
    }

    // 创建"其他"交易记录
    final remainingAmount = walletDiff.remainingAmount;
    final isIncome = remainingAmount > 0;

    final otherTransaction = ManualTransaction(
      description: categoryName,
      amount: remainingAmount.abs(),
      category: isIncome
          ? TransactionCategory.otherIncome
          : TransactionCategory.otherExpense,
      walletId: walletId,
      walletName: walletDiff.walletName,
      date: session.endDate,
      notes: '系统自动生成：剩余差额归纳',
    );

    // 添加交易并更新差额
    return addManualTransaction(
      sessionId: sessionId,
      transaction: otherTransaction,
    );
  }

  /// 完成清账会话
  Future<PeriodClearanceSession> completeClearanceSession(
    String sessionId,
  ) async {
    final session = await _loadPeriodClearanceSession(sessionId);
    if (session == null) {
      throw Exception('清账会话不存在: $sessionId');
    }

    if (!session.canComplete) {
      throw Exception('清账会话尚未完成差额分解，无法完成');
    }

    // 将清账中的手动交易转换为实际交易记录
    await _convertManualTransactionsToTransactions(session);

    final updatedSession = session.copyWith(
      status: ClearanceSessionStatus.completed,
      updateDate: DateTime.now(),
    );

    await _savePeriodClearanceSession(updatedSession);
    Logger.debug('🎉 清账会话已完成: ${session.name}');
    return updatedSession;
  }

  /// 处理历史清账数据：将已完成但未转换的清账会话中的交易转换为实际交易记录
  Future<int> processHistoricalClearanceData() async {
    Logger.debug('🔄 开始处理历史清账数据...');

    final completedSessions = await getCompletedSessions();
    var convertedCount = 0;

    for (final session in completedSessions) {
      if (session.manualTransactions.isNotEmpty) {
        try {
          await _convertManualTransactionsToTransactions(session);
          convertedCount++;
          Logger.debug('✅ 已处理历史清账: ${session.name}');
        } catch (e) {
          Logger.debug('⚠️ 处理历史清账失败 ${session.name}: $e');
        }
      }
    }

    Logger.debug('📊 历史清账数据处理完成，共处理 $convertedCount 个会话');
    return convertedCount;
  }

  /// 将清账中的手动交易转换为实际交易记录
  Future<void> _convertManualTransactionsToTransactions(
    PeriodClearanceSession session,
  ) async {
    if (session.manualTransactions.isEmpty) {
      Logger.debug('清账会话 ${session.name} 无手动交易需要转换');
      return;
    }

    // 加载现有交易记录
    final existingTransactions = await _storageService.loadTransactions();

    // 将 ManualTransaction 转换为 Transaction
    final newTransactions = <Transaction>[];
    for (final manualTx in session.manualTransactions) {
      // 检查是否已经存在相同的交易（避免重复添加）
      var transactionExists = false;
      try {
        existingTransactions.firstWhere(
          (t) =>
              t.description == manualTx.description &&
              t.amount == manualTx.amount &&
              t.date == manualTx.date &&
              ((manualTx.category.isIncome &&
                      t.toAccountId == manualTx.walletId) ||
                  (!manualTx.category.isIncome &&
                      t.fromAccountId == manualTx.walletId)),
        );
        transactionExists = true;
      } catch (e) {
        // 交易不存在，可以继续创建
        transactionExists = false;
      }

      // 如果交易已存在，跳过
      if (transactionExists) {
        Logger.debug('交易已存在，跳过: ${manualTx.description}');
        continue;
      }

      // 创建新的交易记录
      final transaction = Transaction(
        description: manualTx.description,
        amount: manualTx.amount,
        type: manualTx.category.isIncome
            ? TransactionType.income
            : TransactionType.expense,
        category: manualTx.category,
        date: manualTx.date,
        notes: manualTx.notes ?? '来自清账: ${session.name}',
        // 根据收入/支出设置账户ID
        fromAccountId: manualTx.category.isIncome ? null : manualTx.walletId,
        toAccountId: manualTx.category.isIncome ? manualTx.walletId : null,
      );

      newTransactions.add(transaction);
      Logger.debug(
        '✅ 已创建交易记录: ${transaction.description} ¥${transaction.amount}',
      );
    }

    // 保存新交易记录
    if (newTransactions.isNotEmpty) {
      final allTransactions = [...existingTransactions, ...newTransactions];
      await _storageService.saveTransactions(allTransactions);
      Logger.debug('💾 已保存 ${newTransactions.length} 条交易记录到交易系统');
    } else {
      Logger.debug('⚠️ 没有新交易需要保存');
    }
  }

  /// 生成周期财务总结
  Future<PeriodSummary> generatePeriodSummary(String sessionId) async {
    final session = await _loadPeriodClearanceSession(sessionId);
    if (session == null) {
      throw Exception('清账会话不存在: $sessionId');
    }

    // 计算收支统计
    var totalIncome = 0.0;
    var totalExpense = 0.0;
    final categoryBreakdown = <String, double>{};

    for (final transaction in session.manualTransactions) {
      if (transaction.category.isIncome) {
        totalIncome += transaction.amount;
      } else {
        totalExpense += transaction.amount;
      }

      // 分类统计
      final categoryName = transaction.category.displayName;
      categoryBreakdown[categoryName] =
          (categoryBreakdown[categoryName] ?? 0.0) + transaction.amount;
    }

    final netChange = totalIncome - totalExpense;

    // 获取主要交易（按金额排序，取前10个）
    final topTransactions = [...session.manualTransactions]
      ..sort((a, b) => b.amount.compareTo(a.amount))
      ..take(10);

    final summary = PeriodSummary(
      sessionId: sessionId,
      sessionName: session.name,
      startDate: session.startDate,
      endDate: session.endDate,
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      netChange: netChange,
      categoryBreakdown: categoryBreakdown,
      topTransactions: topTransactions.toList(),
      generatedDate: DateTime.now(),
    );

    Logger.debug(
      '📊 已生成周期总结: 收入¥${totalIncome.toStringAsFixed(2)}, 支出¥${totalExpense.toStringAsFixed(2)}',
    );
    return summary;
  }

  /// 获取所有周期清账会话
  Future<List<PeriodClearanceSession>> getPeriodClearanceSessions() async {
    try {
      final data = await _storageService.loadPeriodClearanceSessions();
      return data;
    } catch (e) {
      Logger.debug('加载周期清账会话失败: $e');
      return [];
    }
  }

  /// 获取最新的周期清账会话
  Future<PeriodClearanceSession?> getLatestPeriodClearanceSession() async {
    final sessions = await getPeriodClearanceSessions();
    if (sessions.isEmpty) return null;

    // 按创建时间倒序排列，返回最新的
    sessions.sort((a, b) => b.creationDate.compareTo(a.creationDate));
    return sessions.first;
  }

  /// 获取进行中的清账会话
  Future<List<PeriodClearanceSession>> getActiveSessions() async {
    final sessions = await getPeriodClearanceSessions();
    return sessions.where((s) => !s.isCompleted).toList();
  }

  /// 获取已完成的清账会话
  Future<List<PeriodClearanceSession>> getCompletedSessions() async {
    final sessions = await getPeriodClearanceSessions();
    return sessions.where((s) => s.isCompleted).toList();
  }

  /// 删除周期清账会话
  Future<void> deletePeriodClearanceSession(String sessionId) async {
    final sessions = await getPeriodClearanceSessions();
    sessions.removeWhere((s) => s.id == sessionId);
    await _storageService.savePeriodClearanceSessions(sessions);
    Logger.debug('🗑️ 周期清账会话已删除: $sessionId');
  }

  /// 获取清账统计信息
  Future<Map<String, dynamic>> getClearanceStatistics() async {
    final sessions = await getPeriodClearanceSessions();
    final latestSession = await getLatestPeriodClearanceSession();
    final activeSessions = sessions.where((s) => !s.isCompleted).length;
    final completedSessions = sessions.where((s) => s.isCompleted).length;

    return {
      'totalSessions': sessions.length,
      'activeSessions': activeSessions,
      'completedSessions': completedSessions,
      'latestSession': latestSession?.toJson(),
      'walletsWithDifference': latestSession?.walletsWithDifference ?? 0,
      'totalManualTransactions': latestSession?.totalManualTransactions ?? 0,
      'explanationRate': latestSession?.explanationRate ?? 0.0,
    };
  }

  // 私有方法：保存周期清账会话
  Future<void> _savePeriodClearanceSession(
    PeriodClearanceSession session,
  ) async {
    final sessions = await getPeriodClearanceSessions();
    final existingIndex = sessions.indexWhere((s) => s.id == session.id);

    if (existingIndex != -1) {
      sessions[existingIndex] = session;
    } else {
      sessions.add(session);
    }

    await _storageService.savePeriodClearanceSessions(sessions);
  }

  // 私有方法：加载周期清账会话
  Future<PeriodClearanceSession?> _loadPeriodClearanceSession(
    String sessionId,
  ) async {
    final sessions = await getPeriodClearanceSessions();
    try {
      return sessions.firstWhere((s) => s.id == sessionId);
    } catch (e) {
      return null;
    }
  }
}
