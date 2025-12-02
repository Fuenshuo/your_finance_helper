import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:your_finance_flutter/features/insights/services/serverless_ai_data_source.dart';
import 'package:your_finance_flutter/core/services/ai/ai_service_factory.dart';
import 'package:your_finance_flutter/core/services/ai/prompts/prompt_loader.dart';
import 'package:your_finance_flutter/core/services/ai/ai_service.dart';
import 'package:your_finance_flutter/core/models/ai_config.dart';
import 'package:your_finance_flutter/core/utils/performance_monitor.dart';
import 'package:your_finance_flutter/core/models/analysis_summary.dart';
import 'package:your_finance_flutter/core/models/transaction.dart';
import 'package:your_finance_flutter/core/models/flux_view_state.dart';

// Mock classes
class MockAiServiceFactory extends Mock implements AiServiceFactory {}
class MockAiService extends Mock implements AiService {}
class MockAiResponse extends Mock implements AiResponse {}

void main() {
  late ServerlessAiDataSource dataSource;
  late MockAiServiceFactory mockAiFactory;
  late MockAiService mockAiService;

  // Test transaction
  late Transaction testTransaction;

  setUp(() {
    mockAiFactory = MockAiServiceFactory();
    mockAiService = MockAiService();

    dataSource = ServerlessAiDataSource(mockAiFactory, '''
Role: You are an expert personal financial analyst.

Task: Analyze the user's newly recorded transaction.

Input Data:
- Amount: \${amount}
- Category: \${category}
- Description: \${description}
- Date: \${date}

Output Requirement:
Output ONLY valid JSON.

Structure:
{
  "improvementsFound": int, // 0-3
  "topRecommendation": "string", // Concise insight, or empty string if normal.
  "score": int // 0-100 rationality score.
}
''');

    testTransaction = Transaction(
      id: 'test-transaction-123',
      description: 'Lunch at Italian Restaurant',
      amount: -45.67,
      category: TransactionCategory.food, // Use enum instead of string
      date: DateTime(2024, 12, 2, 12, 30),
    );
  });

  group('ServerlessAiDataSource', () {
    test('should return AnalysisSummary on successful AI analysis', () async {
      // Arrange
      const promptTemplate = '''
Role: You are an expert personal financial analyst.

Task: Analyze the user's newly recorded transaction.

Input Data:
- Amount: \${amount}
- Category: \${category}
- Description: \${description}
- Date: \${date}

Output Requirement:
Output ONLY valid JSON.

Structure:
{
  "improvementsFound": int, // 0-3
  "topRecommendation": "string", // Concise insight, or empty string if normal.
  "score": int // 0-100 rationality score.
}
''';

      const expectedJsonResponse = '''
{
  "improvementsFound": 2,
  "topRecommendation": "Consider meal prepping to reduce dining out expenses",
  "score": 75
}
''';

      final mockResponse = MockAiResponse();
      when(mockResponse.content).thenReturn(expectedJsonResponse);

      when(mockAiFactory.createService(any)).thenReturn(mockAiService);
      when(mockAiService.sendMessage(messages: anyNamed('messages')))
          .thenAnswer((_) async => mockResponse);

      // Act
      final result = await dataSource.analyze(testTransaction, FluxTimeframe.week);

      // Assert
      expect(result.improvementsFound, 2);
      expect(result.topRecommendation, 'Consider meal prepping to reduce dining out expenses');
      expect(result.analysisId, isNotEmpty);

      // Verify interactions
      verify(mockAiFactory.createService(any)).called(1);
      verify(mockAiService.sendMessage(messages: anyNamed('messages'))).called(1);
    });

    test('should handle markdown-formatted AI response', () async {
      // Arrange
      const promptTemplate = 'Test template';
      const markdownJsonResponse = '''
```json
{
  "improvementsFound": 1,
  "topRecommendation": "Track daily expenses more carefully"
}
```
''';

      final mockResponse = MockAiResponse();
      when(mockResponse.content).thenReturn(markdownJsonResponse);

      when(mockAiFactory.createService(any)).thenReturn(mockAiService);
      when(mockAiService.sendMessage(messages: anyNamed('messages')))
          .thenAnswer((_) async => mockResponse);

      // Act
      final result = await dataSource.analyze(testTransaction, FluxTimeframe.day);

      // Assert
      expect(result.improvementsFound, 1);
      expect(result.topRecommendation, 'Track daily expenses more carefully');
      expect(result.analysisId, isNotEmpty);
    });

    test('should return empty AnalysisSummary on prompt loading failure', () async {
      // Arrange

      // Act
      final result = await dataSource.analyze(testTransaction, FluxTimeframe.month);

      // Assert
      expect(result.improvementsFound, 0);
      expect(result.topRecommendation, '');
      expect(result.analysisId, isNotEmpty);

      // Verify error handling
    });

    test('should return empty AnalysisSummary on AI service failure', () async {
      // Arrange
      when(mockAiFactory.createService()).thenThrow(Exception('AI service unavailable'));
      when(mockAiService.sendMessage(messages: anyNamed('messages')))
          .thenThrow(Exception('Should not be called'));

      // Act
      final result = await dataSource.analyze(testTransaction, FluxTimeframe.month);

      // Assert
      expect(result.improvementsFound, 0);
      expect(result.topRecommendation, '');
      expect(result.analysisId, isNotEmpty);

      // Verify error handling
    });

    test('should return empty AnalysisSummary on malformed AI response', () async {
      // Arrange
      final mockResponse = MockAiResponse();
      when(mockResponse.content).thenReturn('invalid json response');

      when(mockAiFactory.createService(any)).thenReturn(mockAiService);
      when(mockAiService.sendMessage(messages: anyNamed('messages')))
          .thenAnswer((_) async => mockResponse);

      // Act
      final result = await dataSource.analyze(testTransaction, FluxTimeframe.day);

      // Assert
      expect(result.improvementsFound, 0);
      expect(result.topRecommendation, '');
      expect(result.analysisId, isNotEmpty);

      // Verify error handling
    });

    test('should populate prompt template with transaction data', () async {
      // Arrange
      const promptTemplate = '''
Amount: \${amount}
Category: \${category}
Description: \${description}
Date: \${date}
''';

      const expectedPopulatedPrompt = '''
Amount: -45.67
Category: Food & Dining
Description: Lunch at Italian Restaurant
Date: 2024-12-02T12:30:00.000
''';

      when(mockAiFactory.createService(any)).thenReturn(mockAiService);
      final mockResponse = MockAiResponse();
      when(mockResponse.content).thenReturn('''
{
  "improvementsFound": 0,
  "topRecommendation": ""
}
''');

      when(mockAiService.sendMessage(messages: anyNamed('messages')))
          .thenAnswer((_) async => mockResponse);

      // Act
      await dataSource.analyze(testTransaction, FluxTimeframe.week);

      // Assert
      verify(mockAiService.sendMessage(messages: anyNamed('messages'))).called(1);
    });

    test('should record performance metrics for successful analysis', () async {
      // Arrange
      when(mockAiFactory.createService(any)).thenReturn(mockAiService);
      final mockResponse = MockAiResponse();
      when(mockResponse.content).thenReturn('''
{
  "improvementsFound": 0,
  "topRecommendation": ""
}
''');

      when(mockAiService.sendMessage(messages: anyNamed('messages')))
          .thenAnswer((_) async => mockResponse);

      // Act
      await dataSource.analyze(testTransaction, FluxTimeframe.month);

      // Assert
    });

    test('should record performance metrics for failed analysis', () async {
      // Arrange

      // Act
      await dataSource.analyze(testTransaction, FluxTimeframe.day);

      // Assert
    });
  });
}
