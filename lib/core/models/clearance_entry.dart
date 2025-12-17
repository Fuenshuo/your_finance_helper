import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import 'package:your_finance_flutter/core/models/transaction.dart';

// 周期清账类型枚举
enum PeriodType {
  halfMonth('半月'),
  month('月度'),
  quarter('季度'),
  custom('自定义');

  const PeriodType(this.displayName);
  final String displayName;

  static PeriodType fromDisplayName(String displayName) =>
      PeriodType.values.firstWhere(
        (e) => e.displayName == displayName,
        orElse: () => PeriodType.month,
      );
}

// 清账会话状态
enum ClearanceSessionStatus {
  balanceInput('余额录入中'), // 正在录入各钱包余额
  differenceAnalysis('差额分解中'), // 正在分解差额和添加交易
  completed('已完成'); // 清账完成

  const ClearanceSessionStatus(this.displayName);
  final String displayName;

  static ClearanceSessionStatus fromDisplayName(String displayName) =>
      ClearanceSessionStatus.values.firstWhere(
        (e) => e.displayName == displayName,
        orElse: () => ClearanceSessionStatus.balanceInput,
      );
}

// 钱包余额快照
class WalletBalanceSnapshot extends Equatable {
  const WalletBalanceSnapshot({
    required this.walletId,
    required this.walletName,
    required this.balance,
    required this.recordTime,
  });

  factory WalletBalanceSnapshot.fromJson(Map<String, dynamic> json) =>
      WalletBalanceSnapshot(
        walletId: json['walletId'] as String,
        walletName: json['walletName'] as String,
        balance: (json['balance'] as num).toDouble(),
        recordTime: DateTime.parse(json['recordTime'] as String),
      );
  final String walletId;
  final String walletName;
  final double balance;
  final DateTime recordTime;

  Map<String, dynamic> toJson() => {
        'walletId': walletId,
        'walletName': walletName,
        'balance': balance,
        'recordTime': recordTime.toIso8601String(),
      };

  @override
  List<Object?> get props => [walletId, walletName, balance, recordTime];
}

// 手动添加的交易记录
class ManualTransaction extends Equatable {
  ManualTransaction({
    required this.description,
    required this.amount,
    required this.category,
    required this.walletId,
    required this.walletName,
    required this.date,
    String? id,
    this.notes,
    DateTime? creationDate,
  })  : id = id ?? const Uuid().v4(),
        creationDate = creationDate ?? DateTime.now();

  factory ManualTransaction.fromJson(Map<String, dynamic> json) =>
      ManualTransaction(
        id: json['id'] as String,
        description: json['description'] as String,
        amount: (json['amount'] as num).toDouble(),
        category:
            TransactionCategory.fromDisplayName(json['category'] as String),
        walletId: json['walletId'] as String,
        walletName: json['walletName'] as String,
        date: DateTime.parse(json['date'] as String),
        notes: json['notes'] as String?,
        creationDate: DateTime.parse(json['creationDate'] as String),
      );
  final String id;
  final String description;
  final double amount;
  final TransactionCategory category;
  final String walletId;
  final String walletName;
  final DateTime date;
  final String? notes;
  final DateTime creationDate;

  Map<String, dynamic> toJson() => {
        'id': id,
        'description': description,
        'amount': amount,
        'category': category.displayName,
        'walletId': walletId,
        'walletName': walletName,
        'date': date.toIso8601String(),
        'notes': notes,
        'creationDate': creationDate.toIso8601String(),
      };

  ManualTransaction copyWith({
    String? id,
    String? description,
    double? amount,
    TransactionCategory? category,
    String? walletId,
    String? walletName,
    DateTime? date,
    String? notes,
    DateTime? creationDate,
  }) =>
      ManualTransaction(
        id: id ?? this.id,
        description: description ?? this.description,
        amount: amount ?? this.amount,
        category: category ?? this.category,
        walletId: walletId ?? this.walletId,
        walletName: walletName ?? this.walletName,
        date: date ?? this.date,
        notes: notes ?? this.notes,
        creationDate: creationDate ?? this.creationDate,
      );

  @override
  List<Object?> get props => [
        id,
        description,
        amount,
        category,
        walletId,
        walletName,
        date,
        notes,
        creationDate,
      ];
}

// 钱包差额信息
class WalletDifference extends Equatable {
  // 剩余未解释金额

  const WalletDifference({
    required this.walletId,
    required this.walletName,
    required this.startBalance,
    required this.endBalance,
    required this.explainedAmount,
  })  : totalDifference = endBalance - startBalance,
        remainingAmount = (endBalance - startBalance) - explainedAmount;

  factory WalletDifference.fromJson(Map<String, dynamic> json) =>
      WalletDifference(
        walletId: json['walletId'] as String,
        walletName: json['walletName'] as String,
        startBalance: (json['startBalance'] as num).toDouble(),
        endBalance: (json['endBalance'] as num).toDouble(),
        explainedAmount: (json['explainedAmount'] as num).toDouble(),
      );
  final String walletId;
  final String walletName;
  final double startBalance; // 期初余额
  final double endBalance; // 期末余额
  final double totalDifference; // 总差额
  final double explainedAmount; // 已解释金额（通过添加的交易）
  final double remainingAmount;

  Map<String, dynamic> toJson() => {
        'walletId': walletId,
        'walletName': walletName,
        'startBalance': startBalance,
        'endBalance': endBalance,
        'explainedAmount': explainedAmount,
        'totalDifference': totalDifference,
        'remainingAmount': remainingAmount,
      };

  WalletDifference copyWith({
    String? walletId,
    String? walletName,
    double? startBalance,
    double? endBalance,
    double? explainedAmount,
  }) =>
      WalletDifference(
        walletId: walletId ?? this.walletId,
        walletName: walletName ?? this.walletName,
        startBalance: startBalance ?? this.startBalance,
        endBalance: endBalance ?? this.endBalance,
        explainedAmount: explainedAmount ?? this.explainedAmount,
      );

  // 是否有剩余差额
  bool get hasRemainingDifference => remainingAmount.abs() > 0.01;

  // 差额描述
  String get differenceDescription {
    if (totalDifference.abs() <= 0.01) return '无变化';
    final prefix = totalDifference > 0 ? '增加' : '减少';
    return '$prefix¥${totalDifference.abs().toStringAsFixed(2)}';
  }

  // 剩余差额描述
  String get remainingDescription {
    if (!hasRemainingDifference) return '已完全解释';
    final prefix = remainingAmount > 0 ? '未解释增加' : '未解释减少';
    return '$prefix¥${remainingAmount.abs().toStringAsFixed(2)}';
  }

  @override
  List<Object?> get props => [
        walletId,
        walletName,
        startBalance,
        endBalance,
        explainedAmount,
        totalDifference,
        remainingAmount,
      ];
}

// 周期清账会话模型
class PeriodClearanceSession extends Equatable {
  PeriodClearanceSession({
    required this.name,
    required this.periodType,
    required this.startDate,
    required this.endDate,
    String? id,
    this.status = ClearanceSessionStatus.balanceInput,
    this.startBalances = const [],
    this.endBalances = const [],
    this.walletDifferences = const [],
    this.manualTransactions = const [],
    DateTime? creationDate,
    DateTime? updateDate,
    this.notes,
  })  : id = id ?? const Uuid().v4(),
        creationDate = creationDate ?? DateTime.now(),
        updateDate = updateDate ?? DateTime.now();

  // 反序列化
  factory PeriodClearanceSession.fromJson(Map<String, dynamic> json) =>
      PeriodClearanceSession(
        id: json['id'] as String,
        name: json['name'] as String,
        periodType: PeriodType.fromDisplayName(json['periodType'] as String),
        startDate: DateTime.parse(json['startDate'] as String),
        endDate: DateTime.parse(json['endDate'] as String),
        status:
            ClearanceSessionStatus.fromDisplayName(json['status'] as String),
        startBalances: (json['startBalances'] as List<dynamic>?)
                ?.map(
                  (e) =>
                      WalletBalanceSnapshot.fromJson(e as Map<String, dynamic>),
                )
                .toList() ??
            [],
        endBalances: (json['endBalances'] as List<dynamic>?)
                ?.map(
                  (e) =>
                      WalletBalanceSnapshot.fromJson(e as Map<String, dynamic>),
                )
                .toList() ??
            [],
        walletDifferences: (json['walletDifferences'] as List<dynamic>?)
                ?.map(
                  (e) => WalletDifference.fromJson(e as Map<String, dynamic>),
                )
                .toList() ??
            [],
        manualTransactions: (json['manualTransactions'] as List<dynamic>?)
                ?.map(
                  (e) => ManualTransaction.fromJson(e as Map<String, dynamic>),
                )
                .toList() ??
            [],
        creationDate: DateTime.parse(json['creationDate'] as String),
        updateDate: DateTime.parse(json['updateDate'] as String),
        notes: json['notes'] as String?,
      );
  final String id;
  final String name; // 会话名称，如"2024年1月上半月清账"
  final PeriodType periodType; // 周期类型
  final DateTime startDate; // 周期开始日期
  final DateTime endDate; // 周期结束日期
  final ClearanceSessionStatus status; // 会话状态

  // 余额快照
  final List<WalletBalanceSnapshot> startBalances; // 期初余额快照
  final List<WalletBalanceSnapshot> endBalances; // 期末余额快照

  // 差额分析
  final List<WalletDifference> walletDifferences; // 各钱包差额分析
  final List<ManualTransaction> manualTransactions; // 手动添加的交易

  // 时间戳
  final DateTime creationDate;
  final DateTime updateDate;
  final String? notes;

  // 序列化
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'periodType': periodType.displayName,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'status': status.displayName,
        'startBalances': startBalances.map((e) => e.toJson()).toList(),
        'endBalances': endBalances.map((e) => e.toJson()).toList(),
        'walletDifferences': walletDifferences.map((e) => e.toJson()).toList(),
        'manualTransactions':
            manualTransactions.map((e) => e.toJson()).toList(),
        'creationDate': creationDate.toIso8601String(),
        'updateDate': updateDate.toIso8601String(),
        'notes': notes,
      };

  // 复制并修改
  PeriodClearanceSession copyWith({
    String? id,
    String? name,
    PeriodType? periodType,
    DateTime? startDate,
    DateTime? endDate,
    ClearanceSessionStatus? status,
    List<WalletBalanceSnapshot>? startBalances,
    List<WalletBalanceSnapshot>? endBalances,
    List<WalletDifference>? walletDifferences,
    List<ManualTransaction>? manualTransactions,
    DateTime? creationDate,
    DateTime? updateDate,
    String? notes,
  }) =>
      PeriodClearanceSession(
        id: id ?? this.id,
        name: name ?? this.name,
        periodType: periodType ?? this.periodType,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        status: status ?? this.status,
        startBalances: startBalances ?? this.startBalances,
        endBalances: endBalances ?? this.endBalances,
        walletDifferences: walletDifferences ?? this.walletDifferences,
        manualTransactions: manualTransactions ?? this.manualTransactions,
        creationDate: creationDate ?? this.creationDate,
        updateDate: updateDate ?? this.updateDate,
        notes: notes ?? this.notes,
      );

  // 获取统计信息
  int get totalWallets => walletDifferences.length;
  int get walletsWithDifference =>
      walletDifferences.where((w) => w.hasRemainingDifference).length;
  int get totalManualTransactions => manualTransactions.length;

  // 计算总差额
  double get totalDifference =>
      walletDifferences.fold(0.0, (sum, w) => sum + w.totalDifference);

  // 计算已解释金额
  double get totalExplainedAmount =>
      walletDifferences.fold(0.0, (sum, w) => sum + w.explainedAmount);

  // 计算剩余未解释金额
  double get totalRemainingAmount =>
      walletDifferences.fold(0.0, (sum, w) => sum + w.remainingAmount);

  // 计算解释完成度
  double get explanationRate {
    if (totalDifference.abs() <= 0.01) return 1.0;
    return (totalExplainedAmount.abs() / totalDifference.abs()).clamp(0.0, 1.0);
  }

  // 是否可以完成
  bool get canComplete =>
      status == ClearanceSessionStatus.differenceAnalysis &&
      walletsWithDifference == 0;

  // 是否已完成
  bool get isCompleted => status == ClearanceSessionStatus.completed;

  // 周期描述
  String get periodDescription =>
      '${startDate.toString().substring(0, 10)} 至 ${endDate.toString().substring(0, 10)}';

  @override
  List<Object?> get props => [
        id,
        name,
        periodType,
        startDate,
        endDate,
        status,
        startBalances,
        endBalances,
        walletDifferences,
        manualTransactions,
        creationDate,
        updateDate,
        notes,
      ];
}

// 周期财务总结
class PeriodSummary extends Equatable {
  const PeriodSummary({
    required this.sessionId,
    required this.sessionName,
    required this.startDate,
    required this.endDate,
    required this.totalIncome,
    required this.totalExpense,
    required this.netChange,
    required this.categoryBreakdown,
    required this.topTransactions,
    required this.generatedDate,
  });

  factory PeriodSummary.fromJson(Map<String, dynamic> json) => PeriodSummary(
        sessionId: json['sessionId'] as String,
        sessionName: json['sessionName'] as String,
        startDate: DateTime.parse(json['startDate'] as String),
        endDate: DateTime.parse(json['endDate'] as String),
        totalIncome: (json['totalIncome'] as num).toDouble(),
        totalExpense: (json['totalExpense'] as num).toDouble(),
        netChange: (json['netChange'] as num).toDouble(),
        categoryBreakdown:
            Map<String, double>.from(json['categoryBreakdown'] as Map),
        topTransactions: (json['topTransactions'] as List<dynamic>)
            .map((e) => ManualTransaction.fromJson(e as Map<String, dynamic>))
            .toList(),
        generatedDate: DateTime.parse(json['generatedDate'] as String),
      );
  final String sessionId;
  final String sessionName;
  final DateTime startDate;
  final DateTime endDate;
  final double totalIncome; // 总收入
  final double totalExpense; // 总支出
  final double netChange; // 净变化
  final Map<String, double> categoryBreakdown; // 分类统计
  final List<ManualTransaction> topTransactions; // 主要交易
  final DateTime generatedDate;

  Map<String, dynamic> toJson() => {
        'sessionId': sessionId,
        'sessionName': sessionName,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'totalIncome': totalIncome,
        'totalExpense': totalExpense,
        'netChange': netChange,
        'categoryBreakdown': categoryBreakdown,
        'topTransactions': topTransactions.map((e) => e.toJson()).toList(),
        'generatedDate': generatedDate.toIso8601String(),
      };

  @override
  List<Object?> get props => [
        sessionId,
        sessionName,
        startDate,
        endDate,
        totalIncome,
        totalExpense,
        netChange,
        categoryBreakdown,
        topTransactions,
        generatedDate,
      ];
}
