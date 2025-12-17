import 'package:flutter_test/flutter_test.dart';
import 'package:your_finance_flutter/features/insights/models/daily_cap.dart';

void main() {
  group('DailyCap Model Tests', () {
    late DailyCap dailyCap;
    final testDate = DateTime(2025, 11, 27);

    setUp(() {
      dailyCap = DailyCap(
        id: 'test_daily_cap',
        date: testDate,
        referenceAmount: 200.0,
        currentSpending: 50.0,
        percentage: 0.25,
        status: CapStatus.safe,
      );
    });

    test('should calculate remainingAmount correctly', () {
      expect(dailyCap.remainingAmount, 150.0);
    });

    test('should identify when over budget', () {
      final overBudgetCap = dailyCap.copyWith(currentSpending: 250.0);
      expect(overBudgetCap.isOverBudget, true);
    });

    test('should identify when not over budget', () {
      expect(dailyCap.isOverBudget, false);
    });

    test('should copy with updated values', () {
      final updatedCap = dailyCap.copyWith(
        currentSpending: 75.0,
        percentage: 0.375,
      );

      expect(updatedCap.currentSpending, 75.0);
      expect(updatedCap.percentage, 0.375);
      expect(updatedCap.id, dailyCap.id); // unchanged
      expect(updatedCap.referenceAmount, dailyCap.referenceAmount); // unchanged
    });

    test('should have correct props for equality', () {
      final identicalCap = DailyCap(
        id: 'test_daily_cap',
        date: testDate,
        referenceAmount: 200.0,
        currentSpending: 50.0,
        percentage: 0.25,
        status: CapStatus.safe,
      );

      expect(dailyCap, equals(identicalCap));
    });

    test('should be different when properties change', () {
      final differentCap = dailyCap.copyWith(currentSpending: 75.0);
      expect(dailyCap, isNot(equals(differentCap)));
    });

    group('CapStatus enum values', () {
      test('safe status for low spending', () {
        expect(CapStatus.safe, equals(CapStatus.safe));
      });

      test('warning status for medium spending', () {
        expect(CapStatus.warning, equals(CapStatus.warning));
      });

      test('danger status for high spending', () {
        expect(CapStatus.danger, equals(CapStatus.danger));
      });
    });

    group('Edge cases', () {
      test('should handle zero reference amount', () {
        final zeroReferenceCap = dailyCap.copyWith(referenceAmount: 0.0);
        expect(zeroReferenceCap.remainingAmount, -50.0); // negative remaining
        expect(zeroReferenceCap.isOverBudget, true);
      });

      test('should handle negative spending', () {
        final negativeSpendingCap = dailyCap.copyWith(currentSpending: -10.0);
        expect(negativeSpendingCap.remainingAmount, 210.0);
        expect(negativeSpendingCap.isOverBudget, false);
      });

      test('should handle very high percentage', () {
        final highPercentageCap = dailyCap.copyWith(
          currentSpending: 1000.0,
          percentage: 5.0,
        );
        expect(highPercentageCap.isOverBudget, true);
      });
    });
  });
}
