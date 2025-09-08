import 'package:uuid/uuid.dart';
import 'package:equatable/equatable.dart';

// 账户类型枚举
enum AccountType {
  cash('现金'),
  bank('银行账户'),
  creditCard('信用卡'),
  investment('投资账户'),
  loan('贷款账户'),
  asset('资产账户'),
  liability('负债账户');

  const AccountType(this.displayName);
  final String displayName;

  static AccountType fromDisplayName(String displayName) {
    return AccountType.values.firstWhere(
      (e) => e.displayName == displayName,
      orElse: () => throw ArgumentError('Unknown AccountType: $displayName'),
    );
  }

  // 判断是否为资产账户
  bool get isAsset {
    return [
      AccountType.cash,
      AccountType.bank,
      AccountType.investment,
      AccountType.asset,
    ].contains(this);
  }

  // 判断是否为负债账户
  bool get isLiability {
    return [
      AccountType.creditCard,
      AccountType.loan,
      AccountType.liability,
    ].contains(this);
  }
}

// 账户状态枚举
enum AccountStatus {
  active('活跃'),
  inactive('停用'),
  closed('已关闭');

  const AccountStatus(this.displayName);
  final String displayName;

  static AccountStatus fromDisplayName(String displayName) {
    return AccountStatus.values.firstWhere(
      (e) => e.displayName == displayName,
      orElse: () => throw ArgumentError('Unknown AccountStatus: $displayName'),
    );
  }
}

// 账户模型
class Account extends Equatable {
  final String id;
  final String name;
  final String? description;
  final AccountType type;
  final AccountStatus status;
  final double balance;
  final String currency; // 币种代码，如 'CNY', 'USD'
  final String? bankName; // 银行名称
  final String? accountNumber; // 账户号码（脱敏显示）
  final String? cardNumber; // 卡号（脱敏显示）
  final double? creditLimit; // 信用额度（信用卡）
  final double? interestRate; // 利率（贷款账户）
  final DateTime? openDate; // 开户日期
  final DateTime? closeDate; // 关闭日期
  final String? iconName; // 图标名称
  final String? color; // 账户颜色
  final bool isDefault; // 是否为默认账户
  final bool isHidden; // 是否隐藏
  final List<String> tags; // 标签
  final DateTime creationDate;
  final DateTime updateDate;
  final String? syncProvider; // 同步提供商（如银行API）
  final String? syncAccountId; // 同步账户ID
  final DateTime? lastSyncDate; // 最后同步时间

  Account({
    String? id,
    required this.name,
    this.description,
    required this.type,
    this.status = AccountStatus.active,
    this.balance = 0.0,
    this.currency = 'CNY',
    this.bankName,
    this.accountNumber,
    this.cardNumber,
    this.creditLimit,
    this.interestRate,
    this.openDate,
    this.closeDate,
    this.iconName,
    this.color,
    this.isDefault = false,
    this.isHidden = false,
    this.tags = const [],
    DateTime? creationDate,
    DateTime? updateDate,
    this.syncProvider,
    this.syncAccountId,
    this.lastSyncDate,
  })  : id = id ?? const Uuid().v4(),
        creationDate = creationDate ?? DateTime.now(),
        updateDate = updateDate ?? DateTime.now();

  // 复制并修改
  Account copyWith({
    String? id,
    String? name,
    String? description,
    AccountType? type,
    AccountStatus? status,
    double? balance,
    String? currency,
    String? bankName,
    String? accountNumber,
    String? cardNumber,
    double? creditLimit,
    double? interestRate,
    DateTime? openDate,
    DateTime? closeDate,
    String? iconName,
    String? color,
    bool? isDefault,
    bool? isHidden,
    List<String>? tags,
    DateTime? creationDate,
    DateTime? updateDate,
    String? syncProvider,
    String? syncAccountId,
    DateTime? lastSyncDate,
  }) {
    return Account(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      cardNumber: cardNumber ?? this.cardNumber,
      creditLimit: creditLimit ?? this.creditLimit,
      interestRate: interestRate ?? this.interestRate,
      openDate: openDate ?? this.openDate,
      closeDate: closeDate ?? this.closeDate,
      iconName: iconName ?? this.iconName,
      color: color ?? this.color,
      isDefault: isDefault ?? this.isDefault,
      isHidden: isHidden ?? this.isHidden,
      tags: tags ?? this.tags,
      creationDate: creationDate ?? this.creationDate,
      updateDate: updateDate ?? DateTime.now(),
      syncProvider: syncProvider ?? this.syncProvider,
      syncAccountId: syncAccountId ?? this.syncAccountId,
      lastSyncDate: lastSyncDate ?? this.lastSyncDate,
    );
  }

  // 获取可用余额（考虑信用额度）
  double get availableBalance {
    if (type == AccountType.creditCard && creditLimit != null) {
      return creditLimit! - balance; // 信用卡可用额度 = 信用额度 - 已用额度
    }
    return balance;
  }

  // 获取显示余额（负债账户显示为负数）
  double get displayBalance {
    if (type.isLiability) {
      return -balance;
    }
    return balance;
  }

  // 获取脱敏的账户号码
  String get maskedAccountNumber {
    if (accountNumber == null || accountNumber!.isEmpty) return '';
    if (accountNumber!.length <= 4) return accountNumber!;
    return '**** **** **** ${accountNumber!.substring(accountNumber!.length - 4)}';
  }

  // 获取脱敏的卡号
  String get maskedCardNumber {
    if (cardNumber == null || cardNumber!.isEmpty) return '';
    if (cardNumber!.length <= 4) return cardNumber!;
    return '**** **** **** ${cardNumber!.substring(cardNumber!.length - 4)}';
  }

  // 序列化
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.name,
      'status': status.name,
      'balance': balance,
      'currency': currency,
      'bankName': bankName,
      'accountNumber': accountNumber,
      'cardNumber': cardNumber,
      'creditLimit': creditLimit,
      'interestRate': interestRate,
      'openDate': openDate?.toIso8601String(),
      'closeDate': closeDate?.toIso8601String(),
      'iconName': iconName,
      'color': color,
      'isDefault': isDefault,
      'isHidden': isHidden,
      'tags': tags,
      'creationDate': creationDate.toIso8601String(),
      'updateDate': updateDate.toIso8601String(),
      'syncProvider': syncProvider,
      'syncAccountId': syncAccountId,
      'lastSyncDate': lastSyncDate?.toIso8601String(),
    };
  }

  // 反序列化
  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      type: AccountType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => throw ArgumentError('Unknown AccountType: ${json['type']}'),
      ),
      status: AccountStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => throw ArgumentError('Unknown AccountStatus: ${json['status']}'),
      ),
      balance: json['balance'] as double,
      currency: json['currency'] as String? ?? 'CNY',
      bankName: json['bankName'] as String?,
      accountNumber: json['accountNumber'] as String?,
      cardNumber: json['cardNumber'] as String?,
      creditLimit: json['creditLimit'] as double?,
      interestRate: json['interestRate'] as double?,
      openDate: json['openDate'] != null ? DateTime.parse(json['openDate'] as String) : null,
      closeDate: json['closeDate'] != null ? DateTime.parse(json['closeDate'] as String) : null,
      iconName: json['iconName'] as String?,
      color: json['color'] as String?,
      isDefault: json['isDefault'] as bool? ?? false,
      isHidden: json['isHidden'] as bool? ?? false,
      tags: List<String>.from(json['tags'] ?? []),
      creationDate: DateTime.parse(json['creationDate'] as String),
      updateDate: DateTime.parse(json['updateDate'] as String),
      syncProvider: json['syncProvider'] as String?,
      syncAccountId: json['syncAccountId'] as String?,
      lastSyncDate: json['lastSyncDate'] != null ? DateTime.parse(json['lastSyncDate'] as String) : null,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        type,
        status,
        balance,
        currency,
        bankName,
        accountNumber,
        cardNumber,
        creditLimit,
        interestRate,
        openDate,
        closeDate,
        iconName,
        color,
        isDefault,
        isHidden,
        tags,
        creationDate,
        updateDate,
        syncProvider,
        syncAccountId,
        lastSyncDate,
      ];
}
