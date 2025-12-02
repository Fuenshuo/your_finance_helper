import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:your_finance_flutter/features/insights/services/serverless_ai_data_source.dart';
import 'package:your_finance_flutter/core/services/ai/ai_service_factory.dart';
import 'package:your_finance_flutter/core/services/ai/prompt_loader.dart';
import 'package:your_finance_flutter/core/utils/performance_monitor.dart';
import 'package:your_finance_flutter/core/models/transaction.dart';
import 'package:your_finance_flutter/core/models/flux_view_state.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late ServerlessAiDataSource dataSource;
  late AiServiceFactory aiFactory;
  late PromptLoader promptLoader;
  late PerformanceMonitor performanceMonitor;

  setUp(() async {
    // Initialize real dependencies for integration testing
    aiFactory = AiServiceFactory();
    promptLoader = PromptLoader();
    performanceMonitor = PerformanceMonitor();

    dataSource = ServerlessAiDataSource(
      aiFactory,
      promptLoader,
      performanceMonitor,
    );
  });

  group('AI Analysis Integration Tests', () {
    testWidgets('complete AI analysis workflow completes within 5 seconds',
        (WidgetTester tester) async {
      // Arrange
      final transaction = Transaction(
        id: 'integration-test-transaction',
        description: 'Gas station fill-up',
        amount: -25.50,
        category: TransactionCategory.transport,
        date: DateTime.now(),
      );

      // Act
      final stopwatch = Stopwatch()..start();
      final result = await dataSource.analyze(transaction, FluxTimeframe.week);
      stopwatch.stop();

      // Assert
      expect(stopwatch.elapsedMilliseconds, lessThan(5000),
          reason: 'AI analysis should complete within 5 seconds');

      // Result should be valid AnalysisSummary (success or safe default)
      expect(result, isNotNull);
      expect(result.improvementsFound, isA<int>());
      expect(result.improvementsFound, greaterThanOrEqualTo(0));
      expect(result.improvementsFound, lessThanOrEqualTo(3));
      expect(result.score, isA<int>());
      expect(result.score, greaterThanOrEqualTo(0));
      expect(result.score, lessThanOrEqualTo(100));
      expect(result.topRecommendation, isA<String>());
    });

    testWidgets('AI analysis handles various transaction types',
        (WidgetTester tester) async {
      // Test different transaction scenarios
      final testCases = [
        Transaction(
          id: 'income-test',
          description: 'Monthly salary',
          amount: 5000.00,
          category: TransactionCategory.salary,
          date: DateTime.now(),
        ),
        Transaction(
          id: 'expense-test',
          description: 'Movie tickets and popcorn',
          amount: -150.00,
          category: TransactionCategory.entertainment,
          date: DateTime.now(),
        ),
        Transaction(
          id: 'transfer-test',
          description: 'Investment transfer',
          amount: -1000.00,
          category: TransactionCategory.otherExpense,
          date: DateTime.now(),
        ),
      ];

      for (final transaction in testCases) {
        // Act
        final stopwatch = Stopwatch()..start();
        final result = await dataSource.analyze(transaction, FluxTimeframe.month);
        stopwatch.stop();

        // Assert
        expect(stopwatch.elapsedMilliseconds, lessThan(5000),
            reason: 'Analysis for ${transaction.category} should complete within 5 seconds');

        expect(result, isNotNull,
            reason: 'Analysis result should not be null for ${transaction.category}');
        expect(result.improvementsFound, greaterThanOrEqualTo(0),
            reason: 'Improvements found should be valid for ${transaction.category}');
        expect(result.score, greaterThanOrEqualTo(0),
            reason: 'Score should be valid for ${transaction.category}');
      }
    });

    testWidgets('AI analysis maintains silent failure on service unavailability',
        (WidgetTester tester) async {
      // This test verifies that if AI services are unavailable,
      // the system gracefully returns safe defaults without throwing exceptions

      final transaction = Transaction(
        id: 'failure-test-transaction',
        description: 'Online purchase',
        amount: -75.00,
        category: TransactionCategory.shopping,
        date: DateTime.now(),
      );

      // Act & Assert - This should not throw any exceptions
      // even if AI services are unavailable during testing
      final result = await dataSource.analyze(transaction, FluxTimeframe.day);

      // Verify we get a safe default response
      expect(result, isNotNull);
      expect(result.improvementsFound, 0); // Safe default
      expect(result.topRecommendation, ''); // Safe default
      expect(result.score, 0); // Safe default
    });

    testWidgets('AI analysis performance is consistent across multiple calls',
        (WidgetTester tester) async {
      // Test performance consistency
      final transaction = Transaction(
        id: 'performance-test',
        description: 'Grocery shopping',
        amount: -50.00,
        category: TransactionCategory.food,
        date: DateTime.now(),
      );

      final durations = <int>[];

      // Perform multiple analysis calls
      for (int i = 0; i < 3; i++) {
        final stopwatch = Stopwatch()..start();
        await dataSource.analyze(transaction, FluxTimeframe.week);
        stopwatch.stop();
        durations.add(stopwatch.elapsedMilliseconds);
      }

      // Assert performance consistency
      final averageDuration = durations.reduce((a, b) => a + b) / durations.length;
      expect(averageDuration, lessThan(5000),
          reason: 'Average analysis time should be under 5 seconds');

      // Check that performance is reasonably consistent
      final maxDuration = durations.reduce((a, b) => a > b ? a : b);
      final minDuration = durations.reduce((a, b) => a < b ? a : b);
      final variance = maxDuration - minDuration;

      expect(variance, lessThan(2000),
          reason: 'Performance variance should be reasonable (< 2 seconds difference)');
    });
  });
}
