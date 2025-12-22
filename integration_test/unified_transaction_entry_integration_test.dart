import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart' as provider;
import 'package:your_finance_flutter/core/providers/account_provider.dart';
import 'package:your_finance_flutter/core/providers/budget_provider.dart';
import 'package:your_finance_flutter/core/providers/stream_insights_flag_provider.dart';
import 'package:your_finance_flutter/core/providers/theme_provider.dart';
import 'package:your_finance_flutter/core/providers/theme_style_provider.dart';
import 'package:your_finance_flutter/core/providers/transaction_provider.dart';
import 'package:your_finance_flutter/screens/unified_transaction_entry_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Unified Transaction Entry Screen Integration Tests', () {
    testWidgets('Screen renders without errors', (tester) async {
      // Pump the screen with all required providers
      await tester.pumpWidget(
        provider.MultiProvider(
          providers: [
            provider.ChangeNotifierProvider(create: (_) => AccountProvider()),
            provider.ChangeNotifierProvider(create: (_) => BudgetProvider()),
            provider.ChangeNotifierProvider(
                create: (_) => TransactionProvider()),
            provider.ChangeNotifierProvider(create: (_) => ThemeProvider()),
            provider.ChangeNotifierProvider(
                create: (_) => ThemeStyleProvider()),
            provider.ChangeNotifierProvider(
                create: (_) => StreamInsightsFlagProvider(
                    flagKey: 'stream_insights', defaultValue: true)),
          ],
          child: const ProviderScope(
            child: MaterialApp(
              home: UnifiedTransactionEntryScreen(),
            ),
          ),
        ),
      );

      // Wait for initial rendering
      await tester.pumpAndSettle();

      // Verify basic elements are present
      expect(find.byType(UnifiedTransactionEntryScreen), findsOneWidget);

      // Check for key UI elements (timeframe controls)
      expect(find.byKey(const Key('unified_timeframe_segmented_control')),
          findsOneWidget);

      // Check for input dock
      expect(find.byKey(const Key('unified_input_dock')), findsOneWidget);
    });

    testWidgets('Time range controls are functional', (tester) async {
      await tester.pumpWidget(
        provider.MultiProvider(
          providers: [
            provider.ChangeNotifierProvider(create: (_) => AccountProvider()),
            provider.ChangeNotifierProvider(create: (_) => BudgetProvider()),
            provider.ChangeNotifierProvider(
                create: (_) => TransactionProvider()),
            provider.ChangeNotifierProvider(create: (_) => ThemeProvider()),
            provider.ChangeNotifierProvider(
                create: (_) => ThemeStyleProvider()),
            provider.ChangeNotifierProvider(
                create: (_) => StreamInsightsFlagProvider(
                    flagKey: 'stream_insights', defaultValue: true)),
          ],
          child: const ProviderScope(
            child: MaterialApp(
              home: UnifiedTransactionEntryScreen(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify timeframe control exists and can be interacted with
      final timeframeControl =
          find.byKey(const Key('unified_timeframe_segmented_control'));
      expect(timeframeControl, findsOneWidget);

      // Test that we can tap the control (this verifies the control is interactive)
      await tester.tap(timeframeControl);
      await tester.pumpAndSettle();
    });

    testWidgets('Timeline view renders', (tester) async {
      await tester.pumpWidget(
        provider.MultiProvider(
          providers: [
            provider.ChangeNotifierProvider(create: (_) => AccountProvider()),
            provider.ChangeNotifierProvider(create: (_) => BudgetProvider()),
            provider.ChangeNotifierProvider(
                create: (_) => TransactionProvider()),
            provider.ChangeNotifierProvider(create: (_) => ThemeProvider()),
            provider.ChangeNotifierProvider(
                create: (_) => ThemeStyleProvider()),
            provider.ChangeNotifierProvider(
                create: (_) => StreamInsightsFlagProvider(
                    flagKey: 'stream_insights', defaultValue: true)),
          ],
          child: const ProviderScope(
            child: MaterialApp(
              home: UnifiedTransactionEntryScreen(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check for timeline view
      expect(find.byKey(const Key('unified_timeline_view')), findsOneWidget);
    });

    testWidgets('Insights view renders', (tester) async {
      await tester.pumpWidget(
        provider.MultiProvider(
          providers: [
            provider.ChangeNotifierProvider(create: (_) => AccountProvider()),
            provider.ChangeNotifierProvider(create: (_) => BudgetProvider()),
            provider.ChangeNotifierProvider(
                create: (_) => TransactionProvider()),
            provider.ChangeNotifierProvider(create: (_) => ThemeProvider()),
            provider.ChangeNotifierProvider(
                create: (_) => ThemeStyleProvider()),
            provider.ChangeNotifierProvider(
                create: (_) => StreamInsightsFlagProvider(
                    flagKey: 'stream_insights', defaultValue: true)),
          ],
          child: const ProviderScope(
            child: MaterialApp(
              home: UnifiedTransactionEntryScreen(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Switch to insights pane (only becomes visible after the toggle).
      await tester.tap(find.byKey(const Key('unified_insights_nav_chip')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('unified_insights_view')), findsOneWidget);
    });
  });
}
