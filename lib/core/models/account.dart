import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

// 贷款类型枚举
enum LoanType {
  mortgage('房贷'),
  commercialMortgage('商业房贷'),
  housingFund('公积金贷款'),
  combinedMortgage('组合贷款'),
  carLoan('车贷'),
  personalLoan('个人消费贷'),
  businessLoan('经营贷'),
  creditCard('信用卡分期'),
  other('其他');

  const LoanType(this.displayName);
  final String displayName;
}

// 还款方式枚举
enum RepaymentMethod {
  equalPrincipalAndInterest('等额本息'),
  equalPrincipal('等额本金'),
  interestOnly('先息后本'),
  bullet('到期还本付息'),
  other('其他');

  const RepaymentMethod(this.displayName);
  final String displayName;
}

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

  static AccountType fromDisplayName(String displayName) =>
      AccountType.values.firstWhere(
        (e) => e.displayName == displayName,
        orElse: () => throw ArgumentError('Unknown AccountType: $displayName'),
      );

  // 判断是否为资产账户
  bool get isAsset => [
        AccountType.cash,
        AccountType.bank,
        AccountType.investment,
        AccountType.asset,
      ].contains(this);

  // 判断是否为负债账户
  bool get isLiability => [
        AccountType.creditCard,
        AccountType.loan,
        AccountType.liability,
      ].contains(this);
}

// 账户状态枚举
enum AccountStatus {
  active('活跃'),
  inactive('停用'),
  closed('已关闭');

  const AccountStatus(this.displayName);
  final String displayName;

  static AccountStatus fromDisplayName(String displayName) =>
      AccountStatus.values.firstWhere(
        (e) => e.displayName == displayName,
        orElse: () =>
            throw ArgumentError('Unknown AccountStatus: $displayName'),
      );
}

// 账户模型
class Account extends Equatable {
  // 最后同步时间

  Account({
    required this.name,
    required this.type,
    String? id,
    this.description,
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
    this.loanType,
    this.loanAmount,
    this.secondInterestRate,
    this.loanTerm,
    this.repaymentMethod,
    this.firstPaymentDate,
    this.remainingPrincipal,
    this.monthlyPayment,
    this.isRecurringPayment = false,
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

  // 反序列化
  factory Account.fromJson(Map<String, dynamic> json) => Account(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String?,
        type: AccountType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () =>
              throw ArgumentError('Unknown AccountType: ${json['type']}'),
        ),
        status: AccountStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () =>
              throw ArgumentError('Unknown AccountStatus: ${json['status']}'),
        ),
        balance: json['balance'] as double,
        currency: json['currency'] as String? ?? 'CNY',
        bankName: json['bankName'] as String?,
        accountNumber: json['accountNumber'] as String?,
        cardNumber: json['cardNumber'] as String?,
        creditLimit: json['creditLimit'] as double?,
        interestRate: json['interestRate'] as double?,
        openDate: json['openDate'] != null
            ? DateTime.parse(json['openDate'] as String)
            : null,
        closeDate: json['closeDate'] != null
            ? DateTime.parse(json['closeDate'] as String)
            : null,
        loanType: json['loanType'] != null
            ? LoanType.values.firstWhere(
                (e) => e.name == json['loanType'] as String,
                orElse: () => LoanType.other,
              )
            : null,
        loanAmount: json['loanAmount'] as double?,
        secondInterestRate: json['secondInterestRate'] as double?,
        loanTerm: json['loanTerm'] as int?,
        repaymentMethod: json['repaymentMethod'] != null
            ? RepaymentMethod.values.firstWhere(
                (e) => e.name == json['repaymentMethod'] as String,
                orElse: () => RepaymentMethod.other,
              )
            : null,
        firstPaymentDate: json['firstPaymentDate'] != null
            ? DateTime.parse(json['firstPaymentDate'] as String)
            : null,
        remainingPrincipal: json['remainingPrincipal'] as double?,
        monthlyPayment: json['monthlyPayment'] as double?,
        isRecurringPayment: json['isRecurringPayment'] as bool? ?? false,
        iconName: json['iconName'] as String?,
        color: json['color'] as String?,
        isDefault: json['isDefault'] as bool? ?? false,
        isHidden: json['isHidden'] as bool? ?? false,
        tags: List<String>.from(json['tags'] as List<dynamic>? ?? []),
        creationDate: DateTime.parse(json['creationDate'] as String),
        updateDate: DateTime.parse(json['updateDate'] as String),
        syncProvider: json['syncProvider'] as String?,
        syncAccountId: json['syncAccountId'] as String?,
        lastSyncDate: json['lastSyncDate'] != null
            ? DateTime.parse(json['lastSyncDate'] as String)
            : null,
      );
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

  // 贷款相关字段
  final LoanType? loanType; // 贷款类型
  final double? loanAmount; // 贷款总额
  final double? secondInterestRate; // 第二利率（组合贷）
  final int? loanTerm; // 贷款期限（月）
  final RepaymentMethod? repaymentMethod; // 还款方式
  final DateTime? firstPaymentDate; // 首次还款日
  final double? remainingPrincipal; // 剩余本金
  final double? monthlyPayment; // 月还款额
  final bool isRecurringPayment; // 是否设置为周期性交易
  final String? iconName; // 图标名称
  final String? color; // 账户颜色
  final bool isDefault; // 是否为默认账户
  final bool isHidden; // 是否隐藏
  final List<String> tags; // 标签
  final DateTime creationDate;
  final DateTime updateDate;
  final String? syncProvider; // 同步提供商（如银行API）
  final String? syncAccountId; // 同步账户ID
  final DateTime? lastSyncDate;

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
    LoanType? loanType,
    double? loanAmount,
    double? secondInterestRate,
    int? loanTerm,
    RepaymentMethod? repaymentMethod,
    DateTime? firstPaymentDate,
    double? remainingPrincipal,
    double? monthlyPayment,
    bool? isRecurringPayment,
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
  }) =>
      Account(
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
        loanType: loanType ?? this.loanType,
        loanAmount: loanAmount ?? this.loanAmount,
        secondInterestRate: secondInterestRate ?? this.secondInterestRate,
        loanTerm: loanTerm ?? this.loanTerm,
        repaymentMethod: repaymentMethod ?? this.repaymentMethod,
        firstPaymentDate: firstPaymentDate ?? this.firstPaymentDate,
        remainingPrincipal: remainingPrincipal ?? this.remainingPrincipal,
        monthlyPayment: monthlyPayment ?? this.monthlyPayment,
        isRecurringPayment: isRecurringPayment ?? this.isRecurringPayment,
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

  // 贷款相关方法

  /// 判断是否为贷款账户
  bool get isLoanAccount => type == AccountType.loan && loanType != null;

  /// 获取实际负债余额（用于总负债计算）
  double get effectiveLiabilityBalance {
    if (isLoanAccount && remainingPrincipal != null) {
      return remainingPrincipal!;
    }
    return balance;
  }

  /// 获取已还本金
  double get paidPrincipal {
    if (!isLoanAccount || loanAmount == null || remainingPrincipal == null) {
      return 0;
    }
    return loanAmount! - remainingPrincipal!;
  }

  /// 获取已还本金比例
  double get paidPrincipalPercentage {
    if (!isLoanAccount || loanAmount == null || loanAmount == 0) {
      return 0;
    }
    return (paidPrincipal / loanAmount!) * 100;
  }

  /// 获取剩余还款期数
  int get remainingPayments {
    if (!isLoanAccount || firstPaymentDate == null || loanTerm == null) {
      return 0;
    }

    final now = DateTime.now();
    final monthsPassed = (now.year - firstPaymentDate!.year) * 12 +
        (now.month - firstPaymentDate!.month);

    return (loanTerm! - monthsPassed).clamp(0, loanTerm!);
  }

  /// 获取下次还款日期
  DateTime? get nextPaymentDate {
    if (!isLoanAccount || firstPaymentDate == null) {
      return null;
    }

    final now = DateTime.now();
    var nextDate = DateTime(
      firstPaymentDate!.year,
      firstPaymentDate!.month,
      firstPaymentDate!.day,
    );

    // 找到下一个还款日期
    while (nextDate.isBefore(now) || nextDate.isAtSameMomentAs(now)) {
      nextDate = DateTime(nextDate.year, nextDate.month + 1, nextDate.day);
    }

    return nextDate;
  }

  // 序列化
  Map<String, dynamic> toJson() => {
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
        'loanType': loanType?.name,
        'loanAmount': loanAmount,
        'secondInterestRate': secondInterestRate,
        'loanTerm': loanTerm,
        'repaymentMethod': repaymentMethod?.name,
        'firstPaymentDate': firstPaymentDate?.toIso8601String(),
        'remainingPrincipal': remainingPrincipal,
        'monthlyPayment': monthlyPayment,
        'isRecurringPayment': isRecurringPayment,
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
        loanType,
        loanAmount,
        secondInterestRate,
        loanTerm,
        repaymentMethod,
        firstPaymentDate,
        remainingPrincipal,
        monthlyPayment,
        isRecurringPayment,
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
