import 'package:your_finance_flutter/features/insights/models/monthly_health.dart';

/// Service for analyzing financial health and providing survival vs lifestyle insights
class HealthAnalysisService {
  HealthAnalysisService._();

  static final HealthAnalysisService _instance = HealthAnalysisService._();

  static HealthAnalysisService get instance => _instance;

  /// Analyze monthly spending to determine survival vs lifestyle breakdown
  Future<Map<String, dynamic>> analyzeSurvivalLifestyleBreakdown({
    required double totalIncome,
    required double totalSpending,
    required List<Map<String, dynamic>> categorizedTransactions,
  }) async {
    // Simulate AI analysis delay
    await Future<void>.delayed(const Duration(milliseconds: 300));

    // Categorize transactions into survival vs lifestyle
    final categorized = _categorizeTransactions(categorizedTransactions);

    final survivalSpending = categorized['survival'] as double;
    final lifestyleSpending = categorized['lifestyle'] as double;

    final survivalPercentage = totalSpending > 0 ? survivalSpending / totalSpending : 0.0;
    final lifestylePercentage = totalSpending > 0 ? lifestyleSpending / totalSpending : 0.0;

    // Determine spending pattern
    final pattern = _determineSpendingPattern(survivalPercentage, lifestylePercentage);

    return {
      'survivalSpending': survivalSpending,
      'lifestyleSpending': lifestyleSpending,
      'survivalPercentage': survivalPercentage,
      'lifestylePercentage': lifestylePercentage,
      'pattern': pattern,
      'analysis': _generatePatternAnalysis(pattern, survivalPercentage, lifestylePercentage),
      'categories': categorized['categories'],
    };
  }

  /// Calculate comprehensive monthly health score
  Future<MonthlyHealthScore> calculateMonthlyHealthScore({
    required DateTime month,
    required double totalIncome,
    required double totalSpending,
    required List<Map<String, dynamic>> categorizedTransactions,
  }) async {
    final breakdown = await analyzeSurvivalLifestyleBreakdown(
      totalIncome: totalIncome,
      totalSpending: totalSpending,
      categorizedTransactions: categorizedTransactions,
    );

    final survivalSpending = breakdown['survivalSpending'] as double;
    final lifestyleSpending = breakdown['lifestyleSpending'] as double;
    final pattern = breakdown['pattern'] as String;

    // Calculate base metrics
    final savingsRate = totalIncome > 0 ? (totalIncome - totalSpending) / totalIncome : 0.0;
    final spendingRatio = totalIncome > 0 ? totalSpending / totalIncome : 0.0;

    // Calculate health score (0-100)
    final score = _calculateHealthScore(
      totalIncome: totalIncome,
      savingsRate: savingsRate,
      spendingRatio: spendingRatio,
      pattern: pattern,
      survivalPercentage: breakdown['survivalPercentage'] as double,
    );

    // Determine grade
    final grade = _calculateGrade(score);

    // Generate factors and diagnosis
    final factors = _generateHealthFactors(
      savingsRate: savingsRate,
      spendingRatio: spendingRatio,
      pattern: pattern,
    );

    final diagnosis = _generateDiagnosis(score, pattern, factors);

    final recommendations = _generateRecommendations(score, pattern, factors);

    // Create metrics map
    final metrics = <String, double>{
      'savingsRate': savingsRate,
      'spendingRatio': spendingRatio,
      'survivalPercentage': breakdown['survivalPercentage'] as double,
      'lifestylePercentage': breakdown['lifestylePercentage'] as double,
      'totalIncome': totalIncome,
      'totalSpending': totalSpending,
      'survivalSpending': survivalSpending,
      'lifestyleSpending': lifestyleSpending,
    };

    return MonthlyHealthScore(
      id: 'health_${month.year}_${month.month.toString().padLeft(2, '0')}',
      month: month,
      grade: grade,
      score: score,
      diagnosis: diagnosis,
      factors: factors,
      recommendations: recommendations,
      metrics: metrics,
    );
  }

  Map<String, dynamic> _categorizeTransactions(List<Map<String, dynamic>> transactions) {
    double survivalSpending = 0.0;
    double lifestyleSpending = 0.0;
    final categories = <String, Map<String, dynamic>>{};

    // Define survival vs lifestyle categories
    const survivalCategories = [
      '住房', '房租', '物业费', '水电', '燃气', '暖气',
      '交通', '公交', '地铁', '打车', '加油',
      '通讯', '电话费', '网费',
      '医疗', '药品', '保险',
      '教育', '学费', '书本',
    ];

    for (final transaction in transactions) {
      final category = transaction['category'] as String;
      final amount = transaction['amount'] as double;

      if (survivalCategories.contains(category) || survivalCategories.any((c) => category.contains(c))) {
        survivalSpending += amount;
        categories[category] = {
          'amount': (categories[category]?['amount'] ?? 0.0) + amount,
          'type': 'survival',
        };
      } else {
        lifestyleSpending += amount;
        categories[category] = {
          'amount': (categories[category]?['amount'] ?? 0.0) + amount,
          'type': 'lifestyle',
        };
      }
    }

    return {
      'survival': survivalSpending,
      'lifestyle': lifestyleSpending,
      'categories': categories,
    };
  }

  String _determineSpendingPattern(double survivalPercent, double lifestylePercent) {
    if (survivalPercent > 0.75) return 'survival_heavy';
    if (lifestylePercent > 0.75) return 'lifestyle_heavy';
    if ((survivalPercent - lifestylePercent).abs() < 0.1) {
      return 'balanced';
    }
    if (survivalPercent > lifestylePercent) return 'survival_leaning';
    return 'lifestyle_leaning';
  }

  String _generatePatternAnalysis(String pattern, double survivalPercent, double lifestylePercent) {
    switch (pattern) {
      case 'survival_heavy':
        return '生存支出占比过高 (${(survivalPercent * 100).round()}%)，建议优化生活支出比例。';
      case 'lifestyle_heavy':
        return '生活支出占比过高 (${(lifestylePercent * 100).round()}%)，可能影响财务稳定性。';
      case 'balanced':
        return '生存与生活支出比例均衡 (${(survivalPercent * 100).round()}% : ${(lifestylePercent * 100).round()}%)。';
      case 'survival_leaning':
        return '偏向生存支出 (${(survivalPercent * 100).round()}% : ${(lifestylePercent * 100).round()}%)，财务较为保守。';
      case 'lifestyle_leaning':
        return '偏向生活支出 (${(survivalPercent * 100).round()}% : ${(lifestylePercent * 100).round()}%)，生活质量较好。';
      default:
        return '支出结构分析中...';
    }
  }

  double _calculateHealthScore({
    required double totalIncome,
    required double savingsRate,
    required double spendingRatio,
    required String pattern,
    required double survivalPercentage,
  }) {
    double score = 50.0; // Base score

    // Savings rate impact (most important)
    if (totalIncome == 0) {
      score = 0; // No income = 0 score
    } else {
      if (savingsRate >= 0.2) score += 25; // Good savings
      else if (savingsRate >= 0.1) score += 15; // Decent savings
      else if (savingsRate >= 0) score += 5; // Some savings
      else score -= (savingsRate.abs() * 100).clamp(0, 50); // Overspending penalty
    }

    // Spending ratio impact
    if (spendingRatio <= 0.8) score += 15; // Under 80% of income
    else if (spendingRatio <= 1.0) score += 5; // Under 100% of income
    else score -= ((spendingRatio - 1.0) * 20).clamp(0, 20); // Overspending penalty

    // Pattern impact
    switch (pattern) {
      case 'balanced':
        score += 10;
        break;
      case 'survival_leaning':
        score += 5;
        break;
      case 'lifestyle_leaning':
        score -= 5;
        break;
      case 'survival_heavy':
        score -= 10;
        break;
      case 'lifestyle_heavy':
        score -= 15;
        break;
    }

    return score.clamp(0.0, 100.0);
  }

  LetterGrade _calculateGrade(double score) {
    if (score >= 90) return LetterGrade.A;
    if (score >= 80) return LetterGrade.B;
    if (score >= 70) return LetterGrade.C;
    if (score >= 60) return LetterGrade.D;
    return LetterGrade.F;
  }

  List<HealthFactor> _generateHealthFactors({
    required double savingsRate,
    required double spendingRatio,
    required String pattern,
  }) {
    final factors = <HealthFactor>[];

    // Savings rate factor
    if (savingsRate >= 0.2) {
      factors.add(HealthFactor(
        name: '储蓄充足',
        impact: 0.8,
        description: '月储蓄率 ${(savingsRate * 100).round()}%，财务基础稳固',
      ));
    } else if (savingsRate >= 0) {
      factors.add(HealthFactor(
        name: '储蓄一般',
        impact: 0.4,
        description: '月储蓄率 ${(savingsRate * 100).round()}%，有改善空间',
      ));
    } else {
      factors.add(HealthFactor(
        name: '支出超支',
        impact: -0.9,
        description: '月支出超出收入 ${(savingsRate.abs() * 100).round()}%，需要立即调整',
      ));
    }

    // Spending pattern factor
    switch (pattern) {
      case 'balanced':
        factors.add(HealthFactor(
          name: '支出均衡',
          impact: 0.6,
          description: '生存与生活支出比例合理，消费结构健康',
        ));
        break;
      case 'survival_heavy':
        factors.add(HealthFactor(
          name: '生存支出过高',
          impact: -0.7,
          description: '生存支出占比过高，可能影响生活质量',
        ));
        break;
      case 'lifestyle_heavy':
        factors.add(HealthFactor(
          name: '生活支出过高',
          impact: -0.8,
          description: '生活支出占比过高，可能影响财务稳定性',
        ));
        break;
    }

    return factors;
  }

  String _generateDiagnosis(double score, String pattern, List<HealthFactor> factors) {
    final grade = _calculateGrade(score);

    switch (grade) {
      case LetterGrade.A:
        return '本月财务状况优秀，各项指标表现良好，建议继续保持当前的理财习惯。';
      case LetterGrade.B:
        return '本月财务状况良好，整体表现稳定，但某些方面仍有改善空间。';
      case LetterGrade.C:
        return '本月财务状况一般，各项指标基本达标，但需要关注潜在风险。';
      case LetterGrade.D:
        return '本月财务状况不佳，多项指标偏离合理范围，建议立即采取调整措施。';
      case LetterGrade.F:
        return '本月财务状况严重堪忧，存在重大财务风险，需要专业指导和紧急调整。';
    }
  }

  List<String> _generateRecommendations(double score, String pattern, List<HealthFactor> factors) {
    final recommendations = <String>[];

    if (score < 60) {
      recommendations.addAll([
        '立即制定详细的预算计划',
        '削减非必要支出，优先保证基本生活需求',
        '寻求额外的收入来源',
        '咨询专业财务顾问',
      ]);
    } else if (score < 80) {
      recommendations.addAll([
        '优化支出结构，平衡生存与生活支出',
        '增加储蓄比例，建立应急基金',
        '定期跟踪收支情况，及时调整',
      ]);
    } else {
      recommendations.addAll([
        '保持良好的财务习惯',
        '考虑投资理财，提高资产收益',
        '为长期目标制定更详细的计划',
      ]);
    }

    // Pattern-specific recommendations
    switch (pattern) {
      case 'survival_heavy':
        recommendations.add('适当增加生活支出，提升生活质量');
        break;
      case 'lifestyle_heavy':
        recommendations.add('控制生活支出比例，增加储蓄和投资');
        break;
    }

    return recommendations.take(5).toList(); // Limit to 5 recommendations
  }
}
