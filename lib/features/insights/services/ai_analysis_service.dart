import 'dart:convert';

import 'package:your_finance_flutter/core/services/ai/ai_service.dart';
import 'package:your_finance_flutter/core/services/ai/ai_service_factory.dart';
import 'package:your_finance_flutter/core/models/ai_config.dart';
import 'package:your_finance_flutter/features/insights/models/daily_cap.dart';
import 'package:your_finance_flutter/features/insights/models/micro_insight.dart';
import 'package:your_finance_flutter/features/insights/models/weekly_anomaly.dart';

/// AI-powered analysis service for generating insights from financial data
class AiAnalysisService {
  AiAnalysisService._();

  static AiAnalysisService? _instance;
  static AiService? _aiService;

  static Future<AiAnalysisService> getInstance() async {
    _instance ??= AiAnalysisService._();
    // TODO: Initialize AI service when configuration is available
    // _aiService ??= await AiServiceFactory.createService(...);
    return _instance!;
  }

  /// Generate detective-style explanation for weekly anomalies
  Future<String> generateAnomalyExplanation(
    WeeklyAnomaly anomaly, {
    String? context,
  }) async {
    if (_aiService == null) {
      // Fallback explanation
      return _generateFallbackAnomalyExplanation(anomaly);
    }

    try {
      final prompt = _buildAnomalyExplanationPrompt(anomaly, context);

      final response = await _aiService!.sendMessage(
        messages: [
          AiMessage(
            role: 'user',
            content: prompt,
          ),
        ],
      );

      return _parseAnomalyExplanationResponse(response.content);
    } catch (e) {
      return _generateFallbackAnomalyExplanation(anomaly);
    }
  }

  /// Generate micro-insight for daily spending cap
  Future<MicroInsight> generateDailyMicroInsight(
    String dailyCapId,
    DailyCap dailyCap, {
    required InsightTrigger trigger,
    String? context,
  }) async {
    if (_aiService == null) {
      // Fallback when AI is not available
      return _generateFallbackInsight(dailyCapId, dailyCap, trigger);
    }

    try {
      final prompt = _buildDailyInsightPrompt(dailyCap, trigger, context);

      final response = await _aiService!.sendMessage(
        messages: [
          AiMessage(
            role: 'user',
            content: prompt,
          ),
        ],
      );

      return _parseMicroInsightResponse(
        response.content,
        dailyCapId,
        trigger,
      );
    } catch (e) {
      // Fallback on AI failure
      return _generateFallbackInsight(dailyCapId, dailyCap, trigger);
    }
  }

  String _buildDailyInsightPrompt(
    DailyCap dailyCap,
    InsightTrigger trigger,
    String? context,
  ) {
    final spending = dailyCap.currentSpending;
    final budget = dailyCap.referenceAmount;
    final percentage = (spending / budget * 100).toStringAsFixed(1);

    return '''
作为一位专业的财务顾问，请为用户的今日消费情况生成一句简短的中文建议。

用户今日消费数据：
- 预算上限：¥${budget.toStringAsFixed(0)}
- 实际消费：¥${spending.toStringAsFixed(0)}
- 消费比例：${percentage}%

触发原因：${_triggerDescription(trigger)}

${context != null ? '额外上下文：$context' : ''}

要求：
1. 建议长度：20-50字
2. 语气：温和、专业、鼓励性
3. 包含具体金额或比例
4. 如果超出预算，建议如何调整
5. 如果控制良好，给予正面反馈

请以JSON格式返回：
{
  "sentiment": "positive|neutral|negative",
  "message": "建议内容",
  "actions": ["行动建议1", "行动建议2"]
}
''';
  }

  MicroInsight _parseMicroInsightResponse(
    String response,
    String dailyCapId,
    InsightTrigger trigger,
  ) {
    try {
      // Parse JSON response
      final jsonStart = response.indexOf('{');
      final jsonEnd = response.lastIndexOf('}');
      if (jsonStart == -1 || jsonEnd == -1) {
        throw FormatException('No JSON found in response');
      }

      final jsonStr = response.substring(jsonStart, jsonEnd + 1);
      final Map<String, dynamic> data = json.decode(jsonStr);

      return MicroInsight(
        id: 'ai_${dailyCapId}_${DateTime.now().millisecondsSinceEpoch}',
        dailyCapId: dailyCapId,
        generatedAt: DateTime.now(),
        sentiment: _parseSentiment(data['sentiment'] as String? ?? 'neutral'),
        message: data['message'] as String? ?? '消费情况正常，请继续保持。',
        actions: List<String>.from(data['actions'] ?? []),
        trigger: trigger,
      );
    } catch (e) {
      // Fallback parsing
      return _generateFallbackInsight(dailyCapId, DailyCap(
        id: dailyCapId,
        date: DateTime.now(),
        referenceAmount: 200.0,
        currentSpending: 0.0,
        percentage: 0.0,
        status: CapStatus.safe,
      ), trigger);
    }
  }

  Sentiment _parseSentiment(String sentiment) {
    switch (sentiment.toLowerCase()) {
      case 'positive':
        return Sentiment.positive;
      case 'negative':
        return Sentiment.negative;
      case 'neutral':
      default:
        return Sentiment.neutral;
    }
  }

  String _buildAnomalyExplanationPrompt(WeeklyAnomaly anomaly, String? context) {
    final isHigh = anomaly.deviation > 0;
    final percent = anomaly.deviation.abs().toStringAsFixed(0);
    final categories = anomaly.categories.join('、');

    return '''
作为一位专业的财务侦探，请分析用户的异常消费行为并给出侦探式的解释。

异常详情：
- 日期：${anomaly.anomalyDate.toString().split(' ')[0]}
- 预期消费：¥${anomaly.expectedAmount.toStringAsFixed(0)}
- 实际消费：¥${anomaly.actualAmount.toStringAsFixed(0)}
- 异常程度：${isHigh ? '高于' : '低于'}预期 $percent%
- 涉及分类：$categories

${context != null ? '额外上下文：$context' : ''}

要求：
1. 像侦探一样分析异常原因
2. 语气专业但有趣，像在讲侦探故事
3. 指出可能的消费模式或习惯
4. 给出合理的解释和建议
5. 长度控制在 50-80 字

请直接给出侦探式的分析结论。
''';
  }

  String _parseAnomalyExplanationResponse(String response) {
    // Clean up the response
    return response.trim().replaceAll('"', '').replaceAll('\n', ' ');
  }

  String _generateFallbackAnomalyExplanation(WeeklyAnomaly anomaly) {
    final isHigh = anomaly.deviation > 0;
    final percent = anomaly.deviation.abs().toStringAsFixed(0);
    final categories = anomaly.categories.isNotEmpty ? anomaly.categories[0] : '消费';

    if (isHigh) {
      return '$categories 支出异常激增 $percent%，侦探发现这可能是周末娱乐或特殊聚会导致的消费高峰。建议关注此类异常以优化预算分配。';
    } else {
      return '$categories 支出明显偏低 $percent%，这表明你在这个时间段控制得很好。侦探建议继续保持这种良好的消费习惯！';
    }
  }

  String _triggerDescription(InsightTrigger trigger) {
    switch (trigger) {
      case InsightTrigger.transactionAdded:
        return '用户刚刚添加了一笔消费记录';
      case InsightTrigger.budgetExceeded:
        return '用户的消费已接近或超过预算上限';
      case InsightTrigger.timeCheck:
        return '用户查看了消费情况';
      case InsightTrigger.manualRequest:
        return '用户主动请求分析';
    }
  }

  MicroInsight _generateFallbackInsight(
    String dailyCapId,
    DailyCap dailyCap,
    InsightTrigger trigger,
  ) {
    final spending = dailyCap.currentSpending;
    final budget = dailyCap.referenceAmount;

    String message;
    Sentiment sentiment;
    List<String> actions;

    if (spending < budget * 0.5) {
      sentiment = Sentiment.positive;
      message = '今日消费控制良好，还剩 ¥${(budget - spending).toStringAsFixed(0)} 预算空间。';
      actions = ['保持良好的消费习惯'];
    } else if (spending < budget) {
      sentiment = Sentiment.neutral;
      message = '今日消费适中，已使用 ${(spending / budget * 100).toStringAsFixed(0)}% 的预算。';
      actions = ['合理安排剩余预算'];
    } else {
      sentiment = Sentiment.negative;
      message = '今日预算超支 ¥${(spending - budget).toStringAsFixed(0)}，建议调整消费计划。';
      actions = ['查看超支原因', '调整明日预算'];
    }

    return MicroInsight(
      id: 'fallback_${dailyCapId}_${DateTime.now().millisecondsSinceEpoch}',
      dailyCapId: dailyCapId,
      generatedAt: DateTime.now(),
      sentiment: sentiment,
      message: message,
      actions: actions,
      trigger: trigger,
    );
  }
}
