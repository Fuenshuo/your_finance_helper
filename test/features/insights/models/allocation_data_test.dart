import 'package:flutter_test/flutter_test.dart';
import 'package:your_finance_flutter/features/insights/models/allocation_data.dart';

void main() {
  group('AllocationData Model', () {
    test('AllocationData calculates totalAmount correctly', () {
      // Given: fixed = 700, flexible = 300
      final allocation = AllocationData(
        fixedAmount: 700.0,
        flexibleAmount: 300.0,
        period: DateTime.now(),
      );

      // When/Then: total should be 700 + 300 = 1000
      expect(allocation.totalAmount, 1000.0);
    });

    test('AllocationData calculates flexibleRatio correctly', () {
      // Given: fixed = 750, flexible = 250
      final allocation = AllocationData(
        fixedAmount: 750.0,
        flexibleAmount: 250.0,
        period: DateTime.now(),
      );

      // When/Then: flexible ratio should be 250/1000 = 0.25
      expect(allocation.flexibleRatio, 0.25);
    });

    test('AllocationData handles zero total correctly', () {
      // Given: all zeros
      final allocation = AllocationData(
        fixedAmount: 0.0,
        flexibleAmount: 0.0,
        period: DateTime.now(),
      );

      // When/Then: flexible ratio should be 0 (division by zero protection)
      expect(allocation.flexibleRatio, 0.0);
      expect(allocation.totalAmount, 0.0);
    });

    test('AllocationData validates correctly', () {
      // Valid data
      final validAllocation = AllocationData(
        fixedAmount: 800.0,
        flexibleAmount: 200.0,
        period: DateTime.now(),
      );
      expect(validAllocation.isValid, isTrue);

      // Invalid: negative fixed amount
      final invalidAllocation1 = AllocationData(
        fixedAmount: -100.0,
        flexibleAmount: 200.0,
        period: DateTime.now(),
      );
      expect(invalidAllocation1.isValid, isFalse);

      // Invalid: negative flexible amount
      final invalidAllocation2 = AllocationData(
        fixedAmount: 800.0,
        flexibleAmount: -50.0,
        period: DateTime.now(),
      );
      expect(invalidAllocation2.isValid, isFalse);
    });

    test('AllocationData handles all fixed expenses correctly', () {
      // Given: 100% fixed expenses
      final allocation = AllocationData(
        fixedAmount: 1000.0,
        flexibleAmount: 0.0,
        period: DateTime.now(),
      );

      // When/Then: flexible ratio should be 0.0
      expect(allocation.flexibleRatio, 0.0);
      expect(allocation.totalAmount, 1000.0);
    });

    test('AllocationData handles all flexible expenses correctly', () {
      // Given: 100% flexible expenses
      final allocation = AllocationData(
        fixedAmount: 0.0,
        flexibleAmount: 1000.0,
        period: DateTime.now(),
      );

      // When/Then: flexible ratio should be 1.0
      expect(allocation.flexibleRatio, 1.0);
      expect(allocation.totalAmount, 1000.0);
    });

    test('AllocationData handles large amounts correctly', () {
      // Given: large amounts
      final allocation = AllocationData(
        fixedAmount: 50000.0,
        flexibleAmount: 25000.0,
        period: DateTime.now(),
      );

      // When/Then: calculations should work correctly
      expect(allocation.totalAmount, 75000.0);
      expect(allocation.flexibleRatio, 1/3); // 25000/75000 = 1/3
    });

    test('AllocationData handles decimal amounts correctly', () {
      // Given: decimal amounts
      final allocation = AllocationData(
        fixedAmount: 123.45,
        flexibleAmount: 67.89,
        period: DateTime.now(),
      );

      // When/Then: calculations should handle decimals
      expect(allocation.totalAmount, 191.34);
      expect(allocation.flexibleRatio, 67.89 / 191.34);
    });

    test('AllocationData constructor creates object correctly', () {
      final period = DateTime(2024, 2, 15);
      final allocation = AllocationData(
        fixedAmount: 650.0,
        flexibleAmount: 350.0,
        period: period,
      );

      expect(allocation.fixedAmount, 650.0);
      expect(allocation.flexibleAmount, 350.0);
      expect(allocation.period, period);
      expect(allocation.totalAmount, 1000.0);
      expect(allocation.flexibleRatio, 0.35);
      expect(allocation.isValid, isTrue);
    });
  });
}
