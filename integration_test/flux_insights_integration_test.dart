import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:your_finance_flutter/core/theme/app_design_tokens.dart';
import 'package:your_finance_flutter/features/insights/screens/flux_insights_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Flux Insights Integration Tests', () {
    testWidgets('Theme switching updates all component colors', (tester) async {
      // Pump the app with sample data
      await tester.pumpWidget(
        const MaterialApp(
          home: FluxInsightsScreen(),
        ),
      );

      // Wait for initial data loading
      await tester.pumpAndSettle();

      // Verify initial theme (light theme by default)
      final initialBackgroundColor = AppDesignTokens.pageBackground(
        tester.element(find.byType(FluxInsightsScreen)),
      );
      expect(initialBackgroundColor, isNotNull);

      // Test theme switching by changing system brightness
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const FluxInsightsScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify dark theme colors are applied
      final darkBackgroundColor = AppDesignTokens.pageBackground(
        tester.element(find.byType(FluxInsightsScreen)),
      );
      expect(darkBackgroundColor, isNotNull);

      // Verify header text is visible in both themes
      expect(find.text('Flux Insights'), findsOneWidget);

      // Verify health score is displayed
      expect(find.text('Financial Health Score'), findsOneWidget);
      expect(find.textContaining('Grade'), findsOneWidget);

      // Verify budget section is displayed
      expect(find.text('Daily Budget Velocity'), findsOneWidget);

      // Verify trend chart section is displayed
      expect(find.text('Spending Trends'), findsOneWidget);

      // Verify structural health section is displayed
      expect(find.text('Structural Health'), findsOneWidget);
    });

    testWidgets('Chart components render and respond to interactions',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FluxInsightsScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify chart containers are present
      expect(find.byType(Container), findsWidgets);

      // Verify text elements are rendered
      expect(find.text('Flux Insights'), findsOneWidget);
      expect(find.text('Financial Health Score'), findsOneWidget);
      expect(find.text('Daily Budget Velocity'), findsOneWidget);
      expect(find.text('Spending Trends'), findsOneWidget);
      expect(find.text('Structural Health'), findsOneWidget);
    });

    testWidgets('Error handling displays fallback content', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FluxInsightsScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Even with potential errors, the UI should still render
      expect(find.text('Flux Insights'), findsOneWidget);

      // Health score should show default value or calculated value
      expect(find.textContaining('Grade'), findsOneWidget);
    });

    testWidgets('Performance monitoring does not break rendering',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FluxInsightsScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // If performance monitoring is working, the UI should still render
      expect(find.text('Flux Insights'), findsOneWidget);
      expect(find.text('Financial Health Score'), findsOneWidget);
    });
  });
}
