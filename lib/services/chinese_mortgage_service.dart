import 'dart:math';

/// 房贷类型
enum MortgageType {
  commercial('商业贷款'),
  gongjijin('公积金贷款'),
  combined('组合贷款');

  const MortgageType(this.displayName);
  final String displayName;
}

/// 中国房贷计算服务
/// 支持组合贷、商业贷、公积金贷等中国特色房贷模式
class ChineseMortgageService {
  factory ChineseMortgageService() => _instance;
  ChineseMortgageService._internal();
  static final ChineseMortgageService _instance =
      ChineseMortgageService._internal();

  /// 当前中国贷款利率（2024年最新）
  static const double currentCommercialRate = 0.0305; // 3.05% 商业贷款利率
  static const double currentGongjijinRate = 0.026; // 2.6% 公积金贷款利率

  /// 计算房贷月供
  MortgageCalculationResult calculateMortgage({
    required double totalAmount, // 贷款总额
    required MortgageType type, // 贷款类型
    required int years, // 贷款年限
    double? commercialRate, // 商业贷款利率（可选，默认使用当前利率）
    double? gongjijinRate, // 公积金贷款利率（可选，默认使用当前利率）
    double? commercialAmount, // 商业贷款金额（组合贷时使用）
    double? gongjijinAmount, // 公积金贷款金额（组合贷时使用）
  }) {
    switch (type) {
      case MortgageType.commercial:
        return _calculateCommercialMortgage(
          totalAmount,
          commercialRate ?? currentCommercialRate,
          years,
        );
      case MortgageType.gongjijin:
        return _calculateGongjijinMortgage(
          totalAmount,
          gongjijinRate ?? currentGongjijinRate,
          years,
        );
      case MortgageType.combined:
        return _calculateCombinedMortgage(
          commercialAmount ?? 0,
          gongjijinAmount ?? 0,
          commercialRate ?? currentCommercialRate,
          gongjijinRate ?? currentGongjijinRate,
          years,
        );
    }
  }

  /// 计算商业贷款
  MortgageCalculationResult _calculateCommercialMortgage(
    double amount,
    double rate,
    int years,
  ) {
    final monthlyRate = rate / 12;
    final months = years * 12;

    final monthlyPayment =
        _calculateMonthlyPayment(amount, monthlyRate, months);
    final totalPayment = monthlyPayment * months;
    final totalInterest = totalPayment - amount;

    return MortgageCalculationResult(
      type: MortgageType.commercial,
      totalAmount: amount,
      monthlyPayment: monthlyPayment,
      totalPayment: totalPayment,
      totalInterest: totalInterest,
      years: years,
      rate: rate,
      commercialAmount: amount,
      gongjijinAmount: 0,
      commercialRate: rate,
      gongjijinRate: 0,
      paymentSchedule: _generatePaymentSchedule(
        amount,
        monthlyPayment,
        monthlyRate,
        months,
        '商业贷款',
      ),
    );
  }

  /// 计算公积金贷款
  MortgageCalculationResult _calculateGongjijinMortgage(
    double amount,
    double rate,
    int years,
  ) {
    final monthlyRate = rate / 12;
    final months = years * 12;

    final monthlyPayment =
        _calculateMonthlyPayment(amount, monthlyRate, months);
    final totalPayment = monthlyPayment * months;
    final totalInterest = totalPayment - amount;

    return MortgageCalculationResult(
      type: MortgageType.gongjijin,
      totalAmount: amount,
      monthlyPayment: monthlyPayment,
      totalPayment: totalPayment,
      totalInterest: totalInterest,
      years: years,
      rate: rate,
      commercialAmount: 0,
      gongjijinAmount: amount,
      commercialRate: 0,
      gongjijinRate: rate,
      paymentSchedule: _generatePaymentSchedule(
        amount,
        monthlyPayment,
        monthlyRate,
        months,
        '公积金贷款',
      ),
    );
  }

  /// 计算组合贷款
  MortgageCalculationResult _calculateCombinedMortgage(
    double commercialAmount,
    double gongjijinAmount,
    double commercialRate,
    double gongjijinRate,
    int years,
  ) {
    final totalAmount = commercialAmount + gongjijinAmount;

    // 计算商业贷款月供
    final commercialMonthlyRate = commercialRate / 12;
    final months = years * 12;
    final commercialMonthlyPayment = _calculateMonthlyPayment(
      commercialAmount,
      commercialMonthlyRate,
      months,
    );

    // 计算公积金贷款月供
    final gongjijinMonthlyRate = gongjijinRate / 12;
    final gongjijinMonthlyPayment = _calculateMonthlyPayment(
      gongjijinAmount,
      gongjijinMonthlyRate,
      months,
    );

    // 总月供
    final totalMonthlyPayment =
        commercialMonthlyPayment + gongjijinMonthlyPayment;

    // 计算总还款和总利息
    final commercialTotalPayment = commercialMonthlyPayment * months;
    final gongjijinTotalPayment = gongjijinMonthlyPayment * months;
    final totalPayment = commercialTotalPayment + gongjijinTotalPayment;
    final totalInterest = totalPayment - totalAmount;

    // 计算加权平均利率
    final weightedRate =
        (commercialAmount * commercialRate + gongjijinAmount * gongjijinRate) /
            totalAmount;

    return MortgageCalculationResult(
      type: MortgageType.combined,
      totalAmount: totalAmount,
      monthlyPayment: totalMonthlyPayment,
      totalPayment: totalPayment,
      totalInterest: totalInterest,
      years: years,
      rate: weightedRate,
      commercialAmount: commercialAmount,
      gongjijinAmount: gongjijinAmount,
      commercialRate: commercialRate,
      gongjijinRate: gongjijinRate,
      paymentSchedule: _generateCombinedPaymentSchedule(
        commercialAmount,
        gongjijinAmount,
        commercialMonthlyPayment,
        gongjijinMonthlyPayment,
        commercialMonthlyRate,
        gongjijinMonthlyRate,
        months,
      ),
    );
  }

  /// 计算等额本息月供
  double _calculateMonthlyPayment(
    double principal,
    double monthlyRate,
    int months,
  ) {
    if (monthlyRate == 0) return principal / months;

    return principal *
        monthlyRate *
        pow(1 + monthlyRate, months) /
        (pow(1 + monthlyRate, months) - 1);
  }

  /// 生成还款计划表（单一贷款）
  List<PaymentScheduleItem> _generatePaymentSchedule(
    double principal,
    double monthlyPayment,
    double monthlyRate,
    int months,
    String loanType,
  ) {
    final schedule = <PaymentScheduleItem>[];
    var remainingPrincipal = principal;

    for (var month = 1; month <= months; month++) {
      final interestPayment = remainingPrincipal * monthlyRate;
      final principalPayment = monthlyPayment - interestPayment;
      remainingPrincipal -= principalPayment;

      schedule.add(
        PaymentScheduleItem(
          month: month,
          paymentDate: DateTime.now().add(Duration(days: 30 * month)),
          monthlyPayment: monthlyPayment,
          principalPayment: principalPayment,
          interestPayment: interestPayment,
          remainingPrincipal: max(0, remainingPrincipal),
          loanType: loanType,
        ),
      );
    }

    return schedule;
  }

  /// 生成组合贷款还款计划表
  List<PaymentScheduleItem> _generateCombinedPaymentSchedule(
    double commercialPrincipal,
    double gongjijinPrincipal,
    double commercialMonthlyPayment,
    double gongjijinMonthlyPayment,
    double commercialMonthlyRate,
    double gongjijinMonthlyRate,
    int months,
  ) {
    final schedule = <PaymentScheduleItem>[];
    var commercialRemaining = commercialPrincipal;
    var gongjijinRemaining = gongjijinPrincipal;

    for (var month = 1; month <= months; month++) {
      // 商业贷款部分
      final commercialInterest = commercialRemaining * commercialMonthlyRate;
      final commercialPrincipalPayment =
          commercialMonthlyPayment - commercialInterest;
      commercialRemaining -= commercialPrincipalPayment;

      // 公积金贷款部分
      final gongjijinInterest = gongjijinRemaining * gongjijinMonthlyRate;
      final gongjijinPrincipalPayment =
          gongjijinMonthlyPayment - gongjijinInterest;
      gongjijinRemaining -= gongjijinPrincipalPayment;

      schedule.add(
        PaymentScheduleItem(
          month: month,
          paymentDate: DateTime.now().add(Duration(days: 30 * month)),
          monthlyPayment: commercialMonthlyPayment + gongjijinMonthlyPayment,
          principalPayment:
              commercialPrincipalPayment + gongjijinPrincipalPayment,
          interestPayment: commercialInterest + gongjijinInterest,
          remainingPrincipal: max(0, commercialRemaining + gongjijinRemaining),
          loanType: '组合贷款',
          commercialPayment: commercialMonthlyPayment,
          gongjijinPayment: gongjijinMonthlyPayment,
          commercialPrincipalPayment: commercialPrincipalPayment,
          gongjijinPrincipalPayment: gongjijinPrincipalPayment,
          commercialInterestPayment: commercialInterest,
          gongjijinInterestPayment: gongjijinInterest,
          commercialRemaining: max(0, commercialRemaining),
          gongjijinRemaining: max(0, gongjijinRemaining),
        ),
      );
    }

    return schedule;
  }

  /// 获取推荐的贷款方案
  List<MortgageRecommendation> getMortgageRecommendations({
    required double propertyValue,
    required double downPaymentRatio, // 首付比例
  }) {
    final loanAmount = propertyValue * (1 - downPaymentRatio);
    final recommendations = <MortgageRecommendation>[];

    // 方案1：纯商业贷款
    final commercialResult = calculateMortgage(
      totalAmount: loanAmount,
      type: MortgageType.commercial,
      years: 30,
    );
    recommendations.add(
      MortgageRecommendation(
        title: '纯商业贷款',
        description: '利率较高但审批简单，适合公积金余额不足的情况',
        result: commercialResult,
        pros: ['审批简单', '额度充足', '放款快'],
        cons: ['利率较高', '总利息多'],
        score: 7,
      ),
    );

    // 方案2：纯公积金贷款（假设有足够公积金）
    if (loanAmount <= 1200000) {
      // 公积金贷款通常有上限
      final gongjijinResult = calculateMortgage(
        totalAmount: loanAmount,
        type: MortgageType.gongjijin,
        years: 30,
      );
      recommendations.add(
        MortgageRecommendation(
          title: '纯公积金贷款',
          description: '利率最低，但额度有限制',
          result: gongjijinResult,
          pros: ['利率最低', '总利息少', '还款压力小'],
          cons: ['额度限制', '审批较慢'],
          score: 9,
        ),
      );
    }

    // 方案3：组合贷款
    final commercialAmount = max(0, loanAmount - 1200000); // 公积金最多120万
    final gongjijinAmount = min(loanAmount, 1200000);

    if (commercialAmount > 0 && gongjijinAmount > 0) {
      final combinedResult = calculateMortgage(
        totalAmount: loanAmount,
        type: MortgageType.combined,
        years: 30,
        commercialAmount: commercialAmount.toDouble(),
        gongjijinAmount: gongjijinAmount.toDouble(),
      );
      recommendations.add(
        MortgageRecommendation(
          title: '组合贷款',
          description: '商业贷款+公积金贷款，兼顾利率和额度',
          result: combinedResult,
          pros: ['利率适中', '额度充足', '灵活性强'],
          cons: ['手续复杂', '审批时间长'],
          score: 8,
        ),
      );
    }

    // 按评分排序
    recommendations.sort((a, b) => b.score.compareTo(a.score));
    return recommendations;
  }
}

/// 房贷计算结果
class MortgageCalculationResult {
  // 还款计划表

  MortgageCalculationResult({
    required this.type,
    required this.totalAmount,
    required this.monthlyPayment,
    required this.totalPayment,
    required this.totalInterest,
    required this.years,
    required this.rate,
    required this.commercialAmount,
    required this.gongjijinAmount,
    required this.commercialRate,
    required this.gongjijinRate,
    required this.paymentSchedule,
  });
  final MortgageType type;
  final double totalAmount; // 贷款总额
  final double monthlyPayment; // 月供
  final double totalPayment; // 总还款额
  final double totalInterest; // 总利息
  final int years; // 贷款年限
  final double rate; // 利率（组合贷为加权平均利率）
  final double commercialAmount; // 商业贷款金额
  final double gongjijinAmount; // 公积金贷款金额
  final double commercialRate; // 商业贷款利率
  final double gongjijinRate; // 公积金贷款利率
  final List<PaymentScheduleItem> paymentSchedule;

  /// 获取利率显示文本
  String get rateDisplayText {
    switch (type) {
      case MortgageType.commercial:
        return '商业贷款利率: ${(commercialRate * 100).toStringAsFixed(2)}%';
      case MortgageType.gongjijin:
        return '公积金贷款利率: ${(gongjijinRate * 100).toStringAsFixed(2)}%';
      case MortgageType.combined:
        return '组合贷款利率: 商业${(commercialRate * 100).toStringAsFixed(2)}% + 公积金${(gongjijinRate * 100).toStringAsFixed(2)}%';
    }
  }

  /// 获取月供显示文本
  String get monthlyPaymentDisplayText {
    switch (type) {
      case MortgageType.commercial:
        return '商业贷款月供: ¥${monthlyPayment.toStringAsFixed(0)}';
      case MortgageType.gongjijin:
        return '公积金贷款月供: ¥${monthlyPayment.toStringAsFixed(0)}';
      case MortgageType.combined:
        return '组合贷款月供: ¥${monthlyPayment.toStringAsFixed(0)}';
    }
  }
}

/// 还款计划项
class PaymentScheduleItem {
  // 公积金贷款剩余本金

  PaymentScheduleItem({
    required this.month,
    required this.paymentDate,
    required this.monthlyPayment,
    required this.principalPayment,
    required this.interestPayment,
    required this.remainingPrincipal,
    required this.loanType,
    this.commercialPayment,
    this.gongjijinPayment,
    this.commercialPrincipalPayment,
    this.gongjijinPrincipalPayment,
    this.commercialInterestPayment,
    this.gongjijinInterestPayment,
    this.commercialRemaining,
    this.gongjijinRemaining,
  });
  final int month; // 期数
  final DateTime paymentDate; // 还款日期
  final double monthlyPayment; // 月供
  final double principalPayment; // 本金
  final double interestPayment; // 利息
  final double remainingPrincipal; // 剩余本金
  final String loanType; // 贷款类型

  // 组合贷款专用字段
  final double? commercialPayment; // 商业贷款月供
  final double? gongjijinPayment; // 公积金贷款月供
  final double? commercialPrincipalPayment; // 商业贷款本金
  final double? gongjijinPrincipalPayment; // 公积金贷款本金
  final double? commercialInterestPayment; // 商业贷款利息
  final double? gongjijinInterestPayment; // 公积金贷款利息
  final double? commercialRemaining; // 商业贷款剩余本金
  final double? gongjijinRemaining;
}

/// 房贷推荐方案
class MortgageRecommendation {
  // 推荐评分 1-10

  MortgageRecommendation({
    required this.title,
    required this.description,
    required this.result,
    required this.pros,
    required this.cons,
    required this.score,
  });
  final String title;
  final String description;
  final MortgageCalculationResult result;
  final List<String> pros;
  final List<String> cons;
  final int score;
}
