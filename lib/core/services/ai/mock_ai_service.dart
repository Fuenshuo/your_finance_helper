import 'package:your_finance_flutter/core/models/ai_config.dart';
import 'package:your_finance_flutter/core/services/ai/ai_service.dart';
import 'package:your_finance_flutter/features/insights/models/daily_cap.dart';
import 'package:your_finance_flutter/features/insights/models/monthly_health.dart';

/// Mock AI Service for testing
class MockAiService implements AiService {
  MockAiService([AiConfig? config])
      : config = config ??
            AiConfig(
              provider: AiProvider.dashscope,
              apiKey: 'mock-key',
              createdAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
              updatedAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
            );
  @override
  final AiConfig config;

  @override
  Future<AiResponse> sendMessage({
    required List<AiMessage> messages,
    String? model,
    double? temperature,
    int? maxTokens,
    Map<String, dynamic>? extraParams,
  }) async =>
      AiResponse(
        content: 'Mock response',
        tokenUsage: const TokenUsage(
          promptTokens: 10,
          completionTokens: 20,
          totalTokens: 30,
        ),
        model: model ?? 'mock-model',
        finishReason: 'stop',
      );

  @override
  Future<AiResponse> sendVisionMessage({
    required List<AiMessage> messages,
    String? model,
    double? temperature,
    int? maxTokens,
    Map<String, dynamic>? extraParams,
  }) async =>
      AiResponse(
        content: 'Mock vision response',
        tokenUsage: const TokenUsage(
          promptTokens: 10,
          completionTokens: 20,
          totalTokens: 30,
        ),
        model: model ?? 'mock-vision-model',
        finishReason: 'stop',
      );

  @override
  List<String> getAvailableLlmModels() => ['mock-llm-model'];

  @override
  List<String> getAvailableVisionModels() => ['mock-vision-model'];

  @override
  Future<bool> validateApiKey() async => true;

  @override
  String get providerName => 'Mock AI Service';

  /// Analyze daily spending cap
  Future<DailyCap> analyzeDailyCap(
    List<Map<String, dynamic>>? transactions,
  ) async {
    // Return a mock daily cap
    return DailyCap(
      id: 'mock-daily-cap',
      date: DateTime.now(),
      referenceAmount: 100.0,
      currentSpending: 50.0,
      percentage: 0.5,
      status: CapStatus.safe,
    );
  }

  /// Analyze monthly health
  Future<MonthlyHealthScore> analyzeMonthlyHealth(
    Map<String, dynamic> monthlyData,
  ) async {
    // Return a mock monthly health score
    return MonthlyHealthScore(
      id: 'mock-monthly-health',
      month: DateTime.now(),
      grade: LetterGrade.B,
      score: 85.0,
      diagnosis: 'Mock monthly health analysis',
      factors: const [
        HealthFactor(
          name: '支出控制',
          impact: 0.8,
          description: '支出控制良好',
        ),
      ],
      recommendations: const ['保持良好习惯'],
      metrics: const {'testRatio': 1.0},
    );
  }

  /// Analyze weekly patterns
  Future<Map<String, dynamic>> analyzeWeeklyPatterns(
    Map<String, dynamic> weeklyData,
  ) async {
    // Return mock weekly analysis
    return {
      'anomalies': <dynamic>[],
      'trend': 'stable',
      'insights': ['本周消费较为平稳'],
    };
  }
}
