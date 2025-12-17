import 'package:flutter_test/flutter_test.dart';
import 'package:your_finance_flutter/features/insights/models/monthly_health.dart';
import 'package:your_finance_flutter/features/insights/services/health_analysis_service.dart';

void main() {
  late HealthAnalysisService service;

  setUp(() {
    service = HealthAnalysisService.instance;
  });

  group('HealthAnalysisService Tests', () {
    test('should analyze survival vs lifestyle breakdown correctly', () async {
      final transactions = [
        {'category': '住房', 'amount': 3000.0},
        {'category': '餐饮', 'amount': 2000.0},
        {'category': '交通', 'amount': 500.0},
        {'category': '娱乐', 'amount': 1500.0},
        {'category': '购物', 'amount': 1000.0},
      ];

      final result = await service.analyzeSurvivalLifestyleBreakdown(
        totalIncome: 10000.0,
        totalSpending: 8000.0,
        categorizedTransactions: transactions,
      );

      expect(result['survivalSpending'], 3500.0); // 住房 + 交通
      expect(result['lifestyleSpending'], 4500.0); // 餐饮 + 娱乐 + 购物
      expect(result['survivalPercentage'], 0.4375); // 3500/8000
      expect(result['lifestylePercentage'], 0.5625); // 4500/8000
      expect(result['pattern'], 'lifestyle_leaning');
    });

    test('should identify balanced spending pattern', () async {
      final transactions = [
        {'category': '住房', 'amount': 2500.0},
        {'category': '交通', 'amount': 500.0},
        {'category': '餐饮', 'amount': 1500.0},
        {'category': '娱乐', 'amount': 1000.0},
      ];

      final result = await service.analyzeSurvivalLifestyleBreakdown(
        totalIncome: 10000.0,
        totalSpending: 5500.0,
        categorizedTransactions: transactions,
      );

      expect(result['survivalSpending'], 3000.0); // 住房 + 交通
      expect(result['lifestyleSpending'], 2500.0); // 餐饮 + 娱乐
      expect(result['pattern'], 'balanced');
    });

    test('should identify survival-heavy pattern', () async {
      final transactions = [
        {'category': '住房', 'amount': 4000.0},
        {'category': '交通', 'amount': 1000.0},
        {'category': '水电', 'amount': 500.0},
        {'category': '通讯', 'amount': 300.0},
        {'category': '餐饮', 'amount': 800.0},
      ];

      final result = await service.analyzeSurvivalLifestyleBreakdown(
        totalIncome: 10000.0,
        totalSpending: 6600.0,
        categorizedTransactions: transactions,
      );

      expect(result['survivalSpending'], 5800.0);
      expect(result['lifestyleSpending'], 800.0);
      expect(result['survivalPercentage'],
          closeTo(0.879, 0.01)); // 5800/6600 ≈ 0.879
      expect(result['pattern'], 'survival_heavy');
    });

    test('should identify lifestyle-heavy pattern', () async {
      final transactions = [
        {'category': '住房', 'amount': 1000.0},
        {'category': '餐饮', 'amount': 3000.0},
        {'category': '娱乐', 'amount': 2500.0},
        {'category': '购物', 'amount': 2000.0},
        {'category': '旅行', 'amount': 1500.0},
      ];

      final result = await service.analyzeSurvivalLifestyleBreakdown(
        totalIncome: 10000.0,
        totalSpending: 10000.0,
        categorizedTransactions: transactions,
      );

      expect(result['survivalSpending'], 1000.0);
      expect(result['lifestyleSpending'], 9000.0);
      expect(result['survivalPercentage'], 0.1);
      expect(result['lifestylePercentage'], 0.9);
      expect(result['pattern'], 'lifestyle_heavy');
    });

    test('should calculate monthly health score correctly', () async {
      final transactions = [
        {'category': '住房', 'amount': 2500.0},
        {'category': '交通', 'amount': 500.0},
        {'category': '餐饮', 'amount': 1500.0},
        {'category': '娱乐', 'amount': 800.0},
        {'category': '购物', 'amount': 700.0},
      ];

      final healthScore = await service.calculateMonthlyHealthScore(
        month: DateTime(2025, 11),
        totalIncome: 10000.0,
        totalSpending: 6000.0,
        categorizedTransactions: transactions,
      );

      expect(healthScore.id, 'health_2025_11');
      expect(healthScore.month, DateTime(2025, 11));
      expect(healthScore.score, greaterThan(0));
      expect(healthScore.score, lessThanOrEqualTo(100));
      expect(healthScore.factors, isNotEmpty);
      expect(healthScore.recommendations, isNotEmpty);
      expect(healthScore.metrics, isNotEmpty);
    });

    test('should assign correct grades based on score', () async {
      final transactions = [
        {'category': '住房', 'amount': 2000.0},
        {'category': '餐饮', 'amount': 1000.0},
      ];

      // Test A grade (high score)
      final highScore = await service.calculateMonthlyHealthScore(
        month: DateTime(2025, 11),
        totalIncome: 10000.0,
        totalSpending: 3000.0, // 70% savings rate
        categorizedTransactions: transactions,
      );

      expect(highScore.grade, LetterGrade.A);
      expect(highScore.score, closeTo(90, 10)); // Should be high

      // Test D grade (low score)
      final lowScore = await service.calculateMonthlyHealthScore(
        month: DateTime(2025, 11),
        totalIncome: 5000.0,
        totalSpending: 6000.0, // Overspending
        categorizedTransactions: transactions,
      );

      expect(lowScore.grade, LetterGrade.F);
      expect(lowScore.score, lessThan(60));
    });

    test('should generate appropriate diagnosis', () async {
      final transactions = [
        {'category': '住房', 'amount': 2000.0},
        {'category': '餐饮', 'amount': 1000.0},
      ];

      final highScore = await service.calculateMonthlyHealthScore(
        month: DateTime(2025, 11),
        totalIncome: 10000.0,
        totalSpending: 3000.0,
        categorizedTransactions: transactions,
      );

      expect(highScore.diagnosis, contains('优秀'));
      expect(highScore.diagnosis, contains('良好'));
    });

    test('should provide actionable recommendations', () async {
      final transactions = [
        {'category': '住房', 'amount': 2000.0},
        {'category': '餐饮', 'amount': 1000.0},
      ];

      final lowScore = await service.calculateMonthlyHealthScore(
        month: DateTime(2025, 11),
        totalIncome: 5000.0,
        totalSpending: 6000.0,
        categorizedTransactions: transactions,
      );

      expect(lowScore.recommendations, hasLength(greaterThan(0)));
      expect(lowScore.recommendations.first, isNotEmpty);
    });

    test('should calculate metrics correctly', () async {
      final transactions = [
        {'category': '住房', 'amount': 3000.0},
        {'category': '餐饮', 'amount': 2000.0},
      ];

      final healthScore = await service.calculateMonthlyHealthScore(
        month: DateTime(2025, 11),
        totalIncome: 10000.0,
        totalSpending: 5000.0,
        categorizedTransactions: transactions,
      );

      expect(
          healthScore.metrics['savingsRate'], 0.5); // (10000-5000)/10000 = 0.5
      expect(healthScore.metrics['spendingRatio'], 0.5); // 5000/10000 = 0.5
      expect(healthScore.metrics['survivalPercentage'], 0.6); // 3000/5000 = 0.6
      expect(
          healthScore.metrics['lifestylePercentage'], 0.4); // 2000/5000 = 0.4
      expect(healthScore.metrics['totalIncome'], 10000.0);
      expect(healthScore.metrics['totalSpending'], 5000.0);
    });

    test('should handle edge cases correctly', () async {
      // Test with no transactions
      final emptyScore = await service.calculateMonthlyHealthScore(
        month: DateTime(2025, 11),
        totalIncome: 10000.0,
        totalSpending: 0.0,
        categorizedTransactions: [],
      );

      expect(emptyScore.score,
          closeTo(100, 10)); // Should get high score for no spending

      // Test with zero income
      final zeroIncomeScore = await service.calculateMonthlyHealthScore(
        month: DateTime(2025, 11),
        totalIncome: 0.0,
        totalSpending: 1000.0,
        categorizedTransactions: [
          {'category': '餐饮', 'amount': 1000.0}
        ],
      );

      expect(zeroIncomeScore.score, lessThan(50)); // Should be low score
    });

    group('Category analysis', () {
      test('should correctly categorize transactions', () async {
        final transactions = [
          {'category': '住房', 'amount': 3000.0}, // Survival
          {'category': '房租', 'amount': 2000.0}, // Survival
          {'category': '水电', 'amount': 500.0}, // Survival
          {'category': '餐饮', 'amount': 1500.0}, // Lifestyle
          {'category': '娱乐', 'amount': 1000.0}, // Lifestyle
          {'category': '购物', 'amount': 800.0}, // Lifestyle
        ];

        final result = await service.analyzeSurvivalLifestyleBreakdown(
          totalIncome: 10000.0,
          totalSpending: 8800.0,
          categorizedTransactions: transactions,
        );

        final categories = result['categories'] as Map<String, dynamic>;

        expect(categories['住房']['type'], 'survival');
        expect(categories['房租']['type'], 'survival');
        expect(categories['水电']['type'], 'survival');
        expect(categories['餐饮']['type'], 'lifestyle');
        expect(categories['娱乐']['type'], 'lifestyle');
        expect(categories['购物']['type'], 'lifestyle');

        expect(result['survivalSpending'], 5500.0); // 3000 + 2000 + 500
        expect(result['lifestyleSpending'], 3300.0); // 1500 + 1000 + 800
      });

      test('should aggregate amounts for same category', () async {
        final transactions = [
          {'category': '餐饮', 'amount': 500.0},
          {'category': '餐饮', 'amount': 300.0},
          {'category': '住房', 'amount': 2000.0},
        ];

        final result = await service.analyzeSurvivalLifestyleBreakdown(
          totalIncome: 10000.0,
          totalSpending: 2800.0,
          categorizedTransactions: transactions,
        );

        final categories = result['categories'] as Map<String, dynamic>;

        expect(categories['餐饮']['amount'], 800.0);
        expect(categories['住房']['amount'], 2000.0);
        expect(result['lifestyleSpending'], 800.0);
        expect(result['survivalSpending'], 2000.0);
      });
    });

    group('Pattern analysis', () {
      test('should generate appropriate pattern analysis', () async {
        final balancedTransactions = [
          {'category': '住房', 'amount': 2000.0},
          {'category': '餐饮', 'amount': 2000.0},
        ];

        final result = await service.analyzeSurvivalLifestyleBreakdown(
          totalIncome: 10000.0,
          totalSpending: 4000.0,
          categorizedTransactions: balancedTransactions,
        );

        expect(result['pattern'], 'balanced');
        expect(result['analysis'], contains('均衡'));
        expect(result['analysis'], contains('50%'));
      });

      test('should provide different analysis for different patterns',
          () async {
        // Survival heavy
        final survivalHeavy = await service.analyzeSurvivalLifestyleBreakdown(
          totalIncome: 10000.0,
          totalSpending: 5000.0,
          categorizedTransactions: [
            {'category': '住房', 'amount': 4000.0},
            {'category': '餐饮', 'amount': 1000.0},
          ],
        );

        expect(survivalHeavy['pattern'], 'survival_heavy');
        expect(survivalHeavy['analysis'], contains('过高'));

        // Lifestyle heavy
        final lifestyleHeavy = await service.analyzeSurvivalLifestyleBreakdown(
          totalIncome: 10000.0,
          totalSpending: 5000.0,
          categorizedTransactions: [
            {'category': '住房', 'amount': 500.0},
            {'category': '餐饮', 'amount': 4500.0},
          ],
        );

        expect(lifestyleHeavy['pattern'], 'lifestyle_heavy');
        expect(lifestyleHeavy['analysis'], contains('过高'));
      });
    });
  });
}
