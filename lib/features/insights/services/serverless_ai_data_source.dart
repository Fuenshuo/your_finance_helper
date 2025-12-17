import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:your_finance_flutter/core/services/ai/ai_service_factory.dart';
import 'package:your_finance_flutter/core/services/ai/ai_config_service.dart';
import 'package:your_finance_flutter/core/services/ai/prompts/prompt_loader.dart';
import 'package:your_finance_flutter/core/models/ai_config.dart';
import 'analysis_data_source.dart';
import '../../../core/models/analysis_summary.dart';
import '../../../core/models/transaction.dart';
import '../../../core/models/flux_view_state.dart';

/// Serverless AI-powered implementation of AnalysisDataSource.
/// Provides local AI analysis using prompt templates and AI services.
class ServerlessAiDataSource implements AnalysisDataSource {
  final AiServiceFactory _aiFactory;
  final AiConfigService _aiConfigService;
  final String? _promptTemplate; // For testing

  ServerlessAiDataSource(this._aiFactory, this._aiConfigService,
      [this._promptTemplate]);

  @override
  Future<AnalysisSummary> analyze(
      Transaction transaction, FluxTimeframe timeframe) async {
    try {
      debugPrint(
          '[ServerlessAiDataSource] Starting AI analysis for transaction: ${transaction.id}');

      // Load and populate prompt
      final promptTemplate =
          _promptTemplate ?? await PromptLoader.loadTransactionAnalysisPrompt();
      final filledPrompt = _populatePrompt(promptTemplate, transaction);

      // Perform AI analysis - load saved config, fallback to default if needed
      AiConfig aiConfig;
      try {
        final loadedConfig = await _aiConfigService.loadConfig();
        if (loadedConfig != null) {
          aiConfig = loadedConfig;
          debugPrint(
              '[ServerlessAiDataSource] Using loaded AI config: ${aiConfig.provider}');
        } else {
          debugPrint(
              '[ServerlessAiDataSource] No saved config found, using default');
          aiConfig = _createDefaultConfig();
        }
      } catch (e) {
        debugPrint(
            '[ServerlessAiDataSource] Failed to load config: $e, using default');
        aiConfig = _createDefaultConfig();
      }

      final aiService = _aiFactory.createService(aiConfig);
      final aiResponse = await aiService.sendMessage(
        messages: [AiMessage(role: 'user', content: filledPrompt)],
      );

      // Clean and parse response
      final cleanedJson = _cleanJsonResponse(aiResponse.content);
      final analysisData = jsonDecode(cleanedJson) as Map<String, dynamic>;

      final analysisSummary = AnalysisSummary.fromJson(analysisData);

      debugPrint(
          '[ServerlessAiDataSource] AI analysis completed successfully for transaction: ${transaction.id}');
      return analysisSummary;
    } catch (e) {
      debugPrint(
          '[ServerlessAiDataSource] AI analysis failed for transaction: ${transaction.id}, error: $e');
      return AnalysisSummary.empty();
    }
  }

  /// Populates the prompt template with transaction data
  String _populatePrompt(String template, Transaction transaction) {
    return template
        .replaceAll('\${amount}', transaction.amount.toString())
        .replaceAll('\${category}', transaction.category.displayName)
        .replaceAll('\${description}', transaction.description)
        .replaceAll('\${date}', transaction.date.toIso8601String());
  }

  /// Cleans AI response by removing markdown formatting
  String _cleanJsonResponse(String aiResponse) {
    // Remove markdown code blocks if present
    var cleaned = aiResponse.trim();
    if (cleaned.startsWith('```json')) {
      cleaned = cleaned.substring(7);
    }
    if (cleaned.endsWith('```')) {
      cleaned = cleaned.substring(0, cleaned.length - 3);
    }
    return cleaned.trim();
  }

  /// Create default AI config for transaction analysis
  static AiConfig _createDefaultConfig() {
    final now = DateTime.now();
    return AiConfig(
      provider: AiProvider.dashscope,
      apiKey:
          'dummy-key-for-development', // This should be configured properly in production
      createdAt: now,
      updatedAt: now,
      llmModel: 'qwen-turbo',
    );
  }
}
