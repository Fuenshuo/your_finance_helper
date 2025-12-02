import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:your_finance_flutter/core/providers/flux_providers.dart';
import 'package:your_finance_flutter/core/models/transaction.dart';
import 'package:your_finance_flutter/core/models/flux_view_state.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;

  setUp(() async {
    // Clear SharedPreferences for clean test state
    SharedPreferences.setMockInitialValues({});
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  group('Analysis Method Switching Integration Tests', () {
    testWidgets('should default to HTTP analysis method', (WidgetTester tester) async {
      // Act
      final analysisMethod = container.read(analysisMethodProvider);

      // Assert
      expect(analysisMethod, AnalysisMethod.http);
    });

    testWidgets('should switch between HTTP and AI analysis methods', (WidgetTester tester) async {
      // Arrange
      final notifier = container.read(analysisMethodProvider.notifier);

      // Act - Switch to AI
      await notifier.setAnalysisMethod(AnalysisMethod.serverlessAi);
      var currentMethod = container.read(analysisMethodProvider);

      // Assert
      expect(currentMethod, AnalysisMethod.serverlessAi);

      // Act - Switch back to HTTP
      await notifier.setAnalysisMethod(AnalysisMethod.http);
      currentMethod = container.read(analysisMethodProvider);

      // Assert
      expect(currentMethod, AnalysisMethod.http);
    });

    testWidgets('should toggle analysis method', (WidgetTester tester) async {
      // Arrange
      final notifier = container.read(analysisMethodProvider.notifier);

      // Initially HTTP
      expect(container.read(analysisMethodProvider), AnalysisMethod.http);

      // Act - Toggle to AI
      await notifier.toggleAnalysisMethod();
      expect(container.read(analysisMethodProvider), AnalysisMethod.serverlessAi);

      // Act - Toggle back to HTTP
      await notifier.toggleAnalysisMethod();
      expect(container.read(analysisMethodProvider), AnalysisMethod.http);
    });

    testWidgets('should persist analysis method across app restarts', (WidgetTester tester) async {
      // Arrange
      final notifier1 = container.read(analysisMethodProvider.notifier);

      // Act - Set to AI method
      await notifier1.setAnalysisMethod(AnalysisMethod.serverlessAi);

      // Simulate app restart by creating new container
      final container2 = ProviderContainer();
      final notifier2 = container2.read(analysisMethodProvider.notifier);

      // Wait for initialization
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert - Should load saved preference
      final savedMethod = container2.read(analysisMethodProvider);
      expect(savedMethod, AnalysisMethod.serverlessAi);

      container2.dispose();
    });

    testWidgets('should use correct data source based on analysis method', (WidgetTester tester) async {
      // Arrange
      final testTransaction = Transaction(
        id: 'switching-test-transaction',
        amount: -25.00,
        category: 'Food',
        description: 'Test meal',
        date: DateTime.now(),
      );

      // Test HTTP method
      final httpDataSource = container.read(httpAnalysisDataSourceProvider);
      expect(httpDataSource, isNotNull);

      // Switch to AI method
      final notifier = container.read(analysisMethodProvider.notifier);
      await notifier.setAnalysisMethod(AnalysisMethod.serverlessAi);

      // Test AI method
      final aiDataSource = container.read(serverlessAiDataSourceProvider);
      expect(aiDataSource, isNotNull);

      // Test configurable provider switches
      final initialConfigurableSource = container.read(analysisDataSourceProvider);
      expect(initialConfigurableSource, isA<HttpAnalysisDataSource>());

      await notifier.setAnalysisMethod(AnalysisMethod.serverlessAi);
      final switchedConfigurableSource = container.read(analysisDataSourceProvider);
      expect(switchedConfigurableSource, isA<ServerlessAiDataSource>());
    });

    testWidgets('should provide working analysis service with method switching', (WidgetTester tester) async {
      // Arrange
      final testTransaction = Transaction(
        id: 'service-test-transaction',
        amount: -45.00,
        category: 'Entertainment',
        description: 'Movie tickets',
        date: DateTime.now(),
      );

      // Test with HTTP method
      final httpService = container.read(streamInsightsAnalysisServiceProvider);
      expect(httpService, isNotNull);

      // Should be able to analyze transaction
      final httpResult = await httpService.analyzeTransaction(testTransaction, FluxTimeframe.weekly);
      expect(httpResult, isNotNull);
      expect(httpResult.score, greaterThanOrEqualTo(0));

      // Switch to AI method
      final notifier = container.read(analysisMethodProvider.notifier);
      await notifier.setAnalysisMethod(AnalysisMethod.serverlessAi);

      // Test with AI method
      final aiService = container.read(streamInsightsAnalysisServiceProvider);
      expect(aiService, isNotNull);

      // Should be able to analyze transaction
      final aiResult = await aiService.analyzeTransaction(testTransaction, FluxTimeframe.weekly);
      expect(aiResult, isNotNull);
      expect(aiResult.score, greaterThanOrEqualTo(0));
    });

    testWidgets('should handle method switching during analysis operations', (WidgetTester tester) async {
      // Arrange
      final testTransaction = Transaction(
        id: 'concurrent-switch-test',
        amount: -30.00,
        category: 'Transportation',
        description: 'Gas station',
        date: DateTime.now(),
      );

      final notifier = container.read(analysisMethodProvider.notifier);

      // Start analysis with HTTP method
      final httpAnalysis = container.read(streamInsightsAnalysisServiceProvider)
          .analyzeTransaction(testTransaction, FluxTimeframe.daily);

      // Switch method during analysis
      await notifier.setAnalysisMethod(AnalysisMethod.serverlessAi);

      // Complete HTTP analysis
      final httpResult = await httpAnalysis;
      expect(httpResult, isNotNull);

      // New analysis should use AI method
      final aiAnalysis = container.read(streamInsightsAnalysisServiceProvider)
          .analyzeTransaction(testTransaction, FluxTimeframe.daily);
      final aiResult = await aiAnalysis;
      expect(aiResult, isNotNull);
    });

    testWidgets('should maintain backwards compatibility with legacy API', (WidgetTester tester) async {
      // Arrange
      final service = container.read(streamInsightsAnalysisServiceProvider);

      // Test legacy method still works
      final result = await service.requestAnalysis(
        transactionIds: ['legacy-test-id'],
        timeframe: FluxTimeframe.monthly,
        pane: FluxPane.insights,
        flagEnabled: true,
      );

      // Assert
      expect(result, isNotNull);
      expect(result.score, greaterThanOrEqualTo(0));
    });
  });
}
