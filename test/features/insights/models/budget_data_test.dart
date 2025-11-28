import 'package:flutter_test/flutter_test.dart';
import 'package:your_finance_flutter/features/insights/models/budget_data.dart';

void main() {
  group('BudgetData Model', () {
    test('BudgetData calculates remainingAmount correctly', () {
      // Given: budget = ¥200, spent = ¥112
      final budget = BudgetData(
        budgetAmount: 200.0,
        spentAmount: 112.0,
        date: DateTime.now(),
      );

      // When/Then: remaining should be 200 - 112 = 88
      expect(budget.remainingAmount, 88.0);
    });

    test('BudgetData calculates progressRatio correctly', () {
      // Given: budget = ¥200, spent = ¥112
      final budget = BudgetData(
        budgetAmount: 200.0,
        spentAmount: 112.0,
        date: DateTime.now(),
      );

      // When/Then: progress ratio should be 112/200 = 0.56
      expect(budget.progressRatio, 0.56);
    });

    test('BudgetData handles zero budget correctly', () {
      // Given: zero budget
      final budget = BudgetData(
        budgetAmount: 0.0,
        spentAmount: 50.0,
        date: DateTime.now(),
      );

      // When/Then: progress ratio should be 0 (division by zero protection)
      expect(budget.progressRatio, 0.0);
      expect(budget.remainingAmount, -50.0); // Still calculates remaining
    });

    test('BudgetData detects overspent correctly', () {
      // Given: spent more than budget
      final budget = BudgetData(
        budgetAmount: 200.0,
        spentAmount: 250.0,
        date: DateTime.now(),
      );

      // When/Then: should be overspent
      expect(budget.isOverspent, isTrue);
      expect(budget.remainingAmount, -50.0); // Negative remaining
      expect(budget.progressRatio, 1.25); // Over 100%
    });

    test('BudgetData detects non-overspent correctly', () {
      // Given: spent less than budget
      final budget = BudgetData(
        budgetAmount: 200.0,
        spentAmount: 150.0,
        date: DateTime.now(),
      );

      // When/Then: should not be overspent
      expect(budget.isOverspent, isFalse);
      expect(budget.remainingAmount, 50.0);
      expect(budget.progressRatio, 0.75);
    });

    test('BudgetData validates correctly', () {
      // Valid data
      final validBudget = BudgetData(
        budgetAmount: 200.0,
        spentAmount: 112.0,
        date: DateTime.now(),
      );
      expect(validBudget.isValid, isTrue);

      // Invalid: negative budget
      final invalidBudget1 = BudgetData(
        budgetAmount: -100.0,
        spentAmount: 50.0,
        date: DateTime.now(),
      );
      expect(invalidBudget1.isValid, isFalse);

      // Invalid: negative spent
      final invalidBudget2 = BudgetData(
        budgetAmount: 200.0,
        spentAmount: -50.0,
        date: DateTime.now(),
      );
      expect(invalidBudget2.isValid, isFalse);
    });

    test('BudgetData handles exact budget match', () {
      // Given: spent exactly equals budget
      final budget = BudgetData(
        budgetAmount: 200.0,
        spentAmount: 200.0,
        date: DateTime.now(),
      );

      // When/Then: should not be overspent, remaining = 0
      expect(budget.isOverspent, isFalse);
      expect(budget.remainingAmount, 0.0);
      expect(budget.progressRatio, 1.0);
    });

    test('BudgetData handles large numbers correctly', () {
      // Given: large budget amounts
      final budget = BudgetData(
        budgetAmount: 10000.0,
        spentAmount: 7500.0,
        date: DateTime.now(),
      );

      // When/Then: calculations should work correctly
      expect(budget.remainingAmount, 2500.0);
      expect(budget.progressRatio, 0.75);
      expect(budget.isOverspent, isFalse);
    });
  });
}
