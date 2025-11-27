import 'package:flutter_test/flutter_test.dart';
import 'package:your_finance_flutter/features/insights/models/monthly_health.dart';

void main() {
  late MonthlyHealthScore healthyScore;
  late MonthlyHealthScore unhealthyScore;
  late MonthlyHealthScore balancedScore;

  setUp(() {
    healthyScore = MonthlyHealthScore(
      id: 'healthy_2025_11',
      month: DateTime(2025, 11),
      grade: LetterGrade.A,
      score: 92.5,
      diagnosis: '本月财务状况良好，生存支出比例适中，建议继续保持。',
      factors: [
        HealthFactor(
          name: '预算控制',
          impact: 0.8,
          description: '支出控制在预算范围内',
        ),
        HealthFactor(
          name: '生存支出比例',
          impact: 0.6,
          description: '生存支出占总支出的42%，比例适中',
        ),
      ],
      recommendations: [
        '继续保持良好的消费习惯',
        '考虑增加储蓄比例',
      ],
      metrics: {
        'savingsRate': 0.2,
        'spendingRatio': 0.8,
        'survivalPercentage': 0.417,
        'lifestylePercentage': 0.583,
        'totalIncome': 15000.0,
        'totalSpending': 12000.0,
      },
    );

    unhealthyScore = MonthlyHealthScore(
      id: 'unhealthy_2025_11',
      month: DateTime(2025, 11),
      grade: LetterGrade.D,
      score: 45.0,
      diagnosis: '本月支出严重超预算，生活支出占比过高，建议立即调整消费结构。',
      factors: [
        HealthFactor(
          name: '预算超支',
          impact: -0.9,
          description: '支出超过收入25%',
        ),
        HealthFactor(
          name: '生活支出过高',
          impact: -0.7,
          description: '生活支出占61%，严重偏高',
        ),
      ],
      recommendations: [
        '立即削减非必要支出',
        '制定严格的预算计划',
        '寻求额外的收入来源',
      ],
      metrics: {
        'savingsRate': -0.125,
        'spendingRatio': 1.125,
        'survivalPercentage': 0.389,
        'lifestylePercentage': 0.611,
        'totalIncome': 8000.0,
        'totalSpending': 9000.0,
      },
    );

    balancedScore = MonthlyHealthScore(
      id: 'balanced_2025_11',
      month: DateTime(2025, 11),
      grade: LetterGrade.B,
      score: 78.0,
      diagnosis: '本月消费结构合理，生存与生活支出比例均衡，表现稳定。',
      factors: [
        HealthFactor(
          name: '支出比例均衡',
          impact: 0.7,
          description: '生存与生活支出比例合理',
        ),
        HealthFactor(
          name: '预算执行良好',
          impact: 0.5,
          description: '支出控制在合理范围内',
        ),
      ],
      recommendations: [
        '保持当前的消费结构',
        '适当增加储蓄',
      ],
      metrics: {
        'savingsRate': 0.167,
        'spendingRatio': 0.833,
        'survivalPercentage': 0.6,
        'lifestylePercentage': 0.4,
        'totalIncome': 12000.0,
        'totalSpending': 10000.0,
      },
    );
  });

  group('MonthlyHealthScore Model Tests', () {
    test('should have correct properties', () {
      expect(healthyScore.id, 'healthy_2025_11');
      expect(healthyScore.month, DateTime(2025, 11));
      expect(healthyScore.grade, LetterGrade.A);
      expect(healthyScore.score, 92.5);
      expect(healthyScore.diagnosis, isNotEmpty);
      expect(healthyScore.factors, hasLength(2));
      expect(healthyScore.recommendations, hasLength(2));
      expect(healthyScore.metrics, isNotEmpty);
    });

    test('should calculate savings rate from metrics', () {
      expect(healthyScore.metrics['savingsRate'], 0.2);
      expect(unhealthyScore.metrics['savingsRate'], -0.125);
      expect(balancedScore.metrics['savingsRate'], 0.167);
    });

    test('should calculate spending ratio from metrics', () {
      expect(healthyScore.metrics['spendingRatio'], 0.8);
      expect(unhealthyScore.metrics['spendingRatio'], 1.125);
      expect(balancedScore.metrics['spendingRatio'], 0.833);
    });

    test('should have survival and lifestyle percentages', () {
      expect(healthyScore.metrics['survivalPercentage'], 0.417);
      expect(unhealthyScore.metrics['survivalPercentage'], 0.389);
      expect(balancedScore.metrics['survivalPercentage'], 0.6);
    });

    test('should have total income and spending metrics', () {
      expect(healthyScore.metrics['totalIncome'], 15000.0);
      expect(healthyScore.metrics['totalSpending'], 12000.0);
      expect(unhealthyScore.metrics['totalIncome'], 8000.0);
      expect(unhealthyScore.metrics['totalSpending'], 9000.0);
    });

    test('should have correct equality', () {
      final identicalScore = MonthlyHealthScore(
        id: 'healthy_2025_11',
        month: DateTime(2025, 11),
        grade: LetterGrade.A,
        score: 92.5,
        diagnosis: '本月财务状况良好，生存支出比例适中，建议继续保持。',
        factors: [
          HealthFactor(
            name: '预算控制',
            impact: 0.8,
            description: '支出控制在预算范围内',
          ),
          HealthFactor(
            name: '生存支出比例',
            impact: 0.6,
            description: '生存支出占总支出的42%，比例适中',
          ),
        ],
        recommendations: [
          '继续保持良好的消费习惯',
          '考虑增加储蓄比例',
        ],
        metrics: {
          'savingsRate': 0.2,
          'spendingRatio': 0.8,
          'survivalPercentage': 0.417,
          'lifestylePercentage': 0.583,
          'totalIncome': 15000.0,
          'totalSpending': 12000.0,
        },
      );

      expect(healthyScore, equals(identicalScore));
    });

    test('should be different when properties change', () {
      final differentScore = MonthlyHealthScore(
        id: 'different_2025_11',
        month: DateTime(2025, 11),
        grade: LetterGrade.A,
        score: 92.5,
        diagnosis: '本月财务状况良好，生存支出比例适中，建议继续保持。',
        factors: healthyScore.factors,
        recommendations: healthyScore.recommendations,
        metrics: healthyScore.metrics,
      );

      expect(healthyScore, isNot(equals(differentScore)));
    });

    group('LetterGrade enum values', () {
      test('should have correct grade values', () {
        expect(LetterGrade.A.index, 0);
        expect(LetterGrade.B.index, 1);
        expect(LetterGrade.C.index, 2);
        expect(LetterGrade.D.index, 3);
        expect(LetterGrade.F.index, 4);
      });

      test('should map grades to scores correctly', () {
        expect(healthyScore.grade, LetterGrade.A);
        expect(unhealthyScore.grade, LetterGrade.D);
        expect(balancedScore.grade, LetterGrade.B);
      });
    });

    group('HealthFactor tests', () {
      test('should create health factor correctly', () {
        final factor = HealthFactor(
          name: '预算控制',
          impact: 0.8,
          description: '支出控制在预算范围内',
        );

        expect(factor.name, '预算控制');
        expect(factor.impact, 0.8);
        expect(factor.description, '支出控制在预算范围内');
      });

      test('should handle positive and negative impacts', () {
        final positiveFactor = healthyScore.factors.first;
        final negativeFactor = unhealthyScore.factors.first;

        expect(positiveFactor.impact, greaterThan(0));
        expect(negativeFactor.impact, lessThan(0));
      });

      test('should have descriptive names', () {
        for (final factor in healthyScore.factors) {
          expect(factor.name, isNotEmpty);
          expect(factor.description, isNotEmpty);
        }
      });
    });

    group('Recommendations tests', () {
      test('should provide actionable recommendations', () {
        expect(healthyScore.recommendations, hasLength(2));
        expect(unhealthyScore.recommendations, hasLength(3));
        expect(balancedScore.recommendations, hasLength(2));
      });

      test('should have meaningful recommendations', () {
        for (final recommendation in healthyScore.recommendations) {
          expect(recommendation, isNotEmpty);
        }
      });
    });

    group('Metrics validation', () {
      test('should have all required metrics', () {
        expect(healthyScore.metrics.containsKey('savingsRate'), true);
        expect(healthyScore.metrics.containsKey('spendingRatio'), true);
        expect(healthyScore.metrics.containsKey('survivalPercentage'), true);
        expect(healthyScore.metrics.containsKey('lifestylePercentage'), true);
        expect(healthyScore.metrics.containsKey('totalIncome'), true);
        expect(healthyScore.metrics.containsKey('totalSpending'), true);
      });

      test('should have reasonable metric values', () {
        expect(healthyScore.metrics['savingsRate'], greaterThan(0));
        expect(healthyScore.metrics['spendingRatio'], lessThan(1));
        expect(unhealthyScore.metrics['savingsRate'], lessThan(0));
        expect(unhealthyScore.metrics['spendingRatio'], greaterThan(1));
      });
    });

    group('Edge cases', () {
      test('should handle zero score', () {
        final zeroScore = MonthlyHealthScore(
          id: 'zero_2025_11',
          month: DateTime(2025, 11),
          grade: LetterGrade.F,
          score: 0.0,
          diagnosis: '严重财务危机',
          factors: [],
          recommendations: ['立即寻求专业帮助'],
          metrics: {},
        );

        expect(zeroScore.score, 0.0);
        expect(zeroScore.grade, LetterGrade.F);
      });

      test('should handle perfect score', () {
        final perfectScore = MonthlyHealthScore(
          id: 'perfect_2025_11',
          month: DateTime(2025, 11),
          grade: LetterGrade.A,
          score: 100.0,
          diagnosis: '完美财务状况',
          factors: [],
          recommendations: ['保持现状'],
          metrics: {},
        );

        expect(perfectScore.score, 100.0);
        expect(perfectScore.grade, LetterGrade.A);
      });

      test('should handle empty factors and recommendations', () {
        final minimalScore = MonthlyHealthScore(
          id: 'minimal_2025_11',
          month: DateTime(2025, 11),
          grade: LetterGrade.C,
          score: 70.0,
          diagnosis: '一般财务状况',
          factors: [],
          recommendations: [],
          metrics: {},
        );

        expect(minimalScore.factors, isEmpty);
        expect(minimalScore.recommendations, isEmpty);
      });
    });
  });
}