import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'
    hide ChangeNotifierProvider;
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:your_finance_flutter/core/models/account.dart';
import 'package:your_finance_flutter/core/models/budget.dart';
import 'package:your_finance_flutter/core/models/flux_view_state.dart';
import 'package:your_finance_flutter/core/models/parsed_transaction.dart';
import 'package:your_finance_flutter/core/models/transaction.dart';
import 'package:your_finance_flutter/core/providers/account_provider.dart';
import 'package:your_finance_flutter/core/providers/budget_provider.dart';
import 'package:your_finance_flutter/core/providers/flux_providers.dart';
import 'package:your_finance_flutter/core/providers/stream_insights_flag_provider.dart';
import 'package:your_finance_flutter/core/providers/theme_provider.dart';
import 'package:your_finance_flutter/core/providers/theme_style_provider.dart';
import 'package:your_finance_flutter/core/providers/transaction_provider.dart';
import 'package:your_finance_flutter/screens/unified_transaction_entry_screen.dart';

const Key kTimeframeSegmentedControlKey =
    Key('unified_timeframe_segmented_control');
const Key kTimelineViewKey = Key('unified_timeline_view');
const Key kInsightsViewKey = Key('unified_insights_view');
const Key kInsightsNavChipKey = Key('unified_insights_nav_chip');
const Key kInputDockKey = Key('unified_input_dock');
const Key kTimelineGroupListKey = Key('unified_timeline_group_list');
const Key kDraftCardKey = Key('unified_draft_card');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('UnifiedTransactionEntryScreen Tests', () {
    testWidgets(
      'segmented control taps update FluxViewState timeframe',
      (tester) async {
        final harness = await _pumpUnifiedTransactionEntryScreen(tester);

        expect(find.byKey(kTimeframeSegmentedControlKey), findsOneWidget);
        expect(
          harness.container.read(fluxViewStateProvider).timeframe,
          FluxTimeframe.day,
        );

        await tester.tap(find.text('Week'));
        await tester.pumpAndSettle();
        expect(
          harness.container.read(fluxViewStateProvider).timeframe,
          FluxTimeframe.week,
        );

        await tester.tap(find.text('Month'));
        await tester.pumpAndSettle();
        expect(
          harness.container.read(fluxViewStateProvider).timeframe,
          FluxTimeframe.month,
        );
      },
    );

    testWidgets(
      'AnimatedSwitcher swaps timeline and insights panes while keeping input dock intact',
      (tester) async {
        await _pumpUnifiedTransactionEntryScreen(tester);

        expect(find.byKey(kTimelineViewKey), findsOneWidget);
        expect(find.byKey(kInsightsViewKey), findsNothing);
        expect(find.byKey(kInputDockKey), findsOneWidget);

        await tester.tap(find.byKey(kInsightsNavChipKey));
        await tester.pumpAndSettle();

        expect(find.byKey(kTimelineViewKey), findsNothing);
        expect(find.byKey(kInsightsViewKey), findsOneWidget);
        expect(find.byKey(kInputDockKey), findsOneWidget);
      },
    );

    testWidgets(
      'renders grouped day cards, draft card, and AI input dock interactions',
      (tester) async {
        final initialDraft = ParsedTransaction(
          description: 'AI Draft: Coffee',
          amount: 45,
          accountId: _sampleAccounts.first.id,
          accountName: _sampleAccounts.first.name,
        );

        await _pumpUnifiedTransactionEntryScreen(
          tester,
          transactions: _sampleTransactions,
          initialDraft: initialDraft,
        );

        expect(find.textContaining('1月14日'), findsOneWidget);
        expect(find.textContaining('1月13日'), findsOneWidget);
        expect(find.text('AI Draft: Coffee'), findsOneWidget);
        expect(find.byKey(kDraftCardKey), findsOneWidget);

        final inputField = find.byType(TextField);
        expect(inputField, findsOneWidget);
        await tester.enterText(inputField, '午餐 58');
        await tester.pump();
        expect(find.text('午餐 58'), findsOneWidget);
        expect(
          find.byKey(const ValueKey('rainbow-send-button')),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'feature flag disabled hides merged header and insights view',
      (tester) async {
        await _pumpUnifiedTransactionEntryScreen(
          tester,
          flagEnabled: false,
        );

        expect(find.byKey(kTimeframeSegmentedControlKey), findsNothing);
        expect(find.byKey(kInsightsNavChipKey), findsNothing);
        expect(find.byKey(kInsightsViewKey), findsNothing);
        expect(find.byKey(kTimelineViewKey), findsOneWidget);
      },
    );
  });
}

class _ScreenHarness {
  const _ScreenHarness({
    required this.container,
  });

  final ProviderContainer container;
}

Future<_ScreenHarness> _pumpUnifiedTransactionEntryScreen(
  WidgetTester tester, {
  List<Transaction>? transactions,
  ParsedTransaction? initialDraft,
  bool flagEnabled = true,
}) async {
  final seededTransactions = transactions ?? _sampleTransactions;
  final transactionProvider = TransactionProvider()
    ..seedTransactionsForTesting(transactions: seededTransactions);
  final accountProvider = AccountProvider()
    ..seedAccountsForTesting(_sampleAccounts);
  final budgetProvider = BudgetProvider()
    ..seedBudgetsForTesting(envelopeBudgets: _sampleEnvelopeBudgets);
  final themeProvider = ThemeProvider();
  final themeStyleProvider = ThemeStyleProvider();
  await themeStyleProvider.initialize();

  final prefs = await SharedPreferences.getInstance();
  final flagProvider = StreamInsightsFlagProvider(
    flagKey: streamInsightsFeatureFlag,
    defaultValue: flagEnabled,
    sharedPreferences: prefs,
  );
  await flagProvider.initialize();

  final container = ProviderContainer(
    overrides: [
      streamInsightsFlagStateProvider.overrideWith(
        (ref) => flagProvider,
      ),
      fluxViewStateProvider.overrideWith(
        (ref) => FluxViewStateNotifier(
          initialState: FluxViewState.initial(isFlagEnabled: flagEnabled),
        ),
      ),
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider<TransactionProvider>.value(
            value: transactionProvider,
          ),
          ChangeNotifierProvider<AccountProvider>.value(
            value: accountProvider,
          ),
          ChangeNotifierProvider<BudgetProvider>.value(
            value: budgetProvider,
          ),
          ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
          ChangeNotifierProvider<ThemeStyleProvider>.value(
            value: themeStyleProvider,
          ),
        ],
        child: MaterialApp(
          home: UnifiedTransactionEntryScreen(
            initialDraft: initialDraft,
          ),
        ),
      ),
    ),
  );

  await tester.pump();
  await tester.pump(const Duration(milliseconds: 200));

  return _ScreenHarness(container: container);
}

List<Transaction> get _sampleTransactions => [
      Transaction(
        description: 'Coffee',
        amount: 36,
        type: TransactionType.expense,
        category: TransactionCategory.food,
        date: DateTime(2025, 1, 14, 9),
        fromAccountId: _sampleAccounts.first.id,
      ),
      Transaction(
        description: 'Salary',
        amount: 1200,
        type: TransactionType.income,
        category: TransactionCategory.salary,
        date: DateTime(2025, 1, 13, 12),
        toAccountId: _sampleAccounts.first.id,
      ),
    ];

List<Account> get _sampleAccounts => [
      Account(
        id: 'acc-main',
        name: '主钱包',
        type: AccountType.cash,
        balance: 3200,
        creationDate: DateTime(2024, 1, 1), // ignore: avoid_redundant_argument_values
      ),
    ];

List<EnvelopeBudget> get _sampleEnvelopeBudgets => [
      EnvelopeBudget(
        id: 'budget-food',
        name: '餐饮预算',
        category: TransactionCategory.food,
        allocatedAmount: 800,
        spentAmount: 120,
        period: BudgetPeriod.monthly,
        startDate: DateTime(2025, 1, 1), // ignore: avoid_redundant_argument_values
        endDate: DateTime(2025, 1, 31),
      ),
    ];
