import 'package:equatable/equatable.dart';
import 'package:your_finance_flutter/core/models/transaction.dart';

/// 用户收入画像
/// 用于学习用户的收入模式，提升AI解析置信度
class UserIncomeProfile extends Equatable {
  const UserIncomeProfile({
    this.avgMonthlySalary = 0.0,
    this.bonusMonths = const [],
    this.commonIncomeTypes = const [],
    this.salaryDayPattern = 0, // 通常几号发工资（±3天）
    this.transactionCount = 0, // 已记录的交易数量（用于冷启动判断）
    this.transferDirectionPreference, // 转账方向偏好："sent" | "received" | "internal"
  });

  /// 平均月收入（移动平均）
  final double avgMonthlySalary;

  /// 通常发奖金的月份（1-12）
  final List<int> bonusMonths;

  /// 常见收入类型
  final List<TransactionCategory> commonIncomeTypes;

  /// 发薪日模式（每月几号，±3天）
  final int salaryDayPattern;

  /// 已记录的交易数量（用于冷启动判断）
  final int transactionCount;

  /// 转账方向偏好
  /// "sent": 我转给朋友
  /// "received": 朋友转给我
  /// "internal": 银行卡间转账
  final String? transferDirectionPreference;

  /// 是否为冷启动（前5笔记录）
  bool get isColdStart => transactionCount < 5;

  /// 从JSON创建
  factory UserIncomeProfile.fromJson(Map<String, dynamic> json) {
    return UserIncomeProfile(
      avgMonthlySalary: (json['avgMonthlySalary'] as num?)?.toDouble() ?? 0.0,
      bonusMonths: (json['bonusMonths'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
      commonIncomeTypes: (json['commonIncomeTypes'] as List<dynamic>?)
              ?.map((e) => TransactionCategory.values.firstWhere(
                    (cat) => cat.name == e,
                    orElse: () => TransactionCategory.otherIncome,
                  ))
              .toList() ??
          [],
      salaryDayPattern: json['salaryDayPattern'] as int? ?? 0,
      transactionCount: json['transactionCount'] as int? ?? 0,
      transferDirectionPreference:
          json['transferDirectionPreference'] as String?,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() => {
        'avgMonthlySalary': avgMonthlySalary,
        'bonusMonths': bonusMonths,
        'commonIncomeTypes':
            commonIncomeTypes.map((e) => e.name).toList(),
        'salaryDayPattern': salaryDayPattern,
        'transactionCount': transactionCount,
        'transferDirectionPreference': transferDirectionPreference,
      };

  /// 复制并更新
  UserIncomeProfile copyWith({
    double? avgMonthlySalary,
    List<int>? bonusMonths,
    List<TransactionCategory>? commonIncomeTypes,
    int? salaryDayPattern,
    int? transactionCount,
    String? transferDirectionPreference,
  }) =>
      UserIncomeProfile(
        avgMonthlySalary: avgMonthlySalary ?? this.avgMonthlySalary,
        bonusMonths: bonusMonths ?? this.bonusMonths,
        commonIncomeTypes: commonIncomeTypes ?? this.commonIncomeTypes,
        salaryDayPattern: salaryDayPattern ?? this.salaryDayPattern,
        transactionCount: transactionCount ?? this.transactionCount,
        transferDirectionPreference:
            transferDirectionPreference ?? this.transferDirectionPreference,
      );

  /// 从交易记录更新画像
  UserIncomeProfile updateFromTransaction(Transaction transaction) {
    double newAvgMonthlySalary = avgMonthlySalary;
    List<int> newBonusMonths = List.from(bonusMonths);
    List<TransactionCategory> newCommonIncomeTypes =
        List.from(commonIncomeTypes);
    int newSalaryDayPattern = salaryDayPattern;
    int newTransactionCount = transactionCount + 1;

    // 如果是工资收入，更新平均月收入和发薪日模式
    if (transaction.type == TransactionType.income &&
        transaction.category == TransactionCategory.salary) {
      // 移动平均计算（权重0.3，新数据权重0.7）
      newAvgMonthlySalary = avgMonthlySalary == 0
          ? transaction.amount
          : avgMonthlySalary * 0.3 + transaction.amount * 0.7;

      // 更新发薪日模式（取最常见的发薪日）
      final day = transaction.date.day;
      if (salaryDayPattern == 0) {
        newSalaryDayPattern = day;
      } else {
        // 如果新日期在±3天范围内，保持原模式
        if ((day - salaryDayPattern).abs() <= 3) {
          // 保持原模式
        } else {
          // 更新为新日期（简单策略：取最新日期）
          newSalaryDayPattern = day;
        }
      }
    }

    // 如果是奖金收入，记录月份
    if (transaction.type == TransactionType.income &&
        transaction.category == TransactionCategory.bonus) {
      final month = transaction.date.month;
      if (!newBonusMonths.contains(month)) {
        newBonusMonths.add(month);
      }
    }

    // 更新常见收入类型
    if (transaction.type == TransactionType.income) {
      if (!newCommonIncomeTypes.contains(transaction.category)) {
        newCommonIncomeTypes.add(transaction.category);
        // 只保留前5个最常见的
        if (newCommonIncomeTypes.length > 5) {
          newCommonIncomeTypes.removeAt(0);
        }
      }
    }

    return copyWith(
      avgMonthlySalary: newAvgMonthlySalary,
      bonusMonths: newBonusMonths,
      commonIncomeTypes: newCommonIncomeTypes,
      salaryDayPattern: newSalaryDayPattern,
      transactionCount: newTransactionCount,
    );
  }

  /// 增强置信度（基于用户画像）
  double enhanceConfidence(
    double baseConfidence,
    TransactionType? type,
    TransactionCategory? category,
    double? amount,
    DateTime? date,
  ) {
    double enhanced = baseConfidence;

    // 如果是工资收入，且符合用户模式
    if (type == TransactionType.income &&
        category == TransactionCategory.salary) {
      // 检查是否在发薪日附近（±3天）
      if (date != null && salaryDayPattern > 0) {
        final dayDiff = (date.day - salaryDayPattern).abs();
        if (dayDiff <= 3) {
          enhanced += 0.1; // 提升10%置信度
        }
      }

      // 检查金额是否接近平均月收入（±20%）
      if (amount != null && avgMonthlySalary > 0) {
        final ratio = amount / avgMonthlySalary;
        if (ratio >= 0.8 && ratio <= 1.2) {
          enhanced += 0.1; // 提升10%置信度
        }
      }
    }

    // 如果是奖金收入，且符合用户模式
    if (type == TransactionType.income &&
        category == TransactionCategory.bonus) {
      if (date != null && bonusMonths.contains(date.month)) {
        enhanced += 0.1; // 提升10%置信度
      }
    }

    // 限制在0.0-1.0范围内
    return enhanced.clamp(0.0, 1.0);
  }

  /// 获取转账默认方向
  String? getDefaultTransferDirection() {
    return transferDirectionPreference;
  }

  /// 更新转账方向偏好
  UserIncomeProfile updateTransferDirectionPreference(String direction) {
    return copyWith(transferDirectionPreference: direction);
  }

  @override
  List<Object?> get props => [
        avgMonthlySalary,
        bonusMonths,
        commonIncomeTypes,
        salaryDayPattern,
        transactionCount,
        transferDirectionPreference,
      ];
}

