import 'package:flutter/foundation.dart';
import 'package:your_finance_flutter/core/models/analysis_summary.dart';
import 'package:your_finance_flutter/core/models/flux_view_state.dart';
import 'package:your_finance_flutter/core/models/transaction.dart';
import 'package:your_finance_flutter/core/services/ai/ai_config_service.dart';
import 'package:your_finance_flutter/core/services/ai/ai_service_factory.dart';
import 'package:your_finance_flutter/core/utils/logger.dart';
import 'package:your_finance_flutter/features/insights/services/analysis_data_source.dart';
import 'package:your_finance_flutter/features/insights/services/serverless_ai_data_source.dart';

/// Facade service providing unified API for transaction analysis.
/// Delegates to Serverless AI AnalysisDataSource implementation.
///
/// This service uses the facade pattern to hide the complexity of AI analysis
/// while providing a consistent API for transaction analysis capabilities.
class StreamInsightsAnalysisService {
  /// Constructor with dependency injection
  StreamInsightsAnalysisService(this._dataSource);

  /// The analysis data source to delegate to
  final AnalysisDataSource _dataSource;

  /// Legacy factory method for backwards compatibility
  /// @deprecated Use dependency injection instead
  static StreamInsightsAnalysisService? _instance;

  /// @deprecated Use dependency injection instead
  static Future<StreamInsightsAnalysisService> getInstance() async {
    if (_instance != null) {
      return _instance!;
    }
    // Use Serverless AI implementation
    final aiFactory = AiServiceFactoryImpl();

    // Load AI config - must be configured by user, no defaults allowed
    final configService = await AiConfigService.getInstance();
    final aiConfig = await configService.loadConfig();

    if (aiConfig == null) {
      throw StateError('AI服务未配置！请在设置中配置AI服务提供商和API密钥。\n'
          'AI service not configured! Please configure AI service provider and API key in settings.');
    }

    debugPrint(
      '[StreamInsightsAnalysisService] Loaded AI config: ${aiConfig.provider}, model: ${aiConfig.llmModel}',
    );

    final aiConfigService = await AiConfigService.getInstance();
    final aiDataSource = ServerlessAiDataSource(aiFactory, aiConfigService);
    _instance = StreamInsightsAnalysisService(aiDataSource);
    return _instance!;
  }

  /// Analyzes a single transaction using the configured data source.
  /// This is the primary API for transaction analysis.
  Future<AnalysisSummary> analyzeTransaction(
    Transaction transaction,
    FluxTimeframe timeframe,
  ) async =>
      _dataSource.analyze(transaction, timeframe);

  /// Legacy method for backwards compatibility with existing code.
  /// @deprecated Use analyzeTransaction instead
  Future<AnalysisSummary> requestAnalysis({
    required List<String> transactionIds,
    required FluxTimeframe timeframe,
    required FluxPane pane,
    required bool flagEnabled,
  }) async {
    // For backwards compatibility, analyze only the first transaction
    // In a real implementation, you might want to analyze all transactions
    if (transactionIds.isEmpty) {
      Logger.warning(
        'StreamInsightsAnalysisService',
        'No transaction IDs provided',
      );
      return AnalysisSummary.empty();
    }

    // Create a mock transaction for legacy API compatibility
    // This is a temporary solution until legacy code is migrated
    final mockTransaction = Transaction(
      id: transactionIds.first,
      amount: 0.0, // Unknown amount
      category: TransactionCategory.otherIncome,
      description: 'Legacy API compatibility',
      date: DateTime.now(),
    );

    return analyzeTransaction(mockTransaction, timeframe);
  }

  /// Switches the analysis data source at runtime.
  /// This provides a consistent API for AI analysis capabilities.
  ///
  /// Note: This method is primarily for testing and configuration purposes.
  /// In production, prefer constructor injection for better testability.
  void switchDataSource(AnalysisDataSource newDataSource) {
    // In a more sophisticated implementation, you might want to use
    // a provider or state management solution to handle this
    Logger.info(
      'StreamInsightsAnalysisService',
      'Switching analysis data source at runtime',
    );

    // This would require making _dataSource non-final, which breaks immutability
    // For now, this is a placeholder for future enhancement
    throw UnimplementedError(
      'Runtime data source switching not yet implemented. Use constructor injection instead.',
    );
  }
}
