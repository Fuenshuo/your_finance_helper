// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart' as provider;
import 'package:your_finance_flutter/core/providers/account_provider.dart';
import 'package:your_finance_flutter/core/providers/asset_provider.dart';
import 'package:your_finance_flutter/core/providers/budget_provider.dart';
import 'package:your_finance_flutter/core/providers/expense_plan_provider.dart';
import 'package:your_finance_flutter/core/providers/flux_providers.dart';
import 'package:your_finance_flutter/core/providers/theme_provider.dart';
import 'package:your_finance_flutter/core/providers/theme_style_provider.dart';
import 'package:your_finance_flutter/core/providers/transaction_provider.dart';
import 'package:your_finance_flutter/main_flux.dart';

void main() {
  testWidgets('App smoke test', (tester) async {
    // Build our app with all required providers
    await tester.pumpWidget(
      ProviderScope(
        child: provider.MultiProvider(
          providers: [
            // Flux核心提供者
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
            // Theme providers
            provider.ChangeNotifierProvider(
              create: (_) => ThemeProvider(),
            ),
            provider.ChangeNotifierProvider(
              create: (_) => ThemeStyleProvider()..initialize(),
            ),
            // 兼容性提供者
            provider.ChangeNotifierProvider(
              create: (_) => LegacyDataProvider()..initialize(),
            ),
            provider.ChangeNotifierProvider(
              create: (_) => TransactionProvider()..initialize(),
            ),
            // Required providers
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
          ],
          child: const FluxLedgerApp(),
        ),
      ),
    );

    // Wait for initialization
    await tester.pump();

    // Verify that the app builds without errors
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
