import 'package:flutter_test/flutter_test.dart';
import 'package:your_finance_flutter/features/insights/models/allocation_data.dart';
import 'package:your_finance_flutter/features/insights/models/health_score.dart';

void main() {
  group('HealthScore Model', () {
    test('HealthScore.calculate factory creates correct score and grade mapping', () {
      // Test A grade: >= 90
      final allocationA = AllocationData(
        fixedAmount: 950.0,
        flexibleAmount: 50.0,
        period: DateTime.now(),
      );
      final scoreA = HealthScore.calculate(allocationA);
      expect(scoreA.score, 95.0); // 100 - (0.05 * 100)
      expect(scoreA.grade, HealthGrade.A);

      // Test B grade: >= 80
      final allocationB = AllocationData(
        fixedAmount: 850.0,
        flexibleAmount: 150.0,
        period: DateTime.now(),
      );
      final scoreB = HealthScore.calculate(allocationB);
      expect(scoreB.score, 85.0); // 100 - (0.15 * 100)
      expect(scoreB.grade, HealthGrade.B);

      // Test C grade: >= 70
      final allocationC = AllocationData(
        fixedAmount: 750.0,
        flexibleAmount: 250.0,
        period: DateTime.now(),
      );
      final scoreC = HealthScore.calculate(allocationC);
      expect(scoreC.score, 75.0); // 100 - (0.25 * 100)
      expect(scoreC.grade, HealthGrade.C);

      // Test D grade: >= 60
      final allocationD = AllocationData(
        fixedAmount: 650.0,
        flexibleAmount: 350.0,
        period: DateTime.now(),
      );
      final scoreD = HealthScore.calculate(allocationD);
      expect(scoreD.score, 65.0); // 100 - (0.35 * 100)
      expect(scoreD.grade, HealthGrade.D);

      // Test F grade: < 60
      final allocationF = AllocationData(
        fixedAmount: 500.0,
        flexibleAmount: 500.0,
        period: DateTime.now(),
      );
      final scoreF = HealthScore.calculate(allocationF);
      expect(scoreF.score, 50.0); // 100 - (0.5 * 100)
      expect(scoreF.grade, HealthGrade.F);
    });

    test('HealthScore.calculate clamps score between 0 and 100', () {
      // Test upper bound (should not exceed 100)
      final allocationHigh = AllocationData(
        fixedAmount: 1000.0,
        flexibleAmount: 0.0, // 0% flexible
        period: DateTime.now(),
      );
      final scoreHigh = HealthScore.calculate(allocationHigh);
      expect(scoreHigh.score, 100.0);
      expect(scoreHigh.grade, HealthGrade.A);

      // Test lower bound (should not go below 0)
      final allocationLow = AllocationData(
        fixedAmount: 0.0,
        flexibleAmount: 1000.0, // 100% flexible
        period: DateTime.now(),
      );
      final scoreLow = HealthScore.calculate(allocationLow);
      expect(scoreLow.score, 0.0);
      expect(scoreLow.grade, HealthGrade.F);
    });

    test('HealthScore.isValid returns true for valid scores', () {
      final allocation = AllocationData(
        fixedAmount: 700.0,
        flexibleAmount: 300.0,
        period: DateTime.now(),
      );
      final score = HealthScore.calculate(allocation);

      expect(score.score, greaterThanOrEqualTo(0));
      expect(score.score, lessThanOrEqualTo(100));
      expect(score.isValid, isTrue);
    });

    test('HealthScore sets calculatedAt timestamp', () {
      final before = DateTime.now();
      final allocation = AllocationData(
        fixedAmount: 700.0,
        flexibleAmount: 300.0,
        period: DateTime.now(),
      );
      final score = HealthScore.calculate(allocation);
      final after = DateTime.now();

      expect(score.calculatedAt, isNotNull);
      expect(score.calculatedAt.isAfter(before) || score.calculatedAt.isAtSameMomentAs(before), isTrue);
      expect(score.calculatedAt.isBefore(after) || score.calculatedAt.isAtSameMomentAs(after), isTrue);
    });

  });
}
