import 'package:equatable/equatable.dart';

/// 草稿交易模型
class DraftTransaction extends Equatable {
  /// 交易金额
  final double? amount;

  /// 交易描述
  final String? description;

  /// 交易类型
  final TransactionType? type;

  /// 账户ID
  final String? accountId;

  /// 分类ID
  final String? categoryId;

  /// 交易日期
  final DateTime? transactionDate;

  /// 标签列表
  final List<String> tags;

  /// 是否为支出（如果为null则自动判断）
  final bool? isExpense;

  /// 置信度分数 (0.0-1.0)
  final double confidence;

  /// 创建时间
  final DateTime createdAt;

  /// 最后修改时间
  final DateTime updatedAt;

  DraftTransaction({
    this.amount,
    this.description,
    this.type,
    this.accountId,
    this.categoryId,
    this.transactionDate,
    this.tags = const [],
    this.isExpense,
    this.confidence = 0.0,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  DraftTransaction copyWith({
    double? amount,
    String? description,
    TransactionType? type,
    String? accountId,
    String? categoryId,
    DateTime? transactionDate,
    List<String>? tags,
    bool? isExpense,
    double? confidence,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DraftTransaction(
      amount: amount ?? this.amount,
      description: description ?? this.description,
      type: type ?? this.type,
      accountId: accountId ?? this.accountId,
      categoryId: categoryId ?? this.categoryId,
      transactionDate: transactionDate ?? this.transactionDate,
      tags: tags ?? this.tags,
      isExpense: isExpense ?? this.isExpense,
      confidence: confidence ?? this.confidence,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// 是否已完成填写
  bool get isComplete =>
      amount != null &&
      description != null &&
      type != null &&
      accountId != null &&
      categoryId != null &&
      transactionDate != null;

  /// 是否有数据
  bool get hasData =>
      amount != null ||
      (description?.isNotEmpty ?? false) ||
      type != null ||
      accountId != null ||
      categoryId != null ||
      transactionDate != null ||
      tags.isNotEmpty;

  @override
  List<Object?> get props => [
        amount,
        description,
        type,
        accountId,
        categoryId,
        transactionDate,
        tags,
        isExpense,
        confidence,
        createdAt,
        updatedAt,
      ];
}

/// 交易类型枚举
enum TransactionType {
  expense('支出'),
  income('收入'),
  transfer('转账');

  const TransactionType(this.displayName);
  final String displayName;

  static TransactionType? fromString(String? value) {
    if (value == null) return null;
    return TransactionType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => TransactionType.expense,
    );
  }
}
