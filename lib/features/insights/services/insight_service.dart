import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:your_finance_flutter/features/insights/models/daily_cap.dart';
import 'package:your_finance_flutter/features/insights/models/flux_loop_job.dart';
import 'package:your_finance_flutter/features/insights/models/micro_insight.dart';
import 'package:your_finance_flutter/features/insights/models/weekly_anomaly.dart';
import 'package:your_finance_flutter/features/insights/models/monthly_health.dart';
import 'package:your_finance_flutter/core/models/ai_config.dart';
import 'package:your_finance_flutter/core/services/ai/ai_service.dart';
import 'package:your_finance_flutter/core/services/ai/ai_service_factory.dart';

/// Flux Loop Insight Service - orchestrates AI-powered financial insights
class InsightService {
  InsightService({
    AiService? aiService,
  }) : _aiService = aiService ?? AiServiceFactory.createService(_createDefaultConfig());

  final AiService _aiService;

  // Active background jobs
  final Map<String, FluxLoopJob> _activeJobs = {};
  final Map<String, StreamController<FluxLoopJob>> _jobControllers = {};

  /// Trigger background analysis for transaction changes
  Future<FluxLoopJob> triggerAnalysis({
    required JobType type,
    required String transactionId,
    Map<String, dynamic>? metadata,
  }) async {
    final jobId = 'job_${DateTime.now().millisecondsSinceEpoch}';
    final job = FluxLoopJob(
      id: jobId,
      type: type,
      status: JobStatus.queued,
      createdAt: DateTime.now(),
      metadata: {
        'transactionId': transactionId,
        ...?metadata,
      },
    );

    _activeJobs[jobId] = job;
    _jobControllers[jobId] = StreamController<FluxLoopJob>.broadcast();

    // Start background processing
    _processJob(job);

    return job;
  }

  /// Get job status updates stream
  Stream<FluxLoopJob> jobStatusStream(String jobId) {
    return _jobControllers[jobId]?.stream ?? Stream.empty();
  }

  /// Generate micro-insight for daily spending
  Future<MicroInsight> generateMicroInsight({
    required String dailyCapId,
    required InsightTrigger trigger,
    String? context,
  }) async {
    try {
      final prompt = _buildMicroInsightPrompt(trigger, context);

      // Generate AI response
      final response = await _aiService.sendMessage(
        messages: [
          AiMessage(
            role: 'user',
            content: prompt,
          ),
        ],
      );

      // Parse AI response (simplified - would need proper JSON parsing)
      final sentiment = _parseSentimentFromResponse(response.content);
      final message = _extractMessageFromResponse(response.content);
      final actions = _extractActionsFromResponse(response.content);

      return MicroInsight(
        id: 'micro_${DateTime.now().millisecondsSinceEpoch}',
        dailyCapId: dailyCapId,
        generatedAt: DateTime.now(),
        sentiment: sentiment,
        message: message,
        actions: actions,
        trigger: trigger,
      );
    } catch (e) {
      // Fallback to basic insight
      return MicroInsight(
        id: 'fallback_${DateTime.now().millisecondsSinceEpoch}',
        dailyCapId: dailyCapId,
        generatedAt: DateTime.now(),
        sentiment: Sentiment.neutral,
        message: '消费分析完成，请继续保持良好的消费习惯。',
        actions: ['查看消费明细'],
        trigger: trigger,
      );
    }
  }

  /// Process background job
  Future<void> _processJob(FluxLoopJob job) async {
    try {
      // Update job status to processing
      final processingJob = job.copyWith(status: JobStatus.processing);
      _activeJobs[job.id] = processingJob;
      _jobControllers[job.id]?.add(processingJob);

      // Perform analysis based on job type
      final result = await _performAnalysis(job);

      // Complete job
      final completedJob = job.copyWith(
        status: JobStatus.completed,
        completedAt: DateTime.now(),
        result: jsonEncode(result),
      );

      _activeJobs[job.id] = completedJob;
      _jobControllers[job.id]?.add(completedJob);

    } catch (e) {
      // Fail job
      final failedJob = job.copyWith(
        status: JobStatus.failed,
        completedAt: DateTime.now(),
        error: e.toString(),
      );

      _activeJobs[job.id] = failedJob;
      _jobControllers[job.id]?.add(failedJob);
    } finally {
      // Clean up
      await Future.delayed(const Duration(seconds: 1));
      _jobControllers[job.id]?.close();
      _jobControllers.remove(job.id);
      _activeJobs.remove(job.id);
    }
  }

  /// Perform analysis based on job type
  Future<Map<String, dynamic>> _performAnalysis(FluxLoopJob job) async {
    switch (job.type) {
      case JobType.dailyAnalysis:
        return await _performDailyAnalysis(job);
      case JobType.weeklyPatterns:
        return await _performWeeklyAnalysis(job);
      case JobType.monthlyHealth:
        return await _performMonthlyAnalysis(job);
      case JobType.microInsight:
        return await _performMicroInsightAnalysis(job);
    }
  }

  /// Daily analysis - calculate spending impact
  Future<Map<String, dynamic>> _performDailyAnalysis(FluxLoopJob job) async {
    // Simplified implementation - would analyze transaction impact on daily budget
    return {
      'spendingImpact': 0.0,
      'budgetUtilization': 0.0,
      'recommendations': ['保持当前消费节奏'],
    };
  }

  /// Weekly analysis - detect spending patterns
  Future<Map<String, dynamic>> _performWeeklyAnalysis(FluxLoopJob job) async {
    // Simplified implementation - would detect anomalies in weekly spending
    return {
      'anomalies': [],
      'trend': 'stable',
      'insights': ['本周消费较为平稳'],
    };
  }

  /// Monthly analysis - comprehensive health check
  Future<Map<String, dynamic>> _performMonthlyAnalysis(FluxLoopJob job) async {
    // Simplified implementation - would provide monthly financial health
    return {
      'healthScore': 85.0,
      'grade': 'B',
      'factors': ['预算控制良好', '消费结构合理'],
    };
  }

  /// Micro-insight analysis
  Future<Map<String, dynamic>> _performMicroInsightAnalysis(FluxLoopJob job) async {
    // Generate targeted micro-insight
    return {
      'sentiment': 'neutral',
      'message': '消费行为分析完成',
      'actions': ['查看详细建议'],
    };
  }

  /// Build micro-insight prompt
  String _buildMicroInsightPrompt(InsightTrigger trigger, String? context) {
    final basePrompt = '''
你是一个专业的财务顾问，请根据用户的消费行为提供简短、有帮助的见解。

触发类型: ${trigger.name}
${context != null ? '上下文信息: $context' : ''}

请提供:
1. 情感倾向 (positive/neutral/negative)
2. 一句简短的中文评论 (20-50字)
3. 1-3个具体的行动建议

请用JSON格式返回:
{
  "sentiment": "positive|neutral|negative",
  "message": "中文评论",
  "actions": ["建议1", "建议2"]
}
''';

    return basePrompt;
  }

  /// Parse sentiment from AI response
  Sentiment _parseSentimentFromResponse(String response) {
    if (response.contains('"sentiment": "positive"')) return Sentiment.positive;
    if (response.contains('"sentiment": "negative"')) return Sentiment.negative;
    return Sentiment.neutral;
  }

  /// Extract message from AI response
  String _extractMessageFromResponse(String response) {
    // Simplified extraction - would need proper JSON parsing
    final messageMatch = RegExp(r'"message": "([^"]*)"').firstMatch(response);
    return messageMatch?.group(1) ?? '消费分析完成';
  }

  /// Extract actions from AI response
  List<String> _extractActionsFromResponse(String response) {
    // Simplified extraction - would need proper JSON parsing
    final actionsSection = response.contains('"actions": [')
        ? response.split('"actions": [')[1].split(']')[0]
        : '';

    if (actionsSection.isEmpty) return ['查看消费明细'];

    // Extract quoted strings
    final actionMatches = RegExp(r'"([^"]*)"').allMatches(actionsSection);
    return actionMatches.map((match) => match.group(1)!).toList();
  }

  /// Create default AI config for development
  static AiConfig _createDefaultConfig() {
    final now = DateTime.now();
    return AiConfig(
      provider: AiProvider.dashscope,
      apiKey: 'dummy-key-for-development',
      createdAt: now,
      updatedAt: now,
      llmModel: 'qwen-turbo',
    );
  }

  /// Clean up resources
  void dispose() {
    for (final controller in _jobControllers.values) {
      controller.close();
    }
    _jobControllers.clear();
    _activeJobs.clear();
  }
}
