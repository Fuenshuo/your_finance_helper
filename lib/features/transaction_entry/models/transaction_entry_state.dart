import 'package:equatable/equatable.dart';

import 'package:your_finance_flutter/features/transaction_entry/models/draft_transaction.dart';
import 'package:your_finance_flutter/features/transaction_entry/models/input_validation.dart';

/// 性能指标模型
class PerformanceMetrics extends Equatable {
  PerformanceMetrics({
    this.parseResponseTimeMs = 0,
    this.uiRenderTimeMs = 0,
    this.memoryUsageBytes = 0,
    this.cpuUsagePercent = 0.0,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  /// 解析响应时间 (毫秒)
  final int parseResponseTimeMs;

  /// UI渲染时间 (毫秒)
  final int uiRenderTimeMs;

  /// 内存使用量 (字节)
  final int memoryUsageBytes;

  /// CPU使用率 (百分比)
  final double cpuUsagePercent;

  /// 最后更新时间
  final DateTime lastUpdated;

  PerformanceMetrics copyWith({
    int? parseResponseTimeMs,
    int? uiRenderTimeMs,
    int? memoryUsageBytes,
    double? cpuUsagePercent,
    DateTime? lastUpdated,
  }) =>
      PerformanceMetrics(
        parseResponseTimeMs: parseResponseTimeMs ?? this.parseResponseTimeMs,
        uiRenderTimeMs: uiRenderTimeMs ?? this.uiRenderTimeMs,
        memoryUsageBytes: memoryUsageBytes ?? this.memoryUsageBytes,
        cpuUsagePercent: cpuUsagePercent ?? this.cpuUsagePercent,
        lastUpdated: lastUpdated ?? this.lastUpdated,
      );

  /// 是否超过性能阈值
  bool get exceedsThreshold =>
      parseResponseTimeMs > 50 || // 50ms解析阈值
      uiRenderTimeMs > 16 || // 60fps (16ms/frame) 阈值
      cpuUsagePercent > 80.0; // 80% CPU使用率阈值

  @override
  List<Object?> get props => [
        parseResponseTimeMs,
        uiRenderTimeMs,
        memoryUsageBytes,
        cpuUsagePercent,
        lastUpdated,
      ];
}

/// 交易录入页面的整体状态模型
class TransactionEntryState extends Equatable {
  const TransactionEntryState({
    this.currentInput = '',
    this.draftTransaction,
    this.validation = const InputValidation(),
    this.isParsing = false,
    this.parseError,
    this.isSaving = false,
    this.saveError,
    this.savedTransaction,
    this.performanceMetrics,
  });

  /// 当前输入文本
  final String currentInput;

  /// 解析出的交易草稿
  final DraftTransaction? draftTransaction;

  /// 输入验证状态
  final InputValidation validation;

  /// 是否正在解析
  final bool isParsing;

  /// 解析错误信息
  final String? parseError;

  /// 是否正在保存
  final bool isSaving;

  /// 保存错误信息
  final String? saveError;

  /// 最后保存的交易
  final dynamic savedTransaction;

  /// 性能指标
  final PerformanceMetrics? performanceMetrics;

  TransactionEntryState copyWith({
    String? currentInput,
    DraftTransaction? draftTransaction,
    InputValidation? validation,
    bool? isParsing,
    String? parseError,
    bool? isSaving,
    String? saveError,
    Object? savedTransaction,
    PerformanceMetrics? performanceMetrics,
    bool clearDraftTransaction = false,
    bool clearParseError = false,
    bool clearSaveError = false,
    bool clearSavedTransaction = false,
  }) =>
      TransactionEntryState(
        currentInput: currentInput ?? this.currentInput,
        draftTransaction: clearDraftTransaction
            ? null
            : (draftTransaction ?? this.draftTransaction),
        validation: validation ?? this.validation,
        isParsing: isParsing ?? this.isParsing,
        parseError: clearParseError ? null : (parseError ?? this.parseError),
        isSaving: isSaving ?? this.isSaving,
        saveError: clearSaveError ? null : (saveError ?? this.saveError),
        savedTransaction: clearSavedTransaction
            ? null
            : (savedTransaction ?? this.savedTransaction),
        performanceMetrics: performanceMetrics ?? this.performanceMetrics,
      );

  @override
  List<Object?> get props => [
        currentInput,
        draftTransaction,
        validation,
        isParsing,
        parseError,
        isSaving,
        saveError,
        savedTransaction,
        performanceMetrics,
      ];
}
