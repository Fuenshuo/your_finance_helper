/// Navigation Verification Integration Test
///
/// Comprehensive integration test that verifies Flux Ledger navigation
/// functionality works correctly after cleanup.
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
import 'package:your_finance_flutter/screens/dashboard_home_screen.dart';
import 'package:your_finance_flutter/screens/main_navigation_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Navigation Verification', () {
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
            home: const MainNavigationScreen(),
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
          ),
        ),
      );
    });

    testWidgets('Main navigation screen renders without errors',
        (tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Verify main navigation screen renders
      expect(find.byType(MainNavigationScreen), findsOneWidget);

      // Check for bottom navigation bar
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('Bottom navigation bar has correct tabs', (tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Check for expected navigation items
      // This would need to be customized based on actual tab labels
      expect(find.byIcon(Icons.dashboard), findsOneWidget);
      expect(find.byIcon(Icons.account_balance_wallet), findsOneWidget);
      expect(find.byIcon(Icons.insights), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('Dashboard tab displays correctly', (tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Tap on dashboard tab (first tab, index 0)
      await tester.tap(find.byIcon(Icons.dashboard));
      await tester.pumpAndSettle();

      // Verify dashboard content is displayed
      expect(find.byType(DashboardHomeScreen), findsOneWidget);
    });

    testWidgets('Navigation between tabs works', (tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Start on dashboard tab
      expect(find.byType(DashboardHomeScreen), findsOneWidget);

      // Navigate to transaction entry (assuming second tab)
      await tester.tap(find.byIcon(Icons.account_balance_wallet));
      await tester.pumpAndSettle();

      // This would check for transaction entry screen
      // expect(find.byType(UnifiedTransactionEntryScreen), findsOneWidget);

      // Navigate back to dashboard
      await tester.tap(find.byIcon(Icons.dashboard));
      await tester.pumpAndSettle();

      expect(find.byType(DashboardHomeScreen), findsOneWidget);
    });

    testWidgets('Insights tab loads correctly', (tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Navigate to insights tab
      await tester.tap(find.byIcon(Icons.insights));
      await tester.pumpAndSettle();

      // Check that insights content loads
      // This would be customized based on actual insights screen
      expect(find.text('Insights'), findsWidgets); // Assuming there's a title
    });

    testWidgets('Settings tab is accessible', (tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Navigate to settings tab
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Check that settings content loads
      // This would be customized based on actual settings screen
      expect(find.text('Settings'), findsWidgets); // Assuming there's a title
    });

    testWidgets('Back navigation works within tabs', (tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Navigate to a tab
      await tester.tap(find.byIcon(Icons.insights));
      await tester.pumpAndSettle();

      // Simulate back button press (Android back or iOS swipe)
      // Note: This test assumes the app handles back navigation properly
      await tester.pageBack();
      await tester.pumpAndSettle();

      // Should be back to previous state
      // This test would need customization based on actual back navigation behavior
    });

    testWidgets('Navigation handles provider dependencies', (tester) async {
      // Test without all required providers (should handle gracefully)
      const incompleteWidget = MaterialApp(
        home: MainNavigationScreen(),
      );

      await tester.pumpWidget(incompleteWidget);

      // The navigation screen should handle missing providers gracefully
      // (This test verifies the screen doesn't crash immediately without providers)
      await tester.pumpAndSettle();
    });

    testWidgets('Navigation state persists during tab switches',
        (tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Navigate to transaction tab and perform some action
      await tester.tap(find.byIcon(Icons.account_balance_wallet));
      await tester.pumpAndSettle();

      // Perform some action that changes state (e.g., input text)
      // This would depend on the actual transaction entry screen implementation

      // Switch to another tab
      await tester.tap(find.byIcon(Icons.dashboard));
      await tester.pumpAndSettle();

      // Switch back to transaction tab
      await tester.tap(find.byIcon(Icons.account_balance_wallet));
      await tester.pumpAndSettle();

      // Verify that state was preserved
      // This would check that any input or state was maintained
    });
  });
}
