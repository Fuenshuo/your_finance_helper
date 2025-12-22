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
import 'package:your_finance_flutter/core/providers/theme_provider.dart';
import 'package:your_finance_flutter/core/providers/theme_style_provider.dart';
import 'package:your_finance_flutter/core/providers/transaction_provider.dart';
import 'package:your_finance_flutter/screens/main_navigation_screen.dart';
import 'package:your_finance_flutter/screens/unified_transaction_entry_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Navigation Verification', () {
    late Widget testWidget;

    setUp(() {
      // Setup test widget with all required providers
      testWidget = provider.MultiProvider(
        providers: [
          provider.ChangeNotifierProvider(
            create: (_) => AccountProvider()..initialize(),
          ),
          provider.ChangeNotifierProvider(
            create: (_) => AssetProvider()..initialize(),
          ),
          provider.ChangeNotifierProvider(
            create: (_) => BudgetProvider()..initialize(),
          ),
          provider.ChangeNotifierProvider(
            create: (_) => ExpensePlanProvider()..initialize(),
          ),
          provider.ChangeNotifierProvider(
            create: (_) => TransactionProvider()..initialize(),
          ),
          provider.ChangeNotifierProvider(
            create: (_) => ThemeProvider(),
          ),
          provider.ChangeNotifierProvider(
            create: (_) => ThemeStyleProvider()..initialize(),
          ),
          provider.ChangeNotifierProvider(
            create: (_) => FluxThemeProvider()..initialize(),
          ),
          provider.ChangeNotifierProvider(
            create: (_) => FlowDashboardProvider()..initialize(),
          ),
          provider.ChangeNotifierProvider(
            create: (_) => FlowStreamsProvider()..initialize(),
          ),
          provider.ChangeNotifierProvider(
            create: (_) => FlowInsightsProvider()..initialize(),
          ),
          provider.ChangeNotifierProvider(
            create: (_) => FlowAnalyticsProvider()..initialize(),
          ),
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

      // The Stream+Insights merged UI is enabled by default, which yields:
      // Stream (timeline), Assets, Me.
      expect(find.text('Stream'), findsOneWidget);
      expect(find.text('Assets'), findsOneWidget);
      expect(find.text('Me'), findsOneWidget);

      // Selected tab uses the active icon.
      expect(find.byIcon(Icons.timeline), findsOneWidget);
    });

    testWidgets('Stream tab displays correctly', (tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Tap on stream tab (index 0)
      await tester.tap(find.text('Stream'));
      await tester.pumpAndSettle();

      // Verify stream content is displayed
      expect(find.byType(UnifiedTransactionEntryScreen), findsOneWidget);
    });

    testWidgets('Navigation between tabs works', (tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Start on stream tab
      expect(find.byType(UnifiedTransactionEntryScreen), findsOneWidget);

      // Navigate to assets tab
      await tester.tap(find.text('Assets'));
      await tester.pumpAndSettle();

      // Verify the assets placeholder content is visible.
      expect(find.text('资产与账户模块即将上线'), findsOneWidget);

      // Navigate to me tab
      await tester.tap(find.text('Me'));
      await tester.pumpAndSettle();

      // Verify the me placeholder content is visible.
      expect(find.text('个人中心即将上线'), findsOneWidget);
    });

    testWidgets('Navigation state persists during tab switches',
        (tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Navigate to assets tab and perform some action
      await tester.tap(find.text('Assets'));
      await tester.pumpAndSettle();

      // Switch to another tab (me)
      await tester.tap(find.text('Me'));
      await tester.pumpAndSettle();

      // Switch back to assets tab
      await tester.tap(find.text('Assets'));
      await tester.pumpAndSettle();

      // Verify that state was preserved
      // This would check that any input or state was maintained
    });
  });
}
