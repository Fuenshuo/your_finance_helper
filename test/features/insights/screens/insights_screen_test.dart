import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:your_finance_flutter/features/insights/screens/flux_insights_screen.dart';
import 'package:your_finance_flutter/features/insights/widgets/daily_budget_velocity.dart';
import 'package:your_finance_flutter/features/insights/widgets/structural_health_chart.dart';
import 'package:your_finance_flutter/features/insights/widgets/trend_radar_chart.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FluxInsightsScreen Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues(<String, Object>{});
    });

    testWidgets('renders header title', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: FluxInsightsScreen()));
      expect(find.text('Flux Insights'), findsOneWidget);
    });

    testWidgets('renders core sections and key widgets', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: FluxInsightsScreen()));

      // Initial frame
      expect(find.text('Flux Insights'), findsOneWidget);
      expect(find.text('Financial Health Score'), findsOneWidget);
      expect(find.text('Daily Budget Velocity'), findsOneWidget);
      expect(find.text('Spending Trends'), findsOneWidget);

      expect(find.byType(DailyBudgetVelocity), findsOneWidget);
      expect(find.byType(TrendRadarChart), findsOneWidget);

      // The last section is below the fold; scroll to build it.
      await tester.scrollUntilVisible(
        find.text('Structural Health'),
        300,
        scrollable: find.byType(Scrollable),
      );
      await tester.pump();

      expect(find.text('Structural Health'), findsOneWidget);
      expect(find.byType(StructuralHealthChart), findsOneWidget);
    });

    testWidgets('shows health score and grade text', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: FluxInsightsScreen()));

      // Allow async load + setState (health score) to complete.
      await tester.pumpAndSettle();

      expect(find.textContaining('Grade'), findsWidgets);
    });
  });
}
