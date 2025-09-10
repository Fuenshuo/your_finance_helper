import 'dart:math';

import 'package:your_finance_flutter/models/account.dart';

/// 还款计划项
class PaymentScheduleItem {
  // 剩余本金

  PaymentScheduleItem({
    required this.period,
    required this.paymentDate,
    required this.principal,
    required this.interest,
    required this.totalPayment,
    required this.remainingBalance,
  });

  factory PaymentScheduleItem.fromJson(Map<String, dynamic> json) =>
      PaymentScheduleItem(
        period: json['period'] as int,
        paymentDate: DateTime.parse(json['paymentDate'] as String),
        principal: json['principal'] as double,
        interest: json['interest'] as double,
        totalPayment: json['totalPayment'] as double,
        remainingBalance: json['remainingBalance'] as double,
      );
  final int period; // 期数
  final DateTime paymentDate; // 还款日期
  final double principal; // 本金
  final double interest; // 利息
  final double totalPayment; // 总还款额
  final double remainingBalance;

  Map<String, dynamic> toJson() => {
        'period': period,
        'paymentDate': paymentDate.toIso8601String(),
        'principal': principal,
        'interest': interest,
        'totalPayment': totalPayment,
        'remainingBalance': remainingBalance,
      };
}

/// 贷款计算结果
class LoanCalculationResult {
  // 还款计划

  LoanCalculationResult({
    required this.monthlyPayment,
    required this.totalInterest,
    required this.totalPayment,
    required this.paymentSchedule,
  });

  factory LoanCalculationResult.fromJson(Map<String, dynamic> json) =>
      LoanCalculationResult(
        monthlyPayment: json['monthlyPayment'] as double,
        totalInterest: json['totalInterest'] as double,
        totalPayment: json['totalPayment'] as double,
        paymentSchedule: (json['paymentSchedule'] as List<dynamic>)
            .map((e) => PaymentScheduleItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
  final double monthlyPayment; // 月还款额
  final double totalInterest; // 总利息
  final double totalPayment; // 总还款额
  final List<PaymentScheduleItem> paymentSchedule;

  Map<String, dynamic> toJson() => {
        'monthlyPayment': monthlyPayment,
        'totalInterest': totalInterest,
        'totalPayment': totalPayment,
        'paymentSchedule': paymentSchedule.map((e) => e.toJson()).toList(),
      };
}

/// 贷款计算服务
class LoanCalculationService {
  factory LoanCalculationService() => _instance;
  LoanCalculationService._internal();
  static final LoanCalculationService _instance =
      LoanCalculationService._internal();

  /// 计算等额本息还款计划
  LoanCalculationResult calculateEqualPrincipalAndInterest({
    required double loanAmount,
    required double annualRate,
    required int loanTermMonths,
    required DateTime firstPaymentDate,
    double? secondRate, // 组合贷的第二利率
    double? secondAmount, // 组合贷的第二部分金额
  }) {
    final monthlyRate = annualRate / 12 / 100;
    final secondMonthlyRate = secondRate != null ? secondRate / 12 / 100 : 0;

    // 计算月还款额
    final monthlyPayment = _calculateMonthlyPayment(
      loanAmount,
      monthlyRate,
      loanTermMonths,
    );

    final secondMonthlyPayment = secondAmount != null && secondRate != null
        ? _calculateMonthlyPayment(
            secondAmount, secondMonthlyRate.toDouble(), loanTermMonths)
        : 0.0;

    final totalMonthlyPayment = monthlyPayment + secondMonthlyPayment;

    // 生成还款计划
    final paymentSchedule = <PaymentScheduleItem>[];
    var remainingBalance = loanAmount;
    var secondRemainingBalance = secondAmount ?? 0;
    var totalInterest = 0.0;

    for (var period = 1; period <= loanTermMonths; period++) {
      final paymentDate = DateTime(
        firstPaymentDate.year,
        firstPaymentDate.month + period - 1,
        firstPaymentDate.day,
      );

      // 计算当期利息
      final interest = remainingBalance * monthlyRate;
      final secondInterest = secondRemainingBalance * secondMonthlyRate;
      final totalInterestPayment = interest + secondInterest;

      // 计算当期本金
      final principal = monthlyPayment - interest;
      final secondPrincipal = secondMonthlyPayment - secondInterest;

      // 更新剩余本金
      remainingBalance -= principal;
      secondRemainingBalance -= secondPrincipal;

      // 确保最后一期本金正确
      if (period == loanTermMonths) {
        final adjustedPrincipal = principal + remainingBalance;
        remainingBalance = 0;
        secondRemainingBalance = 0;

        paymentSchedule.add(
          PaymentScheduleItem(
            period: period,
            paymentDate: paymentDate,
            principal: adjustedPrincipal,
            interest: interest,
            totalPayment: adjustedPrincipal + interest + secondInterest,
            remainingBalance: 0,
          ),
        );
      } else {
        paymentSchedule.add(
          PaymentScheduleItem(
            period: period,
            paymentDate: paymentDate,
            principal: principal,
            interest: interest,
            totalPayment: monthlyPayment,
            remainingBalance: remainingBalance + secondRemainingBalance,
          ),
        );
      }

      totalInterest += totalInterestPayment;
    }

    return LoanCalculationResult(
      monthlyPayment: totalMonthlyPayment,
      totalInterest: totalInterest,
      totalPayment: loanAmount + (secondAmount ?? 0) + totalInterest,
      paymentSchedule: paymentSchedule,
    );
  }

  /// 计算等额本金还款计划
  LoanCalculationResult calculateEqualPrincipal({
    required double loanAmount,
    required double annualRate,
    required int loanTermMonths,
    required DateTime firstPaymentDate,
    double? secondRate,
    double? secondAmount,
  }) {
    final monthlyRate = annualRate / 12 / 100;
    final secondMonthlyRate = secondRate != null ? secondRate / 12 / 100 : 0;

    // 计算每月本金
    final monthlyPrincipal = loanAmount / loanTermMonths;
    final secondMonthlyPrincipal =
        secondAmount != null ? secondAmount / loanTermMonths : 0;

    // 生成还款计划
    final paymentSchedule = <PaymentScheduleItem>[];
    var remainingBalance = loanAmount;
    var secondRemainingBalance = secondAmount ?? 0;
    var totalInterest = 0.0;

    for (var period = 1; period <= loanTermMonths; period++) {
      final paymentDate = DateTime(
        firstPaymentDate.year,
        firstPaymentDate.month + period - 1,
        firstPaymentDate.day,
      );

      // 计算当期利息
      final interest = remainingBalance * monthlyRate;
      final secondInterest = secondRemainingBalance * secondMonthlyRate;
      final totalInterestPayment = interest + secondInterest;

      // 计算当期总还款额
      final totalPayment =
          monthlyPrincipal + interest + secondMonthlyPrincipal + secondInterest;

      // 更新剩余本金
      remainingBalance -= monthlyPrincipal;
      secondRemainingBalance -= secondMonthlyPrincipal;

      paymentSchedule.add(
        PaymentScheduleItem(
          period: period,
          paymentDate: paymentDate,
          principal: monthlyPrincipal,
          interest: interest,
          totalPayment: totalPayment,
          remainingBalance: remainingBalance + secondRemainingBalance,
        ),
      );

      totalInterest += totalInterestPayment;
    }

    return LoanCalculationResult(
      monthlyPayment:
          paymentSchedule.isNotEmpty ? paymentSchedule.first.totalPayment : 0,
      totalInterest: totalInterest,
      totalPayment: loanAmount + (secondAmount ?? 0) + totalInterest,
      paymentSchedule: paymentSchedule,
    );
  }

  /// 计算月还款额（等额本息）
  double _calculateMonthlyPayment(
      double principal, double monthlyRate, int months) {
    if (monthlyRate == 0) {
      return principal / months;
    }

    final factor = monthlyRate *
        pow(1 + monthlyRate, months) /
        (pow(1 + monthlyRate, months) - 1);
    return principal * factor;
  }

  /// 根据账户信息计算还款计划
  LoanCalculationResult calculateLoanSchedule(Account account) {
    if (!account.isLoanAccount ||
        account.loanAmount == null ||
        account.interestRate == null ||
        account.loanTerm == null ||
        account.firstPaymentDate == null ||
        account.repaymentMethod == null) {
      throw ArgumentError('账户缺少必要的贷款信息');
    }

    switch (account.repaymentMethod!) {
      case RepaymentMethod.equalPrincipalAndInterest:
        return calculateEqualPrincipalAndInterest(
          loanAmount: account.loanAmount!,
          annualRate: account.interestRate!,
          loanTermMonths: account.loanTerm!,
          firstPaymentDate: account.firstPaymentDate!,
          secondRate: account.secondInterestRate,
          secondAmount: account.loanType == LoanType.combinedMortgage
              ? account.loanAmount! * 0.5 // 假设组合贷各占50%
              : null,
        );
      case RepaymentMethod.equalPrincipal:
        return calculateEqualPrincipal(
          loanAmount: account.loanAmount!,
          annualRate: account.interestRate!,
          loanTermMonths: account.loanTerm!,
          firstPaymentDate: account.firstPaymentDate!,
          secondRate: account.secondInterestRate,
          secondAmount: account.loanType == LoanType.combinedMortgage
              ? account.loanAmount! * 0.5
              : null,
        );
      default:
        throw ArgumentError('不支持的还款方式: ${account.repaymentMethod}');
    }
  }

  /// 计算提前还款后的新还款计划
  LoanCalculationResult calculatePrepaymentSchedule({
    required Account account,
    required double prepaymentAmount,
    required DateTime prepaymentDate,
    bool reduceMonthlyPayment = true, // true: 减少月供, false: 缩短期限
  }) {
    final originalSchedule = calculateLoanSchedule(account);

    // 找到提前还款日期对应的期数
    final prepaymentPeriod = originalSchedule.paymentSchedule
        .where((item) => item.paymentDate.isAfter(prepaymentDate))
        .first
        .period;

    // 计算提前还款后的剩余本金
    final remainingBalance = originalSchedule.paymentSchedule
            .firstWhere((item) => item.period == prepaymentPeriod)
            .remainingBalance -
        prepaymentAmount;

    if (remainingBalance <= 0) {
      // 提前还清
      return LoanCalculationResult(
        monthlyPayment: 0,
        totalInterest: originalSchedule.paymentSchedule
            .where((item) => item.period < prepaymentPeriod)
            .fold(0.0, (sum, item) => sum + item.interest),
        totalPayment: account.loanAmount! + prepaymentAmount,
        paymentSchedule: originalSchedule.paymentSchedule
            .where((item) => item.period < prepaymentPeriod)
            .toList(),
      );
    }

    // 重新计算剩余期数的还款计划
    final remainingMonths = account.loanTerm! - prepaymentPeriod + 1;

    if (reduceMonthlyPayment) {
      // 减少月供
      return calculateEqualPrincipalAndInterest(
        loanAmount: remainingBalance,
        annualRate: account.interestRate!,
        loanTermMonths: remainingMonths,
        firstPaymentDate: prepaymentDate,
      );
    } else {
      // 缩短期限
      final newMonthlyPayment = originalSchedule.monthlyPayment;
      final newMonths = (remainingBalance / newMonthlyPayment).ceil();

      return calculateEqualPrincipalAndInterest(
        loanAmount: remainingBalance,
        annualRate: account.interestRate!,
        loanTermMonths: newMonths,
        firstPaymentDate: prepaymentDate,
      );
    }
  }

  /// 验证贷款设置
  LoanValidationResult validateLoanSettings(Account account) {
    final errors = <String>[];

    if (account.type != AccountType.loan) {
      errors.add('账户类型必须为贷款账户');
    }

    if (account.loanType == null) {
      errors.add('必须设置贷款类型');
    }

    if (account.loanAmount == null || account.loanAmount! <= 0) {
      errors.add('贷款总额必须大于0');
    }

    if (account.interestRate == null || account.interestRate! < 0) {
      errors.add('年利率必须大于等于0');
    }

    if (account.loanTerm == null || account.loanTerm! <= 0) {
      errors.add('贷款期限必须大于0');
    }

    if (account.repaymentMethod == null) {
      errors.add('必须设置还款方式');
    }

    if (account.firstPaymentDate == null) {
      errors.add('必须设置首次还款日期');
    }

    if (account.loanType == LoanType.combinedMortgage) {
      if (account.secondInterestRate == null ||
          account.secondInterestRate! < 0) {
        errors.add('组合贷必须设置第二利率');
      }
    }

    return LoanValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }
}

/// 贷款验证结果
class LoanValidationResult {
  LoanValidationResult({
    required this.isValid,
    required this.errors,
  });
  final bool isValid;
  final List<String> errors;
}
