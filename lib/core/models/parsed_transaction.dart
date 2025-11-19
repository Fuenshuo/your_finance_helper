import 'package:equatable/equatable.dart';
import 'package:your_finance_flutter/core/models/transaction.dart';

/// AI解析后的交易数据
/// 用于存储从自然语言或图片中提取的交易信息
class ParsedTransaction extends Equatable {
  const ParsedTransaction({
    this.description,
    this.amount,
    this.type,
    this.category,
    this.subCategory,
    this.accountId,
    this.accountName,
    this.envelopeBudgetId,
    this.date,
    this.notes,
    this.confidence = 0.0,
    this.source = ParsedTransactionSource.unknown,
    this.rawData,
  });

  /// 交易描述
  final String? description;

  /// 金额
  final double? amount;

  /// 交易类型（收入/支出/转账）
  final TransactionType? type;

  /// 交易分类
  final TransactionCategory? category;

  /// 子分类
  final String? subCategory;

  /// 账户ID
  final String? accountId;

  /// 账户名称（用于显示）
  final String? accountName;

  /// 关联的信封预算ID
  final String? envelopeBudgetId;

  /// 交易日期
  final DateTime? date;

  /// 备注
  final String? notes;

  /// 解析置信度（0.0-1.0）
  final double confidence;

  /// 数据来源
  final ParsedTransactionSource source;

  /// 原始数据（用于调试）
  final Map<String, dynamic>? rawData;

  /// 是否有效（至少包含描述和金额）
  bool get isValid => description != null && description!.isNotEmpty && amount != null && amount! > 0;

  /// 转换为Transaction对象
  Transaction? toTransaction({
    String? id,
    String? fromAccountId,
    String? toAccountId,
    TransactionStatus status = TransactionStatus.confirmed,
  }) {
    if (!isValid) return null;

    return Transaction(
      id: id,
      description: description!,
      amount: amount!,
      type: type,
      category: category ?? TransactionCategory.otherExpense,
      subCategory: subCategory,
      fromAccountId: type == TransactionType.expense || type == TransactionType.transfer
          ? (fromAccountId ?? accountId)
          : null,
      toAccountId: type == TransactionType.income || type == TransactionType.transfer
          ? (toAccountId ?? accountId)
          : null,
      envelopeBudgetId: envelopeBudgetId,
      date: date ?? DateTime.now(),
      notes: notes,
      status: status,
    );
  }

  /// 从JSON创建
  factory ParsedTransaction.fromJson(Map<String, dynamic> json) {
    return ParsedTransaction(
      description: json['description'] as String?,
      amount: (json['amount'] as num?)?.toDouble(),
      type: json['type'] != null
          ? TransactionType.values.firstWhere(
              (e) => e.name == json['type'],
              orElse: () => TransactionType.expense,
            )
          : null,
      category: json['category'] != null
          ? TransactionCategory.values.firstWhere(
              (e) => e.name == json['category'],
              orElse: () => TransactionCategory.otherExpense,
            )
          : null,
      subCategory: json['subCategory'] as String?,
      accountId: json['accountId'] as String?,
      accountName: json['accountName'] as String?,
      envelopeBudgetId: json['envelopeBudgetId'] as String?,
      date: json['date'] != null ? DateTime.parse(json['date'] as String) : null,
      notes: json['notes'] as String?,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      source: ParsedTransactionSource.values.firstWhere(
        (e) => e.name == json['source'],
        orElse: () => ParsedTransactionSource.unknown,
      ),
      rawData: json['rawData'] as Map<String, dynamic>?,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() => {
        'description': description,
        'amount': amount,
        'type': type?.name,
        'category': category?.name,
        'subCategory': subCategory,
        'accountId': accountId,
        'accountName': accountName,
        'envelopeBudgetId': envelopeBudgetId,
        'date': date?.toIso8601String(),
        'notes': notes,
        'confidence': confidence,
        'source': source.name,
        'rawData': rawData,
      };

  /// 复制并更新
  ParsedTransaction copyWith({
    String? description,
    double? amount,
    TransactionType? type,
    TransactionCategory? category,
    String? subCategory,
    String? accountId,
    String? accountName,
    String? envelopeBudgetId,
    DateTime? date,
    String? notes,
    double? confidence,
    ParsedTransactionSource? source,
    Map<String, dynamic>? rawData,
  }) =>
      ParsedTransaction(
        description: description ?? this.description,
        amount: amount ?? this.amount,
        type: type ?? this.type,
        category: category ?? this.category,
        subCategory: subCategory ?? this.subCategory,
        accountId: accountId ?? this.accountId,
        accountName: accountName ?? this.accountName,
        envelopeBudgetId: envelopeBudgetId ?? this.envelopeBudgetId,
        date: date ?? this.date,
        notes: notes ?? this.notes,
        confidence: confidence ?? this.confidence,
        source: source ?? this.source,
        rawData: rawData ?? this.rawData,
      );

  @override
  List<Object?> get props => [
        description,
        amount,
        type,
        category,
        subCategory,
        accountId,
        accountName,
        envelopeBudgetId,
        date,
        notes,
        confidence,
        source,
        rawData,
      ];
}

/// 解析数据来源
enum ParsedTransactionSource {
  naturalLanguage('自然语言'),
  invoice('发票识别'),
  receipt('收据识别'),
  bankStatement('银行账单'),
  unknown('未知');

  const ParsedTransactionSource(this.displayName);
  final String displayName;
}

