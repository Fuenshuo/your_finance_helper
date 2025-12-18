// ignore_for_file: depend_on_referenced_packages
// This file is a test utility and should only be used in tests.
// It's placed in lib/ to match the import path used by test files.

import 'package:mockito/mockito.dart';
import 'package:your_finance_flutter/core/models/ai_config.dart';
import 'package:your_finance_flutter/core/services/ai/ai_service.dart';
import 'package:your_finance_flutter/features/insights/models/daily_cap.dart';
import 'package:your_finance_flutter/features/insights/models/monthly_health.dart';
import 'package:your_finance_flutter/features/insights/models/weekly_anomaly.dart';

/// Mock AI Service for testing
///
/// This mock implements the AiService interface and provides additional
/// test-specific methods that are used in integration tests.
class MockAiService extends Mock implements AiService {
  /// Default config for the mock service
  final AiConfig _defaultConfig = AiConfig(
    provider: AiProvider.dashscope,
    apiKey: 'mock-api-key',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  /// Create a mock AI service with default config
  MockAiService() : super();

  @override
  // ignore: invalid_use_of_visible_for_testing_member
  Future<AiResponse> sendMessage({
    required List<AiMessage> messages,
    String? model,
    double? temperature,
    int? maxTokens,
    Map<String, dynamic>? extraParams,
  }) {
    // ignore: invalid_use_of_visible_for_testing_member
    return super.noSuchMethod(
      Invocation.method(
        #sendMessage,
        [],
        {
          #messages: messages,
          #model: model,
          #temperature: temperature,
          #maxTokens: maxTokens,
          #extraParams: extraParams,
        },
      ),
      returnValue: Future<AiResponse>.value(
        const AiResponse(
          content: 'Mock AI response',
          model: 'mock-model',
        ),
      ),
      returnValueForMissingStub: Future<AiResponse>.value(
        const AiResponse(
          content: 'Mock AI response',
          model: 'mock-model',
        ),
      ),
    ) as Future<AiResponse>;
  }

  @override
  List<String> getAvailableLlmModels() {
    // ignore: invalid_use_of_visible_for_testing_member
    return super.noSuchMethod(
      Invocation.getter(#getAvailableLlmModels),
      returnValue: <String>['mock-llm-model'],
      returnValueForMissingStub: <String>['mock-llm-model'],
    ) as List<String>;
  }

  @override
  List<String> getAvailableVisionModels() {
    // ignore: invalid_use_of_visible_for_testing_member
    return super.noSuchMethod(
      Invocation.getter(#getAvailableVisionModels),
      returnValue: <String>['mock-vision-model'],
      returnValueForMissingStub: <String>['mock-vision-model'],
    ) as List<String>;
  }

  @override
  Future<bool> validateApiKey() {
    // ignore: invalid_use_of_visible_for_testing_member
    return super.noSuchMethod(
      Invocation.method(#validateApiKey, []),
      returnValue: Future<bool>.value(true),
      returnValueForMissingStub: Future<bool>.value(true),
    ) as Future<bool>;
  }

  @override
  String get providerName {
    // ignore: invalid_use_of_visible_for_testing_member
    return super.noSuchMethod(
      Invocation.getter(#providerName),
      returnValue: 'mock',
      returnValueForMissingStub: 'mock',
    ) as String;
  }

  @override
  // ignore: invalid_use_of_visible_for_testing_member
  Future<AiResponse> sendVisionMessage({
    required List<AiMessage> messages,
    String? model,
    double? temperature,
    int? maxTokens,
    Map<String, dynamic>? extraParams,
  }) {
    // ignore: invalid_use_of_visible_for_testing_member
    return super.noSuchMethod(
      Invocation.method(
        #sendVisionMessage,
        [],
        {
          #messages: messages,
          #model: model,
          #temperature: temperature,
          #maxTokens: maxTokens,
          #extraParams: extraParams,
        },
      ),
      returnValue: Future<AiResponse>.value(
        const AiResponse(
          content: 'Mock vision response',
          model: 'mock-vision-model',
        ),
      ),
      returnValueForMissingStub: Future<AiResponse>.value(
        const AiResponse(
          content: 'Mock vision response',
          model: 'mock-vision-model',
        ),
      ),
    ) as Future<AiResponse>;
  }

  @override
  AiConfig get config => _defaultConfig;

  /// Mock method for daily cap analysis
  /// Used in integration tests for daily spending analysis
  /// This is a test-specific method, not part of the AiService interface
  @override
  Future<DailyCap> analyzeDailyCap(List<Map<String, dynamic>>? transactions) {
    // ignore: invalid_use_of_visible_for_testing_member
    return super.noSuchMethod(
      Invocation.method(
        #analyzeDailyCap,
        [transactions],
      ),
      returnValue: Future<DailyCap>.value(
        DailyCap(
          id: 'mock_daily_cap',
          date: DateTime.now(),
          referenceAmount: 500.0,
          currentSpending: 0.0,
          percentage: 0.0,
          status: CapStatus.safe,
        ),
      ),
      returnValueForMissingStub: Future<DailyCap>.value(
        DailyCap(
          id: 'mock_daily_cap',
          date: DateTime.now(),
          referenceAmount: 500.0,
          currentSpending: 0.0,
          percentage: 0.0,
          status: CapStatus.safe,
        ),
      ),
    ) as Future<DailyCap>;
  }

  /// Mock method for weekly pattern analysis
  /// Used in integration tests for weekly spending pattern detection
  /// This is a test-specific method, not part of the AiService interface
  Future<List<WeeklyAnomaly>> analyzeWeeklyPatterns(
    List<Map<String, dynamic>> weeklyData,
  ) {
    // ignore: invalid_use_of_visible_for_testing_member
    return super.noSuchMethod(
      Invocation.method(
        #analyzeWeeklyPatterns,
        [weeklyData],
      ),
      returnValue: Future<List<WeeklyAnomaly>>.value(<WeeklyAnomaly>[]),
      returnValueForMissingStub:
          Future<List<WeeklyAnomaly>>.value(<WeeklyAnomaly>[]),
    ) as Future<List<WeeklyAnomaly>>;
  }

  /// Mock method for monthly health analysis
  /// Used in integration tests for monthly financial health assessment
  /// This is a test-specific method, not part of the AiService interface
  Future<MonthlyHealthScore> analyzeMonthlyHealth(
    Map<String, dynamic> monthlyData,
  ) {
    // ignore: invalid_use_of_visible_for_testing_member
    return super.noSuchMethod(
      Invocation.method(
        #analyzeMonthlyHealth,
        [monthlyData],
      ),
      returnValue: Future<MonthlyHealthScore>.value(
        MonthlyHealthScore(
          id: 'mock_monthly_health',
          month: DateTime.now(),
          grade: LetterGrade.C,
          score: 75.0,
          diagnosis: 'Mock diagnosis',
          factors: const [],
          recommendations: const [],
          metrics: const {},
        ),
      ),
      returnValueForMissingStub: Future<MonthlyHealthScore>.value(
        MonthlyHealthScore(
          id: 'mock_monthly_health',
          month: DateTime.now(),
          grade: LetterGrade.C,
          score: 75.0,
          diagnosis: 'Mock diagnosis',
          factors: const [],
          recommendations: const [],
          metrics: const {},
        ),
      ),
    ) as Future<MonthlyHealthScore>;
  }
}
