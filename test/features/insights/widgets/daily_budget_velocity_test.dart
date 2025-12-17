import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:your_finance_flutter/features/insights/models/budget_data.dart';
import 'package:your_finance_flutter/features/insights/widgets/daily_budget_velocity.dart';

void main() {
  late BudgetData normalBudget;
  late BudgetData overspentBudget;
  late BudgetData zeroBudget;

  setUp(() {
    normalBudget = BudgetData(
      budgetAmount: 200.0,
      spentAmount: 112.0,
      date: DateTime.now(),
    );

    overspentBudget = BudgetData(
      budgetAmount: 200.0,
      spentAmount: 250.0,
      date: DateTime.now(),
    );

    zeroBudget = BudgetData(
      budgetAmount: 0.0,
      spentAmount: 50.0,
      date: DateTime.now(),
    );
  });

  group('DailyBudgetVelocity Widget Tests', () {
    testWidgets('displays normal budget progress correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DailyBudgetVelocity(budgetData: normalBudget),
          ),
        ),
      );

      // Check spent amount display
      expect(find.text('Spent: ¥112'), findsOneWidget);

      // Check remaining amount (positive)
      expect(find.text('Left: ¥88'), findsOneWidget);

      // Check that progress bar exists (can't easily test visual progress without more setup)
      expect(find.byType(FractionallySizedBox), findsOneWidget);
    });

    testWidgets('displays overspent budget correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DailyBudgetVelocity(budgetData: overspentBudget),
          ),
        ),
      );

      // Check spent amount display
      expect(find.text('Spent: ¥250'), findsOneWidget);

      // Check overspent amount (should show "Over" instead of "Left")
      expect(find.text('Over: ¥50'), findsOneWidget);
    });

    testWidgets('displays zero budget empty state correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DailyBudgetVelocity(budgetData: zeroBudget),
          ),
        ),
      );

      // Check empty state message
      expect(find.text('Set a budget to see velocity'), findsOneWidget);

      // Should not show progress bar or amounts
      expect(find.textContaining('Spent:'), findsNothing);
      expect(find.textContaining('Left:'), findsNothing);
      expect(find.textContaining('Over:'), findsNothing);
    });

    testWidgets('displays null budget empty state correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DailyBudgetVelocity(),
          ),
        ),
      );

      // Check empty state message
      expect(find.text('Set a budget to see velocity'), findsOneWidget);
    });

    testWidgets('progress bar has correct height (4px)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DailyBudgetVelocity(budgetData: normalBudget),
          ),
        ),
      );

      // Find the progress bar container
      final container = tester.widget<Container>(
        find
            .byType(Container)
            .at(0), // First container should be the progress bar
      );

      // Check height constraint
      expect(container.constraints?.maxHeight, 4.0);
    });

    testWidgets('handles exact budget match (100% spent)', (tester) async {
      final exactBudget = BudgetData(
        budgetAmount: 200.0,
        spentAmount: 200.0,
        date: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DailyBudgetVelocity(budgetData: exactBudget),
          ),
        ),
      );

      // Should show "Left: ¥0" (not overspent)
      expect(find.text('Spent: ¥200'), findsOneWidget);
      expect(find.text('Left: ¥0'), findsOneWidget);
    });

    testWidgets('handles large budget amounts correctly', (tester) async {
      final largeBudget = BudgetData(
        budgetAmount: 10000.0,
        spentAmount: 7500.0,
        date: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DailyBudgetVelocity(budgetData: largeBudget),
          ),
        ),
      );

      // Should display amounts without decimals (toStringAsFixed(0))
      expect(find.text('Spent: ¥7500'), findsOneWidget);
      expect(find.text('Left: ¥2500'), findsOneWidget);
    });
  });
}
