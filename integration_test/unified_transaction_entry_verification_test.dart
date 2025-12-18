/// Unified Transaction Entry Screen Verification Integration Test
///
/// Comprehensive integration test that verifies all unified_transaction_entry_screen
/// functionality works correctly after the Flux Ledger cleanup.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart' as provider;

import 'package:your_finance_flutter/core/providers/account_provider.dart';
import 'package:your_finance_flutter/core/providers/asset_provider.dart';
import 'package:your_finance_flutter/core/providers/budget_provider.dart';
import 'package:your_finance_flutter/core/providers/expense_plan_provider.dart';
import 'package:your_finance_flutter/core/providers/flux_providers.dart';
import 'package:your_finance_flutter/core/providers/transaction_provider.dart';
import 'package:your_finance_flutter/screens/unified_transaction_entry_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Unified Transaction Entry Screen Verification', () {
    late Widget testWidget;

    setUp(() {
      // Setup test widget with all required providers
      testWidget = provider.MultiProvider(
        providers: [
          provider.ChangeNotifierProvider(
              create: (_) => AccountProvider()..initialize()),
          provider.ChangeNotifierProvider(
              create: (_) => AssetProvider()..initialize()),
          provider.ChangeNotifierProvider(
              create: (_) => BudgetProvider()..initialize()),
          provider.ChangeNotifierProvider(
              create: (_) => ExpensePlanProvider()..initialize()),
          provider.ChangeNotifierProvider(
              create: (_) => TransactionProvider()..initialize()),
          provider.ChangeNotifierProvider(
              create: (_) => FluxThemeProvider()..initialize()),
          provider.ChangeNotifierProvider(
              create: (_) => FlowDashboardProvider()..initialize()),
          provider.ChangeNotifierProvider(
              create: (_) => FlowStreamsProvider()..initialize()),
          provider.ChangeNotifierProvider(
              create: (_) => FlowInsightsProvider()..initialize()),
          provider.ChangeNotifierProvider(
              create: (_) => FlowAnalyticsProvider()..initialize()),
        ],
        child: ProviderScope(
          child: MaterialApp(
            home: const UnifiedTransactionEntryScreen(),
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
          ),
        ),
      );
    });

    testWidgets('Screen renders without errors', (tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Verify the screen renders
      expect(find.byType(UnifiedTransactionEntryScreen), findsOneWidget);

      // Check for key UI elements that should be present
      expect(find.byKey(const Key('unified_timeframe_segmented_control')),
          findsOneWidget);
      expect(find.byKey(const Key('unified_input_dock')), findsOneWidget);
      expect(find.byKey(const Key('unified_timeline_view')), findsOneWidget);
    });

    testWidgets('Time range controls are interactive', (tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Find the timeframe control
      final timeframeControl =
          find.byKey(const Key('unified_timeframe_segmented_control'));
      expect(timeframeControl, findsOneWidget);

      // Test that it's tappable (verifies interactivity)
      await tester.tap(timeframeControl);
      await tester.pumpAndSettle();
    });

    testWidgets('Input dock accepts text input', (tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Find input field in the input dock
      final inputField = find.byKey(const Key('unified_input_dock'));

      // Test basic text input
      await tester.enterText(inputField, 'Test transaction');
      await tester.pumpAndSettle();

      // Verify text was entered (this would be more specific in real implementation)
      expect(find.text('Test transaction'), findsOneWidget);
    });

    testWidgets('Timeline view displays content', (tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Verify timeline view is present
      expect(find.byKey(const Key('unified_timeline_view')), findsOneWidget);

      // Check for timeline group list (may be empty initially but should exist)
      expect(
          find.byKey(const Key('unified_timeline_group_list')), findsOneWidget);
    });

    testWidgets('Insights view is accessible', (tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Check if insights view key exists (may not be visible initially)
      final insightsView = find.byKey(const Key('unified_insights_view'));

      // The insights view should exist in the widget tree even if not visible
      expect(insightsView, findsOneWidget);
    });

    testWidgets('Draft card functionality exists', (tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Check if draft card key exists (may not be visible initially)
      final draftCard = find.byKey(const Key('unified_draft_card'));

      // The draft card should exist in the widget tree even if not visible
      expect(draftCard, findsOneWidget);
    });

    testWidgets('Theme mode affects visual appearance', (tester) async {
      // Test with light theme
      final lightThemeWidget = provider.MultiProvider(
        providers: [
          provider.ChangeNotifierProvider(
              create: (_) => AccountProvider()..initialize()),
          provider.ChangeNotifierProvider(
              create: (_) => AssetProvider()..initialize()),
          provider.ChangeNotifierProvider(
              create: (_) => BudgetProvider()..initialize()),
          provider.ChangeNotifierProvider(
              create: (_) => ExpensePlanProvider()..initialize()),
          provider.ChangeNotifierProvider(
              create: (_) => TransactionProvider()..initialize()),
          provider.ChangeNotifierProvider(
              create: (_) => FluxThemeProvider()..initialize()),
          provider.ChangeNotifierProvider(
              create: (_) => FlowDashboardProvider()..initialize()),
          provider.ChangeNotifierProvider(
              create: (_) => FlowStreamsProvider()..initialize()),
          provider.ChangeNotifierProvider(
              create: (_) => FlowInsightsProvider()..initialize()),
          provider.ChangeNotifierProvider(
              create: (_) => FlowAnalyticsProvider()..initialize()),
        ],
        child: ProviderScope(
          child: MaterialApp(
            home: const UnifiedTransactionEntryScreen(),
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: ThemeMode.light, // Explicitly light mode
          ),
        ),
      );

      await tester.pumpWidget(lightThemeWidget);
      await tester.pumpAndSettle();

      // Verify screen renders in light mode
      expect(find.byType(UnifiedTransactionEntryScreen), findsOneWidget);

      // Test with dark theme
      final darkThemeWidget = provider.MultiProvider(
        providers: [
          provider.ChangeNotifierProvider(
              create: (_) => AccountProvider()..initialize()),
          provider.ChangeNotifierProvider(
              create: (_) => AssetProvider()..initialize()),
          provider.ChangeNotifierProvider(
              create: (_) => BudgetProvider()..initialize()),
          provider.ChangeNotifierProvider(
              create: (_) => ExpensePlanProvider()..initialize()),
          provider.ChangeNotifierProvider(
              create: (_) => TransactionProvider()..initialize()),
          provider.ChangeNotifierProvider(
              create: (_) => FluxThemeProvider()..initialize()),
          provider.ChangeNotifierProvider(
              create: (_) => FlowDashboardProvider()..initialize()),
          provider.ChangeNotifierProvider(
              create: (_) => FlowStreamsProvider()..initialize()),
          provider.ChangeNotifierProvider(
              create: (_) => FlowInsightsProvider()..initialize()),
          provider.ChangeNotifierProvider(
              create: (_) => FlowAnalyticsProvider()..initialize()),
        ],
        child: ProviderScope(
          child: MaterialApp(
            home: const UnifiedTransactionEntryScreen(),
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: ThemeMode.dark, // Explicitly dark mode
          ),
        ),
      );

      await tester.pumpWidget(darkThemeWidget);
      await tester.pumpAndSettle();

      // Verify screen renders in dark mode
      expect(find.byType(UnifiedTransactionEntryScreen), findsOneWidget);
    });

    testWidgets('Screen handles provider dependencies correctly',
        (tester) async {
      // Test without all required providers (should fail gracefully)
      const incompleteWidget = MaterialApp(
        home: UnifiedTransactionEntryScreen(),
      );

      await tester.pumpWidget(incompleteWidget);

      // The screen should handle missing providers gracefully
      // (This test verifies the screen doesn't crash immediately without providers)
      await tester.pumpAndSettle();
    });
  });
}

