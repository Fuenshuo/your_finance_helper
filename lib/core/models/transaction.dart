import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

// 交易流向枚举 - 清晰定义资金流向
enum TransactionFlow {
  /// 外部到钱包 - 收入类交易
  externalToWallet('外部->钱包'),

  /// 钱包到外部 - 支出类交易
  walletToExternal('钱包->外部'),

  /// 钱包到钱包 - 预算转移
  walletToWallet('钱包->钱包'),

  /// 资产到钱包 - 资产变现
  assetToWallet('资产->钱包'),

  /// 钱包到资产 - 资产购入
  walletToAsset('钱包->资产');

  /// 构造函数
  const TransactionFlow(this.displayName);

  /// 显示名称
  final String displayName;

  /// 根据显示名称创建交易流向枚举
  static TransactionFlow fromDisplayName(String displayName) =>
      TransactionFlow.values.firstWhere(
        (e) => e.displayName == displayName,
        orElse: () =>
            throw ArgumentError('Unknown TransactionFlow: $displayName'),
      );

  // 向后兼容的映射
  static TransactionFlow fromLegacyType(TransactionType legacyType) {
    switch (legacyType) {
      case TransactionType.income:
        return TransactionFlow.externalToWallet;
      case TransactionType.expense:
        return TransactionFlow.walletToExternal;
      case TransactionType.transfer:
        return TransactionFlow.walletToWallet;
    }
  }

  // 新流向到旧类型的反向映射（用于向后兼容）
  static TransactionType? toLegacyType(TransactionFlow flow) {
    switch (flow) {
      case TransactionFlow.externalToWallet:
        return TransactionType.income;
      case TransactionFlow.walletToExternal:
        return TransactionType.expense;
      case TransactionFlow.walletToWallet:
        return TransactionType.transfer;
      case TransactionFlow.assetToWallet:
      case TransactionFlow.walletToAsset:
        // 资产交易在旧系统中没有对应的类型，返回null
        return null;
    }
  }
}

// 向后兼容的交易类型枚举
enum TransactionType {
  /// 收入类型交易
  income('收入'),

  /// 支出类型交易
  expense('支出'),

  /// 转账类型交易
  transfer('转账');

  /// 构造函数
  const TransactionType(this.displayName);

  /// 显示名称
  final String displayName;

  /// 根据显示名称创建交易类型枚举
  static TransactionType fromDisplayName(String displayName) =>
      TransactionType.values.firstWhere(
        (e) => e.displayName == displayName,
        orElse: () =>
            throw ArgumentError('Unknown TransactionType: $displayName'),
      );
}

// 交易状态枚举
enum TransactionStatus {
  /// 草稿状态 - 交易正在编辑中
  draft('草稿'),

  /// 已确认状态 - 交易已完成
  confirmed('已确认'),

  /// 待处理状态 - 交易正在处理中
  pending('待处理'),

  /// 已取消状态 - 交易已被取消
  cancelled('已取消');

  /// 构造函数
  const TransactionStatus(this.displayName);

  /// 显示名称
  final String displayName;

  /// 根据显示名称创建交易状态枚举
  static TransactionStatus fromDisplayName(String displayName) =>
      TransactionStatus.values.firstWhere(
        (e) => e.displayName == displayName,
        orElse: () =>
            throw ArgumentError('Unknown TransactionStatus: $displayName'),
      );
}

// 交易分类枚举
enum TransactionCategory {
  // 收入分类
  /// 工资收入
  salary('工资'),

  /// 奖金收入
  bonus('奖金'),

  /// 投资收益
  investment('投资收益'),

  /// 自由职业收入
  freelance('自由职业'),

  /// 礼金收入
  gift('礼金'),

  /// 其他收入
  otherIncome('其他收入'),

  // 支出分类
  /// 餐饮支出
  food('餐饮'),

  /// 交通支出
  transport('交通'),

  /// 购物支出
  shopping('购物'),

  /// 娱乐支出
  entertainment('娱乐'),

  /// 医疗支出
  healthcare('医疗'),

  /// 教育支出
  education('教育'),

  /// 住房支出
  housing('住房'),

  /// 水电费支出
  utilities('水电费'),

  /// 保险支出
  insurance('保险'),

  /// 其他支出
  otherExpense('其他支出');

  /// 构造函数
  const TransactionCategory(this.displayName);

  /// 显示名称
  final String displayName;

  /// 根据显示名称创建交易分类枚举
  static TransactionCategory fromDisplayName(String displayName) =>
      TransactionCategory.values.firstWhere(
        (e) => e.displayName == displayName,
        orElse: () =>
            throw ArgumentError('Unknown TransactionCategory: $displayName'),
      );

  /// 判断是否为收入分类
  bool get isIncome => [
        TransactionCategory.salary,
        TransactionCategory.bonus,
        TransactionCategory.investment,
        TransactionCategory.freelance,
        TransactionCategory.gift,
        TransactionCategory.otherIncome,
      ].contains(this);

  // 判断是否为支出分类
  bool get isExpense => [
        TransactionCategory.food,
        TransactionCategory.transport,
        TransactionCategory.shopping,
        TransactionCategory.entertainment,
        TransactionCategory.healthcare,
        TransactionCategory.education,
        TransactionCategory.housing,
        TransactionCategory.utilities,
        TransactionCategory.insurance,
        TransactionCategory.otherExpense,
      ].contains(this);
}

// 交易记录模型
class Transaction extends Equatable {
  Transaction({
    required this.description,
    required this.amount,
    required this.category,
    required this.date,
    String? id,
    this.flow,
    this.type,
    this.subCategory,
    this.fromWalletId,
    this.toWalletId,
    this.fromAssetId,
    this.toAssetId,
    this.fromAccountId,
    this.toAccountId,
    this.envelopeBudgetId,
    this.expensePlanId,
    this.incomePlanId,
    this.notes,
    this.tags = const [],
    this.status = TransactionStatus.confirmed,
    this.isRecurring = false,
    this.recurringRule,
    this.parentTransactionId,
    DateTime? creationDate,
    DateTime? updateDate,
    this.imagePath,
    this.isAutoGenerated = false,
  })  : id = id ?? const Uuid().v4(),
        creationDate = creationDate ?? DateTime.now(),
        updateDate = updateDate ?? DateTime.now() {
    _validateTransaction();
  }

  /// 从JSON格式反序列化
  factory Transaction.fromJson(Map<String, dynamic> json) {
    // 处理新的交易流向
    TransactionFlow? flow;
    if (json['flow'] != null) {
      try {
        flow = TransactionFlow.values.firstWhere(
          (e) => e.name == json['flow'] as String,
        );
      } catch (e) {
        // 如果找不到对应的枚举值，flow保持为null
      }
    }

    // 向后兼容：如果没有新字段，尝试从旧字段推断
    TransactionType? legacyType;
    if (json['type'] != null) {
      try {
        legacyType = TransactionType.values.firstWhere(
          (e) => e.name == json['type'] as String,
        );
      } catch (e) {
        // 如果找不到对应的枚举值，legacyType保持为null
      }
    }

    // 先解析category
    final category = TransactionCategory.values.firstWhere(
      (e) => e.name == json['category'],
      orElse: () => throw ArgumentError(
        'Unknown TransactionCategory: ${json['category']}',
      ),
    );

    // 如果legacyType为null，尝试根据category推断
    var finalType = legacyType;
    if (finalType == null && category.isIncome) {
      finalType = TransactionType.income;
    } else if (finalType == null && !category.isIncome) {
      finalType = TransactionType.expense;
    }

    return Transaction(
      id: json['id'] as String,
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      flow: flow,
      type: finalType,
      category: category,
      subCategory: json['subCategory'] as String?,
      // 新的钱包ID字段
      fromWalletId: json['fromWalletId'] as String?,
      toWalletId: json['toWalletId'] as String?,
      fromAssetId: json['fromAssetId'] as String?,
      toAssetId: json['toAssetId'] as String?,
      // 向后兼容的字段
      fromAccountId: json['fromAccountId'] as String?,
      toAccountId: json['toAccountId'] as String?,
      envelopeBudgetId: json['envelopeBudgetId'] as String?,
      expensePlanId: json['expensePlanId'] as String?,
      incomePlanId: json['incomePlanId'] as String?,
      date: DateTime.parse(json['date'] as String),
      notes: json['notes'] as String?,
      tags: List<String>.from((json['tags'] as List<dynamic>?) ?? []),
      status: TransactionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () =>
            throw ArgumentError('Unknown TransactionStatus: ${json['status']}'),
      ),
      isRecurring: json['isRecurring'] as bool? ?? false,
      recurringRule: json['recurringRule'] as String?,
      parentTransactionId: json['parentTransactionId'] as String?,
      creationDate: DateTime.parse(json['creationDate'] as String),
      updateDate: DateTime.parse(json['updateDate'] as String),
      imagePath: json['imagePath'] as String?,
      isAutoGenerated: json['isAutoGenerated'] as bool? ?? false,
    );
  }

  /// 交易ID
  final String id;

  /// 交易描述
  final String description;

  /// 交易金额
  final double amount;

  /// 新的交易流向（推荐使用）
  final TransactionFlow? flow;

  /// 向后兼容的旧类型
  final TransactionType? type;

  /// 交易分类
  final TransactionCategory category;

  /// 子分类
  final String? subCategory;

  /// 钱包ID（from和to的语义根据flow确定）
  final String? fromWalletId;

  /// 目标钱包ID
  final String? toWalletId;

  /// 资产ID（用于资产交易）
  final String? fromAssetId;

  /// 目标资产ID
  final String? toAssetId;

  /// 向后兼容的字段 - 来源账户ID
  final String? fromAccountId;

  /// 向后兼容的字段 - 目标账户ID
  final String? toAccountId;

  /// 信封预算ID
  final String? envelopeBudgetId;

  /// 关联的支出计划ID
  final String? expensePlanId;

  /// 关联的收入计划ID
  final String? incomePlanId;

  /// 交易日期
  final DateTime date;

  /// 交易备注
  final String? notes;

  /// 交易标签列表
  final List<String> tags;

  /// 交易状态
  final TransactionStatus status;

  /// 是否为周期性交易
  final bool isRecurring;

  /// 周期性规则
  final String? recurringRule;

  /// 父交易ID（用于周期性交易）
  final String? parentTransactionId;

  /// 创建日期
  final DateTime creationDate;

  /// 更新日期
  final DateTime updateDate;

  /// 图片路径
  final String? imagePath;

  /// 是否为自动生成交易
  final bool isAutoGenerated;

  // 验证交易参数
  void _validateTransaction() {
    // 如果使用新流向，检查必要字段
    if (flow != null) {
      switch (flow!) {
        case TransactionFlow.externalToWallet:
        case TransactionFlow.walletToExternal:
          // 需要钱包ID
          if (fromWalletId == null && toWalletId == null) {
            throw ArgumentError('钱包ID不能为空');
          }
        case TransactionFlow.walletToWallet:
          // 需要两个钱包ID
          if (fromWalletId == null || toWalletId == null) {
            throw ArgumentError('需要指定来源和目标钱包');
          }
        case TransactionFlow.assetToWallet:
        case TransactionFlow.walletToAsset:
          // 需要钱包ID和资产ID
          if ((fromWalletId == null && toWalletId == null) ||
              (fromAssetId == null && toAssetId == null)) {
            throw ArgumentError('需要指定钱包和资产');
          }
      }
    }
  }

  /// 复制并修改交易对象
  Transaction copyWith({
    String? id,
    String? description,
    double? amount,
    TransactionFlow? flow,
    TransactionType? type,
    TransactionCategory? category,
    String? subCategory,
    String? fromWalletId,
    String? toWalletId,
    String? fromAssetId,
    String? toAssetId,
    String? fromAccountId,
    String? toAccountId,
    String? envelopeBudgetId,
    String? expensePlanId,
    String? incomePlanId,
    DateTime? date,
    String? notes,
    List<String>? tags,
    TransactionStatus? status,
    bool? isRecurring,
    String? recurringRule,
    String? parentTransactionId,
    DateTime? creationDate,
    DateTime? updateDate,
    String? imagePath,
    bool? isAutoGenerated,
  }) =>
      Transaction(
        id: id ?? this.id,
        description: description ?? this.description,
        amount: amount ?? this.amount,
        flow: flow ?? this.flow,
        type: type ?? this.type,
        category: category ?? this.category,
        subCategory: subCategory ?? this.subCategory,
        fromWalletId: fromWalletId ?? this.fromWalletId,
        toWalletId: toWalletId ?? this.toWalletId,
        fromAssetId: fromAssetId ?? this.fromAssetId,
        toAssetId: toAssetId ?? this.toAssetId,
        fromAccountId: fromAccountId ?? this.fromAccountId,
        toAccountId: toAccountId ?? this.toAccountId,
        envelopeBudgetId: envelopeBudgetId ?? this.envelopeBudgetId,
        expensePlanId: expensePlanId ?? this.expensePlanId,
        incomePlanId: incomePlanId ?? this.incomePlanId,
        date: date ?? this.date,
        notes: notes ?? this.notes,
        tags: tags ?? this.tags,
        status: status ?? this.status,
        isRecurring: isRecurring ?? this.isRecurring,
        recurringRule: recurringRule ?? this.recurringRule,
        parentTransactionId: parentTransactionId ?? this.parentTransactionId,
        creationDate: creationDate ?? this.creationDate,
        updateDate: updateDate ?? DateTime.now(),
        imagePath: imagePath ?? this.imagePath,
        isAutoGenerated: isAutoGenerated ?? this.isAutoGenerated,
      );

  /// 序列化为JSON格式
  Map<String, dynamic> toJson() => {
        'id': id,
        'description': description,
        'amount': amount,
        // 新的交易流向字段
        'flow': flow?.name,
        // 向后兼容的旧字段
        'type': type?.name ?? TransactionFlow.toLegacyType(flow!)?.name,
        'category': category.name,
        'subCategory': subCategory,
        // 新的钱包ID字段
        'fromWalletId': fromWalletId,
        'toWalletId': toWalletId,
        'fromAssetId': fromAssetId,
        'toAssetId': toAssetId,
        // 向后兼容的字段
        'fromAccountId': fromAccountId,
        'toAccountId': toAccountId,
        'envelopeBudgetId': envelopeBudgetId,
        'date': date.toIso8601String(),
        'notes': notes,
        'tags': tags,
        'status': status.name,
        'isRecurring': isRecurring,
        'recurringRule': recurringRule,
        'parentTransactionId': parentTransactionId,
        'creationDate': creationDate.toIso8601String(),
        'updateDate': updateDate.toIso8601String(),
        'imagePath': imagePath,
        'isAutoGenerated': isAutoGenerated,
      };

  @override
  List<Object?> get props => [
        id,
        description,
        amount,
        flow,
        type,
        category,
        subCategory,
        fromWalletId,
        toWalletId,
        fromAssetId,
        toAssetId,
        fromAccountId,
        toAccountId,
        envelopeBudgetId,
        date,
        notes,
        tags,
        status,
        isRecurring,
        recurringRule,
        parentTransactionId,
        creationDate,
        updateDate,
        imagePath,
        isAutoGenerated,
      ];
}
