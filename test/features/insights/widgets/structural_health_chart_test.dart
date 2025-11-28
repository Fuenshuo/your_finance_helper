import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:your_finance_flutter/features/insights/models/allocation_data.dart';
import 'package:your_finance_flutter/features/insights/widgets/structural_health_chart.dart';

void main() {
  late AllocationData sampleAllocation;
  late AllocationData zeroAllocation;
  late AllocationData fixedOnlyAllocation;
  late AllocationData flexibleOnlyAllocation;

  setUp(() {
    sampleAllocation = AllocationData(
      fixedAmount: 750.0,
      flexibleAmount: 250.0,
      period: DateTime.now(),
    );

    zeroAllocation = AllocationData(
      fixedAmount: 0.0,
      flexibleAmount: 0.0,
      period: DateTime.now(),
    );

    fixedOnlyAllocation = AllocationData(
      fixedAmount: 1000.0,
      flexibleAmount: 0.0,
      period: DateTime.now(),
    );

    flexibleOnlyAllocation = AllocationData(
      fixedAmount: 0.0,
      flexibleAmount: 1000.0,
      period: DateTime.now(),
    );
  });

  group('StructuralHealthChart Widget Tests', () {
    testWidgets('displays chart with sample allocation correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StructuralHealthChart(allocationData: sampleAllocation),
          ),
        ),
      );

      // Should render without errors
      expect(find.byType(StructuralHealthChart), findsOneWidget);
      expect(find.byType(AspectRatio), findsOneWidget);

      // Should show breakdown labels
      expect(find.text('Fixed Expenses'), findsOneWidget);
      expect(find.text('Flexible Expenses'), findsOneWidget);
      expect(find.text('Total'), findsOneWidget);

      // Should show formatted amounts
      expect(find.text('¥750'), findsOneWidget); // Fixed amount
      expect(find.text('¥250'), findsOneWidget); // Flexible amount
      expect(find.text('¥1000'), findsOneWidget); // Total
    });

    testWidgets('displays empty state correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StructuralHealthChart(allocationData: zeroAllocation),
          ),
        ),
      );

      // Should show empty state message
      expect(find.text('Complete spending setup to see health score'), findsOneWidget);
    });

    testWidgets('displays null allocation correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StructuralHealthChart(allocationData: null),
          ),
        ),
      );

      // Should show empty state
      expect(find.text('Complete spending setup to see health score'), findsOneWidget);
    });

    testWidgets('displays fixed-only allocation correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StructuralHealthChart(allocationData: fixedOnlyAllocation),
          ),
        ),
      );

      // Should show fixed expenses and total
      expect(find.text('Fixed Expenses'), findsOneWidget);
      expect(find.text('Flexible Expenses'), findsOneWidget);
      expect(find.text('Total'), findsOneWidget);
      expect(find.text('¥1000'), findsOneWidget); // Fixed amount
      expect(find.text('¥0'), findsOneWidget); // Flexible amount
    });

    testWidgets('displays flexible-only allocation correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StructuralHealthChart(allocationData: flexibleOnlyAllocation),
          ),
        ),
      );

      // Should show flexible expenses and total
      expect(find.text('Fixed Expenses'), findsOneWidget);
      expect(find.text('Flexible Expenses'), findsOneWidget);
      expect(find.text('Total'), findsOneWidget);
      expect(find.text('¥0'), findsOneWidget); // Fixed amount
      expect(find.text('¥1000'), findsOneWidget); // Flexible amount
    });

    testWidgets('displays health score correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StructuralHealthChart(allocationData: sampleAllocation),
          ),
        ),
      );

      // Wait for async calculation to complete
      await tester.pumpAndSettle();

      // Should show health score (75 for 75%/25% allocation)
      expect(find.text('75'), findsOneWidget);
      expect(find.text('Health Score'), findsOneWidget);
    });

    testWidgets('handles large amounts correctly', (WidgetTester tester) async {
      final largeAllocation = AllocationData(
        fixedAmount: 50000.0,
        flexibleAmount: 25000.0,
        period: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StructuralHealthChart(allocationData: largeAllocation),
          ),
        ),
      );

      // Should display amounts without decimals (toStringAsFixed(0))
      expect(find.text('¥50000'), findsOneWidget); // Fixed amount
      expect(find.text('¥25000'), findsOneWidget); // Flexible amount
      expect(find.text('¥75000'), findsOneWidget); // Total
    });

    testWidgets('updates when allocation data changes', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => StructuralHealthChart(
                allocationData: sampleAllocation,
              ),
            ),
          ),
        ),
      );

      // Should show initial data
      expect(find.text('¥750'), findsOneWidget);
      expect(find.text('¥250'), findsOneWidget);

      // Note: Testing data changes would require more complex setup with a stateful wrapper
      // This basic test ensures the widget renders correctly
    });
  });
}
