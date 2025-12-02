import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:your_finance_flutter/features/insights/services/http_analysis_data_source.dart';
import 'package:your_finance_flutter/core/services/dio_http_service.dart';
import 'package:your_finance_flutter/core/models/analysis_summary.dart';
import 'package:your_finance_flutter/core/models/transaction.dart';
import 'package:your_finance_flutter/core/models/flux_view_state.dart';

// Mock classes
class MockDioHttpService extends Mock implements DioHttpService {}

void main() {
  late HttpAnalysisDataSource dataSource;
  late MockDioHttpService mockHttpService;

  // Test transaction
  late Transaction testTransaction;

  setUp(() {
    mockHttpService = MockDioHttpService();
    dataSource = HttpAnalysisDataSource(mockHttpService);

    testTransaction = Transaction(
      id: 'compatibility-test-transaction',
      amount: -75.50,
      category: 'Shopping',
      description: 'Online purchase with compatibility check',
      date: DateTime(2024, 12, 2, 14, 30),
    );
  });

  group('HTTP Analysis Backwards Compatibility Tests', () {
    test('should maintain existing API contract structure', () {
      // Verify the class implements the expected interface
      expect(dataSource, isA<HttpAnalysisDataSource>());
      expect(dataSource, isA<AnalysisDataSource>());
    });

    test('should handle successful HTTP response with expected data structure', () async {
      // Arrange
      const expectedJsonResponse = '''
{
  "improvementsFound": 2,
  "topRecommendation": "Consider using cashback credit cards for online purchases",
  "score": 78
}
''';

      when(mockHttpService.post<Map<String, dynamic>>(any, data: anyNamed('data')))
          .thenAnswer((_) async => Response<Map<String, dynamic>>(
                data: {
                  'improvementsFound': 2,
                  'topRecommendation': 'Consider using cashback credit cards for online purchases',
                },
                statusCode: 200,
                requestOptions: RequestOptions(path: '/insights/analysis'),
              ));

      // Act
      final result = await dataSource.analyze(testTransaction, FluxTimeframe.weekly);

      // Assert
      expect(result.improvementsFound, 2);
      expect(result.topRecommendation, 'Consider using cashback credit cards for online purchases');
      expect(result.analysisId, isNotEmpty);

      // Verify the HTTP call was made with correct parameters
      verify(mockHttpService.post<Map<String, dynamic>>(
        '/insights/analysis',
        data: {
          'transactionIds': [testTransaction.id],
          'timeframe': 'weekly',
          'pane': 'insights',
          'flagEnabled': true,
        },
      )).called(1);
    });

    test('should handle HTTP errors gracefully without throwing exceptions', () async {
      // Arrange - Simulate HTTP failure
      when(mockHttpService.post<Map<String, dynamic>>(any, data: anyNamed('data')))
          .thenThrow(DioException(
            requestOptions: RequestOptions(path: '/insights/analysis'),
            error: 'Network timeout',
            type: DioExceptionType.connectionTimeout,
          ));

      // Act - Should not throw
      final result = await dataSource.analyze(testTransaction, FluxTimeframe.monthly);

      // Assert - Returns safe default
      expect(result.improvementsFound, 0);
      expect(result.topRecommendation, '');
      expect(result.analysisId, isNotEmpty);
    });

    test('should handle malformed response data gracefully', () async {
      // Arrange - Simulate malformed response
      when(mockHttpService.post<Map<String, dynamic>>(any, data: anyNamed('data')))
          .thenAnswer((_) async => Response<Map<String, dynamic>>(
                data: {'invalid': 'structure'},
                statusCode: 200,
                requestOptions: RequestOptions(path: '/insights/analysis'),
              ));

      // Act
      final result = await dataSource.analyze(testTransaction, FluxTimeframe.daily);

      // Assert - Returns safe default when parsing fails
      expect(result.improvementsFound, 0);
      expect(result.topRecommendation, '');
      expect(result.analysisId, isNotEmpty);
    });

    test('should handle null response data gracefully', () async {
      // Arrange - Simulate null response
      when(mockHttpService.post<Map<String, dynamic>>(any, data: anyNamed('data')))
          .thenAnswer((_) async => Response<Map<String, dynamic>>(
                data: null,
                statusCode: 200,
                requestOptions: RequestOptions(path: '/insights/analysis'),
              ));

      // Act
      final result = await dataSource.analyze(testTransaction, FluxTimeframe.yearly);

      // Assert - Returns safe default
      expect(result.improvementsFound, 0);
      expect(result.topRecommendation, '');
      expect(result.analysisId, isNotEmpty);
    });

    test('should maintain consistent error handling across different Dio exceptions', () async {
      // Test different types of HTTP errors
      final errorTypes = [
        DioExceptionType.connectionTimeout,
        DioExceptionType.receiveTimeout,
        DioExceptionType.badResponse,
        DioExceptionType.connectionError,
      ];

      for (final errorType in errorTypes) {
        // Arrange
        when(mockHttpService.post<Map<String, dynamic>>(any, data: anyNamed('data')))
            .thenThrow(DioException(
              requestOptions: RequestOptions(path: '/insights/analysis'),
              error: 'Test error',
              type: errorType,
            ));

        // Act
        final result = await dataSource.analyze(testTransaction, FluxTimeframe.weekly);

        // Assert - All errors result in safe defaults
        expect(result.improvementsFound, 0, reason: 'Error type $errorType should return safe default');
        expect(result.topRecommendation, '', reason: 'Error type $errorType should return safe default');
        expect(result.score, 0, reason: 'Error type $errorType should return safe default');
      }
    });

    test('should call correct endpoint with expected parameters', () async {
      // Arrange
      when(mockHttpService.post<Map<String, dynamic>>(any, data: anyNamed('data')))
          .thenAnswer((_) async => Response<Map<String, dynamic>>(
                data: {
                  'improvementsFound': 1,
                  'topRecommendation': 'Test recommendation',
                  'score': 85,
                },
                statusCode: 200,
                requestOptions: RequestOptions(path: '/insights/analysis'),
              ));

      // Act
      await dataSource.analyze(testTransaction, FluxTimeframe.monthly);

      // Assert - Verify exact API contract
      final verification = verify(mockHttpService.post<Map<String, dynamic>>(
        '/insights/analysis',
        data: captureAnyNamed('data'),
      ));

      verification.called(1);

      // Check the captured data
      final capturedData = verification.captured.single as Map<String, dynamic>;
      expect(capturedData['transactionIds'], [testTransaction.id]);
      expect(capturedData['timeframe'], 'monthly');
      expect(capturedData['pane'], 'insights');
      expect(capturedData['flagEnabled'], true);
    });

    test('should be instantiable with real DioHttpService', () {
      // This test ensures the class can be created with real dependencies
      // (Though in practice, we'd use the provider system)

      // We can't easily test with real DioHttpService in unit tests,
      // but we can verify the constructor signature is compatible
      final constructorTest = (DioHttpService httpService) => HttpAnalysisDataSource(httpService);

      // Verify constructor accepts DioHttpService
      final mockService = MockDioHttpService();
      final instance = constructorTest(mockService);
      expect(instance, isA<HttpAnalysisDataSource>());
    });
  });
}
