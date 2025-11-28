import 'package:flutter_test/flutter_test.dart';
import 'package:your_finance_flutter/features/insights/models/allocation_data.dart';
import 'package:your_finance_flutter/features/insights/models/health_score.dart';
import 'package:your_finance_flutter/features/insights/services/financial_calculation_service.dart';

void main() {
  late FinancialCalculationService service;

  setUp(() {
    service = FinancialCalculationService();
  });

  group('FinancialCalculationService - Health Score Calculation', () {
    test('calculateHealthScore with flexibleRatio 0.25 returns score 75', () async {
      // Given: flexible spending ratio of 0.25 (25%)
      final allocation = AllocationData(
        fixedAmount: 750.0,    // 75% fixed
        flexibleAmount: 250.0,  // 25% flexible
        period: DateTime.now(),
      );

      // When: calculate health score
      final result = await service.calculateHealthScore(allocation);

      // Then: score should be 100 - (0.25 * 100) = 75
      expect(result.score, 75.0);
      expect(result.grade, HealthGrade.C);
    });

    test('calculateHealthScore with flexibleRatio 0.1 returns score 90 (A grade)', () async {
      // Given: flexible spending ratio of 0.1 (10%)
      final allocation = AllocationData(
        fixedAmount: 900.0,    // 90% fixed
        flexibleAmount: 100.0,  // 10% flexible
        period: DateTime.now(),
      );

      // When: calculate health score
      final result = await service.calculateHealthScore(allocation);

      // Then: score should be 100 - (0.1 * 100) = 90 (A grade)
      expect(result.score, 90.0);
      expect(result.grade, HealthGrade.A);
    });

    test('calculateHealthScore with flexibleRatio 0.8 returns score 20 (F grade)', () async {
      // Given: flexible spending ratio of 0.8 (80%)
      final allocation = AllocationData(
        fixedAmount: 200.0,    // 20% fixed
        flexibleAmount: 800.0,  // 80% flexible
        period: DateTime.now(),
      );

      // When: calculate health score
      final result = await service.calculateHealthScore(allocation);

      // Then: score should be 100 - (0.8 * 100) = 20 (F grade)
      expect(result.score, 20.0);
      expect(result.grade, HealthGrade.F);
    });

    test('calculateHealthScore clamps score to minimum 0', () async {
      // Given: 100% flexible spending (score should be 0)
      final allocation = AllocationData(
        fixedAmount: 0.0,      // 0% fixed
        flexibleAmount: 1000.0, // 100% flexible
        period: DateTime.now(),
      );

      // When: calculate health score
      final result = await service.calculateHealthScore(allocation);

      // Then: score should be clamped to 0
      expect(result.score, 0.0);
      expect(result.grade, HealthGrade.F);
    });

    test('calculateHealthScore handles zero spending gracefully', () async {
      // Given: zero spending data
      final allocation = AllocationData(
        fixedAmount: 0.0,
        flexibleAmount: 0.0,
        period: DateTime.now(),
      );

      // When: calculate health score
      final result = await service.calculateHealthScore(allocation);

      // Then: should handle gracefully (flexibleRatio = 0.0, score = 100)
      expect(result.score, 100.0);
      expect(result.grade, HealthGrade.A);
    });

    test('calculateHealthScore throws on invalid allocation data', () async {
      // Given: invalid allocation data (negative amounts)
      final allocation = AllocationData(
        fixedAmount: -100.0,  // Invalid negative
        flexibleAmount: -50.0, // Invalid negative
        period: DateTime.now(),
      );

      // When/Then: should throw ArgumentError
      expect(
        () => service.calculateHealthScore(allocation),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('calculateHealthScore returns valid HealthScore object', () async {
      // Given: valid allocation data
      final allocation = AllocationData(
        fixedAmount: 700.0,
        flexibleAmount: 300.0,
        period: DateTime.now(),
      );

      // When: calculate health score
      final result = await service.calculateHealthScore(allocation);

      // Then: should return valid HealthScore
      expect(result, isA<HealthScore>());
      expect(result.score, greaterThanOrEqualTo(0));
      expect(result.score, lessThanOrEqualTo(100));
      expect(result.calculatedAt, isNotNull);
      expect(result.isValid, isTrue);
    });
  });
}
