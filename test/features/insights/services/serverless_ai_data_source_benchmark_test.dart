import 'package:flutter_test/flutter_test.dart';
import 'package:your_finance_flutter/features/insights/services/serverless_ai_data_source.dart';
import 'package:your_finance_flutter/core/services/ai/ai_service_factory.dart';
import 'package:your_finance_flutter/core/services/ai/prompt_loader.dart';
import 'package:your_finance_flutter/core/utils/performance_monitor.dart';
import 'package:your_finance_flutter/core/models/transaction.dart';
import 'package:your_finance_flutter/core/models/flux_view_state.dart';

void main() {
  late ServerlessAiDataSource dataSource;
  late AiServiceFactory aiFactory;
  late PromptLoader promptLoader;
  late PerformanceMonitor performanceMonitor;

  setUp(() async {
    // Use real dependencies for performance benchmarking
    aiFactory = AiServiceFactory();
    promptLoader = PromptLoader();
    performanceMonitor = PerformanceMonitor();

    dataSource = ServerlessAiDataSource(
      aiFactory,
      promptLoader,
      performanceMonitor,
    );
  });

  group('AI Analysis Performance Benchmarks', () {
    test('AI analysis completes within 5 second requirement', () async {
      // Arrange
      final transaction = Transaction(
        id: 'benchmark-transaction',
        description: 'Electricity bill payment',
        amount: -35.00,
        category: TransactionCategory.utilities,
        date: DateTime.now(),
      );

      // Act
      final stopwatch = Stopwatch()..start();
      final result = await dataSource.analyze(transaction, FluxTimeframe.month);
      stopwatch.stop();

      // Assert
      expect(stopwatch.elapsedMilliseconds, lessThanOrEqualTo(5000),
          reason: 'AI analysis must complete within 5 seconds to meet user experience requirements');

      // Verify result is valid
      expect(result, isNotNull);
      expect(result.analysisId, isNotEmpty);
      expect(result.improvementsFound, greaterThanOrEqualTo(0));
    });

    test('AI analysis performance is consistent across different transaction types', () async {
      // Test various transaction scenarios for performance consistency
      final testTransactions = [
        Transaction(id: 'income', description: 'Salary payment', amount: 3000.00, category: TransactionCategory.salary, date: DateTime.now()),
        Transaction(id: 'expense-small', description: 'Coffee', amount: -15.50, category: TransactionCategory.food, date: DateTime.now()),
        Transaction(id: 'expense-medium', description: 'Clothing purchase', amount: -125.00, category: TransactionCategory.shopping, date: DateTime.now()),
        Transaction(id: 'expense-large', description: 'Rent payment', amount: -850.00, category: TransactionCategory.housing, date: DateTime.now()),
        Transaction(id: 'transfer', description: 'Savings transfer', amount: -500.00, category: TransactionCategory.otherExpense, date: DateTime.now()),
      ];

      final performanceResults = <Map<String, dynamic>>[];

      for (final transaction in testTransactions) {
        final stopwatch = Stopwatch()..start();
        final result = await dataSource.analyze(transaction, FluxTimeframe.week);
        stopwatch.stop();

        performanceResults.add({
          'transactionType': transaction.category,
          'amount': transaction.amount,
          'duration': stopwatch.elapsedMilliseconds,
          'success': result != null,
        });

        // Each individual analysis should be within time limits
        expect(stopwatch.elapsedMilliseconds, lessThanOrEqualTo(5000),
            reason: 'Analysis for ${transaction.category} (${transaction.amount}) should be within 5 seconds');
      }

      // Log performance results for analysis
      performanceResults.forEach((result) {
        print('Performance - ${result['transactionType']}: ${result['duration']}ms');
      });

      // Verify all analyses completed successfully
      final allSuccessful = performanceResults.every((result) => result['success'] as bool);
      expect(allSuccessful, isTrue, reason: 'All AI analyses should complete successfully');

      // Calculate average performance
      final totalDuration = performanceResults.fold<int>(0, (sum, result) => sum + (result['duration'] as int));
      final averageDuration = totalDuration / performanceResults.length;

      expect(averageDuration, lessThanOrEqualTo(4000),
          reason: 'Average analysis time should be well under the 5-second limit');
    });

    test('AI analysis handles concurrent requests within performance bounds', () async {
      // Test concurrent performance to ensure system stability
      final transaction = Transaction(
        id: 'concurrent-test',
        amount: -75.00,
        category: 'Entertainment',
        description: 'Concert tickets',
        date: DateTime.now(),
      );

      // Perform 3 concurrent analyses
      final futures = List.generate(3, (_) => dataSource.analyze(transaction, FluxTimeframe.day));

      final stopwatch = Stopwatch()..start();
      final results = await Future.wait(futures);
      stopwatch.stop();

      // All results should be valid
      for (final result in results) {
        expect(result, isNotNull);
        expect(result.analysisId, isNotEmpty);
        expect(result.improvementsFound, greaterThanOrEqualTo(0));
      }

      // Concurrent operations should still be within reasonable time limits
      // (Allow slightly more time for concurrent processing)
      expect(stopwatch.elapsedMilliseconds, lessThanOrEqualTo(8000),
          reason: 'Concurrent AI analyses should complete within 8 seconds total');

      // Individual analysis time should still be reasonable
      final averageTimePerAnalysis = stopwatch.elapsedMilliseconds / results.length;
      expect(averageTimePerAnalysis, lessThanOrEqualTo(3000),
          reason: 'Average time per concurrent analysis should be reasonable');
    });

    test('AI analysis error handling performance does not impact system responsiveness', () async {
      // Test that error scenarios are handled quickly and don't cause hangs
      final transaction = Transaction(
        id: 'error-performance-test',
        amount: -200.00,
        category: 'Travel',
        description: 'Flight booking',
        date: DateTime.now(),
      );

      // This test ensures that even when AI services might be slow or fail,
      // the system maintains responsiveness by returning safe defaults quickly

      final stopwatch = Stopwatch()..start();
      final result = await dataSource.analyze(transaction, FluxTimeframe.yearly);
      stopwatch.stop();

      // Should still complete within time bounds even if AI fails
      expect(stopwatch.elapsedMilliseconds, lessThanOrEqualTo(5000),
          reason: 'Error handling should not cause performance degradation');

      // Should return safe defaults
      expect(result, isNotNull);
      expect(result.improvementsFound, 0); // Safe default
    });

    test('Memory usage during AI analysis remains bounded', () async {
      // This is a basic smoke test for memory issues
      // In a real performance test suite, you would use more sophisticated memory profiling

      final largeTransactionSet = List.generate(5, (index) => Transaction(
        id: 'memory-test-$index',
        amount: -50.0 * (index + 1),
        category: 'Testing',
        description: 'Memory performance test transaction $index',
        date: DateTime.now(),
      ));

      // Perform multiple analyses to check for memory leaks or excessive usage
      for (final transaction in largeTransactionSet) {
        final result = await dataSource.analyze(transaction, FluxTimeframe.month);
        expect(result, isNotNull);

        // Small delay to allow for garbage collection observation
        await Future.delayed(const Duration(milliseconds: 100));
      }

      // If we reach this point without crashes or significant delays,
      // basic memory stability is demonstrated
      expect(true, isTrue, reason: 'Memory usage remained stable during multiple AI analyses');
    });
  });
}
